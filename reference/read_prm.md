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

  the separation bewteen key and value.

## Value

A list made of key-value elements. Note that comments and length of
vectr

The prm file.

## Details

.prm files are simple key-value text files:

     #' Comments start with #
     scalar_key  1.0
     biosedprofile  gaussian
     # Arrays: key followed by count, then values on next line
     array_key 4
     1.0 1.0 1.0 1.0.

The key differences between `read_prm()` and the Atlantis parser are:

- Comments: lines starting with \# are not skipped, they are collected
  and stored as an attributes to the list elements

- Array padding: in the original parser, if fewer values than declared
  size, the last value is repeated to fill. `read_prm()` will throw an
  error instead.

To be consistent with the Atlantis parser, lines with more than 4000
characters (a lot, even for vectors) throw an error. Also, key
duplicates will trigger warnings and the

## Functions

- `write_prm()`: Write a prm file
