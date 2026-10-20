test_that("generate_file() creates run parameter file with default settings", {
  temp_file <- tempfile(fileext = ".prm")
  withr::defer(unlink(temp_file))

  result <- generate_file(x = "run", file = temp_file)

  expect_error(generate_file("wrong"))

  expect_identical(as.character(result), as.character(fs::path(temp_file)))
  expect_true(file.exists(temp_file))

  content <- readLines(temp_file)
  expect_match(content[1], msg_generated_by())
  expect_match(content[4], "^track_contaminants 0")
  expect_match(content[4], "# Flag to turn on tracking of contaminants")
  expect_match(
    grep("^init_scalar", content, value = TRUE),
    "^init_scalar <<TO_EDIT>> "
  )
  # a unit Atlantis knows as written
  expect_match(grep("^dt ", content, value = TRUE), "^dt 12 hour ")
  # LF line endings on every platform
  expect_no_match(
    rawToChar(readBin(temp_file, "raw", file.size(temp_file))),
    "\r",
    fixed = TRUE
  )

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
  expect_warning(
    result <- generate_file(x = "run", file = temp_file, track_contamina = 1),
    "track_contamina"
  )
  content <- readLines(temp_file)
  expect_match(content[4], "^track_contaminants 0")
})

test_that("generate_file() writes arrays and warns about unknown values", {
  f <- withr::local_tempfile(fileext = ".prm")
  expect_warning(
    generate_file(file = f, init_scalar = c(1, 2, 3), notakey = 1),
    "notakey"
  )
  content <- readLines(f)
  i <- grep("^init_scalar", content)
  expect_match(content[i], "^init_scalar 3 ")
  expect_identical(content[i + 1], "1 2 3")
  expect_error(generate_file("run"), "file")
})
