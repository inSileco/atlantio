# Read the biomass of the living groups from the Atlantis biomass index

Reads the biomass index Atlantis writes (`<output>BiomIndx.txt`: biomass
of every group over the whole model domain, in tonnes, `Time` in days)
and keeps the living groups, i.e. every group but the detritus
(`GroupType` `LAB_DET`, `REF_DET` and `CARRION`). Groups are named by
the `Name` column of the groups file, as in the tables of
[`create_time_series_biomass()`](create_time_series_biomass.md).

## Usage

``` r
read_biomass_index(path, groups)
```

## Arguments

- path:

  Path to the biomass index file.

- groups:

  The functional groups: a data frame with columns `Code`, `Name` and
  `GroupType` (e.g. the `group` property of an Atlantis object) or the
  path to the groups CSV file.

## Value

A data frame with columns `group`, `time` (seconds) and `Biomass`
(tonnes).
