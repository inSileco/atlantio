# Create Time Series Biomass for Atlantis objects

S7 generic for creating biomass time series data from Atlantis objects

## Usage

``` r
create_time_series_biomass(x, ...)
```

## Arguments

- x:

  An object to create biomass time series from

- ...:

  Additional arguments passed to methods

## Value

A biomass time series data structure

## Examples

``` r
if (FALSE) { # \dontrun{
new_atlantis() |>
  atlantis_load_files(
    c(
      system.file("examples", "inputs", "tiny.bgm", package = "atlantio"),
      system.file("examples", "inputs", "tiny_biol.prm", package = "atlantio"),
      system.file("examples", "inputs", "tiny_groups.csv", package = "atlantio"),
      system.file("examples", "outputs", "output.nc", package = "atlantio")
    )
  ) |>
  create_time_series_biomass(group = "YPH")
} # }
```
