# Generate parameter files

Generate parameter files

## Usage

``` r
generate_file(x = "run", version = "latest", description = TRUE, file = x, ...)
```

## Arguments

- x:

  File type to generate. Currently supports "run" for run parameter
  files.

- version:

  Atlantis version (currently ignored).

- description:

  Logical. Should parameter descriptions be added as comments in the
  output file?

- file:

  A character string naming the output file. The file extension will be
  ignored and replaced with the expected one (.prm for run files).

- ...:

  Additional values to change (currently not implemented).

## Value

Invisibly returns the path to the generated file.

## Details

Generates parameter files using recommended values from the package's
internal parameter database. If recommended values are missing,
'\<\<TO_EDIT\>\>' is added as a placeholder that users should replace
with appropriate values. Here are the abbreviations used:

- : groups abbreviation

- : fisheries

- : cohort

- : move group code

- : tracer name

The function reads parameter specifications from the package's internal
YAML files and organizes them by category in the output file.

## Examples

``` r
# Generate a run parameter file with default settings
# generate_file(file = "run.prm")

# Generate without descriptions
# generate_file(x = "run", file = "my_run.prm", description = FALSE)
```
