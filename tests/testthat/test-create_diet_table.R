test_that("create_diet_table() works", {
  expect_error(new_atlantis() |> create_diet_table())

  atl2 <- atl1 <- create_atlantis_model()
  atl2@group <- NULL
  res1 <- atl1 |> create_diet_table()

  # we expect data frame
  expect_true(inherits(res1, "data.frame"))
  expect_identical(dim(res1), c(20L, 18L))
  expect_snapshot(res2 <- atl2 |> create_diet_table())
  expect_true(inherits(res1, "data.frame"))
  expect_identical(dim(res1), c(20L, 18L))

  # default column names in res2
  expect_false(identical(res1, res2))
  expect_identical(names(res1)[1L], "WAE")
  expect_identical(names(res2)[1L], "V1")
})
