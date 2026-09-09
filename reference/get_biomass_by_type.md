# Extract biomass data by aggregation type

Extract biomass data from an Atlantis object based on the specified
aggregation type. Different biomass outputs provide different levels of
spatial, temporal, and demographic resolution.

## Usage

``` r
get_biomass_by_type(atlantis, bm_type)
```

## Arguments

- atlantis:

  An Atlantis S7 object containing biomass data.

- bm_type:

  Character string specifying the biomass data type:

  - `"biomass_all"` - Total biomass indices aggregated across all
    spatial boxes

  - `"biomass_box"` - Biomass by spatial box (polygon-level resolution)

  - `"biomass_age"` - Age-structured biomass for vertebrate functional
    groups

## Value

The requested biomass data object (typically a data.frame or array), or
`NULL` if the specified type is not available in the Atlantis object.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get total biomass time series
total_biomass <- get_biomass_by_type(atlantis, "biomass_all")

# Get spatial biomass distribution
spatial_biomass <- get_biomass_by_type(atlantis, "biomass_box")

# Get age-structured data for population analysis
age_biomass <- get_biomass_by_type(atlantis, "biomass_age")
} # }
```
