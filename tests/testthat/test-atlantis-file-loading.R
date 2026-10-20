bio_file <- system.file(
  "examples",
  "inputs",
  "tiny_biol.prm",
  package = "atlantio"
)
bgm_file <- system.file(
  "examples",
  "inputs",
  "tiny.bgm",
  package = "atlantio"
)


test_that("atlantis_load_files() works with character paths", {
  atlantis_obj <- new_atlantis() |>
    atlantis_load_files(bio_file)

  expect_s3_class(atlantis_obj, "atlantio::atlantis")
  expect_true(!is.null(atlantis_obj@biology))
  expect_identical(atlantis_obj@biology |> length(), 1657L)
})

test_that("atlantis_load_files() works with atlantis_file objects", {
  files <- read_atlantis_files(bio_file)

  atlantis_obj <- new_atlantis() |>
    atlantis_load_files(files)

  expect_s3_class(atlantis_obj, "atlantio::atlantis")
  expect_identical(atlantis_obj@biology |> length(), 1657L)
})

test_that("atlantis_load_files() preserves existing data", {
  skip_if_not_installed("sf")
  initial_bio <- list(param1 = "initial_value")
  atlantis_obj <- new_atlantis(biology = initial_bio)

  expect_false(is.null(atlantis_obj@biology))
  expect_true(is.null(atlantis_obj@geometry))

  updated_obj <- atlantis_load_files(atlantis_obj, bgm_file)

  expect_true(!is.null(updated_obj@biology))
  expect_true(!is.null(updated_obj@geometry))
  expect_equal(updated_obj@biology, initial_bio)
})

test_that("atlantis_load_files() overwrites existing data of same type", {
  skip_if_not_installed("sf")
  initial_bgm <- data.frame(x = 1:3, y = 4:6)
  atlantis_obj <- new_atlantis(geometry = initial_bgm)

  expect_equal(atlantis_obj@geometry, initial_bgm)

  updated_obj <- atlantis_load_files(atlantis_obj, bgm_file)

  new_bgm <- updated_obj@geometry
  expect_false(identical(new_bgm, initial_bgm))
  expect_true(nrow(new_bgm) > 3)
})


test_that("atlantis_load_files() works with multiple file types", {
  skip_if_not_installed("sf")

  atlantis_obj <- new_atlantis()
  updated_obj <- atlantis_load_files(atlantis_obj, c(bgm_file, bio_file))

  expect_true(!is.null(updated_obj@geometry))
  expect_true(!is.null(updated_obj@biology))
})

test_that("atlantis_load_files() keeps non-duplicated files when a type is duplicated", {
  skip_if_not_installed("sf")
  bgm_file <- atlantis_examples("inputs", "tiny.bgm")
  bio_file <- atlantis_examples("inputs", "tiny_biol.prm")

  atlantis_obj <- suppressMessages(
    new_atlantis() |> atlantis_load_files(c(bgm_file, bgm_file, bio_file))
  )

  expect_false(is.null(atlantis_obj@geometry))
  expect_false(is.null(atlantis_obj@biology))
  expect_identical(
    atlantis_obj@file_paths$path[atlantis_obj@file_paths$name == "biology"],
    bio_file
  )
})

test_that("atlantis_load_files() skips existing files of unsupported type", {
  bib_file <- system.file("references.bib", package = "atlantio")
  xml_file <- atlantis_examples("outputs", "tiny_biol.xml")
  mort_file <- atlantis_examples("outputs", "outputMort.txt")
  atlantis_obj <- new_atlantis()

  expect_warning(
    res <- atlantis_load_files(atlantis_obj, bib_file),
    "unsupported file type \"unknown\""
  )
  expect_identical(res, atlantis_obj)

  expect_warning(
    res <- atlantis_load_files(atlantis_obj, xml_file),
    "unsupported file type \"xml_file\""
  )
  expect_identical(res, atlantis_obj)

  expect_warning(
    res <- suppressMessages(atlantis_load_files(atlantis_obj, mort_file)),
    "unsupported file type \"unknown\""
  )
  expect_identical(res, atlantis_obj)
})

test_that("atlantis_load_files() says why a file cannot be read", {
  withr::local_dir(withr::local_tempdir())
  writeLines(c("arr 3", "1 2"), "bad.prm")
  run <- readLines(atlantis_examples("inputs", "tiny_run.prm"))
  writeLines(run[!startsWith(run, "verbose")], "run.prm")
  expect_snapshot(
    res <- suppressMessages(
      atlantis_load_files(new_atlantis(), c("bad.prm", "run.prm"))
    )
  )
})

test_that("atlantis_load_files() loads diet output", {
  diet_file <- atlantis_examples("outputs", "outputDietCheck.txt")
  atlantis_obj <- suppressMessages(
    new_atlantis() |> atlantis_load_files(diet_file)
  )
  expect_true(is.data.frame(atlantis_obj@diet))
  expect_null(atlantis_obj@biomass_age)
  expect_identical(
    atlantis_obj@file_paths$path[atlantis_obj@file_paths$name == "diet"],
    diet_file
  )
})

test_that("atlantis_load_files() records the path of detailed diet output", {
  fl <- file.path(withr::local_tempdir(), "outputDetailedDietCheck.txt")
  writeLines(
    c(
      "Time Predator Cohort Box Layer Stock Updated WAE YPH",
      "0 WAE 1 0 1 0 0 0.1 0.2"
    ),
    fl
  )
  atlantis_obj <- suppressMessages(new_atlantis() |> atlantis_load_files(fl))
  expect_s3_class(atlantis_obj@diet_detailed, "data.frame")
  expect_identical(
    atlantis_obj@file_paths$path[
      atlantis_obj@file_paths$name == "diet_detailed"
    ],
    fl
  )
})
