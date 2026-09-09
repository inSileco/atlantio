# Parameter Hints for Atlantis Model Configuration

A list containing parameter names that are used as hints to quickly
identify the file type.

## Usage

``` r
parameters_hints
```

## Format

A named list with 2 elements:

- run:

  Character vector of run configuration parameter names:

  - `title` - Model run title/description

  - `dt` - Time step size (days)

  - `tstop` - End time of simulation (days)

  - `toutstart` - Start time for output (days)

  - `toutinc` - Output time increment (days)

  - `toutfinc` - Final output time increment (days)

- bio:

  Character vector of biology parameter names:

  - `RelTol` - Relative tolerance for numerical integration

  - `Flux_tol` - Flux tolerance threshold

  - `min_pool` - Minimum pool size

  - `min_dens` - Minimum density threshold

## Source

Generated from `inst/parameters/create_hints.R`

## Examples

``` r
data(parameters_hints)

# View hints for run files
parameters_hints$run
#> [1] "title"     "dt"        "tstop"     "toutstart" "toutinc"   "toutfinc" 

# View hints for biology files
parameters_hints$bio
#> [1] "RelTol"   "Flux_tol" "min_pool" "min_dens"
```
