# Write the script that runs Atlantis

Renders the run script template shipped with atlantio
(`inst/run_scripts/script.sh`, the `atlantisMerged` command line) for
the given input files and writes it in the run directory, with the
output folder.
[`run_atlantis()`](https://insileco.io/atlantio/reference/run_atlantis.md)
runs the script with the run directory as its working directory, so
relative paths are relative to it; with Docker, paths must also exist
inside the container.

## Usage

``` r
write_run_script(
  dir,
  init,
  run,
  force,
  physics,
  biology,
  groups,
  fisheries,
  output = "output.nc",
  output_dir = "outputFolder",
  binary = "atlantisMerged",
  file = "run.sh"
)
```

## Arguments

- dir:

  Run directory.

- init, run, force, physics, biology, groups, fisheries:

  Input files: the initial conditions (`-i`), the run (`-r`), forcing
  (`-f`), physics (`-p`) and biology (`-b`) parameter files, the
  functional groups (`-s`) and the fisheries (`-q`).

- output:

  Name of the main output file (`-o`).

- output_dir:

  Output folder (`-d`), created in `dir` if missing.

- binary:

  The Atlantis executable: `"atlantisMerged"` (found on the PATH when
  the script runs) or a path to it.

- file:

  Name of the script.

## Value

The path to the script, invisibly.

## See also

[`run_atlantis()`](https://insileco.io/atlantio/reference/run_atlantis.md)

## Examples

``` r
dir <- tempfile()
dir.create(dir)
write_run_script(
  dir,
  init = "init.nc",
  run = "run.prm",
  force = "force.prm",
  physics = "physics.prm",
  biology = "biology.prm",
  groups = "groups.csv",
  fisheries = "fisheries.csv"
)
readLines(file.path(dir, "run.sh"))
#>  [1] "#!/bin/bash"             "set -e"                 
#>  [3] "atlantisMerged \\"       "    -i init.nc 0 \\"    
#>  [5] "    -o output.nc \\"     "    -r run.prm \\"      
#>  [7] "    -f force.prm \\"     "    -p physics.prm \\"  
#>  [9] "    -b biology.prm \\"   "    -s groups.csv \\"   
#> [11] "    -q fisheries.csv \\" "    -d outputFolder"    
```
