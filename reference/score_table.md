# Calibration objective: deviation from the initial state

Scores how far a model run drifts from its initial state, in the spirit
of Morell et al. (2026, Ecol. Model. 520:111688) and calibrar's
`lnorm2`. Every series – one group x age class x tracer (`Nums`,
`StructN`, `ResN`), or the biomass of one living group – is compared
with its initial (t = 0) value on the log scale, as \\log(x + tiny) -
log(x_0 + tiny)\\.

## Usage

``` r
score_table(
  ts,
  biomass = NULL,
  tolerance = 0.2,
  summary = "snapshot",
  window_years = 2,
  tiny = 0.01,
  exclude = character(),
  method = c("band", "lnorm2"),
  weight = 1,
  target_factor = 1
)

compute_score(ts, ...)
```

## Arguments

- ts:

  Tracer table with columns `group`, `age`, `time` (seconds), `StructN`,
  `ResN` and `Nums`, raw (one row per box and layer) or aggregated.

- biomass:

  Biomass table with columns `group`, `time` (seconds) and `Biomass`,
  e.g. from
  [`read_biomass_index()`](https://insileco.io/atlantio/reference/read_biomass_index.md),
  or `NULL` (default) to score the age-structured tracers only.

- tolerance:

  Half-width of the no-penalty band: one number for the three
  age-structured tracers, or a vector named by tracer (`Nums`,
  `StructN`, `ResN` and, to score `biomass`, `Biomass`).

- summary:

  Statistic each series is scored on over the window (see `stat` in
  [`window_values()`](https://insileco.io/atlantio/reference/window_values.md)):
  one for every tracer, or a vector (a list to pass functions) named by
  tracer, the tracers left out using `"snapshot"`.

- window_years:

  Length of the scoring window in years, counted back from the last
  output step.

- tiny:

  Offset keeping zero values finite on the log scale.

- exclude:

  Names of the groups left out of the score (their tracers and their
  biomass).

- method:

  `"band"` (default) penalizes the excess beyond the tolerance band,
  averaged over the scored values; `"lnorm2"` the squared log ratio to
  the target, summed over them, as Morell et al. (2026).

- weight:

  Weight of the penalty of each series: one number for every tracer, or
  a vector named by tracer, the tracers left out weighing 1. With
  `method = "lnorm2"`, a named `weight` also sets the tracers scored,
  among `Nums`, `StructN`, `ResN`, `Weight` and `Biomass`.

- target_factor:

  Factor applied to the initial value to get the target (Morell et al.'s
  \\b\\): one number for every tracer, or a vector named by tracer, the
  tracers left out using 1.

- ...:

  Arguments passed on to `score_table()`.

## Value

`score_table()`: a data frame with one row per `group` x `age` x
`tracer` and its `penalty` (`age` is `NA` for biomass).
`compute_score()`: the total score, a single number.

## Details

Each series is first reduced to its scored values over the last
`window_years` years of the run by
[`window_values()`](https://insileco.io/atlantio/reference/window_values.md),
with the statistic `summary` gives for its tracer. Scored values within
`[1 - tolerance, 1 + tolerance]` times the initial value are not
penalized; outside that band only the excess beyond the band edge is
squared, which keeps the objective continuous at the edge. The squared
excesses are averaged over the scored values of each series.
`score_table()` returns that penalty per series, `compute_score()` their
sum.

`method = "lnorm2"` scores instead the objective function of Morell et
al. (2026) as implemented in their calibration code (calibrar's
`lnorm2`, targets built from the initial state): no tolerance band, the
squared log ratio \\(log(x + tiny) - log(b x_0 + tiny))^2\\ is summed
over the scored values of each series. Its tracers are the ones `weight`
names, by default those of Morell et al.: the weight-at-age (`Weight`,
wet weight of the average individual in kg,
`(StructN + ResN) * 5.7 * 20 / 1e6`) and, when `biomass` is given, the
`Biomass`. For the unfished phase of their calibration, the biomass
target is the initial biomass times \\b = 1.3\\
(`target_factor = c(Biomass = 1.3)`).

With either method, the penalty of a series is multiplied by the
`weight` of its tracer, and the initial value by its `target_factor`.

The age-structured tracers are aggregated over boxes and layers first
(see
[`aggregate_time_series()`](https://insileco.io/atlantio/reference/aggregate_time_series.md)),
so `ts` can be the raw table of
[`create_time_series_biomass()`](https://insileco.io/atlantio/reference/create_time_series_biomass.md)
or its aggregate. Biomass series that start at zero are left out.

## References

Morell, A., et al. (2026). Ecological Modelling 520:111688.

## Examples

``` r
year <- 365 * 86400
time <- seq(0, 5 * year, by = 73 * 86400)
ts <- data.frame(
  group = "Walleye", age = 1, time = time,
  StructN = 100, ResN = 300 * exp(time / (5 * year)), Nums = 1e6
)
score_table(ts)
#> # A tibble: 3 × 4
#>   group   age   tracer  penalty
#>   <chr>   <chr> <chr>     <dbl>
#> 1 Walleye 1     StructN   0    
#> 2 Walleye 1     ResN      0.525
#> 3 Walleye 1     Nums      0    
compute_score(ts, tolerance = c(Nums = 0.5, StructN = 0.2, ResN = 0.2))
#> [1] 0.5250338
# Morell et al. (2026): weight-at-age, no band, summed squared log ratio
score_table(ts, method = "lnorm2")
#> # A tibble: 1 × 4
#>   group   age   tracer penalty
#>   <chr>   <chr> <chr>    <dbl>
#> 1 Walleye 1     Weight   0.836
```
