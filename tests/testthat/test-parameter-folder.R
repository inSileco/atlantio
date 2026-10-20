# the tiny run file has keys missing from the run template
load_tiny <- function() {
  new_atlantis() |>
    atlantis_load_files(c(
      atlantis_examples("inputs", "tiny_run.prm"),
      atlantis_examples("inputs", "tiny_biol.prm"),
      atlantis_examples("inputs", "tiny_groups.csv")
    )) |>
    suppressWarnings()
}

test_that("apply_parameters() sets values on both scales", {
  mod <- load_tiny()
  tbl <- generate_calibration_table(
    mod,
    atlantis_examples("calibrate", "mum.yaml")
  )
  res <- apply_parameters(mod, tbl, log10(tbl$cur_value) - 1)
  gzs <- tbl$name == "mum_GZS"
  expect_equal(res@biology$mum_GZS[tbl$position[gzs]], tbl$cur_value[gzs] / 10)
  # attributes kept for write_prm()
  expect_identical(
    attributes(res@biology$mum_GZS),
    attributes(mod@biology$mum_GZS)
  )
  res <- apply_parameters(mod, tbl, seq_len(nrow(tbl)), scale = "model")
  expect_equal(res@biology$mum_GZS[tbl$position[gzs]], which(gzs))

  expect_error(apply_parameters(mod, tbl, 1), "has 1 value")
  bad <- tbl[1, ]
  bad$name <- "mum_NOPE"
  expect_error(apply_parameters(mod, bad, 1), "not found")
  bad <- tbl[1, ]
  bad$position <- 99L
  expect_error(apply_parameters(mod, bad, 1), "out of range")
  bad <- tbl[1, ]
  bad$source_file <- "harvest_prm"
  expect_error(apply_parameters(mod, bad, 1), "No harvest file")
  expect_error(apply_parameters(list(), tbl, tbl$cur_value), "Atlantis")
})

test_that("write_parameter_folder() changes only the values that differ", {
  mod <- load_tiny()
  mod@biology$mum_GZS[2] <- 0.004
  mod@run$tstop[1] <- 730
  dir <- withr::local_tempdir()
  expect_message(
    changes <- write_parameter_folder(mod, dir),
    "3 input files"
  )
  expect_setequal(
    list.files(dir),
    c("tiny_run.prm", "tiny_biol.prm", "tiny_groups.csv")
  )
  expect_identical(changes$key, c("tstop", "mum_GZS"))
  expect_identical(changes$position, c(1L, 2L))
  expect_identical(changes$new, c("730", "0.004"))

  # one line changed in each file, the unit kept
  for (f in c("tiny_run.prm", "tiny_biol.prm")) {
    old <- readLines(atlantis_examples("inputs", f))
    new <- readLines(file.path(dir, f))
    expect_length(new, length(old))
    expect_identical(sum(old != new), 1L)
  }
  run <- readLines(file.path(dir, "tiny_run.prm"))
  expect_match(run[startsWith(run, "tstop")], "^tstop\t730 day +# 1-year run")
  expect_identical(
    nrow(compare_prm(mod@biology, file.path(dir, "tiny_biol.prm"))),
    0L
  )

  expect_error(write_parameter_folder(mod, dir), "not empty")
  expect_identical(
    nrow(write_parameter_folder(load_tiny(), dir, overwrite = TRUE)),
    0L
  ) |>
    expect_message()

  # the files not loaded come from `from`
  from <- withr::local_tempdir()
  writeLines("a 1", file.path(from, "physics.prm"))
  dir.create(file.path(from, "inputs"))
  writeLines("1 2", file.path(from, "inputs", "force.ts"))
  writeLines("stale", file.path(from, "tiny_biol.prm"))
  out <- file.path(withr::local_tempdir(), "v2")
  suppressMessages(write_parameter_folder(mod, out, from = from))
  expect_true(file.exists(file.path(out, "physics.prm")))
  expect_true(file.exists(file.path(out, "inputs", "force.ts")))
  expect_identical(
    nrow(compare_prm(mod@biology, file.path(out, "tiny_biol.prm"))),
    0L
  )
  expect_error(
    write_parameter_folder(mod, out, from = "nope", overwrite = TRUE),
    "Cannot find"
  )
})

test_that("patch_prm() keeps the layout and line endings", {
  src <- withr::local_tempfile(fileext = ".prm")
  out <- withr::local_tempfile(fileext = ".prm")
  writeBin(
    charToRaw("# rate\r\nKDEP\t2 # per day\r\n\r\n1.0   2.0\r\nflag 1\r\n"),
    src
  )
  prm <- read_prm(src)
  prm$KDEP[2] <- 3
  changes <- patch_prm(src, prm, out)
  expect_identical(changes$old, "2.0")
  expect_identical(
    rawToChar(readBin(out, "raw", 100)),
    "# rate\r\nKDEP\t2 # per day\r\n\r\n1.0   3\r\nflag 1\r\n"
  )
  prm$nope <- 1
  expect_error(patch_prm(src, prm, out), "not found")

  # Atlantis may read either occurrence of a duplicated key
  writeLines(c("flag 1", "rate 2", "flag 1"), src)
  prm <- suppressWarnings(read_prm(src))
  prm$rate[1] <- 3
  expect_identical(patch_prm(src, prm, out)$key, "rate")
  prm$flag[1] <- 0
  expect_error(patch_prm(src, prm, out), "given 2 times")
})

test_that("compare_prm() compares by parameter name", {
  bio <- read_prm(atlantis_examples("inputs", "tiny_biol.prm"))
  expect_identical(
    nrow(compare_prm(bio, atlantis_examples("inputs", "tiny_biol.prm"))),
    0L
  )
  new <- bio[rev(names(bio))]
  new$mum_GZS[2] <- 0.004
  new$flagnew <- 1
  new$KDEP_DRE <- NULL
  res <- compare_prm(bio, new)
  # in the order of x, then the keys only in y
  expect_identical(res$key, c("mum_GZS", "KDEP_DRE", "flagnew"))
  expect_identical(res$position, c(2L, NA, NA))
  expect_identical(res$y, c("0.004", NA, "1"))
  expect_identical(is.na(res$x), c(FALSE, FALSE, TRUE))

  a <- list(v = structure(c(1, 2), array_length = 2))
  b <- list(v = structure(c(1, 2, 3), array_length = 3))
  res <- compare_prm(a, b)
  expect_identical(res$position, 3L)
  expect_identical(res$x, NA_character_)
})
