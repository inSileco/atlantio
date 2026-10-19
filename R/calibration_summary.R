#' Read the parameter values of calibration runs
#'
#' Collects the `parameters.rds` files that the calibration runs leave in
#' their folders: one list per run with the values tried on the calibration
#' scale (`par`) and on the model scale (`par_model`), the `score`, whether
#' the run `failed` and, for failed runs, the `reason`. The names of `par`
#' are `<name>.<position>`, as in the rows of the calibration table.
#'
#' The generation of a run is read from its folder name when it starts with
#' `gen<number>_` (e.g. `gen003_atlantis_run_...`), `NA` otherwise.
#'
#' @param dir The folder holding one subfolder per run.
#' @param pattern Name of the files to read.
#'
#' @return A data frame with one row per run and parameter value: `run` (the
#'   folder name), `generation`, `score`, `failed`, `reason`, `name`,
#'   `position`, `value` (calibration scale) and `value_model`.
#'
#' @seealso [summarise_calibration()]
#'
#' @export
read_calibration_runs <- function(dir, pattern = "parameters.rds") {
  files <- list.files(
    dir,
    paste0("^", gsub(".", "\\.", pattern, fixed = TRUE), "$"),
    recursive = TRUE,
    full.names = TRUE
  )
  if (!length(files)) {
    cli::cli_abort("No {.file {pattern}} found in {.path {dir}}.")
  }
  out <- lapply(files, \(f) {
    p <- readRDS(f)
    if (is.null(p$par) || is.null(names(p$par))) {
      cli::cli_abort("{.path {f}} has no named {.field par}.")
    }
    run <- basename(dirname(f))
    key <- names(p$par)
    data.frame(
      run = run,
      generation = as.integer(
        stringr::str_match(run, "^gen([0-9]+)_")[, 2]
      ),
      score = p$score %||% NA_real_,
      failed = isTRUE(p$failed),
      reason = p$reason %||% NA_character_,
      name = sub("\\.[0-9]+$", "", key),
      position = as.integer(sub("^.*\\.", "", key)),
      value = unname(p$par),
      value_model = unname(p$par_model %||% NA_real_)
    )
  })
  out <- do.call(rbind, out)
  rownames(out) <- NULL
  out
}


