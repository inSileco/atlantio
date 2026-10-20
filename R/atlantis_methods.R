#' Print method for Atlantis objects
#'
#' @description S7 method for printing Atlantis objects with a summary of loaded data.
#'
#' @param x An Atlantis S7 object
#' @param ... Additional arguments (unused)
#'
#' @noRd
S7::method(print, Atlantis) <- function(x, ...) {
  cli::col_green("Atlantis Model") |>
    cli::cli_h2()

  data_status <- list(
    "Geometry (BGM)" = !is.null(x@geometry),
    "Run file" = !is.null(x@run),
    "Biology parameters" = !is.null(x@biology),
    "Group file" = !is.null(x@group),
    "Main output" = !is.null(x@main_output),
    "Diet data" = !is.null(x@diet),
    "Detailed diet data" = !is.null(x@diet_detailed),
    "Biomass (system-wide)" = !is.null(x@biomass_all),
    "Biomass (per box)" = !is.null(x@biomass_box),
    "Biomass (per age)" = !is.null(x@biomass_age)
  )

  cli::cli_h3("Data availability:")
  for (name in names(data_status)) {
    cli::cli_text(
      "{ifelse(data_status[[name]], cli::symbol$tick, cli::symbol$cross)} ",
      name
    )
  }

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
      if (is.numeric(x@geometry$botz)) {
        "mean depth: {format(mean(x@geometry$botz), digits = 4)} m"
      }
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

#' Create a diet table
#'
#' @description Collects the prey availabilities (`pPREY` parameters) of the
#' biology file in a table.
#'
#' @param x An `Atlantis` object with the biology file loaded; the groups file
#'   gives the column names.
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
#' * pPREY1XXX1: juvenile prey, juvenile predator
#' * pPREY1XXX2: juvenile prey, adult predator
#' * pPREY2XXX1: adult prey, juvenile predator
#' * pPREY2XXX2: adult prey, adult predator
#' where XXX denotes the code of the predator. Note that the realised diet
#' in Atlantis will depend on other factor, for instance the coeficient `mum`,
#' assuming it is used by the functional response (see `predcase_XXXX`).
#'
#' @return A data frame with one row per `pPREY` key (a predator and the
#'   stages of prey and predator) and one column per prey: the groups, then
#'   the detritus in the sediment (`DLsed`, `DRsed`, `DCsed`).
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
#' create_diet_table(my_model)
create_diet_table <- function(x) {
  require_atlantis(x)
  require_biology_file(x)

  nms <- x@biology |> names()
  nms_slc <- nms[grepl("^pPREY", nms)]
  out <- x@biology[grepl("^pPREY", nms)] |>
    do.call(what = rbind) |>
    as.data.frame()
  row.names(out) <- nms_slc

  if (!is.null(x@group)) {
    # one value per group, then one per detritus group in the sediment
    det <- x@group$GroupType %in% c("LAB_DET", "REF_DET", "CARRION")
    names(out) <- c(x@group$Code, paste0(x@group$Code[det], "sed"))
  } else {
    cli::cli_alert_info(
      "Group file missing, cannot assign the correct column names."
    )
  }

  out
}


#' Create a food web
#'
#' @description Builds the binary food web of a model from its diet table (see
#' [create_diet_table()]): a predator eats a prey when any of their `pPREY`
#' values, whatever the stages, is positive.
#'
#' @param x An `Atlantis` object with the biology and groups files loaded.
#'
#' @return A directed igraph object with one vertex per group (and per
#'   detritus in the sediment) and an edge, of `weight` 1, from each predator
#'   to each of its prey.
#'
#' @export
create_foodweb <- function(x) {
  require_atlantis(x)
  require_biology_file(x)
  require_group_file(x)
  diet_table <- create_diet_table(x)

  if (nrow(diet_table) == 0) {
    cli::cli_abort("Diet table is empty; cannot create food web.")
  }

  # the predator: a group code, the longest that matches (codes can hold
  # digits, as the stages)
  codes <- x@group$Code[order(-nchar(x@group$Code))]
  pattern <- paste0(
    "^pPREY[12]?(",
    paste(stringr::str_escape(codes), collapse = "|"),
    ")[12]?$"
  )
  vc_pred <- stringr::str_match(rownames(diet_table), pattern)[, 2]

  diet_adj_mat <- rowsum(+(diet_table > 0), vc_pred) > 0

  idx <- which(diet_adj_mat > 0, arr.ind = TRUE)
  if (!length(idx)) {
    cli::cli_abort("No interaction detected.")
  }

  df_edges <- data.frame(
    from = rownames(diet_adj_mat)[idx[, 1]],
    to = colnames(diet_adj_mat)[idx[, 2]],
    weight = 1
  )
  df_vertices <- data.frame(
    names = unique(c(rownames(diet_adj_mat), colnames(diet_adj_mat)))
  )

  df_edges |>
    igraph::graph_from_data_frame(directed = TRUE, vertices = df_vertices)
}
