# Check that an Atlantis run completed

Atlantis ends a fatal error with
[`quit()`](https://rdrr.io/r/base/quit.html), which prints the error to
stderr and exits with status 0, leaving the output written so far. The
exit status therefore does not tell a completed run from a crashed one:
only the time reached by the main output does. A run counts as complete
if the last time step of its main output is within one output interval
(`toutinc`) of the end of the run (`tstop`).

## Usage

``` r
check_run(output, run)
```

## Arguments

- output:

  Path to the main netCDF output of the run (e.g. `output.nc`).

- run:

  Path to the run parameter file of the run.

## Value

An `atlantis_check` data frame, one row per finding, with columns
`file`, `check`, `severity` (`"error"`, `"warning"` or `"note"`), `key`
(the variable) and `message`.

## Details

The checks (column `check` of the result) are:

- `"missing"` (error): no main output, the run failed before writing it;

- `"unreadable"` (error): the main output cannot be opened;

- `"incomplete"` (error): the main output stops before `tstop`.

`tstop` and `toutinc` are read with their units as Atlantis reads them
(e.g. `tstop 365 day`; a bare number is in seconds).

## See also

[`check_prm()`](check_prm.md) for the parameter files.

## Examples

``` r
check_run(
  system.file("examples", "outputs", "output.nc", package = "atlantio"),
  system.file("examples", "inputs", "tiny_run.prm", package = "atlantio")
)
#> ✔ No problem found.
```
