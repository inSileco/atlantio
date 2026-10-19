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
    group = "Walleye", age = 1, time = 0, box = 0:1, layer = 1,
    StructN = 1, ResN = 1, Nums = 1, weight = c(2, NA), units = "g"
  )
  agg <- aggregate_time_series(ts)
  expect_equal(agg$weight, 2)
  expect_identical(agg$units, "g")
})
