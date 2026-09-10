#' Generate a calibration table
#'
#' @description S7 generic for building the list of parameters to calibrate
#' from a YAML specification file.
#'
#' @param x An `Atlantis` object.
#' @param ... Additional arguments passed to methods
#'
#' @return A data frame with one row per value to calibrate and columns
#' `name`, `cur_value`, `min`, `max`, `position`, `transf` and `source_file`.
#'
#' @details
#' The YAML file is a list of entries, one per parameter, each expanded into
#' one row per value to calibrate. The following fields are recognised:
#'
#' * `name` (required): the parameter name, as listed in
#'   [list_atlantis_parameters()]. The name may contain a placeholder such as
#'   `<GRP>` (e.g. `mum_<GRP>`); the placeholder is then expanded over the
#'   values of an extra field of the same name without angle brackets (see
#'   `GRP` below). Entries without a placeholder (e.g. `rec_m`) yield the
#'   parameter as is.
#' * `position` (optional): integer index, or vector of indices, of the values
#'   to calibrate for array parameters (e.g. one value per cohort or per box).
#'   Defaults to all positions. Positions are validated against the dimension
#'   of the parameter when it can be computed from the loaded files
#'   (`scalar`, `per_group`, `per_cohort` and `per_box` parameters; the
#'   latter requires the geometry file). For other dimensions a warning is
#'   emitted and a single position is assumed.
#' * `transf` (optional): transformation mapping the calibration scale to the
#'   scale used in the parameter file, one of `"identity"` (default),
#'   `"pow10"`, `"pow2"` or `"exp"`, see [transform_parameter_value()]. A log
#'   scale (`pow10` or `exp`) is recommended for rate parameters spanning
#'   several orders of magnitude.
#' * `min`, `max` (optional): lower and upper bounds of the search, expressed
#'   on the calibration scale. With `transf: pow10`, `min: -3` thus means a
#'   lower bound of `0.001` in the parameter file. Default to `-Inf` and
#'   `Inf`.
#' * `is_factor` (optional, default `false`): when `true`, `min` and `max`
#'   are interpreted relative to the current value of the parameter rather
#'   than as absolute bounds. The bounds become `cur_value * transf(min)` and
#'   `cur_value * transf(max)` on the file scale, mapped back to the
#'   calibration scale. For instance, with `transf: pow10`, `min: -1` and
#'   `max: 1` restrict the search to one order of magnitude on each side of
#'   the current value, and with `transf: identity`, `min: 0.5` and
#'   `max: 1.5` to plus or minus 50%. This requires the current value to be
#'   available, i.e. the parameter file the parameter belongs to must be
#'   loaded in `x`.
#'
#' The current value of every parameter is read from the corresponding
#' parameter file loaded in `x` and reported in the `cur_value` column. When
#' the file is not loaded, a warning is emitted and `cur_value` is `NA`
#' (unless `is_factor` is `true`, in which case an error is thrown).
#'
#' A minimal specification looks like:
#'
#' ```yaml
#' - name: mum_<GRP>
#'   GRP: [GZS, RDG, WAE]
#'   min: -6
#'   max: -1
#'   transf: pow10
#' - name: mum_<GRP>
#'   GRP: YPH
#'   position: 2
#'   min: -1
#'   max: 1
#'   transf: pow10
#'   is_factor: true
#' - name: rec_m
#' ```
#'
#' @examples
#' \dontrun{
#' mod  <- new_atlantis() |>
#'   atlantis_load_files(c(
#'     atlantis_examples("inputs", "tiny.bgm"),
#'     atlantis_examples("inputs", "tiny_biol.prm"),
#'     atlantis_examples("inputs", "tiny_groups.csv")
#'   ))
#' mod |>
#'   generate_calibration_table(
#'    atlantis_examples("calibrate", "mum.yaml")
#'  )
#' }
#'
#' @export

generate_calibration_table <- S7::new_generic("generate_calibration_table", "x")


#' Generate a calibration table
#'
#' Build the list of parameters to calibrate from a YAML specification file.
#'
#' @param x An `Atlantis` object.
#' @param path Path to a YAML file describing the parameters to calibrate.
#' @param version Atlantis version identifier. Default is `"3-6722"`.
#'
#' @noRd
S7::method(generate_calibration_table, Atlantis) <- function(
  x,
  path, # would be better to use a function to check the list first!
  version = "3-6722"
) {
  yaml::read_yaml(path) |>
    lapply(
      format_calibration_entry,
      x = x,
      version = version
    ) |>
    do.call(what = rbind)
}


