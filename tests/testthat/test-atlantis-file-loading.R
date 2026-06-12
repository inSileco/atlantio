test_that("atlantis_load_files() works with character paths", {
  # Test with example files from the package
  bgm_file <- system.file(
    "examples",
    "inputs",
    "tiny.bgm",
    package = "atlantio"
  )
  skip_if(bgm_file == "", "Example BGM file not available")

  atlantis_obj <- new_atlantis()
  updated_obj <- atlantis_load_files(atlantis_obj, bgm_file)

  expect_s3_class(updated_obj, "atlantio::atlantis")
  expect_true(!is.null(updated_obj@geometry))

  bgm_data <- updated_obj@geometry
  expect_true(is.data.frame(bgm_data))
  expect_true(nrow(bgm_data) > 0)
})

test_that("atlantis_load_files() works with atlantis_file objects", {
  bgm_file <- system.file(
    "examples",
    "inputs",
    "tiny.bgm",
    package = "atlantio"
  )
  skip_if(bgm_file == "", "Example BGM file not available")

  # Create atlantis_file object
  files <- read_atlantis_files(bgm_file)

  atlantis_obj <- new_atlantis()
  updated_obj <- atlantis_load_files(atlantis_obj, files)

  expect_s3_class(updated_obj, "atlantio::atlantis")
  expect_true(!is.null(updated_obj@geometry))
})

test_that("atlantis_load_files() preserves existing data", {
  # Create object with some initial data
  initial_bio <- list(param1 = "initial_value")
  atlantis_obj <- new_atlantis(biology = initial_bio)

  expect_false(is.null(atlantis_obj@biology))
  expect_true(is.null(atlantis_obj@geometry))

  # Load BGM file (should not affect bio data)
  bgm_file <- system.file(
    "examples",
    "inputs",
    "tiny.bgm",
    package = "atlantio"
  )
  skip_if(bgm_file == "", "Example BGM file not available")

  updated_obj <- atlantis_load_files(atlantis_obj, bgm_file)

  expect_true(!is.null(updated_obj@biology)) # Should still have bio
  expect_true(!is.null(updated_obj@geometry)) # Should now have bgm
  expect_equal(updated_obj@biology, initial_bio) # Bio data should be unchanged
})

test_that("atlantis_load_files() overwrites existing data of same type", {
  # Create object with initial BGM data
  initial_bgm <- data.frame(x = 1:3, y = 4:6)
  atlantis_obj <- new_atlantis(geometry = initial_bgm)

  expect_equal(atlantis_obj@geometry, initial_bgm)

  # Load new BGM file (should overwrite)
  bgm_file <- system.file(
    "examples",
    "inputs",
    "tiny.bgm",
    package = "atlantio"
  )
  skip_if(bgm_file == "", "Example BGM file not available")

  updated_obj <- atlantis_load_files(atlantis_obj, bgm_file)

  new_bgm <- updated_obj@geometry
  expect_false(identical(new_bgm, initial_bgm)) # Should be different
  expect_true(nrow(new_bgm) > 3) # Real BGM should have more rows
})


test_that("atlantis_load_files() works with multiple file types", {
  # Test loading multiple files at once
  bgm_file <- system.file(
    "examples",
    "inputs",
    "tiny.bgm",
    package = "atlantio"
  )
  bio_file <- system.file(
    "examples",
    "inputs",
    "tiny_biol.prm",
    package = "atlantio"
  )

  skip_if(bgm_file == "" || bio_file == "", "Example files not available")

  atlantis_obj <- new_atlantis()
  updated_obj <- atlantis_load_files(atlantis_obj, c(bgm_file, bio_file))

  expect_true(!is.null(updated_obj@geometry))
  expect_true(!is.null(updated_obj@biology))
})
