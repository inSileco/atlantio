#' Parse .prm file contents into structured list
#'
#' @param file Either a path to a file or a connection.
#'
#' @return
#' A list made of key-value elements.
#' Note that comments and length of vectr
#'
#' @details
#' .prm files are simple key-value text files:
#' ```
#'  #' Comments start with #
#'  scalar_key  1.0
#'  biosedprofile  gaussian
#'  # Arrays: key followed by count, then values on next line
#'  array_key 4
#'  1.0 1.0 1.0 1.0.
#' ```
#' The key differences between `read_prm()` and the Atlantis parser are:
#'  * Comments: lines starting with # are not skipped, they are collected and stored as
#'  an attributes to the list elements
#'  * Array padding: in the original parser, if fewer values than declared size,
#'  the last value is repeated to fill. `read_prm()` will throw an error instead.
#'
#' To be consistent with the Atlantis parser, lines with more than 4000
#' characters (a lot, even for vectors) throw an error. Also, key duplicates will
#' trigger warnings and the
#'
#' @export

read_prm <- function(file) {
  # read line by line and split using ending white space or tab
  prm_lines <- readLines(file) |>
    lapply(stringr::str_squish) |>
    Filter(f = \(x) x != "") |> # move empty lines
    unlist() |>
    strsplit(split = "[ \t]+")

  out <- list()
  comments <- list()
  nm <- ""
  k <- 0
  for (i in seq_along(prm_lines)) {
    prm_line <- prm_lines[[i]]

    nch <- nchar(prm_line) |> sum()
    if (nch > 4000) {
      cli::cli_abort("More than 4000 characters on one line.")
    }

    # collect comments for the next one
    if (grepl("^#", prm_line[1])) {
      comments <- c(
        comments,
        paste(prm_line, collapse = " ") |>
          stringr::str_remove("^#+") |>
          stringr::str_squish()
      )
      if (i == length(prm_lines)) {
        cli::cli_warn("Final comments are ignored.")
      }
      next
    }

    # key-pair value
    if (grepl("^[A-Za-z]", prm_line[1])) {
      nm <- prm_line[1]
      if (length(prm_line) == 1) {
        cli::cli_abort("`{nm}` has no value.")
      }
      val <- prm_line[2] |> to_num()
      if (length(prm_line) > 2) {
        comments <- c(
          comments,
          paste(prm_line[-(1L:2L)], collapse = " ") |>
            stringr::str_remove("^#+") |>
            stringr::str_squish()
        )
      }
      if (nm %in% names(out)) {
        cli::cli_warn("Duplicated key `{nm}`, using the last occurrence.")
      }
      out[[nm]] <- val
      if (length(comments)) {
        attr(out[[nm]], "comments") <- comments |> unlist()
        # reset
        comments <- list()
      }
    }

    # row
    if (grepl("^[0-9\\.]", prm_line[1])) {
      if (nm == "") {
        cli::cli_abort("Array ({prm_line}) without key.")
      }
      val <- suppressWarnings(prm_line |> as.numeric())
      if (any(is.na(val))) {
        cli::cli_abort(
          "Array ({prm_line}) includes elements that cannot be coerced to numeric."
        )
      }
      if (length(val) != out[[nm]]) {
        cli::cli_abort(
          "Dimension mismatch for array `{nm}`: {out[[nm]]} element{?s}
          expected, but {length(val)} available."
        )
      }
      if (!is.null(attr(out[[nm]], "comments"))) {
        attr(val, "comments") <- attr(out[[nm]], "comments")
      }
      attr(val, "array_length") <- length(val)
      out[[nm]] <- val
    }
  }

  out
}

#' @describeIn read_prm Write a prm file
#'
#' @param x a list of key-value pairs.
#' @param add_comments Should comments be added.
#' @param sep the separation bewteen key and value.
#'
#' @return
#' The prm file.
#'
#' @export
write_prm <- function(x, file = stdout(), add_comments = TRUE, sep = " ") {
  if (!grepl("^[[:blank:]]+$", sep)) {
    cli::cli_warn(
      "Separation must be white spaces or tabs so the file could be parsed."
    )
  }
  out <- lapply(
    names(x),
    \(y) {
      if (add_comments && !is.null(attr(x[[y]], "comments"))) {
        txt <- paste(
          "#",
          lapply(attr(x[[y]], "comments"), strwrap, width = 78) |> unlist()
        )
      } else {
        txt <- NULL
      }

      if (is.null(attr(x[[y]], "array_length"))) {
        txt <- c(
          txt,
          paste0(y, sep, x[[y]])
        )
      } else {
        txt <- c(
          txt,
          paste0(
            y,
            sep,
            attr(x[[y]], "array_length"),
            "\n",
            paste(x[[y]], collapse = " ")
          )
        )
      }
    }
  )
  unlist(out) |> writeLines(file)
}
