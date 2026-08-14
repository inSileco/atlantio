# Parallel launcher for the tinyAtlantis calibration example.
#
# Plays the same role as calibrate_MPI.R in Atlantis_Calibration: it creates
# the cluster and defines the calibrar control settings (generations,
# population size, restart file, ...), then sources run_model.R, which runs
# the calibration with these settings. Launch it with:
#     Rscript launch.R
# Relaunching it after an interruption resumes from the last restart file.
#
# Prerequisites: those of run_model.R, plus doParallel. The cluster comes
# from the base parallel package; calibrar evaluates each generation with
# foreach's `%dopar%`, which needs a registered backend, and doParallel is
# the thin adapter registering a parallel cluster as one. Workers must share
# the master's filesystem (base_dir lives in the master's tempdir()) and be
# able to reach a docker daemon with the `tinyatl` image.

library(parallel)
library(doParallel)


# ---- 1. Cluster -------------------------------------------------------------

n_workers <- as.integer(Sys.getenv(
  "ATLANTIO_NCORES",
  unset = max(parallel::detectCores() - 1, 1)
))

cl <- makeCluster(n_workers)
registerDoParallel(cl)


# ---- 2. calibrar control ----------------------------------------------------
# Picked up by the calibrate() call in run_model.R; same knobs as
# calibrate_MPI.R. Every generation evaluates `popsize` parameter sets,
# spread over the workers by `%dopar%`.

calibrate_parallel <- TRUE
calibrate_control <- list(
  maxit = 10, # maximum number of generations
  # population size: one model run per worker and generation; calibrar bumps
  # it up to its internal minimum (11 for this problem) when set lower
  popsize = n_workers,
  ncores = n_workers,
  REPORT = 1, # generations between restart-file saves
  # must be a relative path: calibrar derives the hidden per-phase partial
  # file by prefixing a "." to it, which breaks absolute paths
  restart.file = "tinyatl_restart",
  trace = 3 # global and partial fitness
  # `master`/`run` (template directory copied into one working directory per
  # population member) are not needed here: atlantis_run_model() builds its
  # own run directory in tempdir() at every evaluation
)


# ---- 3. Worker setup --------------------------------------------------------
# Hook called by run_model.R right before calibrate(), once its helpers
# exist: `%dopar%` ships the objective function to the workers but not the
# global objects it relies on, so export those and load the packages, as
# calibrate_MPI.R does with clusterExport()/clusterEvalQ().

setup_cluster_nodes <- function() {
  clusterExport(cl, c(
    "docker_user",
    "write_tiny_run_script",
    "weighted_mean_nums",
    "atlantis_compute_score"
  ))
  clusterEvalQ(cl, library(atlantio))
  invisible(NULL)
}


# ---- 4. Run the calibration -------------------------------------------------

source(atlantio::atlantis_examples("calibrate", "run_model.R"))

stopCluster(cl)

res_calib$par
res_calib$value

# the state saved every REPORT generations can be inspected with readRDS() on
# the "tinyatl_restart.*" files written in the current directory
