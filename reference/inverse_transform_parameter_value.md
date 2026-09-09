# Map a parameter value from the file scale back to the calibration scale

Inverse of
[`transform_parameter_value()`](transform_parameter_value.md), used to
get starting values in the space explored by the optimizer.

## Usage

``` r
inverse_transform_parameter_value(x, fun)
```

## Arguments

- x:

  A numeric vector of parameter values on the file scale, or `NULL`.

- fun:

  A string naming the transformation used during calibration. One of
  `"identity"`, `"pow10"` (inverse is `log10(x)`), `"pow2"` (inverse is
  `log2(x)`) or `"exp"` (inverse is `log(x)`).

## Value

The values mapped back to the calibration scale, or `NULL` if `x` is
`NULL`.

## Examples

``` r
inverse_transform_parameter_value(100, "pow10")
#> [1] 2
inverse_transform_parameter_value(c(2, 4, 8), "pow2")
#> [1] 1 2 3
inverse_transform_parameter_value(0.5, "identity")
#> [1] 0.5
```
