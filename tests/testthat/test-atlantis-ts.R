# Write a minimal main-output NetCDF file with one age-structured group
# (`n_cohorts` cohorts) and `volume`, and return its path.
write_mock_main_output <- function(path, group = "Fish", n_cohorts = 12) {
  n_z <- 2
  n_b <- 3
  n_t <- 4
  dim_z <- ncdf4::ncdim_def("z", "", seq_len(n_z))
  dim_b <- ncdf4::ncdim_def("b", "", seq_len(n_b))
  dim_t <- ncdf4::ncdim_def("t", "seconds", seq_len(n_t) - 1)
  vars <- list(ncdf4::ncvar_def("volume", "m3", list(dim_z, dim_b, dim_t)))
  for (coh in seq_len(n_cohorts)) {
    for (field in c("ResN", "StructN", "Nums")) {
      vars[[length(vars) + 1]] <- ncdf4::ncvar_def(
        paste0(group, coh, "_", field),
        "mg N",
        list(dim_z, dim_b, dim_t)
      )
    }
  }
  nc <- ncdf4::nc_create(path, vars)
  withr::defer(ncdf4::nc_close(nc))
  for (v in vars) {
    ncdf4::ncvar_put(nc, v, array(1, dim = c(n_z, n_b, n_t)))
  }
  invisible(path)
}

test_that("create_time_series_biomass() handles groups with 10 or more cohorts", {
  nc_file <- withr::local_tempfile(fileext = ".nc")
  write_mock_main_output(nc_file, group = "Fish", n_cohorts = 12)
  nc <- ncdf4::nc_open(nc_file)
  withr::defer(ncdf4::nc_close(nc))

  mod <- new_atlantis(
    main_output = nc,
    biology = list(X_CN = 5.7, k_wetdry = 20)
  )
  res <- suppressMessages(
    create_time_series_biomass(mod, group = "Fish", use_group_code = FALSE)
  )

  expect_setequal(unique(res$age), as.character(1:12))
  # 12 cohorts x 2 layers x 3 boxes x 4 time steps
  expect_identical(nrow(res), 12L * 2L * 3L * 4L)
  expect_equal(unique(res$weight), (1 + 1) * 1 * 20 * 5.7 * 1e-3)
})

test_that("create_time_series_biomass(aggregate = TRUE) matches aggregating after", {
  nc_file <- withr::local_tempfile(fileext = ".nc")
  write_mock_main_output(nc_file, group = "Fish", n_cohorts = 3)
  nc <- ncdf4::nc_open(nc_file, write = TRUE)
  withr::defer(ncdf4::nc_close(nc))
  # cells that differ, and an empty one
  nums <- array(seq_len(2 * 3 * 4), dim = c(2, 3, 4))
  nums[1, 1, ] <- 0
  ncdf4::ncvar_put(nc, "Fish2_Nums", nums)
  ncdf4::ncvar_put(nc, "Fish2_ResN", array(runif(24, 1, 5), dim = c(2, 3, 4)))

  mod <- new_atlantis(
    main_output = nc,
    biology = list(X_CN = 5.7, k_wetdry = 20)
  )
  raw <- suppressMessages(
    create_time_series_biomass(mod, group = "Fish", use_group_code = FALSE)
  )
  agg <- suppressMessages(
    create_time_series_biomass(
      mod,
      group = "Fish",
      use_group_code = FALSE,
      aggregate = TRUE
    )
  )
  # 3 cohorts x 4 time steps
  expect_identical(nrow(agg), 3L * 4L)
  expect_false(any(c("box", "layer") %in% names(agg)))
  expect_equal(agg, aggregate_time_series(raw))
  expect_equal(
    agg$weight,
    (agg$ResN + agg$StructN) * agg$Nums * 20 * 5.7 * 1e-3
  )
  expect_identical(unique(agg$units), "g")
})

test_that("create_time_series_biomass() weights match the biomass index", {
  skip_if_not_installed("sf")
  mod <- new_atlantis() |>
    atlantis_load_files(c(
      atlantis_examples("inputs", "tiny.bgm"),
      atlantis_examples("inputs", "tiny_biol.prm"),
      atlantis_examples("inputs", "tiny_groups.csv"),
      atlantis_examples("outputs", "output.nc")
    ))
  withr::defer(ncdf4::nc_close(mod@main_output))
  res <- suppressMessages(create_time_series_biomass(mod, c("WAE", "DIA")))
  # the index leaves out the boundary boxes
  inside <- res$time == 0 &
    res$box %in% mod@geometry$.bx0[!mod@geometry$boundary]
  tonnes <- tapply(res$weight[inside], res$group[inside], sum, na.rm = TRUE)
  index <- read_biomass_index(
    atlantis_examples("outputs", "outputBiomIndx.txt"),
    mod@group
  )
  index <- index[index$time == 0, ]
  expect_equal(
    as.vector(tonnes[c("Walleye", "Diatom_N")]) * 1e-6,
    index$Biomass[match(c("Walleye", "Diatom"), index$group)],
    tolerance = 1e-6
  )
})
