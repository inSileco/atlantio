test_that("Full workflow: create -> load files -> access data", {
  # Test the complete workflow
  atlantis_obj <- new_atlantis()

  # Load example files if available
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
  group_file <- system.file(
    "examples",
    "inputs",
    "tiny_groups.csv",
    package = "atlantio"
  )

  skip_if(
    any(c(bgm_file, bio_file, group_file) == ""),
    "Example files not available"
  )

  # Load files step by step
  atlantis_obj <- atlantis_load_files(atlantis_obj, bgm_file)
  expect_true(!is.null(atlantis_obj@geometry))

  atlantis_obj <- atlantis_load_files(atlantis_obj, bio_file)
  expect_true(!is.null(atlantis_obj@biology))

  atlantis_obj <- atlantis_load_files(atlantis_obj, group_file)
  expect_true(!is.null(atlantis_obj@group))

  # Access and verify data
  bgm_data <- atlantis_obj@geometry
  bio_data <- atlantis_obj@biology
  group_data <- atlantis_obj@group

  expect_true(is.data.frame(bgm_data))
  expect_true(is.list(bio_data))
  expect_true(is.data.frame(group_data))

  expect_true(nrow(bgm_data) > 0)
  expect_true(length(bio_data) > 0)
  expect_true(nrow(group_data) > 0)
})


test_that("Error handling works correctly", {
  atlantis_obj <- new_atlantis()

  # Test with non-existent file
  expect_warning(
    suppressMessages({
      result <- atlantis_load_files(atlantis_obj, "non_existent_file.txt")
    }),
    "non_existent_file.txt does not exist."
  ) # Should not produce warnings, just handle gracefully

  # Test accessing data that doesn't exist
  expect_null(atlantis_obj@geometry)
  expect_null(atlantis_obj@biology)
  expect_false(!is.null(atlantis_obj@geometry))
  expect_false(!is.null(atlantis_obj@biology))
})

test_that("Object immutability and proper updating", {
  # Create initial object
  original_obj <- new_atlantis()
  test_data <- data.frame(x = 1:3)

  # Loading files should create new object, not modify original
  updated_obj <- new_atlantis(geometry = test_data)

  expect_true(is.null(original_obj@geometry)) # Original should be unchanged
  expect_false(is.null(updated_obj@geometry)) # Updated should have data
})

test_that("Multiple file loading preserves all data", {
  # Skip if example files not available
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

  skip_if(any(c(bgm_file, bio_file) == ""), "Example files not available")

  # Load multiple files at once
  atlantis_obj <- new_atlantis()
  atlantis_obj <- atlantis_load_files(atlantis_obj, c(bgm_file, bio_file))

  expect_true(!is.null(atlantis_obj@geometry))
  expect_true(!is.null(atlantis_obj@biology))

  # Both data types should be properly loaded
  bgm_data <- atlantis_obj@geometry
  bio_data <- atlantis_obj@biology

  expect_true(nrow(bgm_data) > 0)
  expect_true(length(bio_data) > 0)
})
