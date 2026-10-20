test_that("input_files has one row per file property of Atlantis", {
  props <- setdiff(S7::prop_names(new_atlantis()), c("file_paths", "version"))
  expect_setequal(input_files$name, props)
})

test_that("input_files gives the names of the outputs Atlantis writes", {
  out <- input_files[grepl("\\.txt$", input_files$file_extension), ]
  # no detailed diet output among the examples
  out <- out[out$name != "diet_detailed", ]
  for (i in seq_len(nrow(out))) {
    fl <- atlantis_examples("outputs", paste0("output", out$file_extension[i]))
    res <- suppressMessages(suppressWarnings(read_atlantis_files(fl)))
    expect_identical(res[[1]]$type, out$name[i])
  }
})
