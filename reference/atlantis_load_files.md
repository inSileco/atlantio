# Load Atlantis files into model object

Load Atlantis input and output files into an existing Atlantis object.
This function automatically detects file types and assigns data to the
appropriate properties based on file extensions and content. Only
properties with newly loaded data are updated; existing properties are
preserved unless overwritten.

## Usage

``` r
atlantis_load_files(atlantis, files, filenames = basename(files))
```

## Arguments

- atlantis:

  An existing Atlantis S7 object to update with new data.

- files:

  Either:

  - Character vector of file paths to Atlantis files

  - An `atlantis_file` object (created by
    [`read_atlantis_files()`](read_atlantis_files.md))

  Supported file types include:

  - `.geometry` - Box Geometry Model files

  - `.prm` - Parameter files (bio and run)

  - `.nc` - NetCDF output files

  - `.txt`, `.csv` - Diet and biomass snapshot files

- filenames:

  file basenames (used as hints)

## Value

Updated Atlantis S7 object with newly loaded data merged with existing
properties.

## See also

[`read_atlantis_files()`](read_atlantis_files.md),
[`new_atlantis()`](new_atlantis.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Create empty object and load files
atlantis <- new_atlantis()  |>
 atlantis_load_files(c(
  "model.geometry",
  "biology.prm",
  "run.prm",
  "output.nc"
))

# Load additional files later
atlantis <- atlantis_load_files(atlantis, "diet_check.txt")
} # }
```
