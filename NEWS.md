# atlantio 0.0.0.9001

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
      `create_time_series_biomass()`.
