test_that("read_atlantis_files() handles wrong file type", {
  res1 <- read_atlantis_files("wrong.wrg")
  res2 <- system.file("references.bib", package = "atlantio") |>
    read_atlantis_files()
  rese1 <- rese2 <- list(list(
    path = "wrong.wrg",
    type = "unknown",
    object = NULL
  ))
  rese2[[1]]$path <- system.file("references.bib", package = "atlantio")
  expect_true(inherits(res1, "atlantis_file"))
  expect_identical(unclass(res1), rese1)
  expect_identical(unclass(res2), rese2)
})

test_that("read_bgm() works", {
  skip_if_not_installed("sf")
  fl1 <- system.file("examples", "inputs", "tiny.bgm", package = "atlantio")
  res1 <- read_bgm(fl1)
  res2 <- read_atlantis_files(fl1)
  res3 <- read_atlantis_files(c(fl1, fl1))
  expect_identical(res1$type, "geometry")
  expect_true(inherits(res1$object, "sf"))
  expect_length(res2[[1]], 3)
  expect_identical(res2[[1L]]$type, res1$type)
  expect_identical(res3[[1L]], res2[[1L]])
})


test_that("read_group_file() works", {
  fl1 <- system.file(
    "examples",
    "inputs",
    "tiny_groups.csv",
    package = "atlantio"
  )
  res1 <- read_atlantis_files(fl1)
  expect_identical(res1[[1]]$object |> dim(), c(15L, 32L))
  expect_identical(res1[[1]]$type, "group")
})

test_that("read_xml() converts XML files to lists", {
  fl1 <- system.file(
    "examples",
    "outputs",
    "tiny_biol.xml",
    package = "atlantio"
  )
  res_direct <- read_xml(fl1)
  expect_identical(res_direct$type, "xml_file")
  expect_type(res_direct$object, "list")
  res_wrapped <- read_atlantis_files(fl1)
  expect_identical(res_wrapped[[1]]$type, "xml_file")
  expect_identical(res_wrapped[[1]]$object, res_direct$object)
})

test_that("read_txt_files() classifies output text files", {
  read_type <- function(...) {
    fl <- atlantis_examples("outputs", ...)
    suppressMessages(suppressWarnings(read_atlantis_files(fl)))[[1]]$type
  }
  expect_identical(read_type("outputDietCheck.txt"), "diet")
  expect_identical(read_type("outputBiomIndx.txt"), "biomass_all")
  expect_identical(read_type("outputBoxBiomass.txt"), "biomass_box")
  expect_identical(read_type("outputAgeBiomIndx.txt"), "biomass_age")
  expect_identical(
    read_type("outputAnnualAgeBiomIndx.txt"),
    "biomass_age_annual"
  )
  expect_identical(read_type("outputYOY.txt"), "yoy")
  expect_identical(read_type("outputMort.txt"), "unknown")
  expect_identical(read_type("outputSSB.txt"), "unknown")
})

test_that("read_txt_files() never returns a NULL type", {
  txt_files <- list.files(
    atlantis_examples("outputs"),
    pattern = "\\.txt$",
    full.names = TRUE
  )
  types <- vapply(
    txt_files,
    \(fl) suppressMessages(suppressWarnings(read_atlantis_files(fl)))[[1]]$type,
    character(1)
  )
  expect_true(all(nzchar(types)))
  expect_false("biomass_age" %in% types[grepl("DietCheck", names(types))])
})

test_that("read_txt_files() classifies detailed diet output by column layout", {
  fl <- withr::local_tempfile(fileext = ".txt")
  writeLines(
    c(
      "Time Predator Cohort Box Layer Stock Updated WAE YPH",
      "0 WAE 1 0 1 0 0 0.1 0.2"
    ),
    fl
  )
  res <- suppressMessages(read_txt_files(fl, "outputDetailedDietCheck.txt"))
  expect_identical(res$type, "diet_detailed")
  # too few columns must not error
  writeLines(c("Time Predator", "0 WAE"), fl)
  res <- suppressMessages(read_txt_files(fl, "outputDetailedDietCheck.txt"))
  expect_identical(res$type, "unknown")
})
