# See https://rconsortium.github.io/S7/articles/packages.html
# nocov start
.onLoad <- function(libname, pkgname) {
  S7::methods_register()
}

# enable usage of <S7_object>@name in package code
#' @rawNamespace if (getRversion() < "4.3.0") importFrom("S7", "@")
#' @importFrom rlang .data
NULL
# nocov end

`%||%` <- function(x, y) if (is.null(x)) y else x

`%notin%` <- function(x, table) is.na(match(x, table))

to_num <- function(x) {
  suppressWarnings(out <- x |> as.numeric())
  if (is.na(out)) {
    x
  } else {
    out
  }
}


path_to_atlantio <- function(...) {
  system.file(..., package = "atlantio", mustWork = TRUE)
}


extract_field <- function(x, field) {
  lapply(x, \(y) y[[field]] %||% NA)
}
