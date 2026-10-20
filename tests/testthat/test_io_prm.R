test_that("read_prm() aborts when it must", {
  expect_error(
    system.file("mock", "prm", "partial_e1.prm", package = "atlantio") |>
      read_prm(),
    "More than 4000 characters on one line."
  )
  expect_error(
    system.file("mock", "prm", "partial_e2.prm", package = "atlantio") |>
      read_prm(),
    "`missing_value` has no value."
  )
  expect_error(
    system.file("mock", "prm", "partial_e3a.prm", package = "atlantio") |>
      read_prm(),
    "Array (.1, 2, 1, 1, 6, 3, 1, and 4) without key.",
    fixed = TRUE
  )
  expect_error(
    system.file("mock", "prm", "partial_e3b.prm", package = "atlantio") |>
      read_prm(),
    "Array (1, 1, 1, 1, #, this, is, and wrong) includes elements that cannot be coerced to numeric.",
    fixed = TRUE
  )
  expect_error(
    system.file("mock", "prm", "partial_e3c.prm", package = "atlantio") |>
      read_prm(),
    "Dimension mismatch for array `flag`: 5 elements expected, but 4 available.",
    fixed = TRUE
  )
})


test_that("read_prm() warns when it must", {
  expect_warning(
    res <- system.file("mock", "prm", "partial_w1.prm", package = "atlantio") |>
      read_prm(),
    "Final comments are ignored"
  )
  expect_identical(res, list(only_one_ok = 1))
  expect_warning(
    res <- system.file("mock", "prm", "partial_w2.prm", package = "atlantio") |>
      read_prm(),
    "Duplicated key `flag_ok`, using the last occurrence."
  )
  expect_identical(res, list(flag_ok = 0))
})

test_that("read_prm() works", {
  res1 <- system.file("mock", "prm", "partial_ok1.prm", package = "atlantio") |>
    read_prm()
  expect_identical(
    attr(res1$verbose, "comments"),
    c("Partial file used to test read function", "Detailed logged output")
  )
  expect_true(is.null(attr(res1$verbose, "array_length")))
  attr(res1$verbose, "comments") <- NULL
  expect_identical(res1$verbose, 0)

  expect_identical(res1$flag_sanity_check, 1)

  expect_identical(
    attr(res1$init_scalar, "comments"),
    "Multiplicative scalar for vertebrate initial densities. Only values for vertebrates used."
  )
  expect_identical(attr(res1$init_scalar, "array_length"), 6L)
  attr(res1$init_scalar, "comments") <- NULL
  attr(res1$init_scalar, "array_length") <- NULL
  expect_identical(res1$init_scalar, rep(1, 6))

  # full read
  res1 <- system.file(
    "examples",
    "inputs",
    "tiny_biol.prm",
    package = "atlantio"
  ) |>
    read_prm()
  expect_identical(length(res1), 1657L)
  expect_identical(as.numeric(res1$RelTol), 0.1)
})

test_that("read_prm() reads arrays starting with a signed value", {
  fl <- withr::local_tempfile(lines = c("arr 3", "-1 2 3", "brr 2", "+.5 1"))
  res <- read_prm(fl)
  expect_identical(as.vector(res$arr), c(-1, 2, 3))
  expect_identical(attr(res$arr, "array_length"), 3L)
  expect_identical(as.vector(res$brr), c(0.5, 1))
})


test_that("write_prm() warns when it must", {
  fl <- withr::local_file("filew.prm")
  expect_warning(
    system.file("mock", "prm", "partial_ok1.prm", package = "atlantio") |>
      read_prm() |>
      write_prm(fl, sep = " _ "),
    "Separation must be white spaces or tabs so the file could be parsed.",
    fixed = TRUE
  )
})


test_that("write_prm() works", {
  fl <- withr::local_file("file1.prm")
  system.file("mock", "prm", "partial_ok1.prm", package = "atlantio") |>
    read_prm() |>
    write_prm(fl)
  expect_identical(
    read_prm(fl),
    system.file("mock", "prm", "partial_f1.prm", package = "atlantio") |>
      read_prm()
  )

  system.file("mock", "prm", "partial_ok1.prm", package = "atlantio") |>
    read_prm() |>
    write_prm(fl, add_comments = FALSE)
  expect_identical(
    read_prm(fl),
    system.file("mock", "prm", "partial_f2.prm", package = "atlantio") |>
      read_prm()
  )
})

test_that("read_prm() and write_prm() keep time units", {
  run <- read_prm(atlantis_examples("inputs", "tiny_run.prm"))
  expect_identical(attr(run$tstop, "unit"), "day")
  expect_identical(attr(run$dt, "unit"), "hour")
  expect_identical(
    attr(run$tstop, "comments"),
    "1-year run; set 5 day for a quick smoke test"
  )
  fl <- withr::local_tempfile(fileext = ".prm")
  write_prm(run[c("tstop", "dt", "toutinc")], fl, add_comments = FALSE)
  expect_identical(
    readLines(fl),
    c("tstop 365 day", "dt 12 hour", "toutinc 5 day")
  )
  expect_identical(prm_seconds(fl, "tstop"), 365 * 86400)

  writeLines(c("dt 500 ms # half a second", "tstop 2 Days"), fl)
  run <- read_prm(fl)
  expect_identical(attr(run$dt, "unit"), "ms")
  expect_identical(attr(run$dt, "comments"), "half a second")
  expect_identical(attr(run$tstop, "unit"), "Days")
})


test_that("read_prm_files() works", {
  expect_snapshot(
    res <- system.file(
      "mock",
      "prm",
      "partial_ok1.prm",
      package = "atlantio"
    ) |>
      read_prm_files()
  )
  expect_identical(
    res$type,
    "unknown"
  )
  res <- system.file(
    "examples",
    "inputs",
    "tiny_biol.prm",
    package = "atlantio"
  ) |>
    read_prm_files()
  expect_identical(
    res$type,
    "biology"
  )
  res <- suppressWarnings(
    system.file("examples", "inputs", "tiny_run.prm", package = "atlantio") |>
      read_prm_files()
  )
  expect_identical(
    res$type,
    "run"
  )
})
