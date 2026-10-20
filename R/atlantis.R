#' Atlantis Ecosystem Model Container
#'
#' @description
#' An S7 class that serves as a comprehensive container for all components of an
#' Atlantis ecosystem model, including input parameters, spatial geometry, and
#' simulation outputs. This class provides a structured way to organize and access
#' the various data types produced by Atlantis model runs.
#'
#' @section Model Components:
#' The Atlantis class contains the following major component types:
#'
#' **Input Files:**
#' * Spatial geometry and configuration
#' * Biological and physical parameters
#' * Initial conditions and forcing data
#'
#' **Output Files:**
#' * Time series biomass and abundance data
#' * Spatial distribution snapshots
#' * Predation and diet composition matrices
#'
#' @param geometry `[sf object]`\cr
#' Spatial geometry from geometry (Box Geometry Model) file defining the model
#' domain as polygons with depth layers and connectivity.
#' @param run `[list]`\cr
#' Run configuration parameters from .prm file including simulation settings,
#' timesteps, and output specifications.
#' @param initial `[ncdf4]`\cr
#' Initial conditions: the open netCDF file (see [read_nc()]), to close with
#' `ncdf4::nc_close()`.
#' @param biology `[list]`\cr
#' Biology parameters from .prm file including growth rates, mortality,
#' recruitment, and physiological parameters for each functional group.
#' @param group `[data.frame]`\cr Functional group definitions specifying
#' species codes, names, group types (vertebrate/invertebrate), and model
#' structure.
#' @param forcing `[list]`\cr
#' Environmental forcing data including temperature, salinity, and other
#' physical drivers that vary through time.
#' @param fisheries `[data.frame]`\cr
#' Fisheries configuration and catch time series data for commercial and
#' recreational fishing activities.
#' @param harvest `[list]`\cr
#' Harvest policies and management scenarios including fishing mortality rates
#' and selectivity patterns.
#' @param physics `[list]`\cr
#' Physical oceanographic parameters including mixing, transport, and
#' hydrodynamic processes.
#' @param main_output `[ncdf4]`\cr
#' Main output: the open netCDF file of the run (see [read_nc()]), read by
#' [create_time_series()] and [create_time_series_biomass()]; close it with
#' `ncdf4::nc_close()`.
#' @param biomass_all `[data.frame]`\cr
#' Biomass of every group over the whole model domain (`BiomIndx.txt`).
#' @param biomass_box `[data.frame]`\cr
#' Biomass of every group per box (`BoxBiomass.txt`).
#' @param biomass_age `[data.frame]`\cr
#' Biomass per age class of the age-structured groups (`AgeBiomIndx.txt`).
#' @param biomass_age_annual `[data.frame]`\cr
#' The same, yearly (`AnnualAgeBiomIndx.txt`).
#' @param diet `[data.frame]`\cr
#' Diet composition of the predators (`DietCheck.txt`).
#' @param diet_detailed `[data.frame]`\cr
#' Diet composition per box and layer (`DetailedDietCheck.txt`).
#' @param yoy `[data.frame]`\cr
#' Biomass of recruits per year (`YOY.txt`).
#' @param file_paths `[data.frame]`\cr
#' The files: the rows of [input_files] with the path of each file loaded
#' (`NA` otherwise).
#' @param version `[character]`\cr
#' Atlantis version used.
#'
#' @details
#' [atlantis_load_files()] fills every property but `physics`, `forcing`,
#' `fisheries` and `harvest`, which can be set by hand, e.g.
#' `x@harvest <- read_prm("harvest.prm")`.
#'
#' @references
#' The outputs are described in the Atlantis User's Guide Part I
#' <https://research.csiro.au/atlantis/wp-content/uploads/sites/52/2025/05/AtlantisUserGuide_PartI.pdf>
#'
#' @export
#'
Atlantis <- S7::new_class(
  "atlantis",
  properties = list(
    geometry = S7::class_any,
    run = S7::class_any,
    initial = S7::class_any,
    biology = S7::class_any,
    group = S7::class_any,
    physics = S7::class_any,
    forcing = S7::class_any,
    fisheries = S7::class_any,
    harvest = S7::class_any,
    main_output = S7::class_any,
    biomass_all = S7::class_any,
    biomass_box = S7::class_any,
    biomass_age = S7::class_any,
    biomass_age_annual = S7::class_any,
    diet = S7::class_any,
    diet_detailed = S7::class_any,
    yoy = S7::class_any,
    file_paths = S7::class_any,
    version = S7::class_character
  )
)

