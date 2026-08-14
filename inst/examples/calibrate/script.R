# Calibration example: tune the `mum` parameters of tinyAtlantis with calibrar.
#
# Prerequisites:
# - the docker image `tinyatl`, built from ../tinyAtlantis:
#     cd ../tinyAtlantis && docker build -t tinyatl .
# - the packages calibrar and processx (both in Suggests).
#
# The parameters to calibrate are described in mum.yaml; only the biology
# parameter file is re-exported per iteration since every entry targets it.

library(atlantio)


# ---- 1. Atlantis object and calibration table -------------------------------

mod <- new_atlantis() |>
  atlantis_load_files(c(
    atlantis_examples("inputs", "tiny.bgm"),
    atlantis_examples("inputs", "tiny_biol.prm"),
    atlantis_examples("inputs", "tiny_groups.csv")
  ))

df_prm_calib <- mod |>
  generate_calibration_table(atlantis_examples("calibrate", "mum.yaml"))


# ---- 2. Base input directory ------------------------------------------------
# Copy the tiny model inputs once and extend the run to 3 years so the score
# window (last 2 years) excludes the transient first year. tiny_hydro.nc only
# covers 400 days but Atlantis loops hydro files automatically, and the solar
# series has Solar_radiation_rewind 1. The tstop edit is a plain-text
# substitution: read_prm()/write_prm() would drop the `day` unit token.

base_dir <- file.path(tempdir(), "atlantis_base_inputs")
dir.create(base_dir, showWarnings = FALSE)
file.copy(
  list.files(atlantis_examples("inputs"), full.names = TRUE),
  base_dir,
  overwrite = TRUE
)
run_prm_file <- file.path(base_dir, "tiny_run.prm")
readLines(run_prm_file) |>
  sub(pattern = "^tstop\\s.*", replacement = "tstop\t1095 day") |>
  writeLines(run_prm_file)

docker_user <- paste0(
  system("id -u", intern = TRUE), ":", system("id -g", intern = TRUE)
)


# ---- 3. Helpers -------------------------------------------------------------

#' Map a parameter value from the file scale back to the calibration scale
#'
#' Inverse of `atlantio:::transform_parameter_value()`, used to get starting
#' values in the space explored by the optimizer.
#'
#' @param x Numeric vector of parameter values on the file scale.
#' @param fun Name of the transformation used during calibration.
#'
#' @noRd
inverse_transform_parameter_value <- function(x, fun) {
  switch(fun,
    identity = x,
    pow10 = log10(x),
    pow2 = log2(x),
    exp = log(x),
    cli::cli_abort("Unknown transformation function {.val {fun}}.")
  )
}

#' Write the run script for the tiny model
#'
#' Render the run script template shipped with atlantio for the tiny model
#' files and write it as `run.sh` in `run_dir`. Paths are basenames because
#' docker runs with `run_dir` mounted as its working directory.
#'
#' @param run_dir Directory containing the model input files.
#'
#' @noRd
write_tiny_run_script <- function(run_dir) {
  script <- readLines(system.file("run_scripts", "script.sh", package = "atlantio"))
  values <- c(
    "init_file" = "tiny_init.nc",
    "output_main" = "output.nc",
    "run.prm" = "tiny_run.prm",
    "force.prm" = "tiny_force.prm",
    "physics.prm" = "tiny_physics.prm",
    "biol.prm" = "tiny_biol.prm",
    "groups.csv" = "tiny_groups.csv",
    "fisheries.csv" = "tiny_fisheries.csv",
    "output_dir" = "outputFolder"
  )
  for (key in names(values)) {
    script <- gsub(paste0("{{", key, "}}"), values[[key]], script, fixed = TRUE)
  }
  path <- file.path(run_dir, "run.sh")
  writeLines(script, path)
  Sys.chmod(path, "0755")
  invisible(path)
}

#' Temporary objective score
#'
#' Placeholder score: the mean biomass over the last `window_days` days should
#' be close to the initial biomass, i.e. the sum over groups of the squared
#' log-deviations (same spirit as calibrar's `lnorm2`).
#'
#' @param biomass_all Biomass table read from `outputBiomIndx.txt`.
#' @param groups Character vector of group codes to score.
#' @param window_days Length of the scoring window, counted from the end of
#' the run. Default is the last two years.
#' @param tiny Offset keeping zero biomasses finite on the log scale.
#'
#' @noRd
atlantis_compute_score <- function(
  biomass_all,
  groups,
  window_days = 730,
  tiny = 0.01
) {
  init <- unlist(biomass_all[biomass_all$Time == 0, groups])
  tmax <- max(biomass_all$Time)
  tail_rows <- biomass_all[biomass_all$Time > tmax - window_days, groups]
  sum((log(colMeans(tail_rows) + tiny) - log(init + tiny))^2)
}


