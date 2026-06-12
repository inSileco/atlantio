#' Test requirements
#'
#' @noRd
#'
require_main_output <- function(x) {
  if (is.null(x@main_output)) {
    cli::cli_abort("main output required.")
  }
  invisible(TRUE)
}

require_biology_file <- function(x) {
  if (is.null(x@biology)) {
    cli::cli_abort("No bio data available in Atlantis object.")
  }
  invisible(TRUE)
}

require_group_file <- function(x) {
  if (is.null(x@group)) {
    cli::cli_abort("Group info required.")
  }
  invisible(TRUE)
}

require_valid_group <- function(group, x) {
  chk <- group[!all(group %in% x@group$Code[x@group$IsTurnedOn > 0])]
  if (length(chk)) {
    cli::cli_abort(
      "{length(chk)} group{?s} not in group file (or turned off): {chk}"
    )
  }
  invisible(TRUE)
}
