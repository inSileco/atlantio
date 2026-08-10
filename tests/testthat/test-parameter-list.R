test_that("atlantis_parameter_list() works", {
  expect_error(atlantis_parameter_list("wrong"))
  res <- atlantis_parameter_list()
  expect_identical(length(res), 3L)
  expect_identical(length(res$parameters), 686L)
  expect_identical(length(res$abbreviations), 20L)
})
