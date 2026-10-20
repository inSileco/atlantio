# Set the values of a variable of an Atlantis initial-conditions file

Writes values per box (and per layer for a 3D variable) into a variable
of an initial-conditions file, leaving the other cells as they are.
Boxes are numbered from 0 as in Atlantis, layers are the index of the
`z` dimension from 1: the water layers from 1 to `numlayers` of the box,
then the sediment layers (the first one is `wcnz + 1`).

## Usage

``` r
set_init_values(path, variable, values, file = path)
```

## Arguments

- path:

  Path to the initial-conditions netCDF file.

- variable:

  Name of the variable.

- values:

  A data frame with columns `box`, `value` and, for a 3D variable,
  `layer`.

- file:

  Path of the file written: `path` itself (the default) or a copy of it.

## Value

`file`, invisibly.

## See also

[`check_init()`](https://insileco.io/atlantio/reference/check_init.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# 30 mg N m-3 of refractory detritus in the surface layer of boxes 1 and 2
set_init_values(
  "init.nc",
  "Refractory_detritus_N",
  data.frame(box = 1:2, layer = 1, value = 30),
  file = "init_new.nc"
)
} # }
```
