parameters_hints <- list(
  run = c(
    "title",
    "dt",
    "tstop",
    "toutstart",
    "toutinc",
    "toutfinc"
  ),
  bio = c(
    "RelTol",
    "Flux_tol",
    "min_pool",
    "min_dens"
  )
)

save(parameters_hints, file = "data/parameters_hints.rda")
