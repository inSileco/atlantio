# Create biomass time series

Reads the tracers of functional groups from the main output: reserve and
structural nitrogen and numbers (`ResN`, `StructN`, `Nums`) for the
age-structured groups, nitrogen for the biomass pools, with their
weight.

## Usage

``` r
create_time_series_biomass(
  x,
  group,
  age = NULL,
  box = NULL,
  layer = NULL,
  use_group_code = TRUE,
  aggregate = FALSE,
  boundary = TRUE
)
```

## Arguments

- x:

  An `Atlantis` object with the main output and the biology file loaded,
  and the groups file when `use_group_code = TRUE`.

- group:

  Groups: their codes, or with `use_group_code = FALSE` their names as
  in the main output.

- age:

  Age classes of the age-structured groups; all if `NULL`.

- box:

  Boxes, numbered from 0 as in Atlantis; all boxes if `NULL`.

- layer:

  Layers, numbered from 1; all layers if `NULL`.

- use_group_code:

  Are the groups given by code (`TRUE`) or by name?

- aggregate:

  Should the series be aggregated over boxes and layers while they are
  read, one cohort at a time (see
  [`aggregate_time_series()`](aggregate_time_series.md))? Biomass pools
  get their weight summed.

- boundary:

  Keep the boundary boxes? `FALSE` leaves them out, as Atlantis' biomass
  index does, and needs the geometry file.

## Value

A data frame with one row per group x age x box x layer x time, or per
group x age x time with `aggregate = TRUE`: `group` (the group name),
`age` (`NA` for biomass pools), `time` (seconds), `box`, `layer`, the
tracers, `weight` and `units`.

## Details

`weight` is the wet weight in g: the nitrogen (mg N) times `X_CN` and
`k_wetdry` from the biology file. For a biomass pool, the nitrogen is
its concentration times the cell volume, or times the box area for the
epibenthic groups (one value per box, in mg N m-2), which needs the
geometry file. Atlantis' own biomass index uses a wet-to-dry ratio of
20, whatever `k_wetdry` is, and leaves out the boundary boxes (see
`boundary`).

With `aggregate = TRUE`, the series are reduced over boxes and layers as
they are read (see
[`aggregate_time_series()`](aggregate_time_series.md)): one cohort of
one group at a time, so the full per-box table is never held in memory.
For a whole run that table can weigh more than 1 GB and building it
peaks at several GB.

## References

- https://atlantis-ecosystem-model.github.io/AtlantisWiki/user_guides/quarto_site/part1/11-consumer-processes.html#size-refuge-from-predation

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
