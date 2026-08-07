test_that("atlantis_parameter_list() works", {
  expect_error(atlantis_parameter_list("wrong"))
  res <- atlantis_parameter_list()
  expect_identical(length(res), 2L)
  expect_identical(length(res$parameters), 686L)
})
