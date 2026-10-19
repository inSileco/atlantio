#' Calibration objective: deviation from the initial state
#'
#' Scores how far a model run drifts from its initial state, in the spirit of
#' Morell et al. (2026, Ecol. Model. 520:111688) and calibrar's `lnorm2`.
#' Every series -- one group x age class x tracer (`Nums`, `StructN`,
#' `ResN`), or the biomass of one living group -- is compared with its
#' initial (t = 0) value on the log scale, as
#' \eqn{log(x + tiny) - log(x_0 + tiny)}.
#'
#' Each series is first reduced to its scored values over the last
#' `window_years` years of the run by [window_values()], with the statistic
#' `summary` gives for its tracer. Scored values within
#' `[1 - tolerance, 1 + tolerance]` times the initial value are not
#' penalized; outside that band only the excess beyond the band edge is
#' squared, which keeps the objective continuous at the edge. The squared
#' excesses are averaged over the scored values of each series.
#' `score_table()` returns that penalty per series, `compute_score()` their
#' sum.
#'
#' The age-structured tracers are aggregated over boxes and layers first
#' (see [aggregate_time_series()]), so `ts` can be the raw table of
#' [create_time_series_biomass()] or its aggregate. Biomass series that
#' start at zero are left out.
#'
#' @param ts Tracer table with columns `group`, `age`, `time` (seconds),
#'   `StructN`, `ResN` and `Nums`, raw (one row per box and layer) or
#'   aggregated.
#' @param biomass Biomass table with columns `group`, `time` (seconds) and
#'   `Biomass`, e.g. from [read_biomass_index()], or `NULL` (default) to
#'   score the age-structured tracers only.
#' @param tolerance Half-width of the no-penalty band: one number for the
#'   three age-structured tracers, or a vector named by tracer (`Nums`,
#'   `StructN`, `ResN` and, to score `biomass`, `Biomass`).
#' @param summary Statistic each series is scored on over the window (see
#'   `stat` in [window_values()]): one for every tracer, or a vector (a list
#'   to pass functions) named by tracer, the tracers left out using
#'   `"snapshot"`.
#' @param window_years Length of the scoring window in years, counted back
#'   from the last output step.
#' @param tiny Offset keeping zero values finite on the log scale.
#' @param exclude Names of the groups left out of the score (their tracers
#'   and their biomass).
#'
#' @return `score_table()`: a data frame with one row per `group` x `age` x
#'   `tracer` and its `penalty` (`age` is `NA` for biomass).
#'   `compute_score()`: the total score, a single number.
#'
#' @references
#' Morell, A., et al. (2026). Ecological Modelling 520:111688.
#'
#' @examples
#' year <- 365 * 86400
#' time <- seq(0, 5 * year, by = 73 * 86400)
#' ts <- data.frame(
#'   group = "Walleye", age = 1, time = time,
#'   StructN = 100, ResN = 300 * exp(time / (5 * year)), Nums = 1e6
#' )
#' score_table(ts)
#' compute_score(ts, tolerance = c(Nums = 0.5, StructN = 0.2, ResN = 0.2))
#'
#' @export
score_table <- function(
  ts,
  biomass = NULL,
  tolerance = 0.2,
  summary = "snapshot",
  window_years = 2,
  tiny = 0.01,
  exclude = character()
) {
  tolerance <- resolve_tolerance(tolerance)
  summary <- resolve_summary(summary, names(tolerance))
  if (
    !is.numeric(window_years) || length(window_years) != 1 || window_years <= 0
  ) {
    cli::cli_abort("{.arg window_years} must be a single positive number.")
  }
  window_s <- window_years * 365 * 86400

  # only the initial step and the window enter the score: aggregate over
  # boxes and layers for those alone (a raw table runs into tens of millions
  # of rows)
  agg <- ts |>
    dplyr::filter(
      .data$time == 0 | .data$time > max(.data$time) - window_s
    ) |>
    aggregate_time_series() |>
    tidyr::pivot_longer(
      c("StructN", "ResN", "Nums"),
      names_to = "tracer",
      values_to = "value"
    ) |>
    dplyr::mutate(age = as.character(.data$age))

  if (!is.null(biomass)) {
    if (!"Biomass" %in% names(tolerance)) {
      cli::cli_abort(
        "{.arg tolerance} must name a {.val Biomass} band to score
         {.arg biomass}."
      )
    }
    agg <- biomass |>
      dplyr::filter(
        .data$Biomass[.data$time == 0] > 0,
        .by = "group"
      ) |>
      dplyr::transmute(
        group = .data$group,
        age = NA_character_,
        time = .data$time,
        tracer = "Biomass",
        value = .data$Biomass
      ) |>
      dplyr::bind_rows(x = agg)
  }
  agg <- dplyr::filter(agg, !.data$group %in% exclude)

  init <- agg |>
    dplyr::filter(.data$time == 0) |>
    dplyr::select("group", "age", "tracer", init = "value")
  scored <- agg |>
    dplyr::reframe(
      value = window_values(
        .data$time,
        .data$value,
        summary[[.data$tracer[1]]],
        window_years
      ),
      .by = c("group", "age", "tracer")
    ) |>
    dplyr::inner_join(init, by = c("group", "age", "tracer"))

  scored |>
    dplyr::mutate(
      tol = tolerance[.data$tracer],
      log_ratio = log(.data$value + tiny) - log(.data$init + tiny),
      excess = pmax(.data$log_ratio - log(1 + .data$tol), 0) +
        pmax(log(1 - .data$tol) - .data$log_ratio, 0)
    ) |>
    dplyr::summarise(
      penalty = mean(.data$excess^2),
      .by = c("group", "age", "tracer")
    )
}