#' Summarise the parameter values of a calibration
#'
#' Summarises, for every parameter value of a calibration table, the values
#' tried by the calibration runs: what the best runs agree on, which
#' parameters are pushed against their bounds, where the runs that failed
#' went, and how the values moved from one generation to the next.
#'
#' The runs are ranked by score among those that completed. The values are
#' reported on the model scale, either as they are (`"value"`) or as a factor
#' of the starting value (`cur_value` of `calib_table`, `"factor"`). By
#' default, a parameter is reported as a factor when its starting value lies
#' within its bounds, and as a value otherwise (e.g. a rate started at a
#' placeholder `1e-12` below its search range). The statistics are computed
#' on the calibration scale and then mapped to the model scale.
#'
#' @param runs The runs: a data frame as returned by
#'   [read_calibration_runs()], or the folder to read them from.
#' @param calib_table The calibration table of the runs, as returned by
#'   [generate_calibration_table()].
#' @param n_best Number of best runs whose range is given.
#' @param n_top Number of best runs whose median, and the number at a bound,
#'   are given.
#' @param relative Report the parameters as factors of their starting value?
#'   `NULL` (default) to decide per parameter as described above, `TRUE` or
#'   `FALSE` for all, or one value per row of `calib_table`.
#' @param bound_tol A value counts as at a bound when it is closer to it than
#'   this fraction of the search range (calibration scale).
#'
#' @return A list of three data frames:
#'   * `parameters`: one row per row of `calib_table` with `name`,
#'     `position`, `start` (starting value), `scale` (`"factor"` or
#'     `"value"`), `best` (best run), `low` and `high` (range of the
#'     `n_best` best runs), `median` (median of the `n_top` best runs),
#'     `at_bound` (number of the `n_top` best runs at a bound) and
#'     `failed_shift` (mean value of the failed runs minus that of the
#'     completed runs, calibration scale; `NA` without failed runs);
#'   * `generations`: per generation and parameter, the `median` of the
#'     `n_best` best completed runs of the generation, on the scale of
#'     `parameters`;
#'   * `scores`: per generation, the number of `runs`, of `failed` runs, and
#'     the `best` and `median` scores of the completed runs.
#'
#' @seealso [read_calibration_runs()], [apply_parameters()] to apply the
#'   values of a run.
#'
#' @examples
#' \dontrun{
#' tbl <- generate_calibration_table(mod, "calibration.yaml")
#' res <- summarise_calibration("calibration_results", tbl)
#' res$parameters
#' }
#'
#' @export
summarise_calibration <- function(runs, calib_table, n_best = 5, n_top = 20,
                                  relative = NULL, bound_tol = 0.01) {
  if (is.character(runs)) {
    runs <- read_calibration_runs(runs)
  }
  needed <- c("name", "cur_value", "min", "max", "position", "transf")
  missing <- setdiff(needed, names(calib_table))
  if (length(missing)) {
    cli::cli_abort("{.arg calib_table} lacks column{?s} {.field {missing}}.")
  }
  key <- paste(calib_table$name, calib_table$position, sep = ".")
  run_key <- paste(runs$name, runs$position, sep = ".")
  unknown <- setdiff(run_key, key)
  if (length(unknown)) {
    cli::cli_abort(
      "{length(unknown)} parameter value{?s} of the runs not in
      {.arg calib_table}: {.field {unknown}}."
    )
  }
  # one row per run, one column per parameter value (calibration scale)
  info <- unique(runs[c("run", "generation", "score", "failed")])
  wide <- tapply(runs$value, list(runs$run, run_key), \(v) v[1])
  wide <- wide[info$run, key, drop = FALSE]
  ok <- !info$failed & !is.na(info$score)
  rank <- order(info$score[ok])
  ranked <- wide[ok, , drop = FALSE][rank, , drop = FALSE]
  if (!nrow(ranked)) {
    cli::cli_abort("No completed run to summarise.")
  }
  best <- ranked[seq_len(min(n_best, nrow(ranked))), , drop = FALSE]
  top <- ranked[seq_len(min(n_top, nrow(ranked))), , drop = FALSE]

  start <- calib_table$cur_value
  if (is.null(relative)) {
    lo <- mapply(transform_parameter_value, calib_table$min, calib_table$transf)
    hi <- mapply(transform_parameter_value, calib_table$max, calib_table$transf)
    relative <- !is.na(start) & start != 0 & start >= lo & start <= hi
  }
  relative <- rep_len(relative, length(key)) & !is.na(start) & start != 0
  # calibration scale to the scale of the report
  report <- function(v, j) {
    v <- transform_parameter_value(v, calib_table$transf[j])
    if (relative[j]) v / start[j] else v
  }
  stat <- function(m, f) {
    vapply(seq_along(key), \(j) report(f(m[, j]), j), numeric(1))
  }
  range <- calib_table$max - calib_table$min
  at_bound <- vapply(seq_along(key), \(j) {
    if (!is.finite(range[j])) {
      return(NA_integer_)
    }
    d <- pmin(abs(top[, j] - calib_table$min[j]), abs(top[, j] - calib_table$max[j]))
    sum(d < bound_tol * range[j])
  }, integer(1))
  failed <- wide[info$failed, , drop = FALSE]
  failed_shift <- if (nrow(failed)) {
    colMeans(failed) - colMeans(wide[ok, , drop = FALSE])
  } else {
    rep(NA_real_, length(key))
  }
  parameters <- data.frame(
    name = calib_table$name,
    position = calib_table$position,
    start = start,
    scale = ifelse(relative, "factor", "value"),
    best = stat(ranked[1, , drop = FALSE], identity),
    low = stat(best, min),
    high = stat(best, max),
    median = stat(top, stats::median),
    at_bound = at_bound,
    failed_shift = unname(failed_shift)
  )

  gens <- sort(unique(info$generation))
  generations <- lapply(gens, \(g) {
    sel <- ok & info$generation %in% g
    m <- wide[sel, , drop = FALSE][order(info$score[sel]), , drop = FALSE]
    m <- m[seq_len(min(n_best, nrow(m))), , drop = FALSE]
    if (!nrow(m)) {
      return(NULL)
    }
    data.frame(
      generation = g,
      name = calib_table$name,
      position = calib_table$position,
      median = stat(m, stats::median)
    )
  })
  generations <- do.call(rbind, generations)
  scores <- lapply(gens, \(g) {
    sel <- info$generation %in% g
    s <- info$score[sel & ok]
    data.frame(
      generation = g,
      runs = sum(sel),
      failed = sum(sel & info$failed),
      best = if (length(s)) min(s) else NA_real_,
      median = if (length(s)) stats::median(s) else NA_real_
    )
  })
  scores <- do.call(rbind, scores)
  list(parameters = parameters, generations = generations, scores = scores)
}
