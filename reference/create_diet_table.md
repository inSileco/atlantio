# Create Diet Table

Generic function for creating diet tables from model data.

## Usage

``` r
create_diet_table(x, ...)
```

## Arguments

- x:

  Object containing diet/bio data

- ...:

  Additional arguments

## Value

A data.frame representing the diet table with predator-prey
relationships

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

- pPREY1XXX1: juvenile-juvenile

- pPREY1XXX2: juvenile-adult

- pPREY2XXX1: adult-juvenile

- pPREY2XXX2: adult-adult where XXX denotes the code for the prey
  species. Note that the realised diet in Atlantis will depend on other
  factor, for instance the coeficient `mum`, assuming it is used by the
  functional response (see `predcase_XXXX`).

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
```
