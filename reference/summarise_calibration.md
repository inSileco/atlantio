# Summarise the parameter values of a calibration

Summarises, for every parameter value of a calibration table, the values
tried by the calibration runs: what the best runs agree on, which
parameters are pushed against their bounds, where the runs that failed
went, and how the values moved from one generation to the next.

## Usage

``` r
summarise_calibration(
  runs,
  calib_table,
  n_best = 5,
  n_top = 20,
  relative = NULL,
  bound_tol = 0.01
)
```

## Arguments

- runs:

  The runs: a data frame as returned by
  [`read_calibration_runs()`](read_calibration_runs.md), or the folder
  to read them from.

- calib_table:

  The calibration table of the runs, as returned by
  [`generate_calibration_table()`](generate_calibration_table.md).

- n_best:

  Number of best runs whose range is given.

- n_top:

  Number of best runs whose median, and the number at a bound, are
  given.

- relative:

  Report the parameters as factors of their starting value? `NULL`
  (default) to decide per parameter as described above, `TRUE` or
  `FALSE` for all, or one value per row of `calib_table`.

- bound_tol:

  A value counts as at a bound when it is closer to it than this
  fraction of the search range (calibration scale).

## Value

A list of three data frames:

- `parameters`: one row per row of `calib_table` with `name`,
  `position`, `start` (starting value), `scale` (`"factor"` or
  `"value"`), `best` (best run), `low` and `high` (range of the `n_best`
  best runs), `median` (median of the `n_top` best runs), `at_bound`
  (number of the `n_top` best runs at a bound) and `failed_shift` (mean
  value of the failed runs minus that of the completed runs, calibration
  scale; `NA` without failed runs);

- `generations`: per generation and parameter, the `median` of the
  `n_best` best completed runs of the generation, on the scale of
  `parameters`;

- `scores`: per generation, the number of `runs`, of `failed` runs, and
  the `best` and `median` scores of the completed runs.

## Details

The runs are ranked by score among those that completed. The values are
reported on the model scale, either as they are (`"value"`) or as a
factor of the starting value (`cur_value` of `calib_table`, `"factor"`).
By default, a parameter is reported as a factor when its starting value
lies within its bounds, and as a value otherwise (e.g. a rate started at
a placeholder `1e-12` below its search range). The statistics are
computed on the calibration scale and then mapped to the model scale.

## See also

[`read_calibration_runs()`](read_calibration_runs.md),
[`apply_parameters()`](apply_parameters.md) to apply the values of a
run.

## Examples

``` r
if (FALSE) { # \dontrun{
tbl <- generate_calibration_table(mod, "calibration.yaml")
res <- summarise_calibration("calibration_results", tbl)
res$parameters
} # }
```
