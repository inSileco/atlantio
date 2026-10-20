#' Function to validate parameter files
#'
#' @noRd

validate_file <- function(x, template) {
  ref <- system.file(
    file.path("parameters", template),
    package = "atlantio"
  ) |>
    yaml::read_yaml()

  missing_params <- setdiff(vapply(ref, \(r) r$Name, character(1)), names(x))

  if (length(missing_params)) {
    cli::cli_abort(
      "{length(missing_params)} Parameter{?s} missing: {missing_params}"
    )
  }

  x
}


valid_values <- function(type, value, name) {
  switch(
    type,
    "Boolean" = check_boolean(value, name),
    "Integer" = check_integer(value, name),
    "String" = check_string(value, name),
    "Float" = check_float(value, name),
    "Lookup" = check_lookup(value, name),
    "FloatArray" = check_float_array(value, name),
    cli::cli_abort("Unknown type")
  )
}


check_boolean <- function(value, name) {
  # everything that is not 0 will be 1
  out <- as.integer(value != 0)
  if (!length(out) || is.na(out)) {
    cli::cli_abort("{name} must be a boolean.")
  }
  out
}

check_integer <- function(value, name) {
  suppressWarnings(out <- as.integer(value))
  if (!length(out) || is.na(out)) {
    cli::cli_abort("{name} must be an integer.")
  }
  out
}

check_float <- function(value, name) {
  suppressWarnings(out <- as.double(value))
  if (!length(out) || is.na(out)) {
    cli::cli_abort("{name} must be a double.")
  }
  out
}

check_float_array <- function(value, name) {
  if (!length(value) || anyNA(value)) {
    cli::cli_abort("{name} must be a float array.")
  }
  value
}

check_string <- function(value, name) {
  suppressWarnings(out <- as.character(value))
  if (!length(out) || is.na(out)) {
    cli::cli_abort("{name} must be a character string.")
  }
  out
}

check_lookup <- function(value, name) {
  if (!length(value) || is.na(value)) {
    cli::cli_abort("{name} must be an enum.")
  }
  value
}
