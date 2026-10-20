# two parameters: `a` on a log scale started inside its bounds, `b`
# started below them
mock_calib_table <- function() {
  data.frame(
    name = c("a", "b"),
    cur_value = c(100, 1e-12),
    min = c(1, -5),
    max = c(3, -2),
    position = c(1L, 2L),
    transf = "pow10",
    source_file = "biology_prm"
  )
}

# one folder per run, with its parameters.rds
write_mock_runs <- function(dir, runs) {
  for (i in seq_len(nrow(runs))) {
    d <- file.path(dir, runs$run[i])
    dir.create(d, recursive = TRUE)
    par <- c(a.1 = runs$a[i], b.2 = runs$b[i])
    saveRDS(
      list(
        par = par,
        par_model = 10^par,
        score = runs$score[i],
        failed = runs$failed[i],
        reason = if (runs$failed[i]) "crashed"
      ),
      file.path(d, "parameters.rds")
    )
  }
  invisible(dir)
}

mock_runs <- function() {
  data.frame(
    run = c(
      "gen000_r0",
      "gen001_r1",
      "gen001_r2",
      "gen001_r3",
      "gen002_r4",
      "gen002_r5"
    ),
    a = c(2, 2.5, 1, 1.5, 2.2, 3),
    b = c(-3, -4, -2, -5, -3.5, -2),
    score = c(50, 40, 30, 1e8, 10, 20),
    failed = c(FALSE, FALSE, FALSE, TRUE, FALSE, FALSE)
  )
}

test_that("read_calibration_runs() reads every run", {
  dir <- write_mock_runs(withr::local_tempdir(), mock_runs())
  res <- read_calibration_runs(dir)
  expect_named(
    res,
    c(
      "run",
      "generation",
      "score",
      "failed",
      "reason",
      "name",
      "position",
      "value",
      "value_model"
    )
  )
  expect_identical(nrow(res), 12L)
  expect_identical(unique(res$generation), c(0L, 1L, 2L))
  expect_identical(unique(res$reason[res$failed]), "crashed")
  expect_identical(unique(res$name), c("a", "b"))
  expect_equal(res$value_model, 10^res$value)

  saveRDS(list(par = 1), file.path(dir, "gen000_r0", "parameters.rds"))
  expect_error(read_calibration_runs(dir), "no named")
  expect_error(read_calibration_runs(withr::local_tempdir()), "No")
})

test_that("summarise_calibration() summarises the best runs", {
  dir <- write_mock_runs(withr::local_tempdir(), mock_runs())
  res <- summarise_calibration(dir, mock_calib_table(), n_best = 2, n_top = 3)
  expect_named(res, c("parameters", "generations", "scores"))
  p <- res$parameters
  # `a` as a factor of 100, `b` as a value
  expect_identical(p$scale, c("factor", "value"))
  # completed runs by score: r4 (10), r5 (20), r2 (30), r1 (40), r0 (50)
  expect_equal(p$best, c(10^2.2 / 100, 10^-3.5))
  expect_equal(p$low, c(10^2.2 / 100, 10^-3.5))
  expect_equal(p$high, c(10^3 / 100, 10^-2))
  expect_equal(p$median, c(10^2.2 / 100, 10^-2))
  # r5 and r2 are at a bound of `a`, r5 and r2 of `b`
  expect_identical(p$at_bound, c(2L, 2L))
  expect_equal(
    p$failed_shift,
    c(1.5 - mean(c(2, 2.5, 1, 2.2, 3)), -5 - mean(c(-3, -4, -2, -3.5, -2)))
  )

  g <- res$generations
  expect_identical(unique(g$generation), 0:2)
  expect_equal(g$median[g$generation == 1 & g$name == "a"], 10^1.75 / 100)
  expect_identical(res$scores$runs, c(1L, 3L, 2L))
  expect_identical(res$scores$failed, c(0L, 1L, 0L))
  expect_equal(res$scores$best, c(50, 30, 10))

  p <- summarise_calibration(
    dir,
    mock_calib_table(),
    relative = FALSE
  )$parameters
  expect_identical(p$scale, c("value", "value"))
  expect_equal(p$best[1], 10^2.2)

  runs <- read_calibration_runs(dir)
  expect_error(summarise_calibration(runs, mock_calib_table()[1, ]), "not in")
  runs$failed <- TRUE
  expect_error(summarise_calibration(runs, mock_calib_table()), "No completed")
})

test_that("read_calibration_runs() reads par exactly and keeps nested runs apart", {
  dir <- withr::local_tempdir()
  for (round in c("round1", "round2")) {
    d <- file.path(dir, round, "run_1")
    dir.create(d, recursive = TRUE)
    saveRDS(list(par = c(a.1 = 1), score = 1), file.path(d, "parameters.rds"))
  }
  expect_setequal(
    read_calibration_runs(dir)$run,
    c("round1/run_1", "round2/run_1")
  )
  # a missing par is not read from par_model
  saveRDS(
    list(par_model = c(a.1 = 10), score = 1),
    file.path(dir, "round1", "run_1", "parameters.rds")
  )
  expect_error(read_calibration_runs(dir), "no named")
})

test_that("summarise_calibration() keeps the runs without generation", {
  dir <- withr::local_tempdir()
  runs <- mock_runs()
  runs$run <- sub("^gen[0-9]+_", "", runs$run)
  write_mock_runs(dir, runs)
  res <- summarise_calibration(dir, mock_calib_table())
  expect_s3_class(res$generations, "data.frame")
  expect_identical(unique(res$generations$generation), NA_integer_)
  expect_identical(res$scores$runs, nrow(runs))
})
