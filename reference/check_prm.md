# Check Atlantis parameter files

Lists the problems of Atlantis parameter files that Atlantis reads
silently (or reads differently from [`read_prm()`](read_prm.md)), and
combinations of flags known to give wrong results. The files are scanned
line by line, so a malformed array does not stop the other checks (it
does stop [`read_prm()`](read_prm.md)).

## Usage

``` r
check_prm(bio = NULL, run = NULL, force = NULL)
```

## Arguments

- bio, run, force:

  Paths to the biology, run and forcing parameter files; any can be
  `NULL`. The time series of the forcing file are read relative to its
  folder.

## Value

An `atlantis_check` data frame, one row per finding, with columns
`file`, `check`, `severity` (`"error"`, `"warning"` or `"note"`), `key`
(the variable) and `message`.

## Details

The checks on every file (column `check` of the result) are:

- `"count"` (error): an array whose declared length differs from the
  number of values on the next line; Atlantis pads with the last value
  or ignores the extra values, [`read_prm()`](read_prm.md) aborts;

- `"duplicate"` (warning): a key given twice;

- `"line_endings"` (warning): Windows (CRLF) line endings;

- `"tabs"` (note): tabs as separators;

- `"units"` (note): time units after values (e.g. `dt 12 hour`);
  Atlantis converts them, [`read_prm()`](read_prm.md) keeps the numbers
  only;

- `"unknown"` (note): keys of the run file missing from the run
  template.

And the checks across files, which need `bio` (and `force` for the last
one), for every group stocked (`flagstocking<GRP> 1` or
`flagrecruit<GRP> 18`, both read from the `MultRects` time series):

- `"stocked_twice"` (error): `flagstocking<GRP> 1` with
  `flagrecruit<GRP> 18`, which adds the series twice;

- `"random_spawn"` (warning): `flagrandom 1`, which moves the spawn day
  by up to 14 days, while groups are stocked: the series is read on the
  spawn day only;

- `"spawn_day"`: years whose stocking is never read because no non-zero
  value falls on the group's spawn day (`<GRP>_Time_Spawn`, on a 365-day
  year); error if no stocking is delivered at all, warning otherwise.
  The time series are assumed to start with the run.

## See also

[`check_init()`](check_init.md) for the initial-conditions file.

## Examples

``` r
if (FALSE) { # \dontrun{
check_prm(bio = "le_bio.prm", run = "le_run.prm", force = "le_force.prm")
} # }
```
