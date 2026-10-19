# atlantio (development version)

* `atlantis_load_files()` says why a file cannot be read. It said that the
  file did not exist, and reported only the first of several such files.
  Loading a run file no longer warns about the keys missing from the run
  template, which `check_prm()` reports.
* `check_run()` checks that a run completed: Atlantis exits with status 0
  after a fatal error, so a run counts as complete only if the last time step
  of its main output reaches `tstop` (within one `toutinc`), read with its
  units as Atlantis reads them.
* `create_diet_table()`, `create_foodweb()`, `create_time_series()`,
  `create_time_series_biomass()` and `generate_calibration_table()` are
  functions rather than S7 generics, so their help pages document their
  arguments. They no longer accept unused arguments.
* The help of `create_diet_table()` swapped predator and prey: its rows are
  the predators (with the stages) and its columns the prey, and the edges of
  `create_foodweb()` go from predator to prey.
* `create_time_series_biomass()` converts the nitrogen of biomass pools to wet
  weight with `X_CN` and `k_wetdry`, as for the age-structured groups. It used
  `1 + X_RS`, which made pool weights about 30 times too low.
* `create_time_series_biomass()` returns the epibenthic groups (one value per
  box, in mg N m-2), weighted by the box area of the geometry file. It
  returned no row for them.
* `create_time_series_biomass()` gains `boundary`: `boundary = FALSE` leaves
  out the boundary boxes, as Atlantis' biomass index does.
* `create_time_series_biomass()` labels biomass pools with the group name (it
  used the variable name, e.g. `Diatom_N`) and an `NA` age, and labels
  correctly the groups whose name holds a digit.
* Writing a parameter set back into a parameter folder:
    - `apply_parameters()` sets the values of a calibration table (on the
      calibration or the model scale) in the parameter files loaded in an
      Atlantis object;
    - `write_parameter_folder()` writes the input files of an Atlantis object
      into a folder, optionally on top of a copy of another folder (for the
      files not loaded, such as the physics and forcing files). The run and
      biology files are patched in place, only the values that changed, so
      their comments, units, layout and line endings are kept;
    - `compare_prm()` compares two parameter files by parameter name.
* Summarising a calibration: `read_calibration_runs()` collects the
  `parameters.rds` of every run, and `summarise_calibration()` gives, per
  parameter value, the best run, the range of the best runs and the median of
  the top runs (as factors of the starting value or as values), how many top
  runs sit at a bound, how failed runs differ from completed ones, and the
  values and scores per generation.
* The `atlantis_check` tables of `check_init()`, `check_prm()` and
  `check_run()` now print as a summary when the package is installed (the
  print method was registered on a copy of `print()` left in the namespace by
  the S7 print method of `Atlantis`).
* The vignettes cover the new functions: checking the inputs and the runs in
  Get Started, and in the calibration vignette, `check_run()` and
  `apply_parameters()` / `write_parameter_folder()` in the objective
  function, and a new step 5 summarising the runs and writing the next
  parameter folder.
* `new_atlantis()` matches property names exactly: `new_atlantis(diet_detailed
  = d)` also set `diet`.
* `read_atlantis_files()` uses `filenames` when given several files. It
  ignored them, so renamed outputs (e.g. Shiny uploads) were not recognised.
* `read_prm()` keeps the time unit after a value (e.g. `day` in
  `tstop 365 day`) as the attribute `unit`, and `write_prm()` writes it back.
  `write_prm()` wrote the number alone, which Atlantis reads in seconds.
* `read_prm()` reads arrays whose first value has a sign (e.g. `-1 2 3`).
  Such rows were skipped, so the array was read as its count.
* `score_table()` and `compute_score()` gain `method = "lnorm2"`, the
  objective function of Morell et al. (2026) as in their calibration code
  (squared log ratio to the target summed over the scored values, no band,
  on the weight-at-age and the biomass by default), and `weight` and
  `target_factor` (Morell et al.'s b) per tracer, for both methods.


# atlantio 0.3.0

* New calibration objective functions:
    - `score_table()` and `compute_score()` score how far a run drifts from
      its initial state (log ratio to t = 0, a no-penalty band per tracer,
      squared excess beyond the band), per group x age x tracer or in total,
      on the age-structured tracers and optionally on the biomass of every
      living group;
    - `window_values()` reduces a series to its scored values over the last
      years of a run (yearly snapshots or a statistic such as the mean);
    - `aggregate_time_series()` aggregates the tracer table of
      `create_time_series_biomass()` over boxes and layers (Nums summed,
      StructN and ResN weighted by Nums);
    - `read_biomass_index()` reads the biomass index of the living groups.
* `create_time_series_biomass()` gains `aggregate`: with `aggregate = TRUE`
  the series are reduced over boxes and layers while they are read, one
  cohort at a time, so the per-box table of a whole run is never held in
  memory (peak memory of a Lake Erie run roughly halved).
* `aggregate_time_series()` sums a `weight` column and keeps `units`.
* New checks of the model input files, both returning an `atlantis_check`
  table (one row per finding: file, check, severity, key, message):
    - `check_init()` checks an initial-conditions file in the cells Atlantis
      uses: NaN, negative values, cells left unset where Atlantis silently
      uses a non-zero `_FillValue`, groups switched on but empty or missing,
      and pools far from the other groups of their type;
    - `check_prm()` scans parameter files line by line (so a malformed array
      does not stop it): array counts that do not match their values,
      duplicated keys, CRLF line endings, tabs, units after values, unknown
      run keys, and the stocking traps (`flagstocking` with `flagrecruit`
      18, `flagrandom` 1 with stocking, stocking never on the spawn day).
* `set_init_values()` sets a variable of an initial-conditions file per box
  and layer from a table.


# atlantio 0.2.2

* `generate_calibration_table()` can calibrate the linear and quadratic
  mortality rates `<GRP>_mL` and `<GRP>_mQ`, now listed in the parameter
  dictionary with the new dimension `per_stage`: one value per stage, read
  from the `NumStages` column of the groups file (2 for juvenile/adult
  groups, 1 otherwise).
* The Beverton-Holt recruitment parameters `BHalpha_<GRP>` and `BHbeta_<GRP>`
  are listed in the parameter dictionary, so they can be calibrated.
* `generate_calibration_table()` expands placeholder keys of non-array type
  (e.g. `mum_<GRP>_T15`, `C_<GRP>_T15`) to a single value per key; they were
  given one position per group, all but the first with no current value.


# atlantio 0.2.1

* `generate_calibration_table()`:
    - expands names with several placeholders (only the last one was
      replaced), e.g. `pPREY<PREYCOHORT><PRED><PREDCOHORT>`;
    - gains the field `ignored_values` to leave out positions holding given
      values, e.g. `ignored_values: 0` to calibrate only existing diet links;
    - checks positions of `per_prey` parameters (one value per group plus
      one per detritus group);
    - caps the bounds of proportion parameters (e.g. `pPREY`) to `[0, 1]`.
* The diet availability key is now listed as
  `pPREY<PREYCOHORT><PRED><PREDCOHORT>`: the first digit is the prey stage,
  the last one the predator stage (the two were swapped).


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