#' Format one calibration entry
#'
#' Convert a single YAML parameter specification into a data frame of
#' calibration rows, expanding `<abbrev>` placeholders in the parameter name
#' using the corresponding values stored in the `Atlantis` object.
#'
#' @param x An `Atlantis` object.
#' @param prm A list describing one parameter (fields `name`, and optionally
#' `min`, `max`, `position`, `transf`).
#' @param version Atlantis version identifier. Default is `"3-6722"`.
#'
#' @return A data frame with columns `name`, `min`, `max`, `position`,
#' `transf` and `source_file`.
#'
#' @noRd
format_calibration_entry <- function(x, prm, version = "3-6722") {
  if (length(prm$name) != 1) {
    cli::cli_abort("Parameter name should have a length of 1.")
  }
  transf <- validate_transf(prm$transf %||% "identity")
  ls_prm_all <- list_atlantis_parameters()$parameters
  prm_idx <- ls_prm_all |>
    Position(f = \(y) y$name == prm$name)
  if (is.na(prm_idx)) {
    cli::cli_abort("Unknown parameter.")
  }
  if (length(prm$name) != 1) {
    cli::cli_abort("Parameter name should have a length of 1.")
  }
  prm_info <- ls_prm_all[[prm_idx]]

  if (stringr::str_detect(prm$name, "<[A-Za-z]+>")) {
    abbrev <- prm$name |>
      stringr::str_extract_all("<[A-Za-z]+>") |>
      unlist()
    if (length(abbrev)) {
      abb_prm_name <- abbrev |>
        stringr::str_replace_all("[<>]", "") |>
        unlist()
      mis_abb_prm <- setdiff(abb_prm_name, names(prm))
      if (length(mis_abb_prm)) {
        cli::cli_abort("{mis_abb_prm} missing from calibrarion file.")
      }
      # compting all combinations
      df_key_val <- prm[abb_prm_name] |>
        expand.grid(stringsAsFactors = FALSE)

      ls_prm_pos <- ls_prm_nam <- list()
      for (i in df_key_val |>
        nrow() |>
        seq_len()) {
        tmp <- prm$name
        for (j in ncol(df_key_val)) {
          tmp <- tmp |>
            stringr::str_replace(abbrev[j], df_key_val[i, j])
        }
        prm_dim <- compute_parameter_dimension(
          x,
          prm_info$dimension,
          group = df_key_val$GRP[i]
        )
        ls_prm_pos[[i]] <- generate_position_set(prm$position, prm_dim)
        ls_prm_nam[[i]] <- rep(tmp, ls_prm_pos[[i]] |> length())
      }
      ls_prm_nam <- ls_prm_nam |> unlist()
      ls_prm_pos <- ls_prm_pos |> unlist()
    }
  } else {
    ls_prm_nam <- prm$name
    prm_dim <- compute_parameter_dimension(x, prm_info$dimension)
    ls_prm_pos <- generate_position_set(prm$position, prm_dim)
  }

  is_factor <- prm$is_factor %||% FALSE
  ls_prm_val <- get_values(
    x,
    ls_prm_nam,
    ls_prm_pos,
    prm_info$source_file,
    is_factor
  )

  out_min <- prm$min %||% -Inf
  out_max <- prm$max %||% Inf
  if (is_factor) {
    out_min <- inverse_transform_parameter_value(
      ls_prm_val * transform_parameter_value(out_min, transf),
      transf
    )
    out_max <- inverse_transform_parameter_value(
      ls_prm_val * transform_parameter_value(out_max, transf),
      transf
    )
  } else {}

  data.frame(
    name = ls_prm_nam,
    cur_value = ls_prm_val,
    min = out_min,
    max = out_max,
    position = ls_prm_pos,
    transf = transf,
    source_file = prm_info$source_file,
    row.names = NULL
  )
}


