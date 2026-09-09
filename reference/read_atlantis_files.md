# Read Atlantis inputs and outputs files

Functions to read Atlantis inputs and outputs.

## Usage

``` r
read_atlantis_files(files, filenames = basename(files))

read_bgm(path)

read_nc(path)

read_group_file(path)

read_prm_files(path)

read_txt_files(path, filename)

read_xml(path)
```

## Arguments

- files:

  vector of paths that point to file(s) to read.

- filenames:

  file basenames. This is important for the Shiny app as files uploaded
  are renamed but the basename remains available.

- path:

  path that points to the file to read.

- filename:

  File basename.

## Value

Returns an object of class `atlantis_file`, which is a list of 3
elements:

- `path`: the path to the file;

- `type`: the type of input or output;

- `object`: the R object used by the Shiny App.

## Details

The `read_atlantis_files()` function implements a file processing
pipeline for handling diverse Atlantis ecosystem model file formats. One
or several files can be processed at once. Internally, the way files are
processed is determined by file extension using a switch statement:

- `.bgm`: Box geometry files → `[read_bgm()]`

- `.nc`: NetCDF files → `[read_nc()]`

- `.prm`: Parameter files → `[read_prm_files()]`

- `.csv`: Group definition files → `[read_group_file()]`

- `.txt`: Various output formats → `[read_txt_files()]` Basic
  examination of the content is done to determine the type of file and
  exhaustive validation is carried out if available. Note that unknown
  file types are marked as `"unknown"` rather than causing crashes, and
  unreadable files are marked as `"cannot read"`.

## Functions

- `read_bgm()`: Read BGM (box geometry) files

- `read_nc()`: Read NetCDF files and classify as init or main output

- `read_group_file()`: Read CSV group definition files

- `read_prm_files()`: Read and classify PRM parameter files

- `read_txt_files()`: Read and classify TXT output files. The name of
  the file is used as a clue to determine the type of files.

- `read_xml()`: Read XML files and convert them to lists

## Examples

``` r
hh <- system.file("examples", "inputs", "tiny_biol.prm", package = "atlantio") |>
  read_atlantis_files()
```
