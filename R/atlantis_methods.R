#' Print method for Atlantis objects
#'
#' @description S7 method for printing Atlantis objects with a summary of loaded data.
#'
#' @param x An Atlantis S7 object
#' @param ontogenetic_stage Logical, if `TRUE` keeps predator juvenile/adult
#' variants as separate nodes in the food web.
#' @param ... Additional arguments (unused)
#'
#' @noRd
S7::method(print, Atlantis) <- function(x, ...) {
  cli::col_green("Atlantis Model") |>
    cli::cli_h2()

  # Check and display data availability
  data_status <- list(
    "Geometry (BGM)" = !is.null(x@geometry),
    "Biology parameters" = !is.null(x@biology),
    "Group file" = !is.null(x@group),
    "Main output" = !is.null(x@main_output),
    "Diet data" = !is.null(x@diet),
    "Detailed diet data" = !is.null(x@diet_detailed),
    "Biomass (system-wide)" = !is.null(x@biomass_all),
    "Biomass (per box)" = !is.null(x@biomass_box),
    "Biomass (per age)" = !is.null(x@biomass_age)
  )

  # would probably move all this to summary method
  cli::cli_h3("Data availability:")
  for (name in names(data_status)) {
    cli::cli_text(
      "{ifelse(data_status[[name]], cli::symbol$tick, cli::symbol$cross)} ",
      name
    )
  }

  # Additional details for key components
  if (!is.null(x@group)) {
    cli::cli_h3("Group details:")
    vec_to_ul(
      "{nrow(x@group)} group{?s}",
      "{x@group$GroupType |> unique() |> length()} group type{?s}",
      "{x@group$IsPredator |> sum()} predator{?s}"
    )
  }

  if (!is.null(x@geometry)) {
    cli::cli_h3("Geometry details:\n")
    bbx <- x@geometry$boundary
    vec_to_ul(
      "{nrow(x@geometry)} {?box/boxes} (including {sum(bbx)} boundary {?box/boxes})",
      "mean depth: {format(mean(x@geometry$botz), digits = 4)} m"
    )
  }

  if (!is.null(x@main_output)) {
    cli::cli_h3("Main output details:\n")
    vec_to_ul(
      "{length(x@main_output$var)} variable{?s}",
      "{x@main_output$dim$t$len} time step{?s}"
    )
  }

  invisible(x)
}

#' Create Diet Table
#'
#' @description Generic function for creating diet tables from model data.
#'
#' @param x Object containing diet/bio data
#' @param ... Additional arguments
#'
#' @details
#' In Atlantis model, the availability of prey is determined by the product of
#' the prey biomass and the prey choice coefficient `pPREY`. The latter is a
#' proportion (between 0 and 1) of prey biomass actually available to the
#' predator. The function finds this information in the model and creates the
#' diet table that is the collection of the pPREY values.
#'
#' Atlantis distinguishes prey choice values for juveniles and adults. The
#' distinction exists if species have ontogenetic stages and if the flag
#' `age_structured_prey_XXX` is set to one. Note that for those species the
#' first mature age group is given by `XXX_age_mat`. Therefore there are up to
#' 4 `pPREY` values per prey-predator combination:
#' * pPREY1XXX1: juvenile-juvenile
#' * pPREY1XXX2: juvenile-adult
#' * pPREY2XXX1: adult-juvenile
#' * pPREY2XXX2: adult-adult
#' where XXX denotes the code for the prey species. Note that the realised diet
#' in Atlantis will depend on other factor, for instance the coeficient `mum`,
#' assuming it is used by the functional response (see `predcase_XXXX`).
#'
#' @return A data.frame representing the diet table with predator-prey relationships
#'
#' @references
#' * Asta Audzijonyte, Rebecca Gorton, Isaac Kaplan, Jacob M. Kasper, Elizabeth
#' A. Fulton, 2025. Atlantis User’s Guide Part I: General Overview, Physics &
#' Ecology <https://research.csiro.au/atlantis/wp-content/uploads/sites/52/2025/05/AtlantisUserGuide_PartI.pdf>
#'
#' @export
#' @examples
#' my_model <- new_atlantis() |>
#'   atlantis_load_files(
#'     c(
#'       system.file("examples", "inputs", "tiny.bgm", package = "atlantio"),
#'       system.file("examples", "inputs", "tiny_biol.prm", package = "atlantio"),
#'       system.file("examples", "inputs", "tiny_groups.csv", package = "atlantio")
#'     )
#'   )
create_diet_table <- S7::new_generic("create_diet_table", "x")

#' Create Diet Table for Atlantis objects
#'
#' @description S7 method for creating diet tables from Atlantis objects using
#' bio and group data.
#'
#' @param x An Atlantis S7 object containing bio and optionally group data
#' @param ... Additional arguments (unused)
#'
#' @return A data.frame representing the diet table with predator-prey relationships
#'
#' @noRd
S7::method(create_diet_table, Atlantis) <- function(x, ...) {
  require_biology_file(x)

  nms <- x@biology |> names()
  nms_slc <- nms[grepl("^pPREY", nms)]
  out <- x@biology[grepl("^pPREY", nms)] |>
    do.call(what = rbind) |>
    as.data.frame()
  row.names(out) <- nms_slc

  if (!is.null(x@group)) {
    # needs to confirm whether these groups are always present
    # DL: labile detritus
    # DR: refractory detritus
    # DC: carrion
    # sed = sediment
    names(out) <- c(x@group$Code, "DLsed", "DRsed", "DCsed")
  } else {
    cli::cli_alert_info(
      "Group file missing, cannot assign the correct column names."
    )
  }

  out
}


#' Create Food Web for Atlantis objects
#'
#' @description S7 generic for creating food web data structures from Atlantis objects
#'
#' @param x An object to create food web from
#' @param ... Additional arguments passed to methods
#'
#' @return A food web data structure
#'
#' @export
create_foodweb <- S7::new_generic("create_foodweb", "x")

#' Create Food Web for Atlantis objects
#'
#' @description S7 method for creating food web data structures from Atlantis objects
#'
#' @param x An Atlantis S7 object
#' @param ... Additional arguments (unused).
#'
#' @return A food web data structure represented as an igraph object with
#' binary (presence/absence) edges
#'
#' @noRd
S7::method(create_foodweb, Atlantis) <- function(x, ...) {
  diet_table <- create_diet_table(x)

  require_group_file(x)

  if (nrow(diet_table) == 0) {
    cli::cli_abort("Diet table is empty; cannot create food web.")
  }

  vc_prey <- rownames(diet_table) |>
    stringr::str_extract("pPREY[1-2]?([A-Z]+)[1-2]?", group = 1)

  diet_adj_mat <- (diet_table > 0) |>
    apply(2, \(x) {
      split(x, vc_prey) |>
        lapply(any) |>
        unlist()
    })

  idx <- which(diet_adj_mat > 0, arr.ind = TRUE)
  if (!length(idx)) {
    cli::cli_abort("No interaction detected.")
  }

  df_edges <- data.frame(
    from = rownames(diet_adj_mat)[idx[, 1]],
    to = colnames(diet_adj_mat)[idx[, 2]],
    weight = 1
  )
  # we could add various details
  df_vertices <- data.frame(
    names = unique(c(rownames(diet_adj_mat), colnames(diet_adj_mat)))
  )

  df_edges |>
    igraph::graph_from_data_frame(directed = TRUE, vertices = df_vertices)
}
