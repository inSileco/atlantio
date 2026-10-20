#' Plot a food web
#'
#' @description Draws the food web of a model from its diet table (see
#' [create_diet_table()]): nodes are the groups (and the detritus in the
#' sediment) placed by trophic level, edges go from prey to predator. Pathways
#' can be highlighted with a table of links and colours.
#'
#' @param x An `Atlantis` object with the biology and groups files loaded. If
#'   the system-wide biomass (`outputBiomIndx.txt`) is loaded, node size is the
#'   initial biomass and node colour the ratio of the final biomass (mean over
#'   the last `window` days) to the initial one.
#' @param highlight A data frame of the links to highlight, with the columns
#'   `prey`, `predator` (group codes) and `colour`, and optionally `pathway`,
#'   the name of the pathway the link belongs to, shown in the legend. Links
#'   absent from the food web (e.g. proposed links) are drawn dashed.
#' @param x_position A named vector of horizontal positions (names are group
#'   codes) that overrides the default layout, for some or all nodes.
#' @param focus A vector of group codes. If not `NULL`, only these groups, the
#'   groups they interact with (their prey and predators) and the links
#'   involving them are drawn. Trophic levels are still computed from the
#'   whole food web.
#' @param window Number of days at the end of the run used to compute the
#'   final biomass.
#'
#' @details
#' Edge width is the largest `pPREY` value over the stages of prey and
#' predator. The trophic level of a group is 1 plus the mean of the trophic
#' levels of its prey, weighted by these values (cannibalism ignored); groups
#' without prey are at level 1. By default, pelagic groups are on the left and
#' benthic groups (benthos, sediment bacteria and detritus, benthic primary
#' producers) on the right, spread evenly within each trophic level.
#'
#' @return A ggplot object.
#'
#' @export
#' @examples
#' my_model <- new_atlantis() |>
#'   atlantis_load_files(
#'     c(
#'       system.file("examples", "inputs", "tiny_biol.prm", package = "atlantio"),
#'       system.file("examples", "inputs", "tiny_groups.csv", package = "atlantio"),
#'       system.file("examples", "outputs", "outputBiomIndx.txt", package = "atlantio")
#'     )
#'   )
#' plot_foodweb(my_model)
#'
#' pathways <- data.frame(
#'   prey = c("DIA", "GRN", "CAL", "GZS", "CHI"),
#'   predator = c("CAL", "CAL", "GZS", "WAE", "WAE"),
#'   colour = c("#1a9850", "#1a9850", "#1a9850", "#1a9850", "#d73027"),
#'   pathway = c(rep("Pelagic", 4), "Proposed")
#' )
#' plot_foodweb(my_model, highlight = pathways)
#'
#' # Walleye, its prey and its predators only
#' plot_foodweb(my_model, focus = "WAE")
plot_foodweb <- function(
  x,
  highlight = NULL,
  x_position = NULL,
  focus = NULL,
  window = 730
) {
  rlang::check_installed("ggplot2", reason = "to plot the food web.")
  require_atlantis(x)
  require_biology_file(x)
  require_group_file(x)

  edges <- foodweb_edges(x)
  nodes <- foodweb_nodes(x, edges, x_position, focus)
  nodes <- foodweb_biomass(x, nodes, window)

  # cannibalism (prey == predator) cannot be drawn as a curve
  shown <- edges$prey != edges$predator
  if (!is.null(focus)) {
    shown <- shown & (edges$prey %in% focus | edges$predator %in% focus)
  }
  edges_xy <- foodweb_xy(edges[shown, ], nodes)
  with_biomass <- !all(is.na(nodes$size))

  p <- ggplot2::ggplot() +
    ggplot2::geom_curve(
      data = edges_xy,
      ggplot2::aes(
        x = .data$x,
        y = .data$y,
        xend = .data$xend,
        yend = .data$yend,
        linewidth = .data$p
      ),
      curvature = 0.15,
      colour = if (is.null(highlight)) "grey35" else "grey60",
      alpha = if (is.null(highlight)) 0.35 else 0.12,
      arrow = grid::arrow(length = grid::unit(0.08, "cm"))
    ) +
    ggplot2::scale_linewidth(range = c(0.15, 1.6), name = "pPREY")

  if (!is.null(highlight)) {
    p <- p + foodweb_highlight(highlight, edges, nodes)
  }

  if (with_biomass) {
    p <- p +
      ggplot2::geom_point(
        data = nodes[!is.na(nodes$size), ],
        ggplot2::aes(
          x = .data$x,
          y = .data$tl,
          size = .data$size,
          fill = .data$lratio
        ),
        shape = 21,
        colour = "grey20",
        stroke = 0.4
      ) +
      ggplot2::scale_size(
        range = c(2, 9),
        name = "log10 initial\nbiomass (t)"
      ) +
      ggplot2::scale_fill_gradient2(
        low = "#2166ac",
        mid = "white",
        high = "#b2182b",
        midpoint = 0,
        limits = c(-3, 3),
        breaks = -3:3,
        labels = c("<=1e-3", "1e-2", "0.1", "1", "10", "100", ">=1e3"),
        na.value = "grey85",
        name = "end / initial"
      )
  }
  p <- p +
    ggplot2::geom_point(
      data = nodes[is.na(nodes$size), ],
      ggplot2::aes(x = .data$x, y = .data$tl),
      shape = if (with_biomass) 22 else 21,
      size = if (with_biomass) 3 else 5,
      fill = "grey85",
      colour = "grey20"
    )

  if (rlang::is_installed("ggrepel")) {
    p <- p +
      ggrepel::geom_text_repel(
        data = nodes,
        ggplot2::aes(x = .data$x, y = .data$tl, label = .data$code),
        size = 2.8,
        point.padding = 0.4,
        min.segment.length = 0.5,
        seed = 1
      )
  } else {
    p <- p +
      ggplot2::geom_text(
        data = nodes,
        ggplot2::aes(x = .data$x, y = .data$tl, label = .data$code),
        size = 2.8,
        vjust = -1.2
      )
  }

  p +
    ggplot2::annotate(
      "text",
      x = c(0.5, 1.5),
      y = min(nodes$tl) - 0.4,
      label = c("pelagic", "benthic"),
      fontface = "italic",
      colour = "grey40"
    ) +
    ggplot2::labs(x = NULL, y = "Trophic level") +
    ggplot2::theme_minimal(base_size = 10) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank()
    )
}


