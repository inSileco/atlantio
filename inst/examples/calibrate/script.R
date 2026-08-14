#' Run an Atlantis model for calibration
#'
#' Run one calibration iteration: validate the calibration list, apply the
#' parameter transformations, write the input files and run script, run the
#' model and compute the objective function.
#'
#' @param par Numeric vector of parameter values to calibrate.
#' @param atlantis An `Atlantis` object.
#' @param version Atlantis version identifier. Default is `"3-6722"`.
#'
#' @noRd
atlantis_run_model <- function(
  par,
  atlantis,
  version = "3-6722"
) {

  library(altantio)
  mod  <- new_atlantis() |>
     atlantis_load_files(c(
       atlantis_examples("inputs", "tiny.bgm"),
       atlantis_examples("inputs", "tiny_biol.prm"),
       atlantis_examples("inputs", "tiny_groups.csv")
     ))
  df_prm_calib <-  mod |>
     generate_calibration_table(atlantis_examples("calibrate", "mum.yaml"))
   )

  cli::cli_progress_step("Applying tranformation")

  cli::cli_progress_step("Writing new input files and script")

  cli::cli_progress_step("Running the model")

  cli::cli_progress_step("Computing the objective score and returning it")
}
