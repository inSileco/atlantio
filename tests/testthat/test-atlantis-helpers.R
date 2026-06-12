test_that("Atlantis class can hold different data types accessible via @", {
  # Test that the class can hold various R data types
  test_df <- data.frame(a = 1:3, b = 4:6)
  test_list <- list(x = "value", y = 123)
  test_matrix <- matrix(1:6, nrow = 2)
  test_vector <- c(1, 2, 3)

  atlantis_obj <- new_atlantis(
    geometry = test_df,
    biology = test_list,
    group = test_matrix,
    main_output = test_vector
  )

  expect_equal(atlantis_obj@geometry, test_df)
  expect_equal(atlantis_obj@biology, test_list)
  expect_equal(atlantis_obj@group, test_matrix)
  expect_equal(atlantis_obj@main_output, test_vector)
})

test_that("Direct property access via @ works correctly", {
  test_data <- data.frame(x = 1:5)
  atlantis_obj <- new_atlantis(geometry = test_data)

  # Direct property access should work
  expect_equal(atlantis_obj@geometry, test_data)
  expect_null(atlantis_obj@biology)

  # Direct property access is now the preferred method
  expect_equal(atlantis_obj@geometry, test_data)
  expect_null(atlantis_obj@biology)
})

test_that("Edge cases: empty data structures", {
  # Test with empty data structures
  empty_df <- data.frame()
  empty_list <- list()

  atlantis_obj <- new_atlantis(
    geometry = empty_df,
    biology = empty_list
  )

  expect_true(!is.null(atlantis_obj@geometry)) # Should still be "present" even if empty
  expect_true(!is.null(atlantis_obj@biology)) # Should still be "present" even if empty

  expect_equal(atlantis_obj@geometry, empty_df)
  expect_equal(atlantis_obj@biology, empty_list)
})

test_that("Large objects can be stored", {
  # Test with larger data structures
  large_df <- data.frame(
    x = 1:1000,
    y = runif(1000),
    z = sample(LETTERS, 1000, replace = TRUE)
  )

  atlantis_obj <- new_atlantis(geometry = large_df)

  expect_true(!is.null(atlantis_obj@geometry))
  retrieved_data <- atlantis_obj@geometry
  expect_equal(nrow(retrieved_data), 1000)
  expect_equal(ncol(retrieved_data), 3)
})
