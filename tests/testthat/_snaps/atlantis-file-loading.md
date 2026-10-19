# atlantis_load_files() says why a file cannot be read

    Code
      res <- suppressMessages(atlantis_load_files(new_atlantis(), c("bad.prm",
        "run.prm")))
    Condition
      Warning:
      Cannot read 'bad.prm'.
      x Dimension mismatch for array `arr`: 3 elements expected, but 2 available.
      Warning:
      Cannot read 'run.prm'.
      x 1 Parameter missing: verbose

