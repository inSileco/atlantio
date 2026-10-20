# Aggregate age-structured tracers over boxes and layers

Reduces a tracer table with one row per group x age x box x layer x time
(the table of
[`create_time_series_biomass()`](https://insileco.io/atlantio/reference/create_time_series_biomass.md))
to one row per group x age x time: `Nums` summed, `StructN` and `ResN`
as Nums-weighted means, i.e. the condition of the average individual.
Empty cells do not count, and a cohort with no individual left gets 0,
so a collapse also shows in its condition. A `weight` column is summed
and a `units` column kept. A table without `box` or `layer` column is
returned as is.

## Usage

``` r
aggregate_time_series(ts)
```

## Arguments

- ts:

  Tracer table with columns `group`, `age`, `time`, `StructN`, `ResN`
  and `Nums`, and optionally `box`, `layer`, `weight` and `units`.

## Value

A data frame with one row per `group` x `age` x `time` and the columns
`StructN`, `ResN` and `Nums` (and `weight` and `units` when `ts` has
them).

## Examples

``` r
ts <- data.frame(
  group = "Walleye", age = 1, time = 0, box = 1:2, layer = 1,
  StructN = c(100, 200), ResN = c(300, 600), Nums = c(1, 3)
)
aggregate_time_series(ts)
#>     group age time StructN ResN Nums
#> 1 Walleye   1    0     175  525    4
```
