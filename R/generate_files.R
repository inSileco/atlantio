#' Generate parameter files
#'
#' @param x File type to generate. Currently supports "run" for run parameter files.
#' @param version Atlantis version (currently ignored).
#' @param description Logical. Should parameter descriptions be added as comments in the output file?
#' @param file Path of the file written; its extension is set to `.prm`.
#' @param ... Values to set, named after the parameters of the run file (e.g.
#'   `dt = 6`). An array is written as its length, with the values on the
#'   next line. Unknown names are ignored, with a warning.
#'
#' @return Invisibly returns the path to the generated file.
#'
#' @details
#' Generates parameter files using recommended values from the package's internal
#' parameter database. If recommended values are missing, '<<TO_EDIT>>' is added
#' as a placeholder that users should replace with appropriate values. Here are the abbreviations used:
#' - <GRP>: groups abbreviation
#' - <f>: fisheries
#' - <coh>: cohort
#' - <moveGroupCode>: move group code
#' - <tracerName>: tracer name
#'
#' The function reads parameter specifications from the package's internal YAML
#' files and organizes them by category in the output file.
#'
#' @examples
#' # a run parameter file with the recommended values
#' run <- generate_file(file = tempfile(fileext = ".prm"))
#' readLines(run, n = 8)
#'
#' # without descriptions, with a time step of 6 hours
#' generate_file(file = tempfile(fileext = ".prm"), description = FALSE, dt = 6)
#'
#' @export

generate_file <- function(
  x = "run",
  version = "latest",
  description = TRUE,
  file,
  ...
) {
  switch(
    x,
    "run" = generate_run_file(version, description, file, ...),
    cli::cli_abort(
      "Unknown file type {.val {x}}: only {.val run} is supported."
    )
  )
}


generate_run_file <- function(version, description, file, ...) {
  args <- list(...)

  tmp <- system.file("parameters", "run.yaml", package = "atlantio") |>
    yaml::read_yaml() |>
    lapply(\(x) {
      x$Category <- x$Category %||% "other"
      x
    })
  vc_nm <- tmp |>
    extract_field("Name") |>
    unlist()

  unknown <- setdiff(names(args), vc_nm)
  if (length(unknown)) {
    cli::cli_warn("Unknown run parameter{?s} ignored: {.field {unknown}}.")
  }
  if (length(args)) {
    args <- args[names(args) %in% vc_nm]
    for (i in seq_along(args)) {
      idx <- which(vc_nm == names(args)[i])
      tmp[[idx]]$RecommendedValue <- valid_values(
        tmp[[idx]]$Type,
        args[[i]],
        names(args)[i]
      )
    }
  }

  out <- split(tmp, (tmp |> lapply(\(y) y$Category) |> unlist()))

  file <- fs::path_ext_set(file, ".prm")
  cat("# ", msg_generated_by(), "\n\n", file = file, append = FALSE, sep = "")

  categ <- out |> names()
  for (i in seq_along(out)) {
    cat(
      "# ========= ",
      categ[i],
      "\n",
      append = TRUE,
      file = file,
      sep = ""
    )
    for (j in seq_along(out[[i]])) {
      prm <- out[[i]][[j]]
      value <- prm$RecommendedValue %||% "<<TO_EDIT>>"
      # an array: its length, then the values on the next line
      values <- NULL
      if (identical(prm$Type, "FloatArray") && is.numeric(value)) {
        values <- paste0(paste(value, collapse = " "), "\n")
        value <- length(value)
      }
      cat(
        paste(
          prm$Name,
          value,
          prm$Units,
          ifelse(description, paste("\t#", prm$Description), "")
        ),
        "\n",
        values,
        append = TRUE,
        file = file,
        sep = ""
      )
    }
    cat("\n", append = TRUE, file = file)
  }

  invisible(file)
}
