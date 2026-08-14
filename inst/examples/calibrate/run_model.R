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
# Copy the tiny model inputs once and extend the run to 4 years so the score
# window (last 2 years) excludes the transient first years. tiny_hydro.nc only
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
  sub(pattern = "^tstop\\s.*", replacement = "tstop\t1460 day") |>
  writeLines(run_prm_file)

# every evaluation leaves its time series and parameter values in one folder
# per run under `results_dir`, which -- unlike tempdir() -- persists after the
# session; override the default location with ATLANTIO_RESULTS_DIR
results_dir <- Sys.getenv("ATLANTIO_RESULTS_DIR", "calibration_results")
dir.create(results_dir, showWarnings = FALSE, recursive = TRUE)
# absolute path, so workers resolve it regardless of their working directory
results_dir <- normalizePath(results_dir)

docker_user <- paste0(
  system("id -u", intern = TRUE), ":", system("id -g", intern = TRUE)
)


# ---- 3. Helpers -------------------------------------------------------------



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

#' Nums-weighted mean tolerating empty cells
#'
#' Average an individual-level tracer (StructN or ResN) across boxes/layers,
#' weighting by the number of individuals so empty cells (fill values) do not
#' contribute. Returns 0 when the cohort has no individual left, so the
#' condition series also registers a collapse on the log scale.
#'
#' @noRd
weighted_mean_nums <- function(x, nums) {
  w <- ifelse(is.na(nums), 0, nums)
  x <- ifelse(is.na(x), 0, x)
  if (sum(w) == 0) {
    return(0)
  }
  sum(x * w) / sum(w)
}

#' Objective score on StructN, ResN and Nums
#'
#' Score in the spirit of Morell et al. (2026, Ecol. Model. 520:111688) and
#' calibrar's `lnorm2`, but computed on the age-structured tracers instead of
#' biomass. For every group x age class, per-time-step values are aggregated
#' over boxes and layers (Nums summed; StructN and ResN as Nums-weighted
#' means, i.e. the average individual condition) and compared to their initial
#' (t = 0) values on the log scale, as in `lnorm2`:
#' `r(t) = log(x(t) + tiny) - log(x(0) + tiny)`.
#'
#' As in Morell et al., who duplicate their year-2011 targets and compare them
#' to annual model outputs from years 14 and 15, only annual snapshots are
#' scored: the output steps closest to the whole-year anniversaries of t = 0
#' falling in the scoring window (the last `window_days` days). Sampling the
#' anniversaries keeps the comparison at the same phase of the seasonal cycle
#' as the reference values, so seasonal oscillations are not mistaken for
#' drift.
#'
#' Snapshot values that stay within `[1 - tolerance, 1 + tolerance]` times the
#' initial value are not penalized -- the counterpart of the trend threshold
#' theta in the stability penalty of Morell et al. Outside the band, only the
#' excess beyond the band edge is squared, which keeps the objective
#' continuous at the edge. The squared excesses are averaged over the
#' snapshots of each series and summed over group x age x tracer.
#'
#' @param ts Tidy tracer table from `create_time_series_biomass()`, with one
#' row per group x age x box x layer x time and columns `StructN`, `ResN` and
#' `Nums`.
#' @param window_days Length of the scoring window, counted from the end of
#' the run. Default is the last two years, i.e. two annual snapshots.
#' @param tolerance Half-width of the no-penalty band around initial values.
#' Default is 20%.
#' @param tiny Offset keeping zero values finite on the log scale.
#'
#' @noRd
atlantis_compute_score <- function(
  ts,
  window_days = 730,
  tolerance = 0.2,
  tiny = 0.01
) {
  # per-time-step aggregation over boxes and layers
  agg <- ts |>
    dplyr::summarise(
      StructN = weighted_mean_nums(StructN, Nums),
      ResN = weighted_mean_nums(ResN, Nums),
      Nums = sum(Nums, na.rm = TRUE),
      .by = c(group, age, time)
    ) |>
    tidyr::pivot_longer(
      c(StructN, ResN, Nums),
      names_to = "tracer",
      values_to = "value"
    )

  # nearest output step to each whole-year anniversary of t = 0 in the window
  times <- sort(unique(agg$time))
  year <- 365 * 86400
  anniversaries <- seq(year, max(times), by = year)
  anniversaries <- anniversaries[
    anniversaries > max(times) - window_days * 86400
  ]
  if (!length(anniversaries)) {
    cli::cli_abort("No whole-year anniversary in the scoring window.")
  }
  snapshot_times <- vapply(
    anniversaries,
    \(a) times[which.min(abs(times - a))],
    numeric(1)
  ) |>
    unique()

  init <- agg |>
    dplyr::filter(time == 0) |>
    dplyr::select(group, age, tracer, init = value)
  snapshots <- agg |>
    dplyr::filter(time %in% snapshot_times) |>
    dplyr::inner_join(init, by = c("group", "age", "tracer"))

  score <- snapshots |>
    dplyr::mutate(
      log_ratio = log(value + tiny) - log(init + tiny),
      excess = pmax(log_ratio - log(1 + tolerance), 0) +
        pmax(log(1 - tolerance) - log_ratio, 0)
    ) |>
    dplyr::summarise(
      penalty = mean(excess^2),
      .by = c(group, age, tracer)
    )
  sum(score$penalty)
}


