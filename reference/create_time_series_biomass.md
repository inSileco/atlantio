# Create Time Series Biomass for Atlantis objects

S7 generic for creating biomass time series data from Atlantis objects

With `aggregate = TRUE`, the series are reduced over boxes and layers as
they are read (see
[`aggregate_time_series()`](aggregate_time_series.md)): one cohort of
one group at a time, so the full per-box table is never held in memory.
For a whole run that table can weigh more than 1 GB and building it
peaks at several GB.

## Usage

``` r
create_time_series_biomass(x, ...)
```

## Arguments

- x:

  An object to create biomass time series from

- ...:

  Additional arguments passed to methods: `group`, `age`, `box`,
  `layer`, `use_group_code` and `aggregate` (`FALSE` by default).

## Value

A biomass time series data structure: one row per group x age x box x
layer x time, or per group x age x time with `aggregate = TRUE`.

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
  create_time_series_biomass(group = "YPH", aggregate = TRUE)
} # }
```
