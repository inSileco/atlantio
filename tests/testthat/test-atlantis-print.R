test_that("print method works for empty Atlantis object", {
  atlantis_obj <- new_atlantis()
  expect_snapshot(print(atlantis_obj))
})

test_that("print method shows correct status for populated object", {
  # Create object with some data
  test_geometry <- data.frame(box = 1:5, depth = runif(5))
  test_bio <- list(param1 = "value1")

  atlantis_obj <- new_atlantis(
    geometry = test_geometry,
    biology = test_bio
  )
  expect_snapshot(print(atlantis_obj))
})

test_that("print method shows geometry details when available", {
  test_geometry <- data.frame(box = 1:10, depth = runif(10))
  atlantis_obj <- new_atlantis(geometry = test_geometry)
  expect_snapshot(print(atlantis_obj))
})

test_that("print method shows main output details when available", {
  # Create mock main output structure
  mock_main_output <- list(
    var = list(temp = list(), salt = list(), biomass = list()),
    dim = list(t = list(len = 100))
  )

  atlantis_obj <- new_atlantis(main_output = mock_main_output)
  expect_snapshot(print(atlantis_obj))
})

test_that("print method returns object invisibly", {
  atlantis_obj <- new_atlantis()

  # Should return the object invisibly
  suppressMessages(result <- print(atlantis_obj))
  expect_identical(result, atlantis_obj)
})

test_that("print method handles complex object with multiple data types", {
  # Create object with multiple data types
  atlantis_obj <- new_atlantis(
    geometry = data.frame(box = 1:15, depth = runif(15)),
    biology = list(species = "cod", growth_rate = 0.3),
    group = data.frame(Code = c("COD", "HAD"), Name = c("Cod", "Haddock")),
    biomass_all = data.frame(Time = 1:50, Total = runif(50)),
    diet = data.frame(Time = 1:20, Predator = rep("COD", 20))
  )
  expect_snapshot(print(atlantis_obj))
})