# ---- 4. Objective function --------------------------------------------------

#' Run an Atlantis model for calibration
#'
#' Run one calibration iteration: apply the parameter transformations, write
#' the input files and run script, run the model in docker and compute the
#' objective score. Each run leaves a folder under `results_dir` holding the
#' tracer time series the score is derived from (`time_series.rds`) and the
#' parameter values with the score (`parameters.rds`, calibration scale, map
#' to model values with `transform_parameter_value()`); every other run file
#' is removed, unless `keep_files = TRUE`.
#'
#' @param par Numeric vector of parameter values (calibration scale), one per
#' row of `calib_table`.
#' @param atlantis An `Atlantis` object with the biology file loaded.
#' @param calib_table Calibration table from `generate_calibration_table()`.
#' @param base_dir Directory holding the reference input files.
#' @param results_dir Persistent directory collecting one result folder per
#' run.
#' @param groups Character vector of age-structured group codes entering the
#' score (their StructN/ResN/Nums tracers are read from `output.nc`).
#' @param version Atlantis version identifier. Default is `"3-6722"`.
#' @param keep_files Keep all run files? By default only `time_series.rds`
#' and `parameters.rds` are left in the run directory.
#'
#' @noRd
atlantis_run_model <- function(
  par,
  atlantis,
  calib_table,
  base_dir,
  results_dir,
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
      transform_parameter_value(par[i], calib_table$transf[i])
  }

  cli::cli_progress_step("Writing new input files and script")
  # claim a unique run directory: dir.create() is atomic and fails when the
  # path already exists, so no two evaluations -- even on different nodes
  # sharing the filesystem -- can end up writing to the same folder
  for (i in 1:5) {
    run_dir <- tempfile(
      sprintf("atlantis_run_%d_", Sys.getpid()),
      tmpdir = results_dir
    )
    created <- dir.create(run_dir, showWarnings = FALSE)
    if (created) {
      break
    }
  }
  if (!created) {
    cli::cli_abort("Could not create a unique run directory in {results_dir}.")
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
  out_file <- file.path(run_dir, "outputFolder", "output.nc")
  if (res$status != 0 || !file.exists(out_file)) {
    # keep the parameter values of failed runs too: they map the parameter
    # regions where the model crashes
    saveRDS(
      list(par = par, score = 1e8, failed = TRUE),
      file.path(run_dir, "parameters.rds")
    )
    if (!keep_files) {
      unlink(
        setdiff(
          list.files(run_dir, full.names = TRUE),
          file.path(run_dir, "parameters.rds")
        ),
        recursive = TRUE
      )
    }
    cli::cli_alert_warning(
      "Model run failed (exit status {res$status}), returning penalty score."
    )
    return(1e8)
  }

  cli::cli_progress_step("Computing the objective score and returning it")
  # load output.nc into a copy of `atlantis` so create_time_series_biomass()
  # finds the biology (X_CN, k_wetdry) and group tables it needs
  out <- atlantis |>
    atlantis_load_files(out_file) |>
    suppressMessages()
  on.exit(ncdf4::nc_close(out@main_output), add = TRUE)
  ts <- suppressMessages(create_time_series_biomass(out, groups))
  score <- atlantis_compute_score(ts)

  cli::cli_progress_step("Saving the results and cleaning the run directory")
  saveRDS(ts, file.path(run_dir, "time_series.rds"))
  saveRDS(
    list(par = par, score = score, failed = FALSE),
    file.path(run_dir, "parameters.rds")
  )
  if (!keep_files) {
    unlink(
      setdiff(
        list.files(run_dir, full.names = TRUE),
        file.path(run_dir, c("time_series.rds", "parameters.rds"))
      ),
      recursive = TRUE
    )
  }
  score
}


# ---- 5. Calibration with calibrar -------------------------------------------

# only age-structured groups carry the StructN/ResN/Nums tracers scored here;
# in the tiny model these are also exactly the groups calibrated in mum.yaml
groups <- mod@group$Code[mod@group$NumCohorts > 1]

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
score0 <- atlantis_run_model(
  start, mod, df_prm_calib, base_dir, results_dir, groups
)
cli::cli_alert_info("Score at starting values: {round(score0, 4)}")

# a launcher (see launch.R) can drive the calibration on a cluster by
# defining these settings before sourcing this file; standalone, the
# defaults below give a serial run
if (!exists("calibrate_control")) {
  calibrate_control <- list(maxit = 10)
}
if (!exists("calibrate_parallel")) {
  calibrate_parallel <- FALSE
}
# ship the helpers defined above to the launcher's workers, if any
if (exists("setup_cluster_nodes")) {
  setup_cluster_nodes()
}

res_calib <- calibrar::calibrate(
  par = start,
  fn = atlantis_run_model,
  lower = df_prm_calib$min,
  upper = df_prm_calib$max,
  phases = NULL,
  method = "AHR-ES",
  control = calibrate_control,
  parallel = calibrate_parallel,
  atlantis = mod,
  calib_table = df_prm_calib,
  base_dir = base_dir,
  results_dir = results_dir,
  groups = groups
)
res_calib$par
res_calib$value