# ---- 4. Objective function --------------------------------------------------

#' Run an Atlantis model for calibration
#'
#' Run one calibration iteration: apply the parameter transformations, write
#' the input files and run script, run the model in docker and compute the
#' objective score.
#'
#' @param par Numeric vector of parameter values (calibration scale), one per
#' row of `calib_table`.
#' @param atlantis An `Atlantis` object with the biology file loaded.
#' @param calib_table Calibration table from `generate_calibration_table()`.
#' @param base_dir Directory holding the reference input files.
#' @param groups Character vector of group codes entering the score.
#' @param version Atlantis version identifier. Default is `"3-6722"`.
#' @param keep_files Keep the run directory instead of deleting it on exit?
#'
#' @noRd
atlantis_run_model <- function(
  par,
  atlantis,
  calib_table,
  base_dir,
  groups,
  version = "3-6722",
  keep_files = FALSE
) {

  cli::cli_progress_step("Applying transformation")
  bio <- atlantis@biology
  for (i in seq_len(nrow(calib_table))) {
    # element assignment preserves the array_length/comments attributes that
    # write_prm() needs to emit valid arrays
    bio[[calib_table$name[i]]][calib_table$position[i]] <-
      atlantio:::transform_parameter_value(par[i], calib_table$transf[i])
  }

  cli::cli_progress_step("Writing new input files and script")
  run_dir <- tempfile("atlantis_run_")
  dir.create(run_dir)
  if (!keep_files) {
    on.exit(unlink(run_dir, recursive = TRUE), add = TRUE)
  }
  file.copy(list.files(base_dir, full.names = TRUE), run_dir)
  write_prm(bio, file.path(run_dir, "tiny_biol.prm"))
  write_tiny_run_script(run_dir)
  dir.create(file.path(run_dir, "outputFolder"))

  cli::cli_progress_step("Running the model")
  res <- processx::run(
    "docker",
    c(
      "run", "--rm",
      "--user", docker_user,
      "-v", paste0(run_dir, ":/model"),
      "-w", "/model",
      "--entrypoint", "bash",
      "tinyatl", "run.sh"
    ),
    error_on_status = FALSE,
    timeout = 600
  )
  out_file <- file.path(run_dir, "outputFolder", "outputBiomIndx.txt")
  if (res$status != 0 || !file.exists(out_file)) {
    cli::cli_alert_warning(
      "Model run failed (exit status {res$status}), returning penalty score."
    )
    return(1e8)
  }

  cli::cli_progress_step("Computing the objective score and returning it")
  out <- new_atlantis() |>
    atlantis_load_files(out_file) |>
    suppressMessages()
  atlantis_compute_score(out@biomass_all, groups)
}


# ---- 5. Calibration with calibrar -------------------------------------------

# all group codes are biomass columns of outputBiomIndx.txt
groups <- mod@group$Code

# starting values: current biology values mapped back to the calibration scale
# and clamped into the bounds
start <- vapply(
  seq_len(nrow(df_prm_calib)),
  function(i) {
    inverse_transform_parameter_value(
      mod@biology[[df_prm_calib$name[i]]][df_prm_calib$position[i]],
      df_prm_calib$transf[i]
    )
  },
  numeric(1)
)
start <- pmin(pmax(start, df_prm_calib$min), df_prm_calib$max)
names(start) <- paste(df_prm_calib$name, df_prm_calib$position, sep = ".")

# sanity check: one objective evaluation at the starting point
score0 <- atlantis_run_model(start, mod, df_prm_calib, base_dir, groups)
cli::cli_alert_info("Score at starting values: {round(score0, 4)}")

res_calib <- calibrar::calibrate(
  par = start,
  fn = atlantis_run_model,
  lower = df_prm_calib$min,
  upper = df_prm_calib$max,
  phases = NULL,
  method = "AHR-ES",
  control = list(maxit = 10),
  atlantis = mod,
  calib_table = df_prm_calib,
  base_dir = base_dir,
  groups = groups
)
res_calib$par
res_calib$value
