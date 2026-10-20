# Apply a set of calibrated values to an Atlantis object

Sets the values of a calibration table, e.g. the parameters of the best
run of a calibration, in the parameter files loaded in an Atlantis
object. Each row of `calib_table` names a parameter (`name`), a position
in it (`position`), its file (`source_file`) and, for values on the
calibration scale, its transformation (`transf`).

## Usage

``` r
apply_parameters(x, calib_table, par, scale = c("calibration", "model"))
```

## Arguments

- x:

  An `Atlantis` object with the parameter files of `calib_table` loaded.

- calib_table:

  A calibration table, as returned by
  [`generate_calibration_table()`](https://insileco.io/atlantio/reference/generate_calibration_table.md).

- par:

  The values, one per row of `calib_table`.

- scale:

  Scale of `par`: `"calibration"` (default), the scale the optimizer
  works on, mapped to the file scale with
  [`transform_parameter_value()`](https://insileco.io/atlantio/reference/transform_parameter_value.md),
  or `"model"`, the values as written in the parameter files.

## Value

`x` with the values set.

## See also

[`write_parameter_folder()`](https://insileco.io/atlantio/reference/write_parameter_folder.md)
to write the files,
[`compare_prm()`](https://insileco.io/atlantio/reference/compare_prm.md)
to compare them.

## Examples

``` r
mod <- new_atlantis() |>
  atlantis_load_files(c(
    atlantis_examples("inputs", "tiny_biol.prm"),
    atlantis_examples("inputs", "tiny_groups.csv")
  ))
tbl <- generate_calibration_table(
  mod,
  atlantis_examples("calibrate", "mum.yaml")
)
# every value one tenth of its current value
mod <- apply_parameters(mod, tbl, log10(tbl$cur_value) - 1)
mod@biology$mum_GZS
#> [1] 0.0036549944 0.0003063438 0.0001678270 0.0000717670 0.0000475500
#> attr(,"comments")
#> [1] "Vertebrate growth rates for each group, per age class mg N d-1"
#> [2] "yzhao oce 25, 2022"                                            
#> attr(,"array_length")
#> [1] 5
```
