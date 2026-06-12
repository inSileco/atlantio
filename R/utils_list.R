#' Utils for lists
#'
#' @description Utils functions.
#'
#' @noRd

get_field_as_vector <- function(x, field) {
  lapply(x, \(y) y[[field]] %||% NA) |> unlist()
}
