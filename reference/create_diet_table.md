# Create a diet table

Collects the prey availabilities (`pPREY` parameters) of the biology
file in a table.

## Usage

``` r
create_diet_table(x)
```

## Arguments

- x:

  An `Atlantis` object with the biology file loaded; the groups file
  gives the column names.

## Value

A data frame with one row per `pPREY` key (a predator and the stages of
prey and predator) and one column per prey: the groups, then the
detritus in the sediment (`DLsed`, `DRsed`, `DCsed`).

## Details

In Atlantis model, the availability of prey is determined by the product
of the prey biomass and the prey choice coefficient `pPREY`. The latter
is a proportion (between 0 and 1) of prey biomass actually available to
the predator. The function finds this information in the model and
creates the diet table that is the collection of the pPREY values.

Atlantis distinguishes prey choice values for juveniles and adults. The
distinction exists if species have ontogenetic stages and if the flag
`age_structured_prey_XXX` is set to one. Note that for those species the
first mature age group is given by `XXX_age_mat`. Therefore there are up
to 4 `pPREY` values per prey-predator combination:

- pPREY1XXX1: juvenile prey, juvenile predator

- pPREY1XXX2: juvenile prey, adult predator

- pPREY2XXX1: adult prey, juvenile predator

- pPREY2XXX2: adult prey, adult predator where XXX denotes the code of
  the predator. Note that the realised diet in Atlantis will depend on
  other factors, for instance the coefficient `mum`, assuming it is used
  by the functional response (see `predcase_XXXX`).

## References

- Asta Audzijonyte, Rebecca Gorton, Isaac Kaplan, Jacob M. Kasper,
  Elizabeth A. Fulton, 2025. Atlantis User’s Guide Part I: General
  Overview, Physics & Ecology
  <https://research.csiro.au/atlantis/wp-content/uploads/sites/52/2025/05/AtlantisUserGuide_PartI.pdf>

## Examples

``` r
my_model <- new_atlantis() |>
  atlantis_load_files(
    c(
      system.file("examples", "inputs", "tiny.bgm", package = "atlantio"),
      system.file("examples", "inputs", "tiny_biol.prm", package = "atlantio"),
      system.file("examples", "inputs", "tiny_groups.csv", package = "atlantio")
    )
  )
create_diet_table(my_model)
#>              WAE  YPH  GZS  RDG  DRE  CHI   DIA   GRN   CAL   ROT    PB    BB
#> pPREY1GZS1 0.000 0.00 0.00 0.00 0.00 0.05 0e+00 0e+00 0.005 0.005 0e+00 0e+00
#> pPREY2GZS1 0.000 0.00 0.00 0.00 0.00 0.05 0e+00 0e+00 0.005 0.005 0e+00 0e+00
#> pPREY1GZS2 0.000 0.00 0.00 0.00 0.00 0.00 5e-02 5e-02 0.001 0.000 0e+00 0e+00
#> pPREY2GZS2 0.000 0.00 0.00 0.00 0.00 0.00 5e-02 5e-02 0.001 0.000 0e+00 0e+00
#> pPREY1WAE1 0.001 0.10 0.10 0.10 0.00 0.10 0e+00 0e+00 0.010 0.010 0e+00 0e+00
#> pPREY2WAE1 0.000 0.00 0.01 0.00 0.00 0.10 0e+00 0e+00 0.010 0.010 0e+00 0e+00
#> pPREY1WAE2 0.050 0.10 0.10 0.10 0.05 0.10 0e+00 0e+00 0.000 0.000 0e+00 0e+00
#> pPREY2WAE2 0.000 0.00 0.10 0.10 0.00 0.10 0e+00 0e+00 0.000 0.000 0e+00 0e+00
#> pPREY1RDG1 0.000 0.00 0.00 0.00 0.02 0.30 0e+00 0e+00 0.010 0.010 0e+00 1e-02
#> pPREY2RDG1 0.000 0.00 0.00 0.00 0.00 0.30 0e+00 0e+00 0.000 0.000 0e+00 1e-02
#> pPREY1RDG2 0.000 0.00 0.00 0.00 0.30 0.30 0e+00 0e+00 0.000 0.000 0e+00 0e+00
#> pPREY2RDG2 0.000 0.00 0.00 0.00 0.30 0.30 0e+00 0e+00 0.000 0.000 0e+00 0e+00
#> pPREY1YPH1 0.000 0.00 0.00 0.00 0.01 0.20 0e+00 0e+00 0.010 0.010 0e+00 0e+00
#> pPREY2YPH1 0.000 0.00 0.00 0.00 0.00 0.20 0e+00 0e+00 0.010 0.010 0e+00 0e+00
#> pPREY1YPH2 0.010 0.01 0.00 0.01 0.01 0.20 0e+00 0e+00 0.050 0.050 0e+00 0e+00
#> pPREY2YPH2 0.000 0.00 0.00 0.00 0.01 0.20 0e+00 0e+00 0.050 0.050 0e+00 0e+00
#> pPREYDRE   0.000 0.00 0.00 0.00 0.00 0.00 5e-04 5e-04 0.001 0.001 5e-04 5e-04
#> pPREYCHI   0.000 0.00 0.00 0.00 0.00 0.00 0e+00 0e+00 0.000 0.000 1e-01 1e-01
#> pPREYCAL   0.000 0.00 0.00 0.00 0.00 0.00 2e-01 2e-01 0.000 0.000 1e-01 1e-01
#> pPREYROT   0.000 0.00 0.00 0.00 0.00 0.00 2e-01 2e-01 0.000 0.000 1e-01 1e-01
#>               DL    DR    DC DLsed DRsed DCsed
#> pPREY1GZS1 0e+00 0e+00 0e+00  0.00  0.00  0.00
#> pPREY2GZS1 0e+00 0e+00 0e+00  0.00  0.00  0.00
#> pPREY1GZS2 0e+00 0e+00 0e+00  0.00  0.00  0.00
#> pPREY2GZS2 0e+00 0e+00 0e+00  0.00  0.00  0.00
#> pPREY1WAE1 0e+00 0e+00 0e+00  0.00  0.00  0.00
#> pPREY2WAE1 0e+00 0e+00 0e+00  0.00  0.00  0.00
#> pPREY1WAE2 0e+00 0e+00 0e+00  0.00  0.00  0.00
#> pPREY2WAE2 0e+00 0e+00 0e+00  0.00  0.00  0.00
#> pPREY1RDG1 1e-01 1e-01 1e-01  0.00  0.00  0.00
#> pPREY2RDG1 1e-01 1e-01 1e-01  0.00  0.00  0.00
#> pPREY1RDG2 1e-01 1e-01 1e-01  0.00  0.00  0.00
#> pPREY2RDG2 1e-01 1e-01 1e-01  0.00  0.00  0.00
#> pPREY1YPH1 1e-02 1e-02 1e-02  0.00  0.00  0.00
#> pPREY2YPH1 1e-02 1e-02 1e-02  0.00  0.00  0.00
#> pPREY1YPH2 1e-02 1e-02 1e-02  0.00  0.00  0.00
#> pPREY2YPH2 1e-02 1e-02 1e-02  0.00  0.00  0.00
#> pPREYDRE   5e-04 5e-04 5e-04  0.00  0.00  0.00
#> pPREYCHI   1e-02 1e-02 1e-02  0.02  0.02  0.02
#> pPREYCAL   1e-01 1e-01 1e-01  0.00  0.00  0.00
#> pPREYROT   1e-01 1e-01 1e-01  0.00  0.00  0.00
```
