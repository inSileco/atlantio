input_files <- yaml12::read_yaml("inst/raw-data/input_files.yaml") |>
  lapply(as.data.frame) |>
  do.call(what = rbind) |>
  dplyr::rename(
    description = desc,
    file_extension = fext
  )

save(input_files, file = "data/input_files.rda", compress = "xz")
