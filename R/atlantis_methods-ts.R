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
    # NB: some should be excluded, need a get_output_varname methods?
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

  # sequence 2D
  sq_2d_time <- rep.int(vc_time, length(box))
  sq_2d_box <- rep(box, each = length(vc_time))
  # sequence 3D
  sq_3d_time <- rep(vc_time, each = length(box) * length(layer))
  sq_3d_box <- rep(box, each = length(layer)) |> rep.int(length(vc_time))
  sq_3d_layer <- rep.int(layer, length(vc_time) * length(box))

  out <- lapply(variable, \(v) {
    sz <- nc$var[[v]]$varsize
    if (length(sz) == 2) {
      # check the correspondance
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
      cli::cli_abort("Unknown variable dimension", type = "error")
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
#' @param x An object to create biomass time series from
#' @param ... Additional arguments passed to methods
#'
#' @return A biomass time series data structure
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
#'   create_time_series_biomass(group = "YPH")
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
  ...
) {
  require_main_output(x)
  require_biology_file(x)

  if (use_group_code) {
    require_group_file(x)
    require_valid_group(group, x)
    #  age_group <- c("FISH", "FISH_INVERT", "SHARK", "MAMMAL", "BIRD", "REPTILE")
    grp_missing <- group[group %notin% x@group$Code]
    if (length(grp_missing)) {
      cli::cli_abort(
        "{length(grp_missing)} unknown group{?s} name: {grp_missing}"
      )
    }
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
      stringr::str_subset(i) |>
      stringr::str_extract(".*([0-9]+)_", group = 1) |>
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
      # this will likely change for age structured biomass pools
      v_field <- c("_ResN", "_StructN", "_Nums")
      out[[i]] <- x |>
        create_time_series(
          variable = paste0(i, do.call(paste0, expand.grid(v_age, v_field))),
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
    } else {
      atlantio_inform("{i} has no age structure, `age` ignored.")
      v_age <- ""
      x_rs <- x@biology$X_RS
      out[[i]] <- x |>
        create_time_series(
          variable = paste0(i, v_age, "_N"),
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
    }
  }

  out |> dplyr::bind_rows()
}
