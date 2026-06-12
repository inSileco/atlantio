test_that("create_foodweb() requires diet information", {
  expect_error(new_atlantis() |> create_foodweb(), "No bio data available")
})

# TODO READ biological file make the foodweb very simple and check

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
