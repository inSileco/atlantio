# Run Atlantis

Runs the script written by
[`write_run_script()`](https://insileco.io/atlantio/reference/write_run_script.md)
in its run directory, either directly with bash or in a Docker
container, and checks with
[`check_run()`](https://insileco.io/atlantio/reference/check_run.md)
that the run completed. Atlantis ends a fatal error with
[`quit()`](https://rdrr.io/r/base/quit.html), which exits with status 0:
only the time reached by the main output tells a completed run from a
crashed one.

## Usage

``` r
run_atlantis(
  dir,
  script = "run.sh",
  docker = NULL,
  mounts = NULL,
  timeout = Inf
)
```

## Arguments

- dir:

  Run directory holding the script and the input files.

- script:

  Name of the script.

- docker:

  Name of the Docker image to run the script in, or `NULL` (the default)
  to run it directly.

- mounts:

  Other folders mounted read-only in the container: a named character
  vector, names the folders and values their path in the container, e.g.
  `c("/data/inputs" = "/model/inputs")`.

- timeout:

  Time limit of the run, in seconds; a full run can take hours.

## Value

A list with the elements of
[`processx::run()`](http://processx.r-lib.org/reference/run.md)
(`status`, `stdout`, `stderr` and `timeout`), `check`, the result of
[`check_run()`](https://insileco.io/atlantio/reference/check_run.md) on
the main output and the run parameter file named in the script, and
`complete`, `TRUE` if the run exited with status 0 within the time limit
and `check` is empty.

## Details

With Docker, the run directory is mounted as the working directory
`/model` of the container and the container runs as the current user, so
that the files it writes can be removed by the R session. A container
still running at the time limit is removed.

## See also

[`write_run_script()`](https://insileco.io/atlantio/reference/write_run_script.md),
[`check_run()`](https://insileco.io/atlantio/reference/check_run.md)

## Examples

``` r
if (FALSE) { # \dontrun{
res <- run_atlantis("run_1", docker = "atlantis", timeout = 86400)
if (!res$complete) print(res$check)
} # }
```
