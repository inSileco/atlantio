# List Atlantis parameters for a given Atlantis version

Returns the list of Atlantis parameters bundled with the package for a
given Atlantis version. Supported versions are listed in
[atlantis_supported_versions](atlantis_supported_versions.md).

## Usage

``` r
list_atlantis_parameters(version = "3-6722")
```

## Arguments

- version:

  Atlantis version, formatted as `"<major_version>-<svn_revision>"`
  (e.g. `"3-6722"`). See
  [atlantis_supported_versions](atlantis_supported_versions.md) for the
  list of supported versions.

## Value

A list of 2 elements:

- `meta`: metadata about the Atlantis code base the parameters were
  extracted from (`atlantis_source`, `atlantis_version`, `bm_struct`)
  and `files`, the list of parameter files declaring the parameters;

- `parameters`: a list where every element describes one parameter with
  the following fields: `name`, `description`, `source_file`,
  `value_type`, `dimension`, `units`, `bm_member`, `reader` and
  `conditional_on`.

## Examples

``` r
prm_list <- list_atlantis_parameters()
prm_list$meta
#> $atlantis_source
#> [1] "AtlantisTrunk/atlantis"
#> 
#> $atlantis_version
#> [1] 3.6722
#> 
#> $bm_struct
#> [1] "MSEBoxModel"
#> 
#> $files
#> $files$physics_prm
#> $files$physics_prm$cli_flag
#> [1] "-p"
#> 
#> $files$physics_prm$bm_field
#> [1] "physprmIfname"
#> 
#> $files$physics_prm$reader_mechanism
#> [1] "direct key-value (readkeyprm_*)"
#> 
#> 
#> $files$run_prm
#> $files$run_prm$cli_flag
#> [1] "-r"
#> 
#> $files$run_prm$bm_field
#> [1] "runprmIfname"
#> 
#> $files$run_prm$reader_mechanism
#> [1] "prm->XML (Util_XML_Read_*)"
#> 
#> 
#> $files$biology_prm
#> $files$biology_prm$cli_flag
#> [1] "-b"
#> 
#> $files$biology_prm$bm_field
#> [1] "bioprmIfname"
#> 
#> $files$biology_prm$reader_mechanism
#> [1] "prm->XML (Util_XML_Read_Species_Param etc.)"
#> 
#> 
#> $files$forcing_prm
#> $files$forcing_prm$cli_flag
#> [1] "-f"
#> 
#> $files$forcing_prm$bm_field
#> [1] "forceIfname"
#> 
#> $files$forcing_prm$reader_mechanism
#> [1] "direct key-value (readkeyprm_*)"
#> 
#> 
#> $files$harvest_prm
#> $files$harvest_prm$cli_flag
#> [1] "-h"
#> 
#> $files$harvest_prm$bm_field
#> [1] "fishprmIfname"
#> 
#> $files$harvest_prm$reader_mechanism
#> [1] "prm->XML (Util_XML_Read_Fishery_Param etc.)"
#> 
#> 
#> $files$groups_csv
#> $files$groups_csv$cli_flag
#> [1] "-s"
#> 
#> $files$groups_csv$bm_field
#> [1] "functionGroupIfname"
#> 
#> $files$groups_csv$reader_mechanism
#> [1] "csv->XML (Util_Read_Functional_Group_XML)"
#> 
#> 
#> $files$fisheries_csv
#> $files$fisheries_csv$cli_flag
#> [1] "-q"
#> 
#> $files$fisheries_csv$bm_field
#> [1] "fisheryIfname"
#> 
#> $files$fisheries_csv$reader_mechanism
#> [1] "csv->XML (Util_Read_Fisheries_XML)"
#> 
#> 
#> 
prm_list$parameters[[1]]
#> $name
#> [1] "include_atmosphere"
#> 
#> $description
#> [1] "Switch enabling the atmospheric exchange concentrations block"
#> 
#> $source_file
#> [1] "physics_prm"
#> 
#> $value_type
#> [1] "int"
#> 
#> $dimension
#> [1] "scalar"
#> 
#> $units
#> NULL
#> 
#> $bm_member
#> [1] "bm->include_atmosphere"
#> 
#> $reader
#> $reader$fn
#> [1] "readkeyprm_i"
#> 
#> $reader$at
#> [1] "atphysics/atphysics.c:229"
#> 
#> $reader$check
#> [1] "none"
#> 
#> 
#> $conditional_on
#> NULL
#> 
```
