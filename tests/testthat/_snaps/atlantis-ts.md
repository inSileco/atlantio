# create_time_series_biomass() needs the geometry for epibenthic groups

    Code
      suppressMessages(create_time_series_biomass(mod, "DRE"))
    Condition
      Error in `require_geometry_file()`:
      ! Geometry file (bgm) required.

# create_time_series_biomass() aborts when no box is left

    Code
      create_time_series_biomass(mod, "WAE", box = 0, boundary = FALSE)
    Condition
      Error in `create_time_series_biomass()`:
      ! No box left: `box` holds only boundary boxes.

---

    Code
      create_time_series(mod, "Temp", box = integer())
    Condition
      Error in `create_time_series()`:
      ! `box` is empty.

