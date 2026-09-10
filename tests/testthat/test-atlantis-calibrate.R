path_to_mock <- function(...) {
  system.file("mock", "calibrate", ..., package = "atlantio")
}

mod <- new_atlantis() |>
  atlantis_load_files(c(
    atlantis_examples("inputs", "tiny_biol.prm"),
    atlantis_examples("inputs", "tiny_groups.csv")
  ))
res_simplest <- mod |>
  generate_calibration_table(
    path_to_mock("right_simplest.yaml")
  )
res_full <- mod |>
  generate_calibration_table(
    path_to_mock("right_full.yaml")
  )
res_relative <- mod |>
  generate_calibration_table(
    path_to_mock("right_relative.yaml")
  )
# issues with last digits
res_relative$min <- round(res_relative$min, 8)
res_relative$max <- round(res_relative$max, 8)

test_that("Error handling works correctly", {
  expect_error(
    mod |>
      generate_calibration_table(
        path_to_mock("wrong_parameter_name.yaml")
      ),
    "Unknown parameter."
  )
  expect_error(
    mod |>
      generate_calibration_table(
        path_to_mock("wrong_group.yaml")
      ),
    "1 group not in group file"
  )
  expect_error(
    new_atlantis() |>
      generate_calibration_table(
        path_to_mock("wrong_transf.yaml")
      ),
    "Unknown transformation function"
  )
  expect_error(
    new_atlantis() |>
      generate_calibration_table(
        path_to_mock("right_full.yaml")
      ),
    "Group info required"
  )
  #
  expect_error(
    new_atlantis() |>
      atlantis_load_files(
        atlantis_examples("inputs", "tiny_groups.csv")
      ) |>
      generate_calibration_table(
        path_to_mock("right_relative.yaml")
      ),
    "Cannot find value for"
  )
})


test_that("Works as expected", {
  expect_identical(
    res_simplest,
    data.frame(
      name = "rec_m",
      cur_value = 1,
      min = -Inf,
      max = Inf,
      position = 1L,
      transf = "identity",
      source_file = "biology_prm"
    )
  )

  expect_identical(
    res_full,
    data.frame(
      name = c(
        rep("mum_GZS", 5),
        rep("mum_WAE", 8),
        rep("mum_YPH", 2),
        rep("mum_RDG", 2),
        "rec_m"
      ),
      cur_value = c(
        0.036549944,
        0.003063438,
        0.00167827,
        0.00071767,
        0.0004755,
        0.00606736,
        0.003030164,
        0.001290054,
        0.001206866,
        0.000960844,
        0.000836366,
        0.000447656,
        0.000447656,
        0.006924034,
        0.0017007,
        0.009661128,
        0.004078176,
        1
      ),
      min = c(rep(-6, 13), rep(-3, 4), -Inf),
      max = c(rep(-1, 17), Inf),
      position = c(
        1L,
        2L,
        3L,
        4L,
        5L,
        1L,
        2L,
        3L,
        4L,
        5L,
        6L,
        7L,
        8L,
        1L,
        3L,
        1L,
        3L,
        1L
      ),
      transf = c(rep("pow10", 17), "identity"),
      source_file = rep("biology_prm", 18)
    )
  )
})

test_that("Works as expected with is_factor set to true", {
  withr::local_options(list(digits = 6))
  expect_identical(
    res_relative,
    data.frame(
      name = c("mum_GZS", "mum_GZS", "mum_GZS", "mum_WAE"),
      cur_value = c(0.036549944, 0.003063438, 0.00167827, 0.00606736),
      min = c(-Inf, -Inf, -3.77513817, 0.00303368),
      max = c(Inf, Inf, -1.77513817, 0.00910104),
      position = c(1L, 2L, 3L, 1L),
      transf = c("pow10", "pow10", "pow10", "identity"),
      source_file = c(
        "biology_prm",
        "biology_prm",
        "biology_prm",
        "biology_prm"
      )
    )
  )
})

test_that("compute_parameter_dimension() handles per_box parameters", {
  skip_if_not_installed("sf")
  expect_error(
    compute_parameter_dimension(mod, "per_box"),
    "Geometry file \\(bgm\\) required"
  )
  mod_geom <- mod |>
    atlantis_load_files(atlantis_examples("inputs", "tiny.bgm"))
  expect_identical(compute_parameter_dimension(mod_geom, "per_box"), 11L)
})
