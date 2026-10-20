test_that("plot_foodweb() requires the biology and groups files", {
  skip_if_not_installed("ggplot2")
  expect_error(new_atlantis() |> plot_foodweb(), "No bio data available")
  atl <- create_atlantis_model()
  atl@group <- NULL
  expect_error(plot_foodweb(atl), "Group info required")
})

test_that("plot_foodweb() draws prey-to-predator edges by trophic level", {
  skip_if_not_installed("ggplot2")
  atl <- create_atlantis_model()
  p <- plot_foodweb(atl)
  expect_s3_class(p, "ggplot")

  edges <- p$layers[[1]]$data
  expect_true(all(edges$prey != edges$predator))
  expect_true(any(edges$prey == "GZS" & edges$predator == "WAE"))
  # basal groups at level 1, Walleye above its prey
  nodes <- foodweb_nodes(atl, foodweb_edges(atl), NULL)
  expect_equal(nodes$tl[nodes$code == "DIA"], 1)
  expect_gt(nodes$tl[nodes$code == "WAE"], nodes$tl[nodes$code == "GZS"])
})

test_that("plot_foodweb() uses the biomass when it is loaded", {
  skip_if_not_installed("ggplot2")
  atl <- create_atlantis_model() |>
    atlantis_load_files(
      system.file(
        "examples",
        "outputs",
        "outputBiomIndx.txt",
        package = "atlantio"
      )
    )
  nodes <- foodweb_biomass(
    atl,
    foodweb_nodes(atl, foodweb_edges(atl), NULL),
    730
  )
  expect_false(is.na(nodes$size[nodes$code == "WAE"]))
  expect_true(all(abs(nodes$lratio) <= 3, na.rm = TRUE))
})

test_that("plot_foodweb() highlights pathways", {
  skip_if_not_installed("ggplot2")
  atl <- create_atlantis_model()
  hl <- data.frame(
    prey = c("GZS", "CHI"),
    predator = c("WAE", "WAE"),
    colour = c("red", "blue"),
    pathway = c("Pelagic", "Proposed")
  )
  p <- plot_foodweb(atl, highlight = hl, x_position = c(WAE = 0.5))
  solid <- p$layers[[2]]$data
  dashed <- p$layers[[3]]$data
  expect_identical(nrow(solid) + nrow(dashed), 2L)
  expect_equal(unique(c(solid$xend, dashed$xend)), 0.5)
  expect_no_error(ggplot2::ggplot_build(p))

  expect_error(
    plot_foodweb(atl, highlight = hl[c("prey", "predator")]),
    "colour"
  )
  hl$prey[1] <- "XXX"
  expect_error(plot_foodweb(atl, highlight = hl), "unknown node")
})
