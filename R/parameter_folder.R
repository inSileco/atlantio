#' Apply a set of calibrated values to an Atlantis object
#'
#' Sets the values of a calibration table, e.g. the parameters of the best
#' run of a calibration, in the parameter files loaded in an Atlantis object.
#' Each row of `calib_table` names a parameter (`name`), a position in it
#' (`position`), its file (`source_file`) and, for values on the calibration
#' scale, its transformation (`transf`).
#'
#' @param x An `Atlantis` object with the parameter files of `calib_table`
#'   loaded.
#' @param calib_table A calibration table, as returned by
#'   [generate_calibration_table()].
#' @param par The values, one per row of `calib_table`.
#' @param scale Scale of `par`: `"calibration"` (default), the scale the
#'   optimizer works on, mapped to the file scale with
#'   [transform_parameter_value()], or `"model"`, the values as written in the
#'   parameter files.
#'
#' @return `x` with the values set.
#'
#' @seealso [write_parameter_folder()] to write the files, [compare_prm()] to
#'   compare them.
#'
#' @examples
#' mod <- new_atlantis() |>
#'   atlantis_load_files(c(
#'     atlantis_examples("inputs", "tiny_biol.prm"),
#'     atlantis_examples("inputs", "tiny_groups.csv")
#'   ))
#' tbl <- generate_calibration_table(
#'   mod,
#'   atlantis_examples("calibrate", "mum.yaml")
#' )
#' # every value one tenth of its current value
#' mod <- apply_parameters(mod, tbl, log10(tbl$cur_value) - 1)
#' mod@biology$mum_GZS
#'
#' @export
apply_parameters <- function(
  x,
  calib_table,
  par,
  scale = c("calibration", "model")
) {
  scale <- match.arg(scale)
  require_atlantis(x)
  needed <- c("name", "position", "transf", "source_file")
  missing <- setdiff(needed, names(calib_table))
  if (length(missing)) {
    cli::cli_abort("{.arg calib_table} lacks column{?s} {.field {missing}}.")
  }
  if (length(par) != nrow(calib_table)) {
    cli::cli_abort(
      "{.arg par} has {length(par)} value{?s} for {nrow(calib_table)} row{?s}
      of {.arg calib_table}."
    )
  }
  par <- unname(as.numeric(par))
  if (scale == "calibration") {
    par <- mapply(transform_parameter_value, par, calib_table$transf)
  }
  for (src in unique(calib_table$source_file)) {
    prop <- get_prop_name(src)
    prm <- S7::prop(x, prop)
    if (is.null(prm)) {
      cli::cli_abort("No {prop} file loaded in {.arg x}.")
    }
    for (i in which(calib_table$source_file == src)) {
      nm <- calib_table$name[i]
      pos <- calib_table$position[i]
      if (is.null(prm[[nm]])) {
        cli::cli_abort("{.field {nm}} not found in the {prop} file.")
      }
      if (pos > length(prm[[nm]])) {
        cli::cli_abort(
          "Position {pos} out of range for {.field {nm}} ({length(prm[[nm]])}
          value{?s})."
        )
      }
      # element assignment keeps the array_length and comments attributes
      prm[[nm]][pos] <- par[i]
    }
    S7::prop(x, prop) <- prm
  }
  x
}


