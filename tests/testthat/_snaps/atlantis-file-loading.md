# atlantis_load_files() says why a file cannot be read

    Code
      res <- suppressMessages(atlantis_load_files(new_atlantis(), c("bad.prm",
        "run.prm")))
    Condition
      Warning:
      Cannot read 'bad.prm'.
      x Dimension mismatch for array `arr`: 3 elements expected, but 2 available.
      Warning:
      Cannot read 'run.prm'.
      x 1 Parameter missing: verbose

# get_biomass_by_type() returns every biomass table

    Code
      get_biomass_by_type(mod, "biomass_annual")
    Condition
      Error in `get_biomass_by_type()`:
      ! `bm_type` must be one of "biomass_all", "biomass_box", "biomass_age", or "biomass_age_annual", not "biomass_annual".
      i Did you mean "biomass_age_annual"?

# atlantis_load_files() warns once about a missing file

    Code
      res <- atlantis_load_files(new_atlantis(), "nope.prm")
    Condition
      Warning:
      nope.prm does not exist.

# atlantis_load_files() aborts on an invalid input

    Code
      atlantis_load_files(new_atlantis(), 1)
    Condition
      Error in `atlantis_load_files()`:
      ! `files` must be file paths or an <atlantis_file> object.