#' @rdname score_table
#' @param ... Arguments passed on to `score_table()`.
#' @export
compute_score <- function(ts, ...) {
  sum(score_table(ts, ...)$penalty)
}


#' Values of a series scored over the last years of a run
#'
#' Reduces one model series (one group x age class x tracer, or the biomass
#' of one group) to the values the objective of [score_table()] compares
#' with the initial value, over a window covering the last `years` years of
#' the run (365-day model years, ending at the last output step). The
#' initial step (t = 0) is never part of the window's statistics.
#'
#' - `"snapshot"`: the output steps closest to the whole-year anniversaries
#'   of t = 0 falling in the window, one value per year. Sampling the
#'   anniversaries keeps the comparison at the phase of the seasonal cycle of
#'   the initial values, but a spiky series (phytoplankton blooms) then
#'   depends on whether an anniversary hits a bloom.
#' - `"mean"`, `"median"`, `"min"`, `"max"`: one value, that statistic over
#'   every output step in the window. The mean averages out blooms and
#'   seasonal cycles; `min`/`max` score the worst trough or peak.
#' - a function: applied to the values in the window, and may return one or
#'   several values (e.g. `\(x) stats::quantile(x, c(0.1, 0.9))`).
#'
#' @param time Output times (seconds).
#' @param value Values of the series at `time`.
#' @param stat Statistic over the window: `"snapshot"`, `"mean"`,
#'   `"median"`, `"min"`, `"max"`, or a function of the window values.
#' @param years Length of the window in years, counted back from the last
#'   output step.
#'
#' @return A numeric vector of the scored values: one per snapshot for
#'   `"snapshot"`, one value for the other statistics.
#'
#' @examples
#' time <- seq(0, 10 * 365 * 86400, by = 30 * 86400)
#' value <- 1 + 0.5 * sin(2 * pi * time / (365 * 86400))
#' window_values(time, value, "snapshot")
#' window_values(time, value, "mean", years = 5)
#' window_values(time, value, \(x) stats::quantile(x, c(.1, .9)))
#'
#' @export
window_values <- function(time, value, stat = "snapshot", years = 2) {
  if (length(time) != length(value)) {
    cli::cli_abort("{.arg time} and {.arg value} must have the same length.")
  }
  if (!is.numeric(years) || length(years) != 1 || years <= 0) {
    cli::cli_abort("{.arg years} must be a single positive number.")
  }
  window_days <- years * 365
  if (is.character(stat) && identical(stat, "snapshot")) {
    snaps <- snapshot_times(time, window_days)
    return(value[match(snaps, time)])
  }
  fn <- if (is.function(stat)) {
    stat
  } else {
    switch(
      stat,
      mean = mean,
      median = stats::median,
      min = min,
      max = max,
      cli::cli_abort(
        "{.arg stat} must be {.val snapshot}, {.val mean}, {.val median},
         {.val min}, {.val max} or a function, not {.val {stat}}."
      )
    )
  }
  in_window <- time > 0 & time > max(time) - window_days * 86400
  if (!any(in_window)) {
    cli::cli_abort("No output step in the scoring window.")
  }
  as.numeric(fn(value[in_window]))
}


