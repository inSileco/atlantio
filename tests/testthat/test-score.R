year <- 365 * 86400

make_ts <- function(resn_end = 300, nums_end = 1e6) {
  time <- seq(0, 5 * year, by = 73 * 86400)
  data.frame(
    group = "Walleye",
    age = 1,
    time = time,
    StructN = 100,
    ResN = ifelse(time > 3 * year, resn_end, 300),
    Nums = ifelse(time > 3 * year, nums_end, 1e6)
  )
}

test_that("window_values() picks the yearly snapshots or a statistic", {
  time <- seq(0, 5 * year, by = 73 * 86400)
  value <- seq_along(time)
  snaps <- window_values(time, value, "snapshot")
  expect_identical(snaps, value[time %in% (c(4, 5) * year)])
  expect_equal(window_values(time, value, "mean"), mean(value[time > 3 * year]))
  expect_equal(window_values(time, value, max, years = 1), max(value))
  expect_error(window_values(time, value, "mode"), "stat")
  expect_error(window_values(time, value[-1]), "same length")
})

test_that("aggregate_time_series() sums Nums and weights condition", {
  ts <- data.frame(
    group = "Walleye",
    age = 1,
    time = 0,
    box = 0:2,
    layer = 1,
    StructN = c(100, 200, NA),
    ResN = c(300, 600, 1e20),
    Nums = c(1, 3, 0)
  )
  agg <- aggregate_time_series(ts)
  expect_equal(nrow(agg), 1)
  expect_equal(agg$Nums, 4)
  expect_equal(agg$StructN, (100 + 3 * 200) / 4)
  expect_equal(agg$ResN, (300 + 3 * 600) / 4)
  ts$Nums <- 0
  expect_equal(aggregate_time_series(ts)$ResN, 0)
  expect_identical(aggregate_time_series(agg), agg)
  expect_error(aggregate_time_series(ts[, -1]), "group")
})

test_that("score_table() is zero within the band and squared beyond it", {
  expect_equal(compute_score(make_ts(resn_end = 330)), 0)
  out <- score_table(make_ts(resn_end = 600))
  expect_setequal(out$tracer, c("StructN", "ResN", "Nums"))
  expected <- (log(600.01) - log(300.01) - log(1.2))^2
  expect_equal(out$penalty[out$tracer == "ResN"], expected)
  expect_equal(compute_score(make_ts(resn_end = 600)), expected)
  # a wider band on ResN removes the penalty
  tol <- c(Nums = 0.5, StructN = 0.2, ResN = 0.6)
  expect_equal(compute_score(make_ts(resn_end = 450), tolerance = tol), 0)
  # a collapse is penalized below the band
  out <- score_table(make_ts(nums_end = 1e3))
  expected <- (log(1e3 + 0.01) - log(1e6 + 0.01) - log(0.8))^2
  expect_equal(out$penalty[out$tracer == "Nums"], expected)
})

test_that("score_table() scores the biomass and excludes groups", {
  time <- seq(0, 5 * year, by = 73 * 86400)
  bm <- rbind(
    data.frame(
      group = "Diatom",
      time = time,
      Biomass = ifelse(time > 3 * year, 10, 1)
    ),
    data.frame(group = "Empty", time = time, Biomass = 0)
  )
  tol <- c(Nums = 0.5, StructN = 0.2, ResN = 0.2, Biomass = 0.5)
  out <- score_table(make_ts(), bm, tol, summary = c(Biomass = "mean"))
  expect_false("Empty" %in% out$group)
  expected <- (log(10.01) - log(1.01) - log(1.5))^2
  expect_equal(out$penalty[out$group == "Diatom"], expected)
  expect_equal(
    compute_score(make_ts(), bm, tol, exclude = "Diatom"),
    0
  )
  expect_error(score_table(make_ts(), bm), "Biomass")
})

test_that("tolerance and summary are validated", {
  expect_error(score_table(make_ts(), tolerance = c(0.2, 0.5)), "one number")
  expect_error(score_table(make_ts(), tolerance = c(Nums = 0.5)), "lacks")
  expect_error(score_table(make_ts(), tolerance = 1.5), "\\[0, 1\\)")
  expect_error(score_table(make_ts(), summary = c(Foo = "mean")), "unknown")
  expect_error(score_table(make_ts(), window_years = -1), "positive")
})

