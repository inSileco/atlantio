#' Function to validate parameter files
#'
#' @noRd

validate_file <- function(x, template) {
  ref <- system.file(
    file.path("parameters", template),
    package = "atlantio"
  ) |>
    yaml12::read_yaml()

  # Logic will be more complicated with Atlantis version
  nm_x <- names(x)
  nm_ref <- ref |> lapply(\(x) x$Name)

  missing_params <- nm_ref[!is.element(nm_ref, nm_x)]
  unknown_params <- nm_x[!is.element(nm_x, nm_ref)]

  if (length(missing_params)) {
    cli::cli_abort(
      "{length(missing_params)} Parameter{?s} missing: {missing_params}"
    )
  }
  if (length(unknown_params)) {
    cli::cli_warn(
      "{length(unknown_params)} Unknown parameter{?s}: {unknown_params}"
    )
  }

  # TODO : Add logic to check actual values

  x
}


# consider switching to https://github.com/hadley/assertthat
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


# Pretty basic checks

check_boolean <- function(value, name) {
  # everything that is not 0 will be 1
  out <- (value != 0) * 1
  if (!length(out) || is.na(out)) {
    cli::cli_abort("{name} must be a boolean.")
  } else {
    as.integer(out)
  }
}

check_integer <- function(value, name) {
  suppressWarnings(out <- as.integer(value))
  if (!length(out) || is.na(out)) {
    cli::cli_abort("{name} must be an integer.")
  } else {
    out
  }
}

check_float <- function(value, name) {
  suppressWarnings(out <- as.double(value))
  if (!length(out) || is.na(out)) {
    cli::cli_abort("{name} must be a double.")
  } else {
    out
  }
}

check_float_array <- function(value, name) {
  # everything that is not 0 will be 1
  out <- value
  if (!length(out) || any(is.na(out))) {
    cli::cli_abort("{name} must be a float array.")
  } else {
    out
  }
}

check_string <- function(value, name) {
  suppressWarnings(out <- as.character(value))
  if (!length(out) || is.na(out)) {
    cli::cli_abort("{name} must be a character string.")
  } else {
    out
  }
}

check_lookup <- function(value, name) {
  out <- value
  if (!length(out) || is.na(out)) {
    cli::cli_abort("{name} must be an enum.")
  } else {
    out
  }
}
