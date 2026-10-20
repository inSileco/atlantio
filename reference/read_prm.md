# Parse .prm file contents into structured list

Parse .prm file contents into structured list

## Usage

``` r
read_prm(file)

write_prm(x, file = stdout(), add_comments = TRUE, sep = " ")
```

## Arguments

- file:

  Either a path to a file or a connection.

- x:

  a list of key-value pairs.

- add_comments:

  Should comments be added.

- sep:

  the separation between key and value.

## Value

A list made of key-value elements. The comments, the length of arrays
and the time unit after a value are kept as the attributes `comments`,
`array_length` and `unit` of the elements.

`NULL`, invisibly: the parameters are written to `file`.

## Details

.prm files are simple key-value text files:

     # Comments start with #
     scalar_key  1.0
     biosedprofile  gaussian
     # Arrays: key followed by count, then values on next line
     array_key 4
     1.0 1.0 1.0 1.0

The key differences between `read_prm()` and the Atlantis parser are:

- Comments: lines starting with \# are not skipped, they are collected
  and stored as an attributes to the list elements

- Units: Atlantis converts a time of the run file to seconds with the
  unit after it (e.g. `tstop 365 day`), if it knows the unit as written
  (see
  [`check_prm()`](https://insileco.io/atlantio/reference/check_prm.md));
  `read_prm()` keeps the number and the unit, as the attribute `unit`,
  which `write_prm()` writes back. A number without unit is read in
  seconds, so change values element-wise (`x$tstop[1] <- 730`):
  replacing the element (`x$tstop <- 730`) drops its attributes.

- Array padding: in the original parser, if fewer values than declared
  size, the last value is repeated to fill. `read_prm()` will throw an
  error instead.

To be consistent with the Atlantis parser, lines with more than 4000
characters (a lot, even for vectors) throw an error. A key given several
times triggers a warning, and its last occurrence is kept; Atlantis may
read another one, e.g. the first for the keys of the run file (see
[`check_prm()`](https://insileco.io/atlantio/reference/check_prm.md)).

## Functions

- `write_prm()`: Write a prm file