test_that("read_biomass_index() keeps the living groups", {
  path <- withr::local_tempfile(fileext = ".txt")
  writeLines(c("Time DIA DL FDM", "0 1 5 2", "365 3 6 4"), path)
  groups <- data.frame(
    Code = c("DIA", "DL", "FDM"),
    Name = c("Diatom", "Labile_detritus", "Freshwater_Drum"),
    GroupType = c("SM_PHY", "LAB_DET", "FISH")
  )
  bm <- read_biomass_index(path, groups)
  expect_setequal(bm$group, c("Diatom", "Freshwater_Drum"))
  expect_equal(bm$time[bm$group == "Diatom"], c(0, 365 * 86400))
  expect_equal(bm$Biomass[bm$group == "Freshwater_Drum"], c(2, 4))
  expect_error(read_biomass_index(path, groups[, -3]), "GroupType")
})

test_that("aggregate_time_series() sums weight and keeps units", {
  ts <- data.frame(
    group = "Walleye",
    age = 1,
    time = 0,
    box = 0:1,
    layer = 1,
    StructN = 1,
    ResN = 1,
    Nums = 1,
    weight = c(2, NA),
    units = "g"
  )
  agg <- aggregate_time_series(ts)
  expect_equal(agg$weight, 2)
  expect_identical(agg$units, "g")
})

test_that("score_table() scores the lnorm2 objective of Morell et al.", {
  ts <- make_ts(resn_end = 330)
  # no band: a 10% drift of ResN is penalized on the weight-at-age
  out <- score_table(ts, method = "lnorm2")
  expect_identical(out$tracer, "Weight")
  w0 <- (100 + 300) * 5.7 * 20 / 1e6
  w1 <- (100 + 330) * 5.7 * 20 / 1e6
  # two yearly snapshots in the default 2-year window, summed
  expected <- 2 * (log(w1 + 0.01) - log(w0 + 0.01))^2
  expect_equal(out$penalty, expected)
  # weight multiplies, a named weight selects the tracers
  out <- score_table(ts, method = "lnorm2", weight = c(ResN = 2, Nums = 1))
  expect_setequal(out$tracer, c("ResN", "Nums"))
  expect_equal(
    out$penalty[out$tracer == "ResN"],
    2 * 2 * (log(330.01) - log(300.01))^2
  )
  expect_equal(out$penalty[out$tracer == "Nums"], 0)
})

test_that("lnorm2 scores the biomass against b times its initial value", {
  time <- seq(0, 5 * year, by = 73 * 86400)
  bm <- data.frame(group = "Diatom", time = time, Biomass = 1.3)
  bm$Biomass[1] <- 1
  out <- score_table(
    make_ts(),
    bm,
    method = "lnorm2",
    target_factor = c(Biomass = 1.3)
  )
  expect_setequal(out$tracer, c("Weight", "Biomass"))
  expect_equal(out$penalty, c(0, 0))
  out <- score_table(make_ts(), bm, method = "lnorm2")
  expect_equal(
    out$penalty[out$tracer == "Biomass"],
    2 * (log(1.31) - log(1.01))^2
  )
})

test_that("weight and target_factor are validated", {
  expect_error(
    score_table(make_ts(), method = "lnorm2", weight = c(Foo = 1)),
    "unknown"
  )
  expect_error(
    score_table(make_ts(), method = "lnorm2", weight = c(Biomass = 1)),
    "biomass"
  )
  expect_error(score_table(make_ts(), weight = -1), "non-negative")
  expect_error(score_table(make_ts(), target_factor = c(1, 2)), "one number")
  expect_error(score_table(make_ts(), method = "foo"), "should be one of")
  # the band method applies weight and target_factor too
  expect_equal(
    compute_score(make_ts(resn_end = 600), weight = c(ResN = 3)),
    3 * compute_score(make_ts(resn_end = 600))
  )
  expect_equal(
    compute_score(make_ts(resn_end = 600), target_factor = c(ResN = 2)),
    0
  )
})

test_that("score_table() needs the values at t = 0", {
  time <- seq(73 * 86400, 5 * year, by = 73 * 86400)
  bm <- data.frame(group = "Diatom", time = time, Biomass = 1)
  tol <- c(Nums = 0.5, StructN = 0.2, ResN = 0.2, Biomass = 0.5)
  expect_error(score_table(make_ts(), bm, tol), "no value at t = 0")
  ts <- make_ts()
  expect_error(score_table(ts[ts$time > 0, ]), "no value at t = 0")
})
