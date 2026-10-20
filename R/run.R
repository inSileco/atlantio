#' Write the script that runs Atlantis
#'
#' Renders the run script template shipped with atlantio
#' (`inst/run_scripts/script.sh`, the `atlantisMerged` command line) for the
#' given input files and writes it in the run directory, with the output
#' folder. [run_atlantis()] runs the script with the run directory as its
#' working directory, so relative paths are relative to it; with Docker,
#' paths must also exist inside the container.
#'
#' @param dir Run directory.
#' @param init,run,force,physics,biology,groups,fisheries Input files: the
#'   initial conditions (`-i`), the run (`-r`), forcing (`-f`), physics
#'   (`-p`) and biology (`-b`) parameter files, the functional groups (`-s`)
#'   and the fisheries (`-q`).
#' @param output Name of the main output file (`-o`).
#' @param output_dir Output folder (`-d`), created in `dir` if missing.
#' @param binary The Atlantis executable: `"atlantisMerged"` (found on the
#'   PATH when the script runs) or a path to it.
#' @param file Name of the script.
#'
#' @return The path to the script, invisibly.
#'
#' @seealso [run_atlantis()]
#'
#' @examples
#' dir <- tempfile()
#' dir.create(dir)
#' write_run_script(
#'   dir,
#'   init = "init.nc",
#'   run = "run.prm",
#'   force = "force.prm",
#'   physics = "physics.prm",
#'   biology = "biology.prm",
#'   groups = "groups.csv",
#'   fisheries = "fisheries.csv"
#' )
#' readLines(file.path(dir, "run.sh"))
#'
#' @export
write_run_script <- function(
  dir,
  init,
  run,
  force,
  physics,
  biology,
  groups,
  fisheries,
  output = "output.nc",
  output_dir = "outputFolder",
  binary = "atlantisMerged",
  file = "run.sh"
) {
  if (!dir.exists(dir)) {
    cli::cli_abort("Cannot find the run directory {.path {dir}}.")
  }
  script <- readLines(path_to_atlantio("run_scripts", "script.sh"))
  values <- c(
    init_file = init,
    output_main = output,
    run.prm = run,
    force.prm = force,
    physics.prm = physics,
    biol.prm = biology,
    groups.csv = groups,
    fisheries.csv = fisheries,
    output_dir = output_dir
  )
  for (key in names(values)) {
    script <- gsub(paste0("{{", key, "}}"), values[[key]], script, fixed = TRUE)
  }
  script <- sub("^atlantisMerged", binary, script)
  dir.create(file.path(dir, output_dir), showWarnings = FALSE)
  path <- file.path(dir, file)
  writeLines(script, path)
  Sys.chmod(path, "0755")
  invisible(path)
}


#' Run Atlantis
#'
#' Runs the script written by [write_run_script()] in its run directory,
#' either directly with bash or in a Docker container, and checks with
#' [check_run()] that the run completed. Atlantis ends a fatal error with
#' `quit()`, which exits with status 0: only the time reached by the main
#' output tells a completed run from a crashed one.
#'
#' With Docker, the run directory is mounted as the working directory
#' `/model` of the container and the container runs as the current user, so
#' that the files it writes can be removed by the R session.
#'
#' @param dir Run directory holding the script and the input files.
#' @param script Name of the script.
#' @param docker Name of the Docker image to run the script in, or `NULL`
#'   (the default) to run it directly.
#' @param mounts Other folders mounted read-only in the container: a named
#'   character vector, names the folders and values their path in the
#'   container, e.g. `c("/data/inputs" = "/model/inputs")`.
#' @param timeout Time limit of the run, in seconds; a full run can take
#'   hours.
#'
#' @return A list with the elements of [processx::run()] (`status`,
#'   `stdout`, `stderr` and `timeout`), `check`, the result of [check_run()]
#'   on the main output and the run parameter file named in the script, and
#'   `complete`, `TRUE` if the run exited with status 0 within the time limit
#'   and `check` is empty.
#'
#' @seealso [write_run_script()], [check_run()]
#'
#' @examples
#' \dontrun{
#' res <- run_atlantis("run_1", docker = "atlantis", timeout = 86400)
#' if (!res$complete) print(res$check)
#' }
#'
#' @export
run_atlantis <- function(
  dir,
  script = "run.sh",
  docker = NULL,
  mounts = NULL,
  timeout = Inf
) {
  rlang::check_installed("processx", reason = "to run Atlantis.")
  dir <- normalizePath(dir, mustWork = TRUE)
  path <- file.path(dir, script)
  if (!file.exists(path)) {
    cli::cli_abort("Cannot find the run script {.path {path}}.")
  }
  files <- script_files(path)
  if (is.null(docker)) {
    command <- "bash"
    args <- script
  } else {
    command <- "docker"
    if (length(mounts) && is.null(names(mounts))) {
      cli::cli_abort("{.arg mounts} must be named by the folders to mount.")
    }
    volumes <- c(
      paste0(dir, ":/model"),
      paste0(normalizePath(names(mounts)), ":", mounts, ":ro")
    )
    args <- c(
      "run",
      "--rm",
      if (.Platform$OS.type == "unix") c("--user", current_user()),
      rbind("-v", volumes),
      "-w",
      "/model",
      "--entrypoint",
      "bash",
      docker,
      script
    )
  }
  res <- processx::run(
    command,
    args,
    wd = dir,
    error_on_status = FALSE,
    timeout = timeout
  )
  res$check <- check_run(
    file.path(dir, files[["output_dir"]], files[["output"]]),
    file.path(dir, files[["run"]])
  )
  res$complete <- identical(res$status, 0L) &&
    !isTRUE(res$timeout) &&
    !nrow(res$check)
  res
}


# the main output, output folder and run file named in a run script
script_files <- function(path) {
  tok <- readLines(path) |>
    sub(pattern = "\\\\$", replacement = "") |>
    paste(collapse = " ") |>
    stringr::str_squish() |>
    strsplit(" ", fixed = TRUE) |>
    unlist()
  flag <- function(f) {
    i <- match(f, tok)
    if (is.na(i) || i == length(tok)) {
      cli::cli_abort("The run script {.path {path}} has no {.code {f}} option.")
    }
    tok[i + 1]
  }
  c(output = flag("-o"), output_dir = flag("-d"), run = flag("-r"))
}

current_user <- function() {
  paste0(
    system2("id", "-u", stdout = TRUE),
    ":",
    system2("id", "-g", stdout = TRUE)
  )
}
