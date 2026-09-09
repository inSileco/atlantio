# atlantio

Read, write and manipulate
[Atlantis](https://research.csiro.au/atlantis/) model inputs and
outputs. `atlantio` provides an S7 class `Atlantis` that represents an
Atlantis model, functions to read and write Atlantis files, and methods
to extract diet tables, food webs and time series from a model.

## Installation

`atlantio` is not on CRAN yet. Install the development version from
GitHub with [pak](https://pak.r-lib.org/):

``` r

# install.packages("pak")
pak::pak("inSileco/atlantio")
```

## Usage

``` r

library(atlantio)
mod <- new_atlantis() |>
  atlantis_load_files(c(
    atlantis_examples("outputs", "output.nc"),
    atlantis_examples("outputs", "outputBiomIndx.txt"),
    atlantis_examples("outputs", "outputBoxBiomass.txt")
  ))
mod

# ── Atlantis Model ──
# 
# ── Data availability: 
# ✖ Geometry (BGM)
# ✖ Run file
# ✖ Biology parameters
# ✖ Group file
# ✔ Main output
# ✖ Diet data
# ✖ Detailed diet data
# ✔ Biomass (system-wide)
# ✔ Biomass (per box)
# ✖ Biomass (per age)
# 
# ── Main output details: 
# • 139 variables
# • 74 time steps
```

See the package vignettes for details on reading models, listing
parameters and calibration workflows.

## License

MIT
