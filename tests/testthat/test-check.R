# Copies the mock initial-conditions file (written by
# inst/mock/nc/write_mock_nc.R) to a temporary directory, so that tests can
# change it; the copy is removed when `env` ends.
local_mock_init <- function(env = parent.frame()) {
  dir <- withr::local_tempdir(.local_envir = env)
  path <- file.path(dir, "init.nc")
  file.copy(system.file("mock", "nc", "init.nc", package = "atlantio"), path)
  path
}

mock_groups <- function() {
  data.frame(
    Code = c("FSH", "DIA", "FLA", "CYA", "DR"),
    Name = c("Fish", "Diatom", "Flagellate", "Cyano", "Refractory_detritus"),
    IsTurnedOn = 1,
    NumCohorts = c(1, 1, 1, 1, 1),
    GroupType = c("FISH", "SM_PHY", "SM_PHY", "SM_PHY", "REF_DET")
  )
}

test_that("check_init() finds unset, negative and invalid values", {
  path <- local_mock_init()
  res <- check_init(path, mock_groups(), ratio = 100)
  expect_s3_class(res, "atlantis_check")
  expect_named(res, c("file", "check", "severity", "key", "message"))
  unset <- res[res$check == "unset", ]
  expect_identical(unset$key, "Refractory_detritus_N")
  expect_match(unset$message, "3 of 5 cells unset.*2000")
  # Cyano is x2000 its sisters, Diatom and Flagellate are close
  expect_identical(res$key[res$check == "sisters"], "Cyano_N")
  expect_false(any(res$check %in% c("zero", "missing")))

  nc <- ncdf4::nc_open(path, write = TRUE)
  x <- ncdf4::ncvar_get(nc, "Diatom_N", collapse_degen = FALSE)
  x[1, 1, 1] <- -1
  x[1, 2, 1] <- NaN
  ncdf4::ncvar_put(nc, "Diatom_N", x)
  ncdf4::ncvar_put(nc, "Fish1_ResN", array(0, c(3, 3, 1)))
  ncdf4::ncvar_put(nc, "Flagellate_N", array(0, c(3, 3, 1)))
  ncdf4::nc_close(nc)
  res <- check_init(path, mock_groups())
  expect_identical(res$severity[1], "error")
  expect_true(all(c("negative", "invalid") %in% res$check[res$key == "Diatom_N"]))
  expect_identical(res$key[res$check == "zero" & res$severity == "error"], "Fish1_ResN")
  expect_identical(res$key[res$check == "zero" & res$severity == "warning"], "Flagellate_N")

  groups <- mock_groups()
  groups$Name[1] <- "Shark"
  res <- check_init(path, groups)
  expect_identical(res$key[res$check == "missing"], "Shark")
  expect_message(check_init(path), "skipped")
})

test_that("set_init_values() writes per box and layer", {
  path <- local_mock_init()
  out <- withr::local_tempfile(fileext = ".nc")
  set_init_values(
    path,
    "Refractory_detritus_N",
    data.frame(box = c(0, 1, 1), layer = c(1, 1, 2), value = 30),
    file = out
  )
  expect_false(any(suppressMessages(check_init(out))$check == "unset"))
  nc <- ncdf4::nc_open(out)
  x <- ncdf4::ncvar_get(nc, "Refractory_detritus_N")
  ncdf4::nc_close(nc)
  expect_equal(x[1:2, 2], c(30, 30))
  expect_equal(x[3, 1:2], c(50, 50))
  # the source is left as it was
  expect_true(any(suppressMessages(check_init(path))$check == "unset"))

  expect_error(
    set_init_values(path, "Diatom_N", data.frame(box = 0, value = 1)),
    "layer"
  )
  expect_error(
    set_init_values(path, "Diatom_N", data.frame(box = 5, layer = 1, value = 1)),
    "Boxes"
  )
  expect_error(set_init_values(path, "Nope", data.frame(box = 0, value = 1)), "Unknown")
  expect_warning(
    set_init_values(path, "Diatom_N", data.frame(box = 2, layer = 1, value = 1)),
    "does not use"
  )
})

