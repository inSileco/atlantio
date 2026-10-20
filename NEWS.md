# atlantio (development version)

* New `plot_foodweb()` draws the food web of a model with ggplot2: groups
  placed by trophic level and habitat (pelagic, benthic), edges from prey to
  predator with a width given by `pPREY`, and, when the biomass index is
  loaded, node size and colour given by the initial biomass and the final /
  initial ratio. `highlight` takes a table of links (`prey`, `predator`,
  `colour`, optionally `pathway`) to highlight; links absent from the food
  web are drawn dashed.


# atlantio 0.5.0

* The `run_model()` of the calibration article records a run whose scoring
  fails as failed. It saved it as completed, with the penalty score, so
  `summarise_calibration()` counted it among the completed runs. It also
  closes the output it reads.
* The example outputs that nothing used (`outputPROD.nc`, `outputTOT.nc`,
  `export.ts`, `inputs.ts`, `tiny_groups.xml` and `tiny_run.xml`) are
  removed: the package is 2 MB smaller.
* Fewer messages. `read_atlantis_files()` no longer prints the column
  specification of every text output, nor an alert for a file it cannot
  read, which `atlantis_load_files()` reports: a missing file gives one
  warning (it gave three). `create_time_series()` and
  `create_time_series_biomass()` say that `layer` or `age` is ignored only
  when it was given. Printing an `Atlantis` object whose geometry has no
  depth no longer warns.
* An `atlantis_check` table subset by columns prints as a data frame. It
  printed "0 errors, 0 warnings, 0 notes." above the rows.
* `atlantis_load_files()` aborts when `files` is neither file paths nor an
  `atlantis_file` object. It printed an alert and returned the object
  unchanged.
* `check_prm()` and `check_run()` read the time units of the run file as
  Atlantis does. Atlantis converts a time with its unit only if the unit is
  spelled exactly as one of its units (`s`, `min`, `hour`, `day`, `week`,
  ...); otherwise it ignores the unit and reads the value in seconds, e.g.
  for `tstop 100 days`, `tstop 100 Day`, `tstop 2 year`, or a unit that ends
  a line with Windows (CRLF) line endings. `check_prm()` reports these units
  as errors (it noted them as converted), and `check_run()` checks the run
  against the seconds Atlantis reads (it converted these units). The
  `"units"` check now covers only the times of the run file, the only values
  Atlantis converts.
* `check_prm()` reports a key given twice in the run file as an error:
  Atlantis reads its first occurrence, while `read_prm()` keeps the last. In
  the other files, the warning says that Atlantis may read another
  occurrence. `check_run()` reads the first occurrence of `tstop` and
  `toutinc`, as Atlantis does; it read the last.
* `create_diet_table()` names the sediment detritus columns after the
  detritus groups of the groups file. It assumed `DL`, `DR` and `DC`.
* `create_foodweb()` works with a single predator (it failed with
  "incorrect number of dimensions") and with group codes holding a digit (it
  cut them at the digit), and checks the groups file before the diet table.
* `create_time_series_biomass()` aborts when `boundary = FALSE` leaves no
  box, and `create_time_series()` when `box` is empty. Both failed with
  "arguments imply differing number of rows".
* `generate_calibration_table()` gives no row, with a warning, for an entry
  whose values are all in `ignored_values`; it failed with "arguments imply
  differing number of rows". Its error for a missing value shows why the
  value is needed (the hint was lost).
* `generate_calibration_table()` reads the parameters of `version`, once.
  It ignored `version` and read the parameter list for every entry.
* `generate_file()` writes the time step as `dt 12 hour`. It wrote
  `dt 12 Hours`, which Atlantis reads as 12 seconds.
* `generate_file()` needs `file`: it wrote `run.prm` into the working
  directory by default. It writes an array given in `...` (`init_scalar`) as
  its length, with the values on the next line, as Atlantis reads it; it
  wrote R code (`init_scalar c(1, 2, 3)`). It writes the placeholder
  `<<TO_EDIT>>` as documented (not `<<TO_EDIT>>>`), and warns about names in
  `...` that are not run parameters, which it ignores.
* `generate_file()` and `write_prm()` write LF line endings on every
  platform. On Windows they wrote CRLF, and Atlantis reads the carriage
  return as part of a unit that ends a line: `tstop 365 day` was 365 seconds.
* `get_biomass_by_type()` returns the annual biomass at age
  (`"biomass_age_annual"`), as the Get Started article says, and aborts on an
  unknown type. It returned `NULL` for both, after an alert.
* `input_files` matches the `Atlantis` class: the detailed diet output is
  named `diet_detailed`, as the property (it was `detail_diet`, so
  `atlantis_load_files()` never recorded its path), the age biomass outputs
  have the names Atlantis writes (`AgeBiomIndx.txt`, `AnnualAgeBiomIndx.txt`),
  and the physics and forcing files have a row.
* `read_calibration_runs()` names a run after its folder relative to `dir`,
  so runs in nested folders with the same name stay apart, matches the file
  name exactly, and no longer reads `par_model` as `par` when `par` is
  missing. `summarise_calibration()` gathers the runs without generation in
  the generation `NA`; `generations` and `scores` were `NULL` when no run
  had one.
* `read_nc()` closes a netCDF file it does not recognise, and `check_run()`
  an output without time dimension; both stayed open.
* `read_prm()` also keeps the units `us`, `usec`, `ms` and `msec` after a
  value. It read them as comments, so `write_prm()` wrote the value without
  its unit.
* `read_prm()` reads an empty file as an empty list, and no longer warns
  about a missing final newline.
* `score_table()` and `compute_score()` abort when a series has no value
  at t = 0, with the groups concerned. They failed with "`..1` must be of
  size ..." or "subscript out of bounds".
* `set_init_values()` removes the copy it made when it fails.
* `transform_parameter_value()` computes `pow10` and `pow2` exactly
  (`10^2` is 100; it gave 100.00000000000004).
* `write_parameter_folder()` aborts rather than change a key given several
  times in its file, as Atlantis may read another occurrence than the one
  changed. It changed the last one.


# atlantio 0.4.0

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
