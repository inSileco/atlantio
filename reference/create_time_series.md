# Create Time Series for Atlantis objects

S7 generic for creating time series data from Atlantis objects

## Usage

``` r
create_time_series(x, ...)
```

## Arguments

- x:

  An object to create time series from

- ...:

  Additional arguments passed to methods

## Value

A time series data structure

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
my_model |> create_time_series(variable = "volume", box = 40)

library(ggplot2)
my_model |>
  create_time_series(variable = "Walleye5_ResN") |>
  ggplot(aes(x = Time, y = value, color = box)) +
  geom_line()
} # }
```