#' Write a complete Atlantis parameter folder
#'
#' Writes the input files of an Atlantis object into a folder, e.g. to build
#' the parameter folder of the next calibration round from the previous one
#' and the calibrated values (see [apply_parameters()]).
#'
#' The run and biology parameter files are written from their source file
#' with only the values that differ from it changed, token by token: the
#' comments, the units (e.g. `tstop 365 day`), the layout and the line
#' endings are kept. A key given several times in its file is not changed:
#' Atlantis may read another occurrence than the one changed (see
#' [check_prm()]), so the function aborts. The other input files loaded
#' (geometry, groups, initial conditions, ...) are copied. Every file keeps
#' the name of its source.
#'
#' Files that are not loaded in `x`, such as the physics and forcing
#' parameter files or the forcing time series, come from `from`: a folder
#' copied whole into `dir` first, whose files are then replaced by those of
#' `x`.
#'
#' @param x An `Atlantis` object.
#' @param dir The folder to write, created if needed.
#' @param from A folder to copy into `dir` first, or `NULL`.
#' @param overwrite Allow `dir` to hold files already?
#'
#' @return Invisibly, a data frame of the values changed, one row per value:
#'   `file`, `key`, `position`, `old` and `new` (as written in the files).
#'
#' @seealso [apply_parameters()], [compare_prm()] to compare two parameter
#'   files.
#'
#' @examples
#' mod <- new_atlantis() |>
#'   atlantis_load_files(c(
#'     atlantis_examples("inputs", "tiny_run.prm"),
#'     atlantis_examples("inputs", "tiny_biol.prm"),
#'     atlantis_examples("inputs", "tiny_groups.csv")
#'   ))
#' mod@biology$mum_GZS[1] <- 0.04
#' dir <- file.path(tempdir(), "params_v2")
#' write_parameter_folder(mod, dir)
#' list.files(dir)
#'
#' @export
write_parameter_folder <- function(x, dir, from = NULL, overwrite = FALSE) {
  require_atlantis(x)
  if (!overwrite && length(list.files(dir, all.files = TRUE, no.. = TRUE))) {
    cli::cli_abort(
      "{.path {dir}} is not empty; set {.code overwrite = TRUE} to write into
      it."
    )
  }
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  if (!is.null(from)) {
    if (!dir.exists(from)) {
      cli::cli_abort("Cannot find the folder {.path {from}}.")
    }
    if (normalizePath(from) == normalizePath(dir)) {
      cli::cli_abort("{.arg from} and {.arg dir} are the same folder.")
    }
    fs::dir_copy(from, dir, overwrite = TRUE)
  }
  inputs <- x@file_paths[
    x@file_paths$type == "input" & !is.na(x@file_paths$path),
  ]
  changes <- list()
  for (i in seq_len(nrow(inputs))) {
    src <- inputs$path[i]
    out <- file.path(dir, basename(src))
    if (inputs$name[i] %in% c("run", "biology")) {
      prm <- S7::prop(x, inputs$name[i])
      changes[[length(changes) + 1]] <- patch_prm(src, prm, out)
    } else if (normalizePath(src) != normalizePath(out, mustWork = FALSE)) {
      file.copy(src, out, overwrite = TRUE)
    }
  }
  changes <- do.call(rbind, changes)
  if (is.null(changes)) {
    changes <- data.frame(
      file = character(),
      key = character(),
      position = integer(),
      old = character(),
      new = character()
    )
  }
  cli::cli_alert_success(
    "{nrow(inputs)} input file{?s} written to {.path {dir}},
    {nrow(changes)} value{?s} changed."
  )
  invisible(changes)
}


#' Compare two Atlantis parameter files
#'
#' Compares two parameter files by parameter name rather than line by line,
#' so that moved lines, comments and layout do not show up: one row per value
#' that differs, per parameter only in one of the files, and per position
#' only in one of the arrays when their lengths differ. Numbers are compared
#' as numbers (`1.0` and `1` are equal).
#'
#' @param x,y Two parameter files: paths, or lists as returned by
#'   [read_prm()] (e.g. the `biology` property of an Atlantis object).
#'
#' @return A data frame with columns `key`, `position` (`NA` for a
#'   parameter only in one file), `x` and `y` (the values as text, `NA` where
#'   missing).
#'
#' @seealso [write_parameter_folder()]
#'
#' @examples
#' bio <- read_prm(atlantis_examples("inputs", "tiny_biol.prm"))
#' new <- bio
#' new$mum_GZS[2] <- 0.004
#' new$flagnew <- 1
#' compare_prm(bio, new)
#'
#' @export
compare_prm <- function(x, y) {
  if (is.character(x)) {
    x <- read_prm(x)
  }
  if (is.character(y)) {
    y <- read_prm(y)
  }
  keys <- union(names(x), names(y))
  out <- lapply(keys, \(k) {
    a <- x[[k]]
    b <- y[[k]]
    if (is.null(a) || is.null(b)) {
      return(data.frame(
        key = k,
        position = NA_integer_,
        x = prm_text(a),
        y = prm_text(b)
      ))
    }
    n <- max(length(a), length(b))
    # read_prm() parses the numbers, so their text is canonical
    pa <- prm_text(a)[seq_len(n)]
    pb <- prm_text(b)[seq_len(n)]
    same <- !is.na(pa) & !is.na(pb) & pa == pb
    if (all(same)) {
      return(NULL)
    }
    data.frame(key = k, position = which(!same), x = pa[!same], y = pb[!same])
  })
  out <- do.call(rbind, out)
  if (is.null(out)) {
    out <- data.frame(
      key = character(),
      position = integer(),
      x = character(),
      y = character()
    )
  }
  rownames(out) <- NULL
  out
}