#' Aggregate age-structured tracers over boxes and layers
#'
#' Reduces a tracer table with one row per group x age x box x layer x time
#' (the table of [create_time_series_biomass()]) to one row per group x age x
#' time: `Nums` summed, `StructN` and `ResN` as Nums-weighted means, i.e.
#' the condition of the average individual. Empty cells do not count, and a
#' cohort with no individual left gets 0, so a collapse also shows in its
#' condition. A `weight` column is summed and a `units` column kept. A table
#' without `box` or `layer` column is returned as is.
#'
#' @param ts Tracer table with columns `group`, `age`, `time`, `StructN`,
#'   `ResN` and `Nums`, and optionally `box`, `layer`, `weight` and `units`.
#'
#' @return A data frame with one row per `group` x `age` x `time` and the
#'   columns `StructN`, `ResN` and `Nums` (and `weight` and `units` when `ts`
#'   has them).
#'
#' @examples
#' ts <- data.frame(
#'   group = "Walleye", age = 1, time = 0, box = 1:2, layer = 1,
#'   StructN = c(100, 200), ResN = c(300, 600), Nums = c(1, 3)
#' )
#' aggregate_time_series(ts)
#'
#' @export
aggregate_time_series <- function(ts) {
  needed <- c("group", "age", "time", "StructN", "ResN", "Nums")
  missing <- setdiff(needed, names(ts))
  if (length(missing)) {
    cli::cli_abort("{.arg ts} lacks column{?s} {.field {missing}}.")
  }
  if (!any(c("box", "layer") %in% names(ts))) {
    return(ts)
  }
  has_weight <- "weight" %in% names(ts)
  if (!has_weight) {
    ts$weight <- NA_real_
  }
  out <- ts |>
    dplyr::summarise(
      StructN = weighted_mean_nums(.data$StructN, .data$Nums),
      ResN = weighted_mean_nums(.data$ResN, .data$Nums),
      Nums = sum(.data$Nums, na.rm = TRUE),
      weight = sum(.data$weight, na.rm = TRUE),
      .by = c("group", "age", "time")
    )
  if (!has_weight) {
    out$weight <- NULL
  }
  if ("units" %in% names(ts)) {
    out$units <- ts$units[1L]
  }
  out
}


#' Read the biomass of the living groups from the Atlantis biomass index
#'
#' Reads the biomass index Atlantis writes (`<output>BiomIndx.txt`: biomass
#' of every group over the whole model domain, in tonnes, `Time` in days)
#' and keeps the living groups, i.e. every group but the detritus
#' (`GroupType` `LAB_DET`, `REF_DET` and `CARRION`). Groups are named by the
#' `Name` column of the groups file, as in the tables of
#' [create_time_series_biomass()].
#'
#' @param path Path to the biomass index file.
#' @param groups The functional groups: a data frame with columns `Code`,
#'   `Name` and `GroupType` (e.g. the `group` property of an Atlantis object)
#'   or the path to the groups CSV file.
#'
#' @return A data frame with columns `group`, `time` (seconds) and `Biomass`
#'   (tonnes).
#'
#' @export
read_biomass_index <- function(path, groups) {
  if (is.character(groups)) {
    if (!file.exists(groups)) {
      cli::cli_abort("Cannot find the groups file {.path {groups}}.")
    }
    groups <- utils::read.csv(groups)
  }
  missing <- setdiff(c("Code", "Name", "GroupType"), names(groups))
  if (length(missing)) {
    cli::cli_abort("{.arg groups} lacks column{?s} {.field {missing}}.")
  }
  living <- groups[!groups$GroupType %in% c("LAB_DET", "REF_DET", "CARRION"), ]
  bi <- utils::read.table(path, header = TRUE, check.names = FALSE)
  codes <- intersect(living$Code, names(bi))
  bi[, c("Time", codes)] |>
    tidyr::pivot_longer(-"Time", names_to = "code", values_to = "Biomass") |>
    dplyr::transmute(
      group = living$Name[match(.data$code, living$Code)],
      time = .data$Time * 86400,
      Biomass = .data$Biomass
    )
}


