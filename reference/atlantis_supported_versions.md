# Atlantis versions supported by atlantio

Atlantis versions supported by atlantio

## Usage

``` r
atlantis_supported_versions
```

## Format

A data frame, each row includes details about one supported Atlantis
version, currently it includes two columns:

- version: Atlantis version, formatted as
  `"<major_version>-<svn_revision>"` (e.g. `"3-6722"`),

- release_date: release date of the version.

## Source

Generated from `inst/raw-data/supported_version.R`.

## See also

[`list_atlantis_parameters()`](list_atlantis_parameters.md)
