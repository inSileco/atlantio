# Create time series from the main output

Extracts variables of the main netCDF output of an Atlantis model as a
tidy data frame, optionally restricted to a set of boxes and layers.

## Usage

``` r
create_time_series(x, variable, box = NULL, layer = NULL)
```

## Arguments

- x:

  An `Atlantis` object with the main output loaded.

- variable:

  Names of the variables (see `names(x@main_output$var)`).

- box:

  Boxes, numbered from 0 as in Atlantis; all boxes if `NULL`.

- layer:

  Layers, numbered from 1; all layers if `NULL`. Ignored for 2D
  variables, whose rows have `layer` -1.

## Value

A data frame with one row per variable x box x layer x time and the
columns `time` (seconds), `box`, `layer`, `value`, `variable` and
`units`.

## Examples

``` r
if (FALSE) { # \dontrun{
my_model <- new_atlantis() |>
  atlantis_load_files(
    c(
      system.file("examples", "inputs", "tiny.bgm", package = "atlantio"),
      system.file("examples", "inputs", "tiny_biol.prm", package = "atlantio"),
      system.file("examples", "inputs", "tiny_groups.csv", package = "atlantio"),
      system.file("examples", "outputs", "output.nc", package = "atlantio")
    )
  )
my_model |> create_time_series(variable = "volume", box = 5)

library(ggplot2)
my_model |>
  create_time_series(variable = "Walleye5_ResN") |>
  ggplot(aes(x = time, y = value, color = box)) +
  geom_line()
} # }
```
