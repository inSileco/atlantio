#' Generate a calibration table
#'
#' @description S7 generic for building the list of parameters to calibrate from a YAML specification file.
#'
#' @param x An `Atlantis` object.
#' @param ... Additional arguments passed to methods
#'
#' @return A list of data frames, one per parameter entry, with columns
#' `name`, `min`, `max`, `position`, `transf` and `source_file`.
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
#'   generate_calibration_table(atlantis_examples("calibrate", "mum.yaml"))
#' )
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

      ls_prm_pos <- ls_abb_prm_name <- list()
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
        ls_abb_prm_name[[i]] <- rep(tmp, ls_prm_pos[[i]] |> length())
      }
      ls_abb_prm_name <- ls_abb_prm_name |> unlist()
      ls_prm_pos <- ls_prm_pos |> unlist()
    }
  } else {
    ls_abb_prm_name <- prm$name
    prm_dim <- compute_parameter_dimension(x, prm_info$dimension)
    ls_prm_pos <- generate_position_set(prm$position, prm_dim)
  }

  data.frame(
    name = ls_abb_prm_name,
    min = prm$min %||% -Inf,
    max = prm$max %||% Inf,
    position = ls_prm_pos,
    transf = validate_transf(prm$transf %||% "identity"),
    source_file = prm_info$source_file
  )
}


#' Run an Atlantis model for calibration
#'
#' Run one calibration iteration: validate the calibration list, apply the
#' parameter transformations, write the input files and run script, run the
#' model and compute the objective function.
#'
#' @param par Numeric vector of parameter values to calibrate.
#' @param atlantis An `Atlantis` object.
#' @param version Atlantis version identifier. Default is `"3-6722"`.
#'
#' @noRd
atlantis_run_model <- function(
  par,
  atlantis,
  version = "3-6722"
) {
  cli::cli_progress_step("Validating callibration list")

  cli::cli_progress_step("Applying tranformation")

  cli::cli_progress_step("Writing new input files and script")

  cli::cli_progress_step("Running the model")

  cli::cli_progress_step("Computing the objective function")
}


pow10 <- function(x) {
  exp(log(10) * x)
}

pow2 <- function(x) {
  exp(log(2) * x)
}


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
      require_geometry_file()
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
