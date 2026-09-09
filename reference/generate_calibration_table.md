# Generate a calibration table

S7 generic for building the list of parameters to calibrate from a YAML
specification file.

## Usage

``` r
generate_calibration_table(x, ...)
```

## Arguments

- x:

  An `Atlantis` object.

- ...:

  Additional arguments passed to methods

## Value

A list of data frames, one per parameter entry, with columns `name`,
`min`, `max`, `position`, `transf` and `source_file`.

## Examples

``` r
if (FALSE) { # \dontrun{
mod  <- new_atlantis() |>
  atlantis_load_files(c(
    atlantis_examples("inputs", "tiny.bgm"),
    atlantis_examples("inputs", "tiny_biol.prm"),
    atlantis_examples("inputs", "tiny_groups.csv")
  ))
mod |>
  generate_calibration_table(
   atlantis_examples("calibrate", "mum.yaml")
 )
} # }
```
