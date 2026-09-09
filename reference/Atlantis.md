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

  `[list]`  
  Initial conditions from .nc file specifying starting biomass, numbers,
  and other state variables for each functional group.

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

  `[list]`  
  Fisheries configuration and catch time series data for commercial and
  recreational fishing activities.

- harvest:

  `[list]`  
  Harvest policies and management scenarios including fishing mortality
  rates and selectivity patterns.

- main_output:

  `[data.frame]`  
  Primary model outputs including biomass and abundance time series for
  all functional groups aggregated across space.

- biomass_all:

  `[array]`  
  Complete biomass snapshots at specific time points showing spatial
  distribution across all boxes and depth layers.

- biomass_box:

  `[array]`  
  Biomass snapshots aggregated by box (spatial polygon) for each
  functional group and time point.

- biomass_age:

  `[array]`  
  Age-structured biomass snapshots showing cohort dynamics for
  vertebrate functional groups.

- biomass_age_annual:

  `[array]`  
  Annual summaries of age-structured biomass data for long-term trend
  analysis.

- diet:

  `[matrix]`  
  Diet composition matrix showing predator-prey relationships and
  consumption rates between functional groups.

- diet_detailed:

  `[array]`  
  Detailed diet matrices with temporal, spatial, and size-based
  resolution of predation interactions.

- yoy:

  `[array]`  
  Snapshot of biomass of recruits per year.

- file_paths:

  `[dataframe]`  
  Data frame listing path to input and output files.

- version:

  `[character]`  
  Atlantis version used.

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

Output list avaialbe here
<https://atlantis-ecosystem-model.github.io/AtlantisWiki/user_guides/markdown_output/AtlantisUserGuide_PartI_CLEAN.html#simulation-outputs>
