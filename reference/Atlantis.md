# Atlantis Ecosystem Model Container

An S7 class that serves as a comprehensive container for all components
of an Atlantis ecosystem model, including input parameters, spatial
geometry, and simulation outputs. This class provides a structured way
to organize and access the various data types produced by Atlantis model
runs.

## Usage

``` r
Atlantis(
  geometry = NULL,
  run = NULL,
  initial = NULL,
  biology = NULL,
  group = NULL,
  physics = NULL,
  forcing = NULL,
  fisheries = NULL,
  harvest = NULL,
  main_output = NULL,
  biomass_all = NULL,
  biomass_box = NULL,
  biomass_age = NULL,
  biomass_age_annual = NULL,
  diet = NULL,
  diet_detailed = NULL,
  yoy = NULL,
  file_paths = NULL,
  version = character(0)
)
```

## Arguments

- geometry:

  `[sf object]`  
  Spatial geometry from geometry (Box Geometry Model) file defining the
  model domain as polygons with depth layers and connectivity.

- run:

  `[list]`  
  Run configuration parameters from .prm file including simulation
  settings, timesteps, and output specifications.

- initial:

  `[ncdf4]`  
  Initial conditions: the open netCDF file (see
  [`read_nc()`](https://insileco.io/atlantio/reference/read_atlantis_files.md)),
  to close with
  [`ncdf4::nc_close()`](https://rdrr.io/pkg/ncdf4/man/nc_close.html).

- biology:

  `[list]`  
  Biology parameters from .prm file including growth rates, mortality,
  recruitment, and physiological parameters for each functional group.

- group:

  `[data.frame]`  
  Functional group definitions specifying species codes, names, group
  types (vertebrate/invertebrate), and model structure.

- physics:

  `[list]`  
  Physical oceanographic parameters including mixing, transport, and
  hydrodynamic processes.

- forcing:

  `[list]`  
  Environmental forcing data including temperature, salinity, and other
  physical drivers that vary through time.

- fisheries:

  `[data.frame]`  
  Fisheries configuration and catch time series data for commercial and
  recreational fishing activities.

- harvest:

  `[list]`  
  Harvest policies and management scenarios including fishing mortality
  rates and selectivity patterns.

- main_output:

  `[ncdf4]`  
  Main output: the open netCDF file of the run (see
  [`read_nc()`](https://insileco.io/atlantio/reference/read_atlantis_files.md)),
  read by
  [`create_time_series()`](https://insileco.io/atlantio/reference/create_time_series.md)
  and
  [`create_time_series_biomass()`](https://insileco.io/atlantio/reference/create_time_series_biomass.md);
  close it with
  [`ncdf4::nc_close()`](https://rdrr.io/pkg/ncdf4/man/nc_close.html).

- biomass_all:

  `[data.frame]`  
  Biomass of every group over the whole model domain (`BiomIndx.txt`).

- biomass_box:

  `[data.frame]`  
  Biomass of every group per box (`BoxBiomass.txt`).

- biomass_age:

  `[data.frame]`  
  Biomass per age class of the age-structured groups
  (`AgeBiomIndx.txt`).

- biomass_age_annual:

  `[data.frame]`  
  The same, yearly (`AnnualAgeBiomIndx.txt`).

- diet:

  `[data.frame]`  
  Diet composition of the predators (`DietCheck.txt`).

- diet_detailed:

  `[data.frame]`  
  Diet composition per box and layer (`DetailedDietCheck.txt`).

- yoy:

  `[data.frame]`  
  Biomass of recruits per year (`YOY.txt`).

- file_paths:

  `[data.frame]`  
  The files: the rows of
  [input_files](https://insileco.io/atlantio/reference/input_files.md)
  with the path of each file loaded (`NA` otherwise).

- version:

  `[character]`  
  Atlantis version used.

## Details

[`atlantis_load_files()`](https://insileco.io/atlantio/reference/atlantis_load_files.md)
fills every property but `physics`, `forcing`, `fisheries` and
`harvest`, which can be set by hand, e.g.
`x@harvest <- read_prm("harvest.prm")`.

## Model Components

The Atlantis class contains the following major component types:

**Input Files:**

- Spatial geometry and configuration

- Biological and physical parameters

- Initial conditions and forcing data

**Output Files:**

- Time series biomass and abundance data

- Spatial distribution snapshots

- Predation and diet composition matrices

## References

The outputs are described in the Atlantis User's Guide Part I
<https://research.csiro.au/atlantis/wp-content/uploads/sites/52/2025/05/AtlantisUserGuide_PartI.pdf>