#' Create new Atlantis model object
#'
#' @description
#' Constructor function for creating a new, empty Atlantis model object. All
#' properties are initialized as NULL and can be populated later using
#' `atlantis_load_files()` or by direct assignment.
#'
#' @param ... Optional named arguments to initialize specific properties.
#'   Property names should match those defined in the Atlantis class
#'   (e.g. geometry, biology, run).
#'
#' @return An Atlantis S7 object with all properties initialized to NULL
#'   unless specified in the arguments.
#'
#' @examples
#' \dontrun{
#' # Create empty Atlantis object
#' atlantis <- new_atlantis()
#'
#' # Create with some initial data
#' atlantis <- new_atlantis(
#'   geometry = my_geometry_data,
#'   biology = my_biology_params
#' )
#' }
#'
#' @seealso [atlantis_load_files()] for loading data from files
#' @export
new_atlantis <- function(...) {
  args <- list(...)
  unknown <- setdiff(names(args), names(formals(Atlantis)))
  if (length(unknown)) {
    cli::cli_warn("unknown properties: {unknown}")
  }
  args <- args[setdiff(names(args), unknown)]
  args$file_paths <- args[["file_paths"]] %||%
    cbind(atlantio::input_files, path = NA_character_)
  args$version <- args[["version"]] %||% "latest"
  do.call(Atlantis, args)
}

#' Load Atlantis files into model object
#'
#' @description
#' Load Atlantis input and output files into an existing Atlantis object. This
#' function automatically detects file types and assigns data to the appropriate
#' properties based on file extensions and content. Only properties with newly
#' loaded data are updated; existing properties are preserved unless overwritten.
#'
#' @param atlantis An existing Atlantis S7 object to update with new data.
#' @param files Either:
#'   * Character vector of file paths to Atlantis files
#'   * An `atlantis_file` object (created by `read_atlantis_files()`)
#'
#'   Supported file types include:
#'   * `.bgm` - Box Geometry Model files
#'   * `.prm` - Parameter files (bio and run)
#'   * `.nc` - NetCDF output files
#'   * `.csv` - Groups file
#'   * `.txt` - Diet and biomass outputs
#' @param filenames file basenames (used as hints)
#'
#' @return Updated Atlantis S7 object with newly loaded data merged with
#'   existing properties.
#'
#' @examples
#' \dontrun{
#' # Create empty object and load files
#' atlantis <- new_atlantis()  |>
#'  atlantis_load_files(c(
#'   "model.geometry",
#'   "biology.prm",
#'   "run.prm",
#'   "output.nc"
#' ))
#'
#' # Load additional files later
#' atlantis <- atlantis_load_files(atlantis, "diet_check.txt")
#' }
#'
#' @seealso [read_atlantis_files()], [new_atlantis()]
#' @export
atlantis_load_files <- function(atlantis, files, filenames = basename(files)) {
  if (is.character(files)) {
    files <- read_atlantis_files(files, filenames)
  }

  if (!inherits(files, "atlantis_file")) {
    cli::cli_alert_warning(
      "Invalid file input: expected 'atlantis_file' object or character vector of file paths"
    )
    return(atlantis)
  }

  v_types <- vapply(files, \(x) x$type, character(1))
  dups <- duplicated(v_types) & v_types %in% S7::prop_names(atlantis)
  if (any(dups)) {
    cli::cli_alert_warning(
      "Several files available for: {unique(v_types[dups])}; only the first one is used."
    )
    files <- files[!dups]
  }

  for (i in seq_along(files)) {
    tmp <- files[[i]]
    if (tmp$type == "cannot read") {
      if (file.exists(tmp$path)) {
        cli::cli_warn(c(
          "Cannot read {.path {tmp$path}}.",
          "x" = "{tmp$object}"
        ))
      } else {
        cli::cli_warn("{tmp$path} does not exist.")
      }
      next
    }
    if (!tmp$type %in% S7::prop_names(atlantis)) {
      cli::cli_warn(
        "{tmp$path} skipped: unsupported file type {.val {tmp$type}}."
      )
      next
    }
    S7::prop(atlantis, tmp$type) <- tmp$object %||% S7::prop(atlantis, tmp$type)
    atlantis@file_paths$path[atlantis@file_paths$name == tmp$type] <- tmp$path
  }

  atlantis
}


#' Extract biomass data by aggregation type
#'
#' @description
#' Extract biomass data from an Atlantis object based on the specified
#' aggregation type. Different biomass outputs provide different levels of
#' spatial, temporal, and demographic resolution.
#'
#' @param atlantis An Atlantis S7 object containing biomass data.
#' @param bm_type Character string specifying the biomass data type:
#'   * `"biomass_all"` - Total biomass indices aggregated across all spatial boxes
#'   * `"biomass_box"` - Biomass by spatial box (polygon-level resolution)
#'   * `"biomass_age"` - Age-structured biomass for vertebrate functional groups
#'   * `"biomass_age_annual"` - Annual age-structured biomass
#'
#' @return The requested biomass table (a data frame), or `NULL` if that
#'   output is not loaded in the Atlantis object. Any other `bm_type` is an
#'   error.
#'
#' @examples
#' \dontrun{
#' # Get total biomass time series
#' total_biomass <- get_biomass_by_type(atlantis, "biomass_all")
#'
#' # Get spatial biomass distribution
#' spatial_biomass <- get_biomass_by_type(atlantis, "biomass_box")
#'
#' # Get age-structured data for population analysis
#' age_biomass <- get_biomass_by_type(atlantis, "biomass_age")
#' }
#'
#' @export
get_biomass_by_type <- function(atlantis, bm_type) {
  bm_type <- rlang::arg_match(
    bm_type,
    c("biomass_all", "biomass_box", "biomass_age", "biomass_age_annual")
  )
  S7::prop(atlantis, bm_type)
}
