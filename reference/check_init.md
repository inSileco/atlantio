# Check an Atlantis initial-conditions file

Lists the values of an initial-conditions file that Atlantis will read
wrongly, or that are likely mistakes. Only the cells Atlantis uses are
checked: the water layers of each box (`numlayers`) and the sediment
layers, for the tracers that exist there (attributes `inwc` and `insed`;
both cell types when neither is set, as for vertebrates).

## Usage

``` r
check_init(path, groups = NULL, ratio = 100)
```

## Arguments

- path:

  Path to the initial-conditions netCDF file.

- groups:

  The functional groups: a data frame with columns `Code`, `Name`,
  `IsTurnedOn`, `NumCohorts` and `GroupType` (e.g. the `group` property
  of an Atlantis object) or the path to the groups CSV file. If `NULL`,
  the checks that need the groups are skipped.

- ratio:

  Fold difference with the sister groups above which a pool is reported.

## Value

An `atlantis_check` data frame, one row per finding, with columns
`file`, `check`, `severity` (`"error"`, `"warning"` or `"note"`), `key`
(the variable) and `message`.

## Details

The checks (column `check` of the result) are:

- `"invalid"` (error): NaN or infinite values;

- `"negative"` (error): negative values;

- `"unset"` (warning): cells left unset (read as `NA`) in a variable
  whose `_FillValue` is not 0, so that Atlantis silently uses the fill
  value there (e.g. 2000 mg N m-3 of refractory detritus), unless every
  value set equals the fill value;

- `"missing"` (error): a group switched on in the groups file with no
  variable in the file;

- `"zero"`: a group switched on but with no biomass or no individual
  anywhere (warning), or an age class with individuals but a `StructN`
  or `ResN` of 0 (error);

- `"sisters"` (warning): a biomass pool whose typical value (median of
  its non-zero cells) is more than `ratio` times larger or smaller than
  the median of the groups of the same type (`GroupType`, the detritus
  types together) and units, or than the other group if there are only
  two.

The last three need `groups`. Values unset are taken as Atlantis takes
them, i.e. equal to their fill value.

## See also

[`check_prm()`](check_prm.md) for the parameter files,
[`set_init_values()`](set_init_values.md) to change values.

## Examples

``` r
if (FALSE) { # \dontrun{
check_init("LakeErieInit_NP.nc", "LakeErieGroupsDem.csv")
} # }
```
