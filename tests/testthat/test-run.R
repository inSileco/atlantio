# A run directory with the tiny run file and a script calling a fake
# Atlantis binary: `body` is the bash code of the binary, which gets the
# Atlantis options and can use $o (main output) and $d (output folder).
local_run_dir <- function(body, env = parent.frame()) {
  dir <- withr::local_tempdir(.local_envir = env)
  file.copy(
    atlantis_examples("inputs", "tiny_run.prm"),
    file.path(dir, "run.prm")
  )
  binary <- file.path(dir, "fake_atlantis")
  writeLines(
    c(
      "#!/bin/bash",
      "while [ $# -gt 0 ]; do",
      "  case $1 in -o) o=$2;; -d) d=$2;; esac",
      "  shift",
      "done",
      body
    ),
    binary
  )
  Sys.chmod(binary, "0755")
  write_run_script(
    dir,
    init = "init.nc",
    run = "run.prm",
    force = "force.prm",
    physics = "physics.prm",
    biology = "biology.prm",
    groups = "groups.csv",
    fisheries = "fisheries.csv",
    binary = binary
  )
  dir
}

test_that("write_run_script() fills the template", {
  dir <- withr::local_tempdir()
  path <- write_run_script(
    dir,
    init = "LakeErieInit_NP.nc",
    run = "le_run.prm",
    force = "force.prm",
    physics = "physics.prm",
    biology = "le_bio.prm",
    groups = "groups.csv",
    fisheries = "fisheries.csv",
    output_dir = "out",
    binary = "/opt/bin/atlantisMerged"
  )
  script <- readLines(path)
  expect_false(any(grepl("{{", script, fixed = TRUE)))
  expect_match(script[3], "^/opt/bin/atlantisMerged")
  expect_true(any(grepl("-i LakeErieInit_NP.nc 0", script, fixed = TRUE)))
  expect_true(any(grepl("-b le_bio.prm", script, fixed = TRUE)))
  expect_true(dir.exists(file.path(dir, "out")))
  expect_identical(
    script_files(path),
    c(output = "output.nc", output_dir = "out", run = "le_run.prm")
  )
  expect_error(write_run_script(file.path(dir, "nope")), "Cannot find")
})

test_that("run_atlantis() tells a complete run from a crashed one", {
  skip_on_os("windows")
  skip_if_not_installed("processx")
  output <- atlantis_examples("outputs", "output.nc")
  dir <- local_run_dir(paste0("cp '", output, "' \"$d/$o\""))
  res <- run_atlantis(dir)
  expect_identical(res$status, 0L)
  expect_true(res$complete)
  expect_identical(nrow(res$check), 0L)

  # a fatal error: a message on stderr, status 0 and no output
  dir <- local_run_dir(c("echo 'quit: fatal error' >&2", "exit 0"))
  res <- run_atlantis(dir)
  expect_identical(res$status, 0L)
  expect_false(res$complete)
  expect_identical(res$check$check, "missing")
  expect_match(res$stderr, "fatal error")

  dir <- local_run_dir("sleep 5")
  res <- run_atlantis(dir, timeout = 0.5)
  expect_true(res$timeout)
  expect_false(res$complete)

  expect_error(run_atlantis(dir, script = "other.sh"), "Cannot find")
})

test_that("run_atlantis() runs the script in docker", {
  skip_on_os("windows")
  skip_if_not_installed("processx")
  dir <- local_run_dir("exit 0")
  inputs <- withr::local_tempdir()
  called <- NULL
  local_mocked_bindings(
    run = function(command, args, ...) {
      called <<- list(command = command, args = args)
      list(status = 0L, stdout = "", stderr = "", timeout = FALSE)
    },
    .package = "processx"
  )
  res <- run_atlantis(
    dir,
    docker = "leatl",
    mounts = stats::setNames("/model/inputs", inputs)
  )
  expect_identical(called$command, "docker")
  args <- paste(called$args, collapse = " ")
  expect_match(
    args,
    paste0("-v ", normalizePath(dir), ":/model "),
    fixed = TRUE
  )
  expect_match(
    args,
    paste0("-v ", normalizePath(inputs), ":/model/inputs:ro"),
    fixed = TRUE
  )
  expect_match(args, "--user [0-9]+:[0-9]+")
  expect_match(args, "-w /model --entrypoint bash leatl run.sh$")
  # nothing was written
  expect_false(res$complete)
  expect_error(run_atlantis(dir, docker = "leatl", mounts = "/x"), "named")
})