# One row per prey-predator link: the largest pPREY over the stages
foodweb_edges <- function(x) {
  diet_table <- create_diet_table(x)
  if (nrow(diet_table) == 0) {
    cli::cli_abort("Diet table is empty; cannot plot the food web.")
  }
  pred <- pprey_predator(rownames(diet_table), x@group$Code)
  mat <- as.matrix(diet_table)
  mat <- do.call(
    rbind,
    lapply(split(seq_along(pred), pred), \(i) {
      apply(mat[i, , drop = FALSE], 2, max)
    })
  )
  idx <- which(mat > 0, arr.ind = TRUE)
  if (!length(idx)) {
    cli::cli_abort("No interaction detected.")
  }
  data.frame(
    prey = colnames(mat)[idx[, 2]],
    predator = rownames(mat)[idx[, 1]],
    p = mat[idx]
  )
}


# Nodes with their trophic level (tl), habitat and position (x)
foodweb_nodes <- function(x, edges, x_position, focus = NULL) {
  det <- x@group$GroupType %in% c("LAB_DET", "REF_DET", "CARRION")
  codes <- c(x@group$Code, paste0(x@group$Code[det], "sed"))
  type <- c(x@group$GroupType, rep("SED_DET", sum(det)))
  keep <- codes %in% c(edges$prey, edges$predator)
  nodes <- data.frame(code = codes[keep], type = type[keep])

  n <- nrow(nodes)
  w <- matrix(0, n, n, dimnames = list(nodes$code, nodes$code))
  w[cbind(edges$predator, edges$prey)] <- edges$p
  diag(w) <- 0
  w <- w / pmax(rowSums(w), 1e-12)
  nodes$tl <- tryCatch(
    solve(diag(n) - w, rep(1, n)),
    error = \(e) {
      cli::cli_abort(
        "Cannot compute the trophic levels: the food web has a loop without
      basal prey."
      )
    }
  )

  if (!is.null(focus)) {
    chk <- setdiff(focus, nodes$code)
    if (length(chk)) {
      cli::cli_abort("{length(chk)} unknown node{?s} in {.arg focus}: {chk}")
    }
    keep <- nodes$code %in%
      c(
        focus,
        edges$prey[edges$predator %in% focus],
        edges$predator[edges$prey %in% focus]
      )
    nodes <- nodes[keep, ]
  }

  nodes$benthic <- grepl(
    "^(SED_|MOB_EP|FILTER|PHYTOBEN|MICROPHTYBENTHOS|SEAGRASS|CORAL|SPONGE|LG_INF|SM_INF|INF)",
    nodes$type
  )
  # spread the nodes within each habitat and (rounded) trophic level
  band <- paste(nodes$benthic, round(nodes$tl))
  nodes$x <- NA_real_
  for (b in unique(band)) {
    i <- which(band == b)
    i <- i[order(nodes$type[i], nodes$tl[i])]
    nodes$x[i] <- nodes$benthic[i] + (seq_along(i) - 0.5) / length(i)
  }
  if (!is.null(x_position)) {
    chk <- setdiff(names(x_position), nodes$code)
    if (length(chk)) {
      cli::cli_abort(
        "{length(chk)} unknown node{?s} in {.arg x_position}: {chk}"
      )
    }
    nodes$x[match(names(x_position), nodes$code)] <- x_position
  }
  nodes
}


