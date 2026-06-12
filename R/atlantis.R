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
#' @param initial `[list]`\cr
#' Initial conditions from .nc file specifying starting biomass, numbers, and
#' other state variables for each functional group.
#' @param biology `[list]`\cr
#' Biology parameters from .prm file including growth rates, mortality,
#' recruitment, and physiological parameters for each functional group.
#' @param group `[data.frame]`\cr Functional group definitions specifying
#' species codes, names, group types (vertebrate/invertebrate), and model
#' structure.
#' @param forcing `[list]`\cr
#' Environmental forcing data including temperature, salinity, and other
#' physical drivers that vary through time.
#' @param fisheries `[list]`\cr
#' Fisheries configuration and catch time series data for commercial and
#' recreational fishing activities.
#' @param harvest `[list]`\cr
#' Harvest policies and management scenarios including fishing mortality rates
#' and selectivity patterns.
#' @param physics `[list]`\cr
#' Physical oceanographic parameters including mixing, transport, and
#' hydrodynamic processes.
#' @param main_output `[data.frame]`\cr
#' Primary model outputs including biomass and abundance time series for all
#' functional groups aggregated across space.
#' @param biomass_all `[array]`\cr
#' Complete biomass snapshots at specific time points showing spatial
#' distribution across all boxes and depth layers.
#' @param biomass_box `[array]`\cr
#' Biomass snapshots aggregated by box (spatial polygon) for each functional
#' group and time point.
#' @param biomass_age `[array]`\cr
#' Age-structured biomass snapshots showing cohort dynamics for vertebrate
#' functional groups.
#' @param biomass_age_annual `[array]`\cr
#' Annual summaries of age-structured biomass data for long-term trend analysis.
#' @param diet `[matrix]`\cr
#' Diet composition matrix showing predator-prey relationships and consumption
#' rates between functional groups.
#' @param diet_detailed `[array]`\cr
#' Detailed diet matrices with temporal, spatial, and size-based resolution of
#' predation interactions.
#' @param yoy `[array]`\cr
#' Snapshot of biomass of recruits per year.
#' @param file_paths  `[dataframe]`\cr
#' Data frame listing path to input and output files.
#' @param version `[character]`\cr
#' Atlantis version used.
#'
#' @references
#' Output list avaialbe here <https://atlantis-ecosystem-model.github.io/AtlantisWiki/user_guides/markdown_output/AtlantisUserGuide_PartI_CLEAN.html#simulation-outputs>
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
  # validator = function(self) {
  #     if (length(self@animals) != self@enclosure) {
  #         "@enclosure should equal length(@animals)"
  #     }
  # }
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
#'   (e.g., geometry, bio, run, etc.).
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
#'   bio = my_biology_params
#' )
#' }
#'
#' @seealso [atlantis_load_files()] for loading data from files
#' @export
new_atlantis <- function(...) {
  args <- list(...)

  # Initialize all properties as NULL if not provided
  properties <- list(
    geometry = args$geometry %||% NULL,
    run = args$run %||% NULL,
    initial = args$initial %||% NULL,
    biology = args$biology %||% NULL,
    group = args$group %||% NULL,
    physics = args$physics %||% NULL,
    forcing = args$forcing %||% NULL,
    fisheries = args$fisheries %||% NULL,
    harvest = args$harvest %||% NULL,
    main_output = args$main_output %||% NULL,
    biomass_all = args$biomass_all %||% NULL,
    biomass_box = args$biomass_box %||% NULL,
    biomass_age = args$biomass_age %||% NULL,
    biomass_age_annual = args$biomass_age_annual %||% NULL,
    diet = args$diet %||% NULL,
    diet_detailed = args$diet_detailed %||% NULL,
    yoy = args$yoy %||% NULL,
    file_paths = args$file_paths %||%
      cbind(atlantio::input_files, path = NA_character_),
    version = args$version %||% "latest"
  )

  nm <- args |> names()
  ind <- !nm %in% names(properties)
  if (any(ind)) {
    cli::cli_warn("unknown properties: {nm[ind]}")
  }

  do.call(Atlantis, properties)
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
#'   * `.geometry` - Box Geometry Model files
#'   * `.prm` - Parameter files (bio and run)
#'   * `.nc` - NetCDF output files
#'   * `.txt`, `.csv` - Diet and biomass snapshot files
#' @param filenames file basenames (used as hints)
#'
#' @return Updated Atlantis S7 object with newly loaded data merged with
#'   existing properties.
#'
#' @examples
#' \dontrun{
#' # Create empty object and load files
#' atlantis <- new_atlantis()
#' atlantis <- atlantis_load_files(atlantis, c(
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

  # check if multiple file of the same type use duplicated
  # cli::cli_alert_warning()
  v_types <- lapply(files, \(x) x$type) |> unlist()
  dups <- duplicated(v_types)
  if (any(dups)) {
    cli::cli_alert_warning(
      "Several files available for: {v_types[dups] |> unique()}",
      "only the first file is used"
    )
    files <- files[dups]
  }

  for (i in seq_along(files)) {
    tmp <- files[[i]]
    if (tmp$type == "cannot read") {
      cli::cli_warn("{tmp$path} does not exist.")
      next
    }
    S7::prop(atlantis, tmp$type) <- tmp$object %||% S7::prop(atlantis, tmp$type)
    atlantis@file_paths$path[atlantis@file_paths$name == tmp$type] <- tmp$path
  }

  atlantis@file_paths

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
#'
#' @return The requested biomass data object (typically a data.frame or array),
#'   or `NULL` if the specified type is not available in the Atlantis object.
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
  if (!bm_type %in% c("biomass_all", "biomass_box", "biomass_age")) {
    cli::cli_alert_warning(
      "Invalid bm_type: must be one of 'biomass_all', 'biomass_box', or 'biomass_age'"
    )
    return(NULL)
  }

  switch(
    bm_type,
    "biomass_all" = atlantis@biomass_all,
    "biomass_box" = atlantis@biomass_box,
    "biomass_age" = atlantis@biomass_age,
    NULL
  )
}