# ---- helpers -----------------------------------------------------------------

#' No-penalty band half-width per tracer
#'
#' @param tolerance One number for the three age-structured tracers, or a
#'   vector named by tracer; `Biomass` is optional.
#'
#' @return A vector named `Nums`, `StructN`, `ResN` and, when given,
#'   `Biomass`.
#'
#' @noRd
resolve_tolerance <- function(tolerance) {
  tracers <- c("Nums", "StructN", "ResN")
  if (is.null(names(tolerance))) {
    if (length(tolerance) != 1) {
      cli::cli_abort(
        "{.arg tolerance} must be one number or a vector named by tracer."
      )
    }
    check_tolerance_range(tolerance)
    return(stats::setNames(rep(tolerance, 3), tracers))
  }
  missing <- setdiff(tracers, names(tolerance))
  if (length(missing)) {
    cli::cli_abort("{.arg tolerance} lacks tracer{?s} {.val {missing}}.")
  }
  tolerance <- tolerance[intersect(c(tracers, "Biomass"), names(tolerance))]
  check_tolerance_range(tolerance)
  tolerance
}

# the lower band edge is log(1 - tolerance)
check_tolerance_range <- function(tolerance) {
  if (!is.numeric(tolerance) || any(tolerance < 0 | tolerance >= 1)) {
    cli::cli_abort("{.arg tolerance} must be in [0, 1).")
  }
  invisible(tolerance)
}

#' Summary statistic of every tracer
#'
#' @param summary One statistic for every tracer, or a vector/list named by
#'   tracer; tracers left out use `"snapshot"`.
#' @param tracers Tracers scored (the names of the resolved tolerance).
#'
#' @return A list named by `tracers`.
#'
#' @noRd
resolve_summary <- function(summary, tracers) {
  if (is.null(summary)) {
    summary <- "snapshot"
  }
  if (
    is.function(summary) ||
      (is.null(names(summary)) && length(summary) == 1)
  ) {
    return(stats::setNames(rep(list(summary), length(tracers)), tracers))
  }
  if (is.null(names(summary))) {
    cli::cli_abort(
      "{.arg summary} must be one statistic or a vector named by tracer."
    )
  }
  unknown <- setdiff(names(summary), c("Nums", "StructN", "ResN", "Biomass"))
  if (length(unknown)) {
    cli::cli_abort("{.arg summary} names unknown tracer{?s} {.val {unknown}}.")
  }
  out <- stats::setNames(rep(list("snapshot"), length(tracers)), tracers)
  for (tr in intersect(names(summary), tracers)) {
    out[[tr]] <- summary[[tr]]
  }
  out
}

#' Output steps closest to the whole-year anniversaries in the window
#'
#' @param times Output times (seconds), duplicates allowed.
#' @param window_days Length of the window, counted from the end of the run.
#'
#' @noRd
snapshot_times <- function(times, window_days = 730) {
  times <- sort(unique(times))
  year <- 365 * 86400
  anniversaries <- seq(year, max(times), by = year)
  anniversaries <- anniversaries[
    anniversaries > max(times) - window_days * 86400
  ]
  if (!length(anniversaries)) {
    cli::cli_abort("No whole-year anniversary in the scoring window.")
  }
  vapply(
    anniversaries,
    \(a) times[which.min(abs(times - a))],
    numeric(1)
  ) |>
    unique()
}

#' Nums-weighted mean tolerating empty cells
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
