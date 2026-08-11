# See https://rconsortium.github.io/S7/articles/packages.html
# nocov start
.onLoad <- function(libname, pkgname) {
  S7::methods_register()
}

# enable usage of <S7_object>@name in package code
#' @rawNamespace if (getRversion() < "4.3.0") importFrom("S7", "@")
NULL

# these packages are only used within S7 method registrations, which R CMD
# check does not scan when looking for namespace usage
ignore_unused_imports <- function() {
  dplyr::bind_rows
  igraph::graph_from_data_frame
  tidyr::pivot_wider
}
# nocov end

# coallescence
`%||%` <- function(x, y) if (is.null(x)) y else x

# not in
`%notin%` <- function(x, table) is.na(match(x, table))

#
to_num <- function(x) {
  suppressWarnings(out <- x |> as.numeric())
  if (is.na(out)) {
    x
  } else {
    out
  }
}


#
path_to_atlantio <- function(...) {
  file.path(
    system.file(..., package = "atlantio", mustWork = TRUE)
  )
}


extract_field <- function(x, field) {
  lapply(x, \(y) y[[field]] %||% NA)
}

find_value <- function(x, field) {
  lapply(x, \(y) y[[field]] %||% NA)
}
