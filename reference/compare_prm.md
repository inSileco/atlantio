# Compare two Atlantis parameter files

Compares two parameter files by parameter name rather than line by line,
so that moved lines, comments and layout do not show up: one row per
value that differs, per parameter only in one of the files, and per
position only in one of the arrays when their lengths differ. Numbers
are compared as numbers (`1.0` and `1` are equal).

## Usage

``` r
compare_prm(x, y)
```

## Arguments

- x, y:

  Two parameter files: paths, or lists as returned by
  [`read_prm()`](https://insileco.io/atlantio/reference/read_prm.md)
  (e.g. the `biology` property of an Atlantis object).

## Value

A data frame with columns `key`, `position` (`NA` for a parameter only
in one file), `x` and `y` (the values as text, `NA` where missing).

## See also

[`write_parameter_folder()`](https://insileco.io/atlantio/reference/write_parameter_folder.md)

## Examples

``` r
bio <- read_prm(atlantis_examples("inputs", "tiny_biol.prm"))
new <- bio
new$mum_GZS[2] <- 0.004
new$flagnew <- 1
compare_prm(bio, new)
#>       key position           x     y
#> 1 mum_GZS        2 0.003063438 0.004
#> 2 flagnew       NA        <NA>     1
```
