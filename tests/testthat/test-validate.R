test_that("check_boolean() works correctly", {
  # Valid boolean inputs
  expect_identical(check_boolean(0, "test"), 0L)
  expect_identical(check_boolean(1, "test"), 1L)
  expect_identical(check_boolean(5, "test"), 1L)
  expect_identical(check_boolean(-3, "test"), 1L)
  expect_identical(check_boolean(TRUE, "test"), 1L)
  expect_identical(check_boolean(FALSE, "test"), 0L)

  # Invalid inputs
  expect_error(check_boolean(NA, "test"), "test must be a boolean")
  expect_error(check_boolean(numeric(0), "test"), "test must be a boolean")
  expect_error(check_boolean(NULL, "test"), "test must be a boolean")
})

test_that("check_integer() works correctly", {
  # Valid integer inputs
  expect_identical(check_integer(5, "test"), 5L)
  expect_identical(check_integer(0, "test"), 0L)
  expect_identical(check_integer(-10, "test"), -10L)
  expect_identical(check_integer(3.0, "test"), 3L)
  expect_identical(check_integer("42", "test"), 42L)

  # Invalid inputs
  expect_error(check_integer(NA, "test"), "test must be an integer")
  expect_error(check_integer("abc", "test"), "test must be an integer")
  expect_error(check_integer(numeric(0), "test"), "test must be an integer")
  expect_error(check_integer(NULL, "test"), "test must be an integer")
})

test_that("check_float() works correctly", {
  # Valid float inputs
  expect_identical(check_float(5.5, "test"), 5.5)
  expect_identical(check_float(0.0, "test"), 0.0)
  expect_identical(check_float(42, "test"), 42.0)
  expect_identical(check_float("3.14", "test"), 3.14)

  # Invalid inputs
  expect_error(check_float(NA, "test"), "test must be a double")
  expect_error(check_float("abc", "test"), "test must be a double")
  expect_error(check_float(numeric(0), "test"), "test must be a double")
  expect_error(check_float(NULL, "test"), "test must be a double")
})

test_that("check_float_array() works correctly", {
  # Valid array inputs
  expect_identical(
    check_float_array(c(1.1, 2.2, 3.3), "test"),
    c(1.1, 2.2, 3.3)
  )
  expect_identical(check_float_array(5.5, "test"), 5.5)
  expect_identical(check_float_array(c(1, 2, 3), "test"), c(1, 2, 3))

  # Invalid inputs
  expect_error(check_float_array(NA, "test"), "test must be a float array")
})

test_that("check_string() works correctly", {
  # Valid string inputs
  expect_identical(check_string("hello", "test"), "hello")
  expect_identical(check_string("", "test"), "")
  expect_identical(check_string(123, "test"), "123")
  expect_identical(check_string(TRUE, "test"), "TRUE")

  # Invalid inputs
  expect_error(check_string(NA, "test"), "test must be a character string")
  expect_error(
    check_string(character(0), "test"),
    "test must be a character string"
  )
  expect_error(check_string(NULL, "test"), "test must be a character string")
})

test_that("check_lookup() works correctly", {
  # Valid lookup inputs (accepts any non-NA, non-empty value)
  expect_identical(check_lookup("option1"), "option1")

  # Invalid inputs
  expect_error(check_lookup(NA, "test"), "test must be an enum")
})

test_that("valid_values() function routing works", {
  # Test Boolean routing
  expect_identical(valid_values("Boolean", 1, "test"), 1L)
  expect_identical(valid_values("Boolean", 0, "test"), 0L)
  expect_identical(valid_values("Boolean", TRUE, "test"), 1L)

  # Test Integer routing
  expect_identical(valid_values("Integer", 5, "test"), 5L)
  expect_identical(valid_values("Integer", "42", "test"), 42L)

  # Test String routing
  expect_identical(valid_values("String", "hello", "test"), "hello")
  expect_identical(valid_values("String", 123, "test"), "123")

  # Test Float routing
  expect_identical(valid_values("Float", 3.14, "test"), 3.14)
  expect_identical(valid_values("Float", "2.5", "test"), 2.5)
})
