# Write a complete Atlantis parameter folder

Writes the input files of an Atlantis object into a folder, e.g. to
build the parameter folder of the next calibration round from the
previous one and the calibrated values (see
[`apply_parameters()`](apply_parameters.md)).

## Usage

``` r
write_parameter_folder(x, dir, from = NULL, overwrite = FALSE)
```

## Arguments

- x:

  An `Atlantis` object.

- dir:

  The folder to write, created if needed.

- from:

  A folder to copy into `dir` first, or `NULL`.

- overwrite:

  Allow `dir` to hold files already?

## Value

Invisibly, a data frame of the values changed, one row per value:
`file`, `key`, `position`, `old` and `new` (as written in the files).

## Details

The run and biology parameter files are written from their source file
with only the values that differ from it changed, token by token: the
comments, the units (e.g. `tstop 365 day`, which
[`write_prm()`](read_prm.md) would turn into 365 seconds), the layout
and the line endings are kept. The other input files loaded (geometry,
groups, initial conditions, ...) are copied. Every file keeps the name
of its source.

Files that are not loaded in `x`, such as the physics and forcing
parameter files or the forcing time series, come from `from`: a folder
copied whole into `dir` first, whose files are then replaced by those of
`x`.

## See also

[`apply_parameters()`](apply_parameters.md),
[`compare_prm()`](compare_prm.md) to compare two parameter files.

## Examples

``` r
mod <- new_atlantis() |>
  atlantis_load_files(c(
    atlantis_examples("inputs", "tiny_run.prm"),
    atlantis_examples("inputs", "tiny_biol.prm"),
    atlantis_examples("inputs", "tiny_groups.csv")
  ))
#> Warning: 8 Unknown parameters: flagratio_warn, K_max_num_zoning, N_to_C, N_to_P,
#> flag_contam_sanity_check, external_box, trackWind, and flag_contamReprodModel
mod@biology$mum_GZS[1] <- 0.04
dir <- file.path(tempdir(), "params_v2")
write_parameter_folder(mod, dir)
#> ✔ 3 input files written to /tmp/RtmpM953Io/params_v2,
#> 1 value changed.
list.files(dir)
#> [1] "tiny_biol.prm"   "tiny_groups.csv" "tiny_run.prm"   
```