# Initial biomass and final / initial ratio, if the biomass is loaded
foodweb_biomass <- function(x, nodes, window) {
  nodes$size <- NA_real_
  nodes$lratio <- NA_real_
  b <- x@biomass_all
  if (is.null(b)) {
    return(nodes)
  }
  last <- b$Time >= max(b$Time) - window
  i <- which(nodes$code %in% names(b))
  b0 <- vapply(nodes$code[i], \(k) b[[k]][1], 0)
  b1 <- vapply(nodes$code[i], \(k) mean(b[[k]][last]), 0)
  ok <- b0 > 0
  nodes$size[i[ok]] <- log10(b0[ok])
  nodes$lratio[i[ok]] <- pmax(pmin(log10(b1[ok] / b0[ok]), 3), -3)
  nodes
}


# Highlighted links: dashed when absent from the food web
foodweb_highlight <- function(highlight, edges, nodes) {
  chk <- setdiff(c("prey", "predator", "colour"), names(highlight))
  if (length(chk)) {
    cli::cli_abort("{.arg highlight} must have the column{?s} {.field {chk}}.")
  }
  highlight <- as.data.frame(highlight)
  chk <- setdiff(c(highlight$prey, highlight$predator), nodes$code)
  if (length(chk)) {
    cli::cli_abort("{length(chk)} unknown node{?s} in {.arg highlight}: {chk}")
  }
  has_pathway <- "pathway" %in% names(highlight)
  if (!has_pathway) {
    highlight$pathway <- highlight$colour
  }
  highlight <- highlight[highlight$prey != highlight$predator, ]
  highlight$in_web <- paste(highlight$prey, highlight$predator) %in%
    paste(edges$prey, edges$predator)
  hl <- foodweb_xy(highlight, nodes)

  aes_hl <- ggplot2::aes(
    x = .data$x,
    y = .data$y,
    xend = .data$xend,
    yend = .data$yend,
    colour = .data$pathway
  )
  arrow_hl <- grid::arrow(length = grid::unit(0.15, "cm"))
  pal <- stats::setNames(hl$colour, hl$pathway)
  pal <- pal[!duplicated(names(pal))]
  list(
    ggplot2::geom_curve(
      data = hl[hl$in_web, ],
      aes_hl,
      curvature = 0.15,
      linewidth = 1.1,
      alpha = 0.85,
      arrow = arrow_hl
    ),
    ggplot2::geom_curve(
      data = hl[!hl$in_web, ],
      aes_hl,
      curvature = -0.3,
      linewidth = 1.1,
      linetype = "22",
      arrow = arrow_hl
    ),
    if (has_pathway) {
      ggplot2::scale_colour_manual(values = pal, name = "Pathway")
    } else {
      ggplot2::scale_colour_identity()
    }
  )
}


foodweb_xy <- function(d, nodes) {
  i <- match(d$prey, nodes$code)
  j <- match(d$predator, nodes$code)
  d$x <- nodes$x[i]
  d$y <- nodes$tl[i]
  d$xend <- nodes$x[j]
  d$yend <- nodes$tl[j]
  d
}