# helpers

prm_text <- function(v) {
  if (is.null(v)) {
    return(NA_character_)
  }
  as.character(v)
}

prm_number <- function(v) {
  suppressWarnings(as.numeric(v))
}

# write `file` to `out` with the values of the parameter list `prm` that
# differ from those in the file changed in place, token by token; returns
# the changes
patch_prm <- function(file, prm, out) {
  raw <- readBin(file, "raw", file.size(file))
  eol <- if (any(raw == as.raw(13))) "\r\n" else "\n"
  lines <- readLines(file, warn = FALSE)
  # the tokens before any comment, positions shared with the full line
  code <- sub("#.*$", "", lines)
  tok <- gregexpr("[^[:blank:]]+", code)
  first <- vapply(regmatches(code, tok), \(t) if (length(t)) t[1] else "", "")
  is_key <- grepl("^[A-Za-z]", first)
  changes <- list()
  for (nm in names(prm)) {
    occ <- which(is_key & first == nm)
    if (!length(occ)) {
      cli::cli_abort("{.field {nm}} not found in {.path {file}}.")
    }
    # the last occurrence, as read_prm() reads it
    li <- occ[length(occ)]
    v <- prm[[nm]]
    if (is.null(attr(v, "array_length"))) {
      at <- li
      idx <- 2L
    } else {
      at <- li + 1L
      while (at <= length(code) && !nzchar(trimws(code[at]))) {
        at <- at + 1L
      }
      idx <- seq_along(v)
    }
    old <- regmatches(code[at], tok[at])[[1]][idx]
    if (anyNA(old)) {
      cli::cli_abort(
        "{.field {nm}} has {length(v)} value{?s} but fewer in {.path {file}}."
      )
    }
    new <- as.character(v)
    num_old <- prm_number(old)
    num_new <- prm_number(new)
    diff <- which(ifelse(
      is.na(num_old) | is.na(num_new),
      old != new,
      num_old != num_new
    ))
    if (!length(diff)) {
      next
    }
    if (length(occ) > 1) {
      cli::cli_abort(
        "{.field {nm}} is given {length(occ)} times in {.path {file}} (lines
        {occ}): Atlantis may not read the occurrence changed, remove the
        duplicates first."
      )
    }
    lines[at] <- replace_tokens(lines[at], tok[[at]], idx[diff], new[diff])
    changes[[length(changes) + 1]] <- data.frame(
      file = basename(out),
      key = nm,
      position = diff,
      old = old[diff],
      new = new[diff]
    )
  }
  con <- file(out, "wb")
  on.exit(close(con))
  writeLines(lines, con, sep = eol)
  do.call(rbind, changes)
}

# replace the tokens `idx` (positions from gregexpr()) of a line, from the
# last so that earlier positions stay valid
replace_tokens <- function(line, m, idx, new) {
  start <- m[idx]
  len <- attr(m, "match.length")[idx]
  for (j in rev(order(start))) {
    line <- paste0(
      substr(line, 1, start[j] - 1),
      new[j],
      substr(line, start[j] + len[j], nchar(line))
    )
  }
  line
}
