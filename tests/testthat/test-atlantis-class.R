test_that("Atlantis S7 class can be created", {
  atlantis_obj <- new_atlantis()

  expect_s3_class(atlantis_obj, "atlantio::atlantis")
  expect_true(S7::S7_inherits(atlantis_obj, Atlantis))
})

test_that("new_atlantis() creates empty object with correct structure", {
  atlantis_obj <- new_atlantis()
  expect_snapshot(atlantis_obj)

  expect_null(atlantis_obj@geometry)
  expect_null(atlantis_obj@initial)
  expect_null(atlantis_obj@biology)
  expect_null(atlantis_obj@group)
  expect_null(atlantis_obj@physics)
  expect_null(atlantis_obj@forcing)
  expect_null(atlantis_obj@main_output)
  expect_null(atlantis_obj@biomass_all)
  expect_null(atlantis_obj@biomass_box)
  expect_null(atlantis_obj@biomass_age)
  expect_null(atlantis_obj@biomass_age_annual)
  expect_null(atlantis_obj@diet)
  expect_null(atlantis_obj@diet_detailed)
  expect_null(atlantis_obj@yoy)
  expect_error(atlantis_obj@wrong)
})

test_that("new_atlantis() accepts initial values", {
  test_data <- list("test_data")
  expect_warning(
    atlantis_obj <- new_atlantis(
      geometry = test_data,
      biology = test_data,
      wrong = 2
    )
  )

  expect_equal(atlantis_obj@geometry, test_data)
  expect_equal(atlantis_obj@biology, test_data)
  expect_null(atlantis_obj@group)
})

test_that("new_atlantis() matches property names exactly", {
  d <- data.frame(x = 1)
  atl <- new_atlantis(diet_detailed = d, biomass_age_annual = d)
  expect_null(atl@diet)
  expect_null(atl@biomass_age)
  expect_identical(atl@diet_detailed, d)
})
