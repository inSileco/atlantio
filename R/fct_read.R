#' Read Atlantis inputs and outputs files
#'
#' @description Functions to read Atlantis inputs and outputs.
#'
#' @param files vector of paths that point to file(s) to read.
#' @param filenames file basenames. This is important for the Shiny app as
#' files uploaded are renamed but the basename remains available.
#'
#' @details
#' The `read_atlantis_files()` function implements a file processing pipeline
#' for handling diverse Atlantis ecosystem model file formats. One or several
#' files can be processed at once. Internally, the way files are processed is
#' determined by file extension using a switch statement:
#' - `.bgm`: Box geometry files → `[read_bgm()]`
#' - `.nc`: NetCDF files → `[read_nc()]`
#' - `.prm`: Parameter files → `[read_prm_files()]`
#' - `.csv`: Group definition files → `[read_group_file()]`
#' - `.txt`: Various output formats → `[read_txt_files()]`
#' Basic examination of the content is done to determine the type of file and
#' exhaustive validation is carried out if available.
#' Note that unknown file types are marked as `"unknown"` rather than causing
#' crashes, and unreadable files are marked as `"cannot read"`.
#'
#' @return Returns an object of class `atlantis_file`, which is a list of
#' 3 elements:
#' * `path`: the path to the file;
#' * `type`: the type of input or output;
#' * `object`: the R object used by the Shiny App.
#'
#' @examples
#' hh <- system.file("examples", "inputs", "tiny_biol.prm", package = "atlantio") |>
#'   read_atlantis_files()
#'
#' @export

read_atlantis_files <- function(files, filenames = basename(files)) {
  if (length(files) > 1) {
    out <- lapply(files, read_atlantis_files) |>
      do.call(what = "c")
    return(structure(out, class = "atlantis_file"))
  }

  out <- list(path = files)
  # read files according to their extension
  res <- tryCatch(
    switch(
      fs::path_ext(files),
      bgm = read_bgm(files),
      nc = read_nc(files),
      prm = read_prm_files(files),
      csv = read_group_file(files),
      xml = read_xml(files),
      txt = read_txt_files(files, filenames),
      list(
        type = "unknown",
        object = NULL
      )
    ),
    error = function(e) e
  )

  if (inherits(res, "error")) {
    cli::cli_alert_danger("Cannot read: {res$message}")
    out <- c(out, list(type = "cannot read", object = res$message))
  } else {
    out <- c(out, res)
  }

  structure(list(out), class = "atlantis_file")
}


#' @describeIn read_atlantis_files Read BGM (box geometry) files
#' @param path path that points to the file to read.
#' @param filename File basename.
#' @export
read_bgm <- function(path) {
  suppressMessages({
    geom <- rbgm::box_sf(rbgm::bgmfile(path))
    # address 'old-style crs object detected' error
    geom <- sf::st_transform(geom, crs = 4326)
  })
  list(
    type = "geometry",
    object = geom
  )
}

#' @describeIn read_atlantis_files Read NetCDF files and classify as init or main output
#' @export
read_nc <- function(path) {
  obj <- ncdf4::nc_open(path)
  vars <- obj$var |> names()
  if (all(c("volume", "dz", "Temp", "salt") %in% vars)) {
    nl <- ncdf4::ncvar_get(obj, varid = "numlayers")
    if (length(dim(nl)) == 1) {
      list(
        type = "initial",
        object = obj
      )
    } else {
      list(
        type = "main_output",
        object = obj
      )
    }
  } else {
    cli::cli_alert("unknown netCDF file")
    list(
      type = "unknown",
      object = NULL
    )
  }
}

#' @describeIn read_atlantis_files Read CSV group definition files
#' @export
read_group_file <- function(path) {
  obj <- utils::read.csv(path)
  if (all(c("code", "index", "isturnedon", "name") %in% tolower(names(obj)))) {
    return(
      list(
        type = "group",
        object = obj
      )
    )
  }
  cli::cli_alert("unknown csv file")
  list(
    type = "unknown",
    object = NULL
  )
}


#' @describeIn read_atlantis_files Read and classify PRM parameter files
#' @export
read_prm_files <- function(path) {
  out <- read_prm(path)

  if (all(atlantio::parameters_hints$run %in% names(out))) {
    out <- validate_file(out, "run.yaml")
    return(
      list(
        type = "run",
        object = out
      )
    )
  }
  if (all(atlantio::parameters_hints$bio %in% names(out))) {
    return(
      list(
        type = "biology",
        object = out
      )
    )
  }
  cli::cli_alert("unknown prm file")
  list(
    type = "unknown",
    object = NULL
  )
}


#' @describeIn read_atlantis_files Read and classify TXT output files. The name
#' of the file is used as a clue to determine the type of files.
#' @export
read_txt_files <- function(path, filename) {
  out <- vroom::vroom(path)
  bnm <- filename
  nm <- names(out)
  if (grepl("BoxBiomass", bnm) && nm[2] == "Box") {
    return(list(type = "biomass_box", object = out))
  } else if (grepl("BiomInd", bnm) && "DivCount" %in% nm) {
    return(list(type = "biomass_all", object = out))
  } else if (grepl("AgeBiomIndx", bnm)) {
    if (grepl("AnnualAgeBiomIndx", bnm)) {
      return(list(type = "biomass_age_annual", object = out))
    } else {
      return(list(type = "biomass_age", object = out))
    }
  } else if (grepl("DietCheck", bnm)) {
    if (
      grepl("DetailedDietCheck", bnm) &&
        nm[2L] == "Predator" &&
        nm[4L] == "Stock"
    ) {
      return(list(type = "diet", object = out))
    } else if (nm[2L] == "Predator" && nm[4L] == "Box") {
      return(list(type = "biomass_age", object = out))
    }
  } else if (grepl("YOY", bnm)) {
    return(list(type = "yoy", object = out))
  } else {
    return(
      list(
        type = "unknown",
        object = NULL
      )
    )
  }
}

#' @describeIn read_atlantis_files Read XML files and convert them to lists
#' @export
read_xml <- function(path) {
  xml_doc <- tryCatch(xml2::read_xml(path), error = function(...) NULL)
  if (is.null(xml_doc)) {
    return(list(type = "unknown", object = NULL))
  }
  xml_list <- xml2::as_list(xml_doc)
  if (is.null(xml_list)) {
    return(list(type = "unknown", object = NULL))
  }
  list(
    type = "xml_file",
    object = xml_list
  )
}
