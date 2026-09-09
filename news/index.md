# Changelog

## atlantio 0.1.2

- Move sf to Suggests.

## atlantio 0.1.1

- Add calibrar script.

## atlantio 0.1.0

- Initial version. The input/output functionalities of the `calypso`
  package have been extracted into this package; the Shiny application
  now lives in `calypso`, which builds on top of `atlantio`.
- Includes:
  - [`list_atlantis_parameters()`](../reference/list_atlantis_parameters.md)
    that returns the list of Atlantis parameters for a supported
    Atlantis version (see the new dataset
    `atlantis_supported_versions`);
  - the S7 class `Atlantis` that represents an Atlantis model, with the
    constructor [`new_atlantis()`](../reference/new_atlantis.md) and the
    loader
    [`atlantis_load_files()`](../reference/atlantis_load_files.md);
  - reading functions for Atlantis files:
    [`read_atlantis_files()`](../reference/read_atlantis_files.md),
    [`read_bgm()`](../reference/read_atlantis_files.md),
    [`read_nc()`](../reference/read_atlantis_files.md),
    [`read_prm()`](../reference/read_prm.md),
    [`read_prm_files()`](../reference/read_atlantis_files.md),
    [`read_group_file()`](../reference/read_atlantis_files.md),
    [`read_txt_files()`](../reference/read_atlantis_files.md),
    [`read_xml()`](../reference/read_atlantis_files.md);
  - a prm writer: [`write_prm()`](../reference/read_prm.md);
  - parameter file generation with
    [`generate_file()`](../reference/generate_file.md) (run file only);
  - S7 methods for `Atlantis` objects:
    [`print()`](https://rdrr.io/r/base/print.html),
    [`create_diet_table()`](../reference/create_diet_table.md),
    [`create_foodweb()`](../reference/create_foodweb.md),
    [`create_time_series()`](../reference/create_time_series.md),
    [`create_time_series_biomass()`](../reference/create_time_series_biomass.md),
    [`generate_calibration_table()`](../reference/generate_calibration_table.md).
