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

A data frame with one row per value to calibrate and columns `name`,
`cur_value`, `min`, `max`, `position`, `transf` and `source_file`.

## Details

The YAML file is a list of entries, one per parameter, each expanded
into one row per value to calibrate. The following fields are
recognised:

- `name` (required): the parameter name, as listed in
  [`list_atlantis_parameters()`](list_atlantis_parameters.md). The name
  may contain a placeholder such as `<GRP>` (e.g. `mum_<GRP>`); the
  placeholder is then expanded over the values of an extra field of the
  same name without angle brackets (see `GRP` below). Entries without a
  placeholder (e.g. `rec_m`) yield the parameter as is.

- `position` (optional): integer index, or vector of indices, of the
  values to calibrate for array parameters (e.g. one value per cohort or
  per box). Defaults to all positions. Positions are validated against
  the dimension of the parameter when it can be computed from the loaded
  files (`scalar`, `per_group`, `per_cohort` and `per_box` parameters;
  the latter requires the geometry file). For other dimensions a warning
  is emitted and a single position is assumed.

- `transf` (optional): transformation mapping the calibration scale to
  the scale used in the parameter file, one of `"identity"` (default),
  `"pow10"`, `"pow2"` or `"exp"`, see
  [`transform_parameter_value()`](transform_parameter_value.md). A log
  scale (`pow10` or `exp`) is recommended for rate parameters spanning
  several orders of magnitude.

- `min`, `max` (optional): lower and upper bounds of the search,
  expressed on the calibration scale. With `transf: pow10`, `min: -3`
  thus means a lower bound of `0.001` in the parameter file. Default to
  `-Inf` and `Inf`.

- `is_factor` (optional, default `false`): when `true`, `min` and `max`
  are interpreted relative to the current value of the parameter rather
  than as absolute bounds. The bounds become `cur_value * transf(min)`
  and `cur_value * transf(max)` on the file scale, mapped back to the
  calibration scale. For instance, with `transf: pow10`, `min: -1` and
  `max: 1` restrict the search to one order of magnitude on each side of
  the current value, and with `transf: identity`, `min: 0.5` and
  `max: 1.5` to plus or minus 50%. This requires the current value to be
  available, i.e. the parameter file the parameter belongs to must be
  loaded in `x`.

The current value of every parameter is read from the corresponding
parameter file loaded in `x` and reported in the `cur_value` column.
When the file is not loaded, a warning is emitted and `cur_value` is
`NA` (unless `is_factor` is `true`, in which case an error is thrown).

A minimal specification looks like:

    - name: mum_<GRP>
      GRP: [GZS, RDG, WAE]
      min: -6
      max: -1
      transf: pow10
    - name: mum_<GRP>
      GRP: YPH
      position: 2
      min: -1
      max: 1
      transf: pow10
      is_factor: true
    - name: rec_m

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
