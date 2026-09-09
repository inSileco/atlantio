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
  # Test with example files from the package
  atlantis_obj <- new_atlantis() |>
    atlantis_load_files(bio_file)

  expect_s3_class(atlantis_obj, "atlantio::atlantis")
  expect_true(!is.null(atlantis_obj@biology))
  expect_identical(atlantis_obj@biology |> length(), 1657L)
})

test_that("atlantis_load_files() works with atlantis_file objects", {
  skip_if(bgm_file == "", "Example BGM file not available")

  # Create atlantis_file object
  files <- read_atlantis_files(bio_file)

  atlantis_obj <- new_atlantis() |>
    atlantis_load_files(files)

  expect_s3_class(atlantis_obj, "atlantio::atlantis")
  expect_identical(atlantis_obj@biology |> length(), 1657L)
})

test_that("atlantis_load_files() preserves existing data", {
  skip_if_not_installed("sf")
  # Create object with some initial data
  initial_bio <- list(param1 = "initial_value")
  atlantis_obj <- new_atlantis(biology = initial_bio)

  expect_false(is.null(atlantis_obj@biology))
  expect_true(is.null(atlantis_obj@geometry))

  # Load BGM file (should not affect bio data)
  skip_if(bgm_file == "", "Example BGM file not available")

  updated_obj <- atlantis_load_files(atlantis_obj, bgm_file)

  expect_true(!is.null(updated_obj@biology)) # Should still have bio
  expect_true(!is.null(updated_obj@geometry)) # Should now have bgm
  expect_equal(updated_obj@biology, initial_bio) # Bio data should be unchanged
})

test_that("atlantis_load_files() overwrites existing data of same type", {
  skip_if_not_installed("sf")
  # Create object with initial BGM data
  initial_bgm <- data.frame(x = 1:3, y = 4:6)
  atlantis_obj <- new_atlantis(geometry = initial_bgm)

  expect_equal(atlantis_obj@geometry, initial_bgm)

  # Load new BGM file (should overwrite)
  skip_if(bgm_file == "", "Example BGM file not available")

  updated_obj <- atlantis_load_files(atlantis_obj, bgm_file)

  new_bgm <- updated_obj@geometry
  expect_false(identical(new_bgm, initial_bgm)) # Should be different
  expect_true(nrow(new_bgm) > 3) # Real BGM should have more rows
})


test_that("atlantis_load_files() works with multiple file types", {
  skip_if_not_installed("sf")

  skip_if(bgm_file == "" || bio_file == "", "Example files not available")

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
