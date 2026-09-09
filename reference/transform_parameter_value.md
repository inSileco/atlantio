# Transform a parameter value

Apply a transformation function to a parameter value. This is used to
map calibrated values back to their natural scale, e.g. when a parameter
is calibrated on a log scale.

## Usage

``` r
transform_parameter_value(x, fun)
```

## Arguments

- x:

  A numeric vector of parameter values, or `NULL`.

- fun:

  A string naming the transformation to apply. One of `"identity"`,
  `"pow10"` (`10^x`), `"pow2"` (`2^x`) or `"exp"` (`exp(x)`).

## Value

The transformed values, or `NULL` if `x` is `NULL`.

## Examples

``` r
transform_parameter_value(2, "pow10")
#> [1] 100
transform_parameter_value(c(1, 2, 3), "pow2")
#> [1] 2 4 8
transform_parameter_value(0.5, "identity")
#> [1] 0.5
```
