#' Input files
#'
#' @docType data
#' @keywords datasets
#' @name input_files
#' @usage input_files
#' @format
#' A data frame, each row includes details about input files, currently it
#' includes four columns:
#' * name: file name,
#' * description: short description,
#' * type: either 'input' (model input) or 'output' (model output),
#' * file_extension: file extension.

"input_files"

#' Atlantis versions supported by atlantio
#'
#' @docType data
#' @keywords datasets
#' @name atlantis_supported_versions
#' @usage atlantis_supported_versions
#' @format
#' A data frame, each row includes details about one supported Atlantis
#' version, currently it includes two columns:
#' * version: Atlantis version, formatted as
#'   `"<major_version>-<svn_revision>"` (e.g. `"3-6722"`),
#' * release_date: release date of the version.
#'
#' @source Generated from `inst/raw-data/supported_version.R`.
#'
#' @seealso [list_atlantis_parameters()]

"atlantis_supported_versions"

#' Parameter Hints for Atlantis Model Configuration
#'
#' A list containing parameter names that are used as hints to quickly identify
#' the file type.
#'
#' @format A named list with 2 elements:
#' \describe{
#'   \item{run}{Character vector of run configuration parameter names:
#'     \itemize{
#'       \item \code{title} - Model run title/description
#'       \item \code{dt} - Time step size (days)
#'       \item \code{tstop} - End time of simulation (days)
#'       \item \code{toutstart} - Start time for output (days)
#'       \item \code{toutinc} - Output time increment (days)
#'       \item \code{toutfinc} - Final output time increment (days)
#'     }
#'   }
#'   \item{bio}{Character vector of biology parameter names:
#'     \itemize{
#'       \item \code{RelTol} - Relative tolerance for numerical integration
#'       \item \code{Flux_tol} - Flux tolerance threshold
#'       \item \code{min_pool} - Minimum pool size
#'       \item \code{min_dens} - Minimum density threshold
#'     }
#'   }
#' }
#'
#'
#' @source Generated from \code{inst/parameters/create_hints.R}
#'
#' @examples
#' data(parameters_hints)
#'
#' # View hints for run files
#' parameters_hints$run
#'
#' # View hints for biology files
#' parameters_hints$bio
#'
"parameters_hints"
