# Create new Atlantis model object

Constructor function for creating a new, empty Atlantis model object.
All properties are initialized as NULL and can be populated later using
[`atlantis_load_files()`](atlantis_load_files.md) or by direct
assignment.

## Usage

``` r
new_atlantis(...)
```

## Arguments

- ...:

  Optional named arguments to initialize specific properties. Property
  names should match those defined in the Atlantis class (e.g.,
  geometry, bio, run, etc.).

## Value

An Atlantis S7 object with all properties initialized to NULL unless
specified in the arguments.

## See also

[`atlantis_load_files()`](atlantis_load_files.md) for loading data from
files

## Examples

``` r
if (FALSE) { # \dontrun{
# Create empty Atlantis object
atlantis <- new_atlantis()

# Create with some initial data
atlantis <- new_atlantis(
  geometry = my_geometry_data,
  bio = my_biology_params
)
} # }
```