test_that("check_prm() scans every file", {
  bio <- withr::local_tempfile(fileext = ".prm")
  writeBin(
    charToRaw(paste0(
      "# a comment\r\n",
      "flagrandom 0\r\n",
      "pSTOCK_RDG 1\r\n",
      "1 1 1 1\r\n",
      "KDEP 2\r\n",
      "0.1\t0.2\r\n",
      "KDEP 3\r\n",
      "DREthresh 8000 mg.N.m-2\r\n",
      "-------\r\n"
    )),
    bio
  )
  res <- check_prm(bio = bio)
  expect_setequal(res$check, c("count", "duplicate", "line_endings", "tabs"))
  expect_identical(res$key[res$check == "count"], "pSTOCK_RDG")
  expect_match(res$message[res$check == "count"], "declares 1 value but the next line has 4")
  expect_match(res$message[res$check == "line_endings"], "9 lines")

  run <- withr::local_tempfile(fileext = ".prm")
  writeLines(c("dt 12 hour # time step", "tstop 100 day", "notakey 1"), run)
  res <- check_prm(run = run)
  expect_setequal(res$check, c("units", "unknown"))
  expect_match(res$message[res$check == "units"], "dt 12 hour.*tstop 100 day")
  expect_match(res$message[res$check == "unknown"], "notakey")
  expect_error(check_prm(), "at least one")
})

test_that("check_prm() flags stocking traps", {
  dir <- withr::local_tempdir()
  ts <- c(
    "## COLUMNS 3",
    "## COLUMN1.name Time",
    "## COLUMN1.units seconds since 2000-01-01 00:00:00",
    "## COLUMN2.name STH",
    "## COLUMN3.name LKT",
    # STH on its spawn day (105) both years, LKT on day 104 instead of 274
    paste(105 * 86400, 1000, 0),
    paste(105 * 86400 + 43200, 0, 0),
    paste(104 * 86400, 0, 500),
    paste(104 * 86400 + 43200, 0, 0),
    paste((365 + 105) * 86400, 1000, 0),
    paste((365 + 105) * 86400 + 43200, 0, 0),
    paste((365 + 274) * 86400, 0, 500),
    paste((365 + 274) * 86400 + 43200, 0, 0)
  )
  writeLines(ts, file.path(dir, "stocking1.ts"))
  force <- file.path(dir, "force.prm")
  writeLines(
    c("nMultRects 1", "typeMultRects 1", "MultRects0.data stocking1.ts"),
    force
  )
  bio <- file.path(dir, "bio.prm")
  writeLines(
    c(
      "flagrandom 1",
      "flagstockingSTH 1", "flagrecruitSTH 18", "STH_Time_Spawn 105",
      "flagstockingLKT 0", "flagrecruitLKT 18", "LKT_Time_Spawn 274"
    ),
    bio
  )
  res <- check_prm(bio = bio, force = force)
  expect_identical(res$key[res$check == "stocked_twice"], "STH")
  expect_identical(res$check[res$key == "flagrandom"], "random_spawn")
  spawn <- res[res$check == "spawn_day", ]
  expect_identical(spawn$key, "LKT")
  expect_identical(spawn$severity, "warning")
  expect_match(spawn$message, "1 of 2 box-years")

  # never on the spawn day: nothing delivered
  writeLines(sub("LKT_Time_Spawn 274", "LKT_Time_Spawn 200", readLines(bio)), bio)
  spawn <- check_prm(bio = bio, force = force)
  spawn <- spawn[spawn$check == "spawn_day", ]
  expect_identical(spawn$severity, "error")
  expect_match(spawn$message, "no fish is delivered")
})

test_that("atlantis_check results print", {
  # fixed file names keep the snapshot stable
  path <- local_mock_init()
  expect_snapshot(print(check_init(path, mock_groups())))
  run <- file.path(dirname(path), "run.prm")
  writeLines("dt 1", run)
  expect_snapshot(print(check_prm(bio = run)))
})
