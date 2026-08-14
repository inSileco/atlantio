# atlantio
<!-- badges: start -->
[![R-CMD-check](https://github.com/inSileco/atlantio/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/inSileco/atlantio/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Read, write and manipulate [Atlantis](https://research.csiro.au/atlantis/) model
inputs and outputs. `atlantio` provides an S7 class `Atlantis` that represents
an Atlantis model, functions to read and write Atlantis files, and methods to
extract diet tables, food webs and time series from a model.

## Installation

`atlantio` is not on CRAN yet. Install the development version from GitHub with
[pak](https://pak.r-lib.org/):

```r
# install.packages("pak")
pak::pak("inSileco/atlantio")
```

## Usage

```r
library(atlantio)
```

See the package vignettes for details on reading models, listing parameters and
calibration workflows.

## License

MIT
