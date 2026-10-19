# Writes the mock netCDF files used by the tests (tests/testthat/test-check.R).
# Run from the package root: Rscript inst/mock/nc/write_mock_nc.R

# A minimal initial-conditions file: 3 boxes (0 to 2) with 1, 2 and 0 water
# layers, 2 water layers + 1 sediment layer, one fish with one cohort, three
# pools and a refractory detritus with a fill value of 2000.
write_mock_init <- function(path) {
  dim_z <- ncdf4::ncdim_def("z", "", 1:3, create_dimvar = FALSE)
  dim_b <- ncdf4::ncdim_def("b", "", 1:3, create_dimvar = FALSE)
  dim_t <- ncdf4::ncdim_def("t", "seconds", 0, unlim = TRUE)
  def <- function(name, dims, fill = 0, prec = "double") {
    ncdf4::ncvar_def(name, "mg N m-3", dims, missval = fill, prec = prec)
  }
  d3 <- list(dim_z, dim_b, dim_t)
  vars <- list(
    numlayers = def("numlayers", list(dim_b, dim_t), prec = "short"),
    Fish1_Nums = def("Fish1_Nums", d3),
    Fish1_StructN = def("Fish1_StructN", d3),
    Fish1_ResN = def("Fish1_ResN", d3),
    Diatom_N = def("Diatom_N", d3),
    Flagellate_N = def("Flagellate_N", d3),
    Cyano_N = def("Cyano_N", d3),
    Refractory_detritus_N = def("Refractory_detritus_N", d3, fill = 2000)
  )
  nc <- ncdf4::nc_create(path, vars)
  ncdf4::ncatt_put(nc, 0, "wcnz", 2L)
  ncdf4::ncatt_put(nc, 0, "sednz", 1L)
  ncdf4::ncvar_put(nc, "numlayers", c(1, 2, 0))
  for (v in names(vars)[-1]) {
    ncdf4::ncatt_put(nc, v, "bmtype", "tracer")
    vert <- grepl("^Fish", v)
    ncdf4::ncatt_put(nc, v, "inwc", if (vert) 0L else 1L)
    ncdf4::ncatt_put(nc, v, "insed", if (vert) 0L else 1L)
  }
  # used cells: box 0 layers 1 and 3, box 1 layers 1, 2 and 3
  cells <- array(0, c(3, 3, 1))
  cells[c(1, 3), 1, 1] <- 1
  cells[, 2, 1] <- 1
  ncdf4::ncvar_put(nc, "Fish1_Nums", cells * 100)
  ncdf4::ncvar_put(nc, "Fish1_StructN", cells * 10)
  ncdf4::ncvar_put(nc, "Fish1_ResN", cells * 26.5)
  ncdf4::ncvar_put(nc, "Diatom_N", cells * 50)
  ncdf4::ncvar_put(nc, "Flagellate_N", cells * 20)
  ncdf4::ncvar_put(nc, "Cyano_N", cells * 1e5)
  # detritus set in the sediment only: the water column gets 2000
  det <- array(NA_real_, c(3, 3, 1))
  det[3, 1:2, 1] <- 50
  ncdf4::ncvar_put(nc, "Refractory_detritus_N", det)
  ncdf4::nc_close(nc)
  invisible(path)
}

# The main output of a run that crashed at day 50: an output every 5 days
# from day 0, time in seconds as Atlantis writes it.
write_mock_output_truncated <- function(path) {
  dim_b <- ncdf4::ncdim_def("b", "", 1:3, create_dimvar = FALSE)
  dim_t <- ncdf4::ncdim_def(
    "t",
    "seconds since 2000-01-01 00:00:00 +10",
    seq(0, 50, by = 5) * 86400,
    unlim = TRUE
  )
  var <- ncdf4::ncvar_def("Diatom_N", "mg N m-3", list(dim_b, dim_t), missval = 0)
  nc <- ncdf4::nc_create(path, list(var))
  ncdf4::ncvar_put(nc, "Diatom_N", array(50, c(3, 11)))
  ncdf4::nc_close(nc)
  invisible(path)
}

write_mock_init(file.path("inst", "mock", "nc", "init.nc"))
write_mock_output_truncated(file.path("inst", "mock", "nc", "output_truncated.nc"))
