#' Create Time Series for Atlantis objects
#'
#' @description S7 generic for creating time series data from Atlantis objects
#'
#' @param x An object to create time series from
#' @param ... Additional arguments passed to methods
#'
#' @return A time series data structure
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

create_time_series <- S7::new_generic("create_time_series", "x")


#' Create Time Series for Atlantis objects
#'
#' @description S7 method for creating time series data from Atlantis objects
#'
#' @param x An Atlantis S7 object
#' @param box Box ID from 0 to n-1.
#' @param layer Layer ID from 1 to n.
#' @param ... Additional arguments (unused)
#'
#' @return A time series data structure
#'
#' @noRd

S7::method(create_time_series, Atlantis) <- function(
  x,
  variable,
  box = NULL,
  layer = NULL
) {
  require_main_output(x)
  nc <- x@main_output

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
        atlantio_inform("2D variable, 'layer' ignored.")
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
          dplyr::arrange(box, layer, time)
      } else {
        cli::cli_abort("Unknown type of variable (dimension mismatch).")
      }
    } else {
      cli::cli_abort("Unknown variable dimension")
    }
  }) |>
    do.call(what = dplyr::bind_rows)
  out |>
    dplyr::mutate(box = box - 1)
}


#' Create Time Series Biomass for Atlantis objects
#'
#' @description S7 generic for creating biomass time series data from Atlantis objects
#'
#' With `aggregate = TRUE`, the series are reduced over boxes and layers as
#' they are read (see [aggregate_time_series()]): one cohort of one group at a
#' time, so the full per-box table is never held in memory. For a whole run
#' that table can weigh more than 1 GB and building it peaks at several GB.
#'
#' @param x An object to create biomass time series from
#' @param ... Additional arguments passed to methods: `group`, `age`, `box`,
#'   `layer`, `use_group_code` and `aggregate` (`FALSE` by default).
#'
#' @return A biomass time series data structure: one row per group x age x
#'   box x layer x time, or per group x age x time with `aggregate = TRUE`.
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
create_time_series_biomass <- S7::new_generic("create_time_series_biomass", "x")


#' Create Time Series Biomass for Atlantis objects
#'
#' @description S7 method for creating biomass time series data from Atlantis objects
#'
#' @param x An Atlantis S7 object
#' @param age Stanza age identifier.
#' @param box Box ID from 0 to n-1.
#' @param layer Layer ID from 1 to n.
#' @param use_group_code Should the group code be used. Default is set to TRUE.
#' If `FALSE`, then the full name of the group as found in the main output file
#' should be used.
#' @param aggregate Should the series be aggregated over boxes and layers
#' while they are read, one cohort at a time (see [aggregate_time_series()])?
#' Biomass pools get their weight summed.
#' @param ... Additional arguments (unused)
#'
#' @return A biomass time series data structure
#'
#' @references
#' * https://atlantis-ecosystem-model.github.io/AtlantisWiki/user_guides/quarto_site/part1/11-consumer-processes.html#size-refuge-from-predation
#'
#' @noRd
S7::method(create_time_series_biomass, Atlantis) <- function(
  x,
  group,
  age = NULL,
  box = NULL,
  layer = NULL,
  use_group_code = TRUE,
  aggregate = FALSE,
  ...
) {
  require_main_output(x)
  require_biology_file(x)

  if (use_group_code) {
    require_group_file(x)
    require_valid_group(group, x)
    group <- x@group |>
      dplyr::filter(Code %in% group) |>
      dplyr::pull(Name)
  }

  var_names <- x@main_output$var |>
    names()
  out <- list()
  for (i in group) {
    # this could be done using x@group$NumCohorts but it mean that group file
    # is always required even though all the info is in the mainoutput
    v_age <- var_names |>
      stringr::str_extract(
        paste0("^", stringr::str_escape(i), "([0-9]+)_(ResN|StructN|Nums)$"),
        group = 1
      ) |>
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

      x_cn <- x@biology$X_CN
      k_wetdry <- x@biology$k_wetdry
      v_field <- c("_ResN", "_StructN", "_Nums")
      age_ts <- \(ages) {
        x |>
          create_time_series(
            variable = paste0(i, do.call(paste0, expand.grid(ages, v_field))),
            box = box,
            layer = layer
          ) |>
          dplyr::mutate(
            group = stringr::str_extract(
              variable,
              "^([A-Za-z _]+)([0-9])+_(ResN|Nums|StructN)$",
              group = 1
            ),
            age = stringr::str_extract(
              variable,
              "^[A-Za-z _]+([0-9]+)_(ResN|Nums|StructN)$",
              group = 1
            ),
            var_type = stringr::str_extract(
              variable,
              "^[A-Za-z0-9 _]+_(ResN|Nums|StructN)$",
              group = 1
            )
          ) |>
          dplyr::select(!c(variable, units)) |>
          tidyr::pivot_wider(
            values_from = value,
            names_from = var_type
          ) |>
          dplyr::mutate(
            weight = (ResN + StructN) * Nums * k_wetdry * x_cn * 1e-3,
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
      atlantio_inform("{i} has no age structure, `age` ignored.")
      x_rs <- x@biology$X_RS
      out[[i]] <- x |>
        create_time_series(
          variable = paste0(i, "_N"),
          box = box,
          layer = layer
        ) |>
        dplyr::rename(
          N = value,
          group = variable
        ) |>
        dplyr::inner_join(
          create_time_series(
            x,
            variable = "volume",
            box = box,
            layer = layer
          ) |>
            dplyr::select(!c(variable, units)) |>
            dplyr::rename(volume = value),
          by = c("time", "box", "layer")
        ) |>
        dplyr::mutate(
          weight = (1 + x_rs) * N * volume * 1e-3,
          units = "g",
          age = ""
        ) |>
        dplyr::select(!c(volume, N))
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
