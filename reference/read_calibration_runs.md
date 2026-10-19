# Read the parameter values of calibration runs

Collects the `parameters.rds` files that the calibration runs leave in
their folders: one list per run with the values tried on the calibration
scale (`par`) and on the model scale (`par_model`), the `score`, whether
the run `failed` and, for failed runs, the `reason`. The names of `par`
are `<name>.<position>`, as in the rows of the calibration table.

## Usage

``` r
read_calibration_runs(dir, pattern = "parameters.rds")
```

## Arguments

- dir:

  The folder holding one subfolder per run.

- pattern:

  Name of the files to read.

## Value

A data frame with one row per run and parameter value: `run` (the folder
name), `generation`, `score`, `failed`, `reason`, `name`, `position`,
`value` (calibration scale) and `value_model`.

## Details

The generation of a run is read from its folder name when it starts with
`gen<number>_` (e.g. `gen003_atlantis_run_...`), `NA` otherwise.

## See also

[`summarise_calibration()`](summarise_calibration.md)
