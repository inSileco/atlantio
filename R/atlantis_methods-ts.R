#' Create time series from the main output
#'
#' Extracts variables of the main netCDF output of an Atlantis model as a tidy
#' data frame, optionally restricted to a set of boxes and layers.
#'
#' @param x An `Atlantis` object with the main output loaded.
#' @param variable Names of the variables (see `names(x@main_output$var)`).
#' @param box Boxes, numbered from 0 as in Atlantis; all boxes if `NULL`.
#' @param layer Layers, numbered from 1; all layers if `NULL`. Ignored for 2D
#'   variables, whose rows have `layer` -1.
#'
#' @return A data frame with one row per variable x box x layer x time and
#'   the columns `time` (seconds), `box`, `layer`, `value`, `variable` and
#'   `units`.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' my_model <- new_atlantis() |>
#'   atlantis_load_files(
#'     c(
#'       system.file("examples", "inputs", "tiny.bgm", package = "atlantio"),
#'       system.file("examples", "inputs", "tiny_biol.prm", package = "atlantio"),
#'       system.file("examples", "inputs", "tiny_groups.csv", package = "atlantio"),
#'       system.file("examples", "outputs", "output.nc", package = "atlantio")
#'     )
#'   )
#' my_model |> create_time_series(variable = "volume", box = 40)
#'
#' library(ggplot2)
#' my_model |>
#'   create_time_series(variable = "Walleye5_ResN") |>
#'   ggplot(aes(x = Time, y = value, color = box)) +
#'   geom_line()
#' }
create_time_series <- function(x, variable, box = NULL, layer = NULL) {
  require_atlantis(x)
  require_main_output(x)
  nc <- x@main_output
  layer_given <- !is.null(layer)

  chk <- variable[!variable %in% names(x@main_output$var)]
  if (length(chk)) {
    cli::cli_abort(
      "{length(chk)} unknown variable{?s}: {cli::col_yellow(chk)}.
      Use `names(x@main_output$var)` to check the list of available variables."
    )
  }

  # nc file goes from 1 to n not from 0 to n - 1
  vc_time <- nc$dim$t$vals
  if (is.null(box)) {
    box <- nc$dim$b$vals
  } else {
    if (!length(box)) {
      cli::cli_abort("{.arg box} is empty.")
    }
    box <- box + 1
    chk <- box[!box %in% nc$dim$b$vals]
    if (length(chk)) {
      cli::cli_abort("{length(chk)} unknown {?box/boxes}: {chk}")
    }
  }
  if (is.null(layer)) {
    layer <- nc$dim$z$vals
  } else {
    chk <- layer[!layer %in% nc$dim$z$vals]
    if (length(chk)) {
      cli::cli_abort("{length(chk)} unknown layer{?s}: {chk}")
    }
  }

  sq_2d_time <- rep.int(vc_time, length(box))
  sq_2d_box <- rep(box, each = length(vc_time))
  sq_3d_time <- rep(vc_time, each = length(box) * length(layer))
  sq_3d_box <- rep(box, each = length(layer)) |> rep.int(length(vc_time))
  sq_3d_layer <- rep.int(layer, length(vc_time) * length(box))

  out <- lapply(variable, \(v) {
    sz <- nc$var[[v]]$varsize
    if (length(sz) == 2) {
      if (sz[1L] == nc$dim$b$len && sz[2L] == nc$dim$t$len) {
        if (layer_given) {
          atlantio_inform("2D variable, 'layer' ignored.")
        }
        tmp <- ncdf4::ncvar_get(nc, v)
        data.frame(
          time = sq_2d_time,
          box = sq_2d_box,
          layer = -1,
          value = tmp[box, ] |> t() |> as.vector(),
          variable = v,
          units = nc$var[[v]]$units
        )
      } else {
        cli::cli_abort("Unknown type of variable (dimension mismatch).")
      }
    } else if (length(sz) == 3) {
      if (
        sz[1L] == nc$dim$z$len &&
          sz[2L] == nc$dim$b$len &&
          sz[3L] == nc$dim$t$len
      ) {
        tmp <- ncdf4::ncvar_get(nc, v)
        data.frame(
          time = sq_3d_time,
          box = sq_3d_box,
          layer = sq_3d_layer,
          value = tmp[layer, box, ] |> as.vector(),
          variable = v,
          units = nc$var[[v]]$units
        ) |>
          dplyr::arrange(.data$box, .data$layer, .data$time)
      } else {
        cli::cli_abort("Unknown type of variable (dimension mismatch).")
      }
    } else {
      cli::cli_abort("Unknown variable dimension")
    }
  }) |>
    do.call(what = dplyr::bind_rows)
  out |>
    dplyr::mutate(box = .data$box - 1)
}


