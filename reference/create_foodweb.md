# Create a food web

Builds the binary food web of a model from its diet table (see
[`create_diet_table()`](https://insileco.io/atlantio/reference/create_diet_table.md)):
a predator eats a prey when any of their `pPREY` values, whatever the
stages, is positive.

## Usage

``` r
create_foodweb(x)
```

## Arguments

- x:

  An `Atlantis` object with the biology and groups files loaded.

## Value

A directed igraph object with one vertex per group (and per detritus in
the sediment) and an edge, of `weight` 1, from each predator to each of
its prey.
