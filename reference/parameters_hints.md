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

  - `dt` - Time step

  - `tstop` - End time of simulation

  - `toutstart` - Start time for output

  - `toutinc` - Output time increment

  - `toutfinc` - Fisheries output time increment

  The times are in seconds, unless a unit follows the value.

- bio:

  Character vector of biology parameter names:

  - `RelTol` - Relative tolerance for numerical integration

  - `Flux_tol` - Flux tolerance threshold

  - `min_pool` - Minimum pool size

  - `min_dens` - Minimum density threshold

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
