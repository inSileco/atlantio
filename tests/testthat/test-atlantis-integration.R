test_that("Full workflow: create -> load files -> access data", {
  atlantis_obj <- new_atlantis()

  bgm_file <- atlantis_examples(
    "inputs",
    "tiny.bgm"
  )
  bio_file <- atlantis_examples(
    "inputs",
    "tiny_biol.prm"
  )
  group_file <- atlantis_examples(
    "inputs",
    "tiny_groups.csv"
  )

  skip_if_not_installed("sf")

  atlantis_obj <- atlantis_load_files(atlantis_obj, bgm_file)
  expect_true(!is.null(atlantis_obj@geometry))

  atlantis_obj <- atlantis_load_files(atlantis_obj, bio_file)
  expect_true(!is.null(atlantis_obj@biology))

  atlantis_obj <- atlantis_load_files(atlantis_obj, group_file)
  expect_true(!is.null(atlantis_obj@group))

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
  skip_if_not_installed("sf")
  atlantis_obj <- new_atlantis()

  expect_warning(
    suppressMessages({
      result <- atlantis_load_files(atlantis_obj, "non_existent_file.txt")
    }),
    "non_existent_file.txt does not exist."
  )

  expect_null(atlantis_obj@geometry)
  expect_null(atlantis_obj@biology)
})

test_that("Object immutability and proper updating", {
  original_obj <- new_atlantis()
  test_data <- data.frame(x = 1:3)

  updated_obj <- new_atlantis(geometry = test_data)

  expect_true(is.null(original_obj@geometry))
  expect_false(is.null(updated_obj@geometry))
})

test_that("Multiple file loading preserves all data", {
  bgm_file <- atlantis_examples(
    "inputs",
    "tiny.bgm"
  )
  bio_file <- atlantis_examples(
    "inputs",
    "tiny_biol.prm"
  )

  skip_if_not_installed("sf")

  atlantis_obj <- new_atlantis() |>
    atlantis_load_files(c(bgm_file, bio_file))

  expect_true(!is.null(atlantis_obj@geometry))
  expect_true(!is.null(atlantis_obj@biology))
  expect_identical(nrow(atlantis_obj@geometry), 11L)
  expect_identical(length(atlantis_obj@biology), 1657L)
})