#' Create biomass time series
#'
#' Reads the tracers of functional groups from the main output: reserve and
#' structural nitrogen and numbers (`ResN`, `StructN`, `Nums`) for the
#' age-structured groups, nitrogen for the biomass pools, with their weight.
#'
#' `weight` is the wet weight in g: the nitrogen (mg N) times `X_CN` and
#' `k_wetdry` from the biology file. For a biomass pool, the nitrogen is its
#' concentration times the cell volume, or times the box area for the
#' epibenthic groups (one value per box, in mg N m-2), which needs the
#' geometry file. Atlantis' own biomass index uses a wet-to-dry ratio of 20,
#' whatever `k_wetdry` is, and leaves out the boundary boxes (see `boundary`).
#'
#' With `aggregate = TRUE`, the series are reduced over boxes and layers as
#' they are read (see [aggregate_time_series()]): one cohort of one group at a
#' time, so the full per-box table is never held in memory. For a whole run
#' that table can weigh more than 1 GB and building it peaks at several GB.
#'
#' @param x An `Atlantis` object with the main output and the biology file
#'   loaded, and the groups file when `use_group_code = TRUE`.
#' @param group Groups: their codes, or with `use_group_code = FALSE` their
#'   names as in the main output.
#' @param age Age classes of the age-structured groups; all if `NULL`.
#' @param box Boxes, numbered from 0 as in Atlantis; all boxes if `NULL`.
#' @param layer Layers, numbered from 1; all layers if `NULL`.
#' @param use_group_code Are the groups given by code (`TRUE`) or by name?
#' @param aggregate Should the series be aggregated over boxes and layers
#'   while they are read, one cohort at a time (see [aggregate_time_series()])?
#'   Biomass pools get their weight summed.
#' @param boundary Keep the boundary boxes? `FALSE` leaves them out, as
#'   Atlantis' biomass index does, and needs the geometry file.
#'
#' @return A data frame with one row per group x age x box x layer x time, or
#'   per group x age x time with `aggregate = TRUE`: `group` (the group name),
#'   `age` (`NA` for biomass pools), `time` (seconds), `box`, `layer`, the
#'   tracers, `weight` and `units`.
#'
#' @references
#' * https://atlantis-ecosystem-model.github.io/AtlantisWiki/user_guides/quarto_site/part1/11-consumer-processes.html#size-refuge-from-predation
#'
#' @examples
#' \dontrun{
#' new_atlantis() |>
#'   atlantis_load_files(
#'     c(
#'       system.file("examples", "inputs", "tiny.bgm", package = "atlantio"),
#'       system.file("examples", "inputs", "tiny_biol.prm", package = "atlantio"),
#'       system.file("examples", "inputs", "tiny_groups.csv", package = "atlantio"),
#'       system.file("examples", "outputs", "output.nc", package = "atlantio")
#'     )
#'   ) |>
#'   create_time_series_biomass(group = "YPH", aggregate = TRUE)
#' }
#'
#' @export
create_time_series_biomass <- function(
  x,
  group,
  age = NULL,
  box = NULL,
  layer = NULL,
  use_group_code = TRUE,
  aggregate = FALSE,
  boundary = TRUE
) {
  require_atlantis(x)
  require_main_output(x)
  require_biology_file(x)

  if (use_group_code) {
    require_group_file(x)
    require_valid_group(group, x)
    group <- x@group |>
      dplyr::filter(.data$Code %in% group) |>
      dplyr::pull("Name")
  }
  if (!boundary) {
    require_geometry_file(x)
    inside <- which(!x@geometry$boundary) - 1
    box <- if (is.null(box)) inside else intersect(box, inside)
    if (!length(box)) {
      cli::cli_abort("No box left: {.arg box} holds only boundary boxes.")
    }
  }

  var_names <- x@main_output$var |>
    names()
  x_cn <- x@biology$X_CN
  k_wetdry <- x@biology$k_wetdry
  out <- list()
  for (i in group) {
    # this could be done using x@group$NumCohorts but it mean that group file
    # is always required even though all the info is in the mainoutput
    pattern <- paste0(
      "^",
      stringr::str_escape(i),
      "([0-9]+)_(ResN|StructN|Nums)$"
    )
    v_age <- var_names |>
      stringr::str_extract(pattern, group = 1) |>
      unique()
    v_age <- v_age[!is.na(v_age)]

    if (length(v_age)) {
      # Age structured
      # :danger: I don't think this works for age-structured biomass pools
      # but it wasn't clear to me what we expect in term of variables for such
      # groups
      if (!is.null(age)) {
        age_missing <- age[age %notin% v_age]
        if (length(age_missing)) {
          cli::cli_abort(
            "{length(age_missing)} age value{?s} missing: {age_missing}"
          )
        } else {
          v_age <- v_age[v_age %in% age]
        }
      }

      v_field <- c("_ResN", "_StructN", "_Nums")
      age_ts <- \(ages) {
        x |>
          create_time_series(
            variable = paste0(i, do.call(paste0, expand.grid(ages, v_field))),
            box = box,
            layer = layer
          ) |>
          dplyr::mutate(
            group = i,
            age = stringr::str_match(.data$variable, pattern)[, 2],
            var_type = stringr::str_match(.data$variable, pattern)[, 3]
          ) |>
          dplyr::select(!c("variable", "units")) |>
          tidyr::pivot_wider(
            values_from = "value",
            names_from = "var_type"
          ) |>
          dplyr::mutate(
            weight = (.data$ResN + .data$StructN) *
              .data$Nums *
              k_wetdry *
              x_cn *
              1e-3,
            units = "g"
          )
      }
      if (aggregate) {
        out[[i]] <- lapply(v_age, \(a) aggregate_time_series(age_ts(a))) |>
          dplyr::bind_rows()
      } else {
        out[[i]] <- age_ts(v_age)
      }
    } else {
      if (!is.null(age)) {
        atlantio_inform("{i} has no age structure, `age` ignored.")
      }
      v_pool <- paste0(i, "_N")
      out[[i]] <- x |>
        create_time_series(
          variable = v_pool,
          box = box,
          layer = layer
        ) |>
        dplyr::rename(
          N = "value",
          group = "variable"
        ) |>
        dplyr::mutate(group = i)
      # cell size: volume (m3), or box area (m2) for the epibenthic groups,
      # whose single value per box is in mg N m-2
      if (length(x@main_output$var[[v_pool]]$varsize) == 2) {
        require_geometry_file(x)
        out[[i]]$size <- x@geometry$area[out[[i]]$box + 1]
      } else {
        out[[i]] <- out[[i]] |>
          dplyr::inner_join(
            create_time_series(
              x,
              variable = "volume",
              box = box,
              layer = layer
            ) |>
              dplyr::select(!c("variable", "units")) |>
              dplyr::rename(size = "value"),
            by = c("time", "box", "layer")
          )
      }
      out[[i]] <- out[[i]] |>
        dplyr::mutate(
          weight = .data$N * .data$size * k_wetdry * x_cn * 1e-3,
          units = "g",
          age = NA_character_
        ) |>
        dplyr::select(!c("size", "N"))
      if (aggregate) {
        out[[i]] <- out[[i]] |>
          dplyr::summarise(
            weight = sum(.data$weight, na.rm = TRUE),
            .by = c("group", "age", "time", "units")
          )
      }
    }
  }

  out |> dplyr::bind_rows()
}
