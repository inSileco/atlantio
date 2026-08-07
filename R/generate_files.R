#' Generate parameter files
#'
#' @param x File type to generate. Currently supports "run" for run parameter files.
#' @param version Atlantis version (currently ignored).
#' @param description Logical. Should parameter descriptions be added as comments in the output file?
#' @param file A character string naming the output file. The file extension will
#'   be ignored and replaced with the expected one (.prm for run files).
#' @param ... Additional values to change (currently not implemented).
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
#' # Generate a run parameter file with default settings
#' # generate_file(file = "run.prm")
#'
#' # Generate without descriptions
#' # generate_file(x = "run", file = "my_run.prm", description = FALSE)
#'
#' @export

generate_file <- function(
  x = "run",
  version = "latest",
  description = TRUE,
  file = x,
  ...
) {
  switch(
    x,
    "run" = generate_run_file(version, description, file, ...),
    stop("unkown file type")
  )
}


generate_run_file <- function(version, description, file, ...) {
  args <- list(...)

  tmp <- system.file("parameters", "run.yaml", package = "atlantio") |>
    yaml::read_yaml() |>
    # ensure field 'Category' exists
    lapply(\(x) {
      x$Category <- x$Category %||% "other"
      x
    })
  vc_nm <- tmp |> get_field_as_vector("Name")

  # Update values (if any)
  if (length(args)) {
    # filter
    args <- args[names(args) %in% vc_nm]
    for (i in seq_along(args)) {
      idx <- which(vc_nm == names(args)[i])
      tmp[[idx]]$RecommendedValue <- valid_values(
        tmp[[idx]]$Type,
        args[i],
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
      cat(
        paste(
          prm$Name,
          prm$RecommendedValue %||% "<<TO_EDIT>>>",
          prm$Units,
          ifelse(description, paste("\t#", prm$Description), "")
        ),
        "\n",
        append = TRUE,
        file = file,
        sep = ""
      )
    }
    cat("\n", append = TRUE, file = file)
  }

  invisible(file)
}
