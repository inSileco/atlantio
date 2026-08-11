test_that("list_atlantis_parameters() works", {
  expect_error(list_atlantis_parameters("wrong"))
  res <- list_atlantis_parameters()
  expect_identical(length(res), 3L)
  expect_identical(length(res$parameters), 686L)
  expect_identical(length(res$abbreviations), 20L)
})
