#' List Atlantis parameters for a given Atlantis version
#'
#' @description Returns the list of Atlantis parameters bundled with the
#' package for a given Atlantis version. Supported versions are listed in
#' [atlantis_supported_versions].
#'
#' @param version Atlantis version, formatted as
#' `"<major_version>-<svn_revision>"` (e.g. `"3-6722"`). See
#' [atlantis_supported_versions] for the list of supported versions.
#'
#' @return A list of 2 elements:
#' * `meta`: metadata about the Atlantis code base the parameters were
#'   extracted from (`atlantis_source`, `atlantis_version`, `bm_struct`) and
#'   `files`, the list of parameter files declaring the parameters;
#' * `parameters`: a list where every element describes one parameter with
#'   the following fields: `name`, `description`, `source_file`, `value_type`,
#'   `dimension`, `units`, `bm_member`, `reader` and `conditional_on`.
#'
#' @examples
#' prm_list <- atlantis_parameter_list()
#' prm_list$meta
#' prm_list$parameters[[1]]
#'
#' @export

atlantis_parameter_list <- function(version = "3-6722") {
  if (version %in% atlantio::atlantis_supported_versions$version) {
    path_to_atlantio(
      "parameters",
      paste0("atlantis_parameters_", version, ".yaml")
    ) |>
      yaml::read_yaml()
  } else {
    cli::cli_abort("Unknown version")
  }
}
