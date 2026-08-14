#' Helper function to quickly access example files.
#'
#' @param ... further arguments passed to `[system.file()]`
#'
#' @export
#'
#' @examples
#' atlantis_examples("inputs", "tiny.bgm")

atlantis_examples <- function(...) {
  system.file("examples", ..., package = "atlantio")
}
