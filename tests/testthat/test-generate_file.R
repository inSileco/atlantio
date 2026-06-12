test_that("generate_file() creates run parameter file with default settings", {
  temp_file <- tempfile(fileext = ".prm")
  withr::defer(unlink(temp_file))

  result <- generate_file(x = "run", file = temp_file)

  expect_error(generate_file("wrong"))

  expect_identical(result |> as.character(), temp_file)
  expect_true(file.exists(temp_file))

  # Check file content with comments
  content <- readLines(temp_file)
  expect_match(content[1], msg_generated_by())
  expect_match(content[4], "^track_contaminants 0")
  expect_match(content[4], "# Flag to turn on tracking of contaminants")
  expect_match(content[57], "^init_scalar <<TO_EDIT>>")

  # Check file content without comments
  result <- generate_file(x = "run", file = temp_file, description = FALSE)
  content <- readLines(temp_file)
  expect_match(content[1], msg_generated_by())
  expect_match(content[4], "^track_contaminants 0")
  expect_no_match(content[4], "# Flag to turn on tracking of contaminants")
})


test_that("generate_file() creates run parameter file with default + input values", {
  temp_file <- tempfile(fileext = ".prm")
  withr::defer(unlink(temp_file))

  result <- generate_file(x = "run", file = temp_file, track_contaminants = 1)
  content <- readLines(temp_file)
  expect_match(content[1], msg_generated_by())
  expect_match(content[4], "^track_contaminants 1")

  expect_error(generate_file(
    x = "run",
    file = temp_file,
    track_contaminants = NA
  ))

  # ignore if not exact match
  result <- generate_file(x = "run", file = temp_file, track_contamina = 1)
  content <- readLines(temp_file)
  expect_match(content[4], "^track_contaminants 0")
})
