# atlantio 0.2.0

* `generate_calibration_table()` supports `is_factor`, when `true`, `min` and 
  `max`are interpreted relative to the current value of the parameter rather than as absolute bounds.
* `atlantis_load_files()` no longer drops files when several files of the same
  type are passed, and skips files of unsupported type (e.g. `unknown`,
  `xml_file`) with a warning instead of erroring.
* `read_txt_files()` classifies `DietCheck` outputs as `diet` and
  `DetailedDietCheck` outputs as `diet_detailed`, and always returns a type.
* `create_time_series_biomass()` now detects all cohorts of groups with 10 or
  more age classes (the cohort index was truncated to its last digit).
* `generate_calibration_table()` no longer errors on `per_box` parameters.
* `require_valid_group()` reports only the groups that are missing or turned
  off, instead of all groups passed.
* Move sf to Suggests.
* Add calibrar script.


# atlantio 0.1.0

* Initial version. The input/output functionalities of the `calypso` package
  have been extracted into this package; the Shiny application now lives in
  `calypso`, which builds on top of `atlantio`.
* Includes:
    - `list_atlantis_parameters()` that returns the list of Atlantis
      parameters for a supported Atlantis version (see the new dataset
      `atlantis_supported_versions`);
    - the S7 class `Atlantis` that represents an Atlantis model, with the
      constructor `new_atlantis()` and the loader `atlantis_load_files()`;
    - reading functions for Atlantis files: `read_atlantis_files()`,
      `read_bgm()`, `read_nc()`, `read_prm()`, `read_prm_files()`,
      `read_group_file()`, `read_txt_files()`, `read_xml()`;
    - a prm writer: `write_prm()`;
    - parameter file generation with `generate_file()` (run file only);
    - S7 methods for `Atlantis` objects: `print()`, `create_diet_table()`,
      `create_foodweb()`, `create_time_series()`,
      `create_time_series_biomass()`, `generate_calibration_table()`.
