test_that("create_foodweb() requires diet information", {
  expect_error(new_atlantis() |> create_foodweb(), "No bio data available")
})

test_that("create_foodweb() builds a directed food web graph", {
  atl <- create_atlantis_model()
  g <- create_foodweb(atl)

  expect_true(igraph::is_igraph(g))
  expect_true(igraph::is_directed(g))
  expect_identical(igraph::gsize(g), 62)
  expect_identical(igraph::gorder(g), 18)
  expect_true(all(c("WAE", "GZS") %in% igraph::V(g)$name))

  edge_id <- igraph::get_edge_ids(g, c("WAE", "GZS"))
  expect_gt(edge_id, 0)
  expect_equal(igraph::E(g)$weight[edge_id], 1)
})

test_that("create_foodweb() works with a single predator", {
  atl <- create_atlantis_model()
  nms <- names(atl@biology)
  atl@biology <- atl@biology[
    !startsWith(nms, "pPREY") | grepl("^pPREY[12]?WAE[12]?$", nms)
  ]
  g <- create_foodweb(atl)
  expect_identical(unique(igraph::as_edgelist(g)[, 1]), "WAE")
})

test_that("create_foodweb() reads predator codes that hold a digit", {
  atl <- create_atlantis_model()
  atl@group$Code[atl@group$Code == "WAE"] <- "WA2"
  names(atl@biology) <- sub("^(pPREY[12]?)WAE", "\\1WA2", names(atl@biology))
  g <- create_foodweb(atl)
  expect_contains(igraph::as_edgelist(g)[, 1], "WA2")
})

test_that("create_foodweb() checks the groups file first", {
  atl <- create_atlantis_model()
  atl@group <- NULL
  expect_snapshot(create_foodweb(atl), error = TRUE)
})
