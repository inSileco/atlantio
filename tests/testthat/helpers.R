create_atlantis_model <- function() {
  new_atlantis() |>
    atlantis_load_files(
      c(
        system.file("examples", "inputs", "tiny.bgm", package = "atlantio"),
        system.file(
          "examples",
          "inputs",
          "tiny_biol.prm",
          package = "atlantio"
        ),
        system.file(
          "examples",
          "inputs",
          "tiny_groups.csv",
          package = "atlantio"
        )
      )
    )
}
