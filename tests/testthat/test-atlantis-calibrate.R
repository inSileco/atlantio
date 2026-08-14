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
})


test_that("Works as expected", {
  expect_identical(
    res_simplest,
    data.frame(
      name = "rec_m",
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