#' Transform a parameter value
#'
#' Apply a transformation function to a parameter value. This is used to
#' map calibrated values back to their natural scale, e.g. when a parameter
#' is calibrated on a log scale.
#'
#' @param x A numeric vector of parameter values, or `NULL`.
#' @param fun A string naming the transformation to apply. One of
#' `"identity"`, `"pow10"` (`10^x`), `"pow2"` (`2^x`) or `"exp"` (`exp(x)`).
#'
#' @return The transformed values, or `NULL` if `x` is `NULL`.
#'
#' @examples
#' transform_parameter_value(2, "pow10")
#' transform_parameter_value(c(1, 2, 3), "pow2")
#' transform_parameter_value(0.5, "identity")
#'
#' @export
transform_parameter_value <- function(x, fun) {
  if (is.null(x)) {
    return(x)
  }
  switch(
    fun,
    "identity" = x,
    "pow10" = pow10(x),
    "pow2" = pow2(x),
    "exp" = exp(x),
    cli::cli_abort("Unknown transformation function.")
  )
}


#' Map a parameter value from the file scale back to the calibration scale
#'
#' Inverse of [transform_parameter_value()], used to get starting
#' values in the space explored by the optimizer.
#'
#' @param x A numeric vector of parameter values on the file scale, or `NULL`.
#' @param fun A string naming the transformation used during calibration. One
#' of `"identity"`, `"pow10"` (inverse is `log10(x)`), `"pow2"` (inverse is
#' `log2(x)`) or `"exp"` (inverse is `log(x)`).
#'
#' @return The values mapped back to the calibration scale, or `NULL` if `x`
#' is `NULL`.
#'
#' @examples
#' inverse_transform_parameter_value(100, "pow10")
#' inverse_transform_parameter_value(c(2, 4, 8), "pow2")
#' inverse_transform_parameter_value(0.5, "identity")
#'
#' @export
inverse_transform_parameter_value <- function(x, fun) {
  if (is.null(x)) {
    return(x)
  }
  switch(
    fun,
    identity = x,
    pow10 = log10(x),
    pow2 = log2(x),
    exp = log(x),
    cli::cli_abort("Unknown transformation function {.val {fun}}.")
  )
}


pow10 <- function(x) {
  exp(log(10) * x)
}

pow2 <- function(x) {
  exp(log(2) * x)
}

validate_transf <- function(x) {
  if (x %in% c("identity", "pow10", "pow2", "exp")) {
    x
  } else {
    cli::cli_abort("Unknown transformation function.")
  }
}

generate_position_set <- function(position, dimension) {
  if (!is.null(position)) {
    if (all(position %in% seq_len(dimension))) {
      position
    } else {
      cli::cli_abort("Invalid position(s).")
    }
  } else {
    seq_len(dimension)
  }
}


compute_parameter_dimension <- function(x, dimension, group = NULL) {
  switch(
    dimension,
    "scalar" = 1,
    "per_box" = {
      require_geometry_file(x)
      x@geometry |> nrow()
    },
    "per_group" = {
      # guessing here that sometimes it's per fish group, sometimes detritus must be excluded. 2B improved.
      require_group_file(x)
      require_valid_group(group, x)
      x@group |> nrow()
    },
    "timeseries" = {
      warn_no_dimension_check()
    },
    "other" = {
      warn_no_dimension_check()
    },
    "per_prey" = {
      warn_no_dimension_check()
    },
    "per_cohort" = {
      require_group_file(x)
      require_valid_group(group, x)
      x@group$NumCohorts[x@group$Code == group]
    },
    "per_layer" = {
      warn_no_dimension_check()
    },
    "per_fishery" = {
      warn_no_dimension_check()
    },
    cli::cli_abort("Unknown dimension")
  )
}


warn_no_dimension_check <- function() {
  cli::cli_warn("No dimension check available.")
  1
}


get_prop_name <- function(bname) {
  switch(
    bname,
    "biology_prm" = "biology",
    "forcing_prm" = "forcing",
    "harvest_prm" = "harvest",
    "groups_csv" = "group",
    "fisheries_csv" = "fisheries",
    "physics_prm" = "physics",
    "run_prm" = "run",
    cli::cli_abort("Unknown property.")
  )
}


get_values <- function(atl, prm_nam, prm_pos, src_file, is_factor = FALSE) {
  mapply(
    \(nam, pos) {
      out <- S7::prop(atl, get_prop_name(src_file))[[nam]][pos]
      if (is.null(out)) {
        if (is_factor) {
          cli::cli_abort(
            "Cannot find value for `{nam}[{pos}]` in '{src_file}'.",
            "i" = "Values are required to use `min` and `max` as factors."
          )
        } else {
          cli::cli_warn(
            "Cannot find value for `{nam}[{pos}]` in '{src_file}'."
          )
          out <- NA
        }
      }
      out
    },
    nam = prm_nam,
    pos = prm_pos
  )
}
