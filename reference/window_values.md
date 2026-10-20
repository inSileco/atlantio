# Values of a series scored over the last years of a run

Reduces one model series (one group x age class x tracer, or the biomass
of one group) to the values the objective of
[`score_table()`](https://insileco.io/atlantio/reference/score_table.md)
compares with the initial value, over a window covering the last `years`
years of the run (365-day model years, ending at the last output step).
The initial step (t = 0) is never part of the window's statistics.

## Usage

``` r
window_values(time, value, stat = "snapshot", years = 2)
```

## Arguments

- time:

  Output times (seconds).

- value:

  Values of the series at `time`.

- stat:

  Statistic over the window: `"snapshot"`, `"mean"`, `"median"`,
  `"min"`, `"max"`, or a function of the window values.

- years:

  Length of the window in years, counted back from the last output step.

## Value

A numeric vector of the scored values: one per snapshot for
`"snapshot"`, one value for the other statistics.

## Details

- `"snapshot"`: the output steps closest to the whole-year anniversaries
  of t = 0 falling in the window, one value per year. Sampling the
  anniversaries keeps the comparison at the phase of the seasonal cycle
  of the initial values, but a spiky series (phytoplankton blooms) then
  depends on whether an anniversary hits a bloom.

- `"mean"`, `"median"`, `"min"`, `"max"`: one value, that statistic over
  every output step in the window. The mean averages out blooms and
  seasonal cycles; `min`/`max` score the worst trough or peak.

- a function: applied to the values in the window, and may return one or
  several values (e.g. `\(x) stats::quantile(x, c(0.1, 0.9))`).

## Examples

``` r
time <- seq(0, 10 * 365 * 86400, by = 30 * 86400)
value <- 1 + 0.5 * sin(2 * pi * time / (365 * 86400))
window_values(time, value, "snapshot")
#> [1] 0.9143534 0.8723234
window_values(time, value, "mean", years = 5)
#> [1] 0.9998222
window_values(time, value, \(x) stats::quantile(x, c(.1, .9)))
#> [1] 0.5219887 1.4780113
```
