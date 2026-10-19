#' Check an Atlantis initial-conditions file
#'
#' Lists the values of an initial-conditions file that Atlantis will read
#' wrongly, or that are likely mistakes. Only the cells Atlantis uses are
#' checked: the water layers of each box (`numlayers`) and the sediment
#' layers, for the tracers that exist there (attributes `inwc` and `insed`;
#' both cell types when neither is set, as for vertebrates).
#'
#' The checks (column `check` of the result) are:
#' * `"invalid"` (error): NaN or infinite values;
#' * `"negative"` (error): negative values;
#' * `"unset"` (warning): cells left unset (read as `NA`) in a variable whose
#'   `_FillValue` is not 0, so that Atlantis silently uses the fill value
#'   there (e.g. 2000 mg N m-3 of refractory detritus), unless every value
#'   set equals the fill value;
#' * `"missing"` (error): a group switched on in the groups file with no
#'   variable in the file;
#' * `"zero"`: a group switched on but with no biomass or no individual
#'   anywhere (warning), or an age class with individuals but a `StructN` or
#'   `ResN` of 0 (error);
#' * `"sisters"` (warning): a biomass pool whose typical value (median of its
#'   non-zero cells) is more than `ratio` times larger or smaller than the
#'   median of the groups of the same type (`GroupType`, the detritus types
#'   together) and units, or than the other group if there are only two.
#'
#' The last three need `groups`. Values unset are taken as Atlantis takes
#' them, i.e. equal to their fill value.
#'
#' @param path Path to the initial-conditions netCDF file.
#' @param groups The functional groups: a data frame with columns `Code`,
#'   `Name`, `IsTurnedOn`, `NumCohorts` and `GroupType` (e.g. the `group`
#'   property of an Atlantis object) or the path to the groups CSV file.
#'   If `NULL`, the checks that need the groups are skipped.
#' @param ratio Fold difference with the sister groups above which a pool is
#'   reported.
#'
#' @return An `atlantis_check` data frame, one row per finding, with columns
#'   `file`, `check`, `severity` (`"error"`, `"warning"` or `"note"`), `key`
#'   (the variable) and `message`.
#'
#' @seealso [check_prm()] for the parameter files, [set_init_values()] to
#'   change values.
#'
#' @examples
#' \dontrun{
#' check_init("LakeErieInit_NP.nc", "LakeErieGroupsDem.csv")
#' }
#'
#' @export
check_init <- function(path, groups = NULL, ratio = 100) {
  if (!is.null(groups)) {
    groups <- resolve_groups(
      groups,
      c("Code", "Name", "IsTurnedOn", "NumCohorts", "GroupType")
    )
  }
  nc <- ncdf4::nc_open(path)
  on.exit(ncdf4::nc_close(nc))
  file <- basename(path)
  cells <- init_cells(nc)

  tracers <- names(nc$var)[vapply(
    names(nc$var),
    \(v) nc_att(nc, v, "bmtype", "") %in% c("tracer", "epibenthos"),
    logical(1)
  )]
  findings <- list()
  # values as Atlantis reads them: unset cells hold the fill value
  values <- list()
  for (v in tracers) {
    x <- init_values(nc, v, cells)
    fill <- nc_att(nc, v, "_FillValue", 0)
    bad <- is.nan(x) | is.infinite(x)
    if (any(bad)) {
      findings[[length(findings) + 1]] <- check_finding(
        file, "invalid", "error", v,
        "{sum(bad)} cell{?s} with NaN or infinite values."
      )
    }
    neg <- !is.na(x) & x < 0
    if (any(neg)) {
      findings[[length(findings) + 1]] <- check_finding(
        file, "negative", "error", v,
        "{sum(neg)} negative value{?s} (min {signif(min(x[neg]), 3)})."
      )
    }
    unset <- is.na(x) & !is.nan(x)
    set <- x[!is.na(x)]
    if (any(unset) && fill != 0 && !all(set == fill)) {
      findings[[length(findings) + 1]] <- check_finding(
        file, "unset", "warning", v,
        if (length(set)) {
          "{sum(unset)} of {length(x)} cells unset: Atlantis uses the fill
          value {fill} there (values set: {signif(min(set), 3)} to
          {signif(max(set), 3)})."
        } else {
          "every cell unset: Atlantis uses the fill value {fill} everywhere."
        }
      )
    }
    x[unset] <- fill
    # reported above, not counted again by the group checks
    x[bad] <- 0
    values[[v]] <- x
  }

  if (is.null(groups)) {
    atlantio_inform("No {.arg groups}: the group checks are skipped.")
  } else {
    findings <- c(
      findings,
      check_init_groups(file, groups, values, nc, ratio)
    )
  }
  new_atlantis_check(findings)
}


#' Check Atlantis parameter files
#'
#' Lists the problems of Atlantis parameter files that Atlantis reads
#' silently (or reads differently from [read_prm()]), and combinations of
#' flags known to give wrong results. The files are scanned line by line, so
#' a malformed array does not stop the other checks (it does stop
#' [read_prm()]).
#'
#' The checks on every file (column `check` of the result) are:
#' * `"count"` (error): an array whose declared length differs from the
#'   number of values on the next line; Atlantis pads with the last value or
#'   ignores the extra values, [read_prm()] aborts;
#' * `"duplicate"` (warning): a key given twice;
#' * `"line_endings"` (warning): Windows (CRLF) line endings;
#' * `"tabs"` (note): tabs as separators;
#' * `"units"` (note): time units after values (e.g. `dt 12 hour`); Atlantis
#'   converts them, [read_prm()] keeps the numbers only;
#' * `"unknown"` (note): keys of the run file missing from the run template.
#'
#' And the checks across files, which need `bio` (and `force` for the last
#' one), for every group stocked (`flagstocking<GRP> 1` or
#' `flagrecruit<GRP> 18`, both read from the `MultRects` time series):
#' * `"stocked_twice"` (error): `flagstocking<GRP> 1` with
#'   `flagrecruit<GRP> 18`, which adds the series twice;
#' * `"random_spawn"` (warning): `flagrandom 1`, which moves the spawn day by
#'   up to 14 days, while groups are stocked: the series is read on the spawn
#'   day only;
#' * `"spawn_day"`: years whose stocking is never read because no non-zero
#'   value falls on the group's spawn day (`<GRP>_Time_Spawn`, on a 365-day
#'   year); error if no stocking is delivered at all, warning otherwise. The
#'   time series are assumed to start with the run.
#'
#' @param bio,run,force Paths to the biology, run and forcing parameter
#'   files; any can be `NULL`. The time series of the forcing file are read
#'   relative to its folder.
#'
#' @inherit check_init return
#'
#' @seealso [check_init()] for the initial-conditions file.
#'
#' @examples
#' \dontrun{
#' check_prm(bio = "le_bio.prm", run = "le_run.prm", force = "le_force.prm")
#' }
#'
#' @export
check_prm <- function(bio = NULL, run = NULL, force = NULL) {
  paths <- c(bio = bio, run = run, force = force)
  if (!length(paths)) {
    cli::cli_abort("Give at least one of {.arg bio}, {.arg run} or {.arg force}.")
  }
  scans <- lapply(paths, scan_prm)
  findings <- lapply(names(paths), \(k) {
    check_prm_file(basename(paths[[k]]), scans[[k]], type = k)
  }) |>
    unlist(recursive = FALSE)
  if (!is.null(bio)) {
    findings <- c(
      findings,
      check_stocking(
        scans$bio,
        basename(bio),
        if (!is.null(force)) scans$force,
        force
      )
    )
  }
  new_atlantis_check(findings)
}


#' Check that an Atlantis run completed
#'
#' Atlantis ends a fatal error with `quit()`, which prints the error to
#' stderr and exits with status 0, leaving the output written so far. The
#' exit status therefore does not tell a completed run from a crashed one:
#' only the time reached by the main output does. A run counts as complete
#' if the last time step of its main output is within one output interval
#' (`toutinc`) of the end of the run (`tstop`).
#'
#' The checks (column `check` of the result) are:
#' * `"missing"` (error): no main output, the run failed before writing it;
#' * `"unreadable"` (error): the main output cannot be opened;
#' * `"incomplete"` (error): the main output stops before `tstop`.
#'
#' `tstop` and `toutinc` are read with their units as Atlantis reads them
#' (e.g. `tstop 365 day`; a bare number is in seconds).
#'
#' @param output Path to the main netCDF output of the run (e.g.
#'   `output.nc`).
#' @param run Path to the run parameter file of the run.
#'
#' @inherit check_init return
#'
#' @seealso [check_prm()] for the parameter files.
#'
#' @examples
#' check_run(
#'   system.file("examples", "outputs", "output.nc", package = "atlantio"),
#'   system.file("examples", "inputs", "tiny_run.prm", package = "atlantio")
#' )
#'
#' @export
check_run <- function(output, run) {
  tstop <- prm_seconds(run, "tstop")
  toutinc <- prm_seconds(run, "toutinc", 0)
  file <- basename(output)
  if (!file.exists(output)) {
    finding <- check_finding(
      file, "missing", "error", "",
      "not found: the run failed before writing its output."
    )
    return(new_atlantis_check(list(finding)))
  }
  # ncdf4 prints its own error before signalling it
  utils::capture.output(
    nc <- tryCatch(ncdf4::nc_open(output), error = \(e) NULL)
  )
  if (is.null(nc) || is.null(nc$dim$t)) {
    finding <- check_finding(
      file, "unreadable", "error", "",
      "cannot be read as an Atlantis output (no time dimension)."
    )
    return(new_atlantis_check(list(finding)))
  }
  on.exit(ncdf4::nc_close(nc))
  time <- nc$dim$t$vals
  end <- if (length(time)) max(time) else 0
  if (grepl("^day", nc$dim$t$units)) {
    end <- end * 86400
  }
  findings <- list()
  if (end < tstop - toutinc) {
    days <- round(end / 86400, 1)
    days_stop <- round(tstop / 86400, 1)
    findings[[1]] <- check_finding(
      file, "incomplete", "error", "tstop",
      "ends at day {days} of {days_stop}: the run stopped early (Atlantis
      exits with status 0 after a fatal error, see its stderr)."
    )
  }
  new_atlantis_check(findings)
}


#' Set the values of a variable of an Atlantis initial-conditions file
#'
#' Writes values per box (and per layer for a 3D variable) into a variable of
#' an initial-conditions file, leaving the other cells as they are. Boxes are
#' numbered from 0 as in Atlantis, layers are the index of the `z` dimension
#' from 1: the water layers from 1 to `numlayers` of the box, then the
#' sediment layers (the first one is `wcnz + 1`).
#'
#' @param path Path to the initial-conditions netCDF file.
#' @param variable Name of the variable.
#' @param values A data frame with columns `box`, `value` and, for a 3D
#'   variable, `layer`.
#' @param file Path of the file written: `path` itself (the default) or a
#'   copy of it.
#'
#' @return `file`, invisibly.
#'
#' @seealso [check_init()]
#'
#' @examples
#' \dontrun{
#' # 30 mg N m-3 of refractory detritus in the surface layer of boxes 1 and 2
#' set_init_values(
#'   "init.nc",
#'   "Refractory_detritus_N",
#'   data.frame(box = 1:2, layer = 1, value = 30),
#'   file = "init_new.nc"
#' )
#' }
#'
#' @export
set_init_values <- function(path, variable, values, file = path) {
  if (!all(c("box", "value") %in% names(values))) {
    cli::cli_abort("{.arg values} needs the columns {.field box} and {.field value}.")
  }
  if (anyNA(values$value) || any(values$value < 0)) {
    cli::cli_abort("{.arg values} has missing or negative values.")
  }
  if (normalizePath(file, mustWork = FALSE) != normalizePath(path)) {
    if (!file.copy(path, file, overwrite = TRUE)) {
      cli::cli_abort("Cannot write {.path {file}}.")
    }
  }
  nc <- ncdf4::nc_open(file, write = TRUE)
  on.exit(ncdf4::nc_close(nc))
  if (!variable %in% names(nc$var)) {
    cli::cli_abort("Unknown variable {.field {variable}}.")
  }
  x <- ncdf4::ncvar_get(nc, variable, collapse_degen = FALSE)
  cells <- init_cells(nc)
  dims <- vapply(nc$var[[variable]]$dim, \(d) d$name, character(1))
  box <- values$box + 1
  if (any(box < 1 | box > nc$dim$b$len)) {
    cli::cli_abort("Boxes go from 0 to {nc$dim$b$len - 1}.")
  }
  if ("z" %in% dims) {
    if (!"layer" %in% names(values)) {
      cli::cli_abort("{.field {variable}} is 3D: {.arg values} needs {.field layer}.")
    }
    if (any(values$layer < 1 | values$layer > nc$dim$z$len)) {
      cli::cli_abort("Layers go from 1 to {nc$dim$z$len}.")
    }
    idx <- cbind(values$layer, box, 1)
    unused <- !cells$valid[cbind(values$layer, box)]
    x[idx] <- values$value
  } else {
    idx <- cbind(box, 1)
    unused <- cells$numlayers[box] == 0
    x[idx] <- values$value
  }
  if (any(unused)) {
    cli::cli_warn(
      "{sum(unused)} value{?s} written in cells Atlantis does not use."
    )
  }
  ncdf4::ncvar_put(nc, variable, x)
  invisible(file)
}


#' @export
print.atlantis_check <- function(x, ...) {
  if (!nrow(x)) {
    cli::cli_alert_success("No problem found.")
    return(invisible(x))
  }
  n <- table(factor(x$severity, levels = check_severities))
  cli::cli_text(
    "{n[['error']]} error{?s}, {n[['warning']]} warning{?s},
    {n[['note']]} note{?s}."
  )
  bullet <- c(error = "x", warning = "!", note = "i")[x$severity]
  txt <- paste0(
    x$file,
    " {.field ", cli_escape(x$key), "} (", x$check, "): ",
    cli_escape(x$message)
  )
  cli::cli_bullets(stats::setNames(txt, bullet))
  invisible(x)
}


# helpers

check_severities <- c("error", "warning", "note")

# one finding; `message` is a glue string evaluated in the caller
check_finding <- function(file, check, severity, key, message,
                          .envir = parent.frame()) {
  data.frame(
    file = file,
    check = check,
    severity = severity,
    key = key,
    message = cli::format_inline(message, .envir = .envir) |>
      stringr::str_squish()
  )
}

new_atlantis_check <- function(findings) {
  out <- do.call(rbind, findings)
  if (is.null(out)) {
    out <- data.frame(
      file = character(),
      check = character(),
      severity = character(),
      key = character(),
      message = character()
    )
  }
  out <- out[order(match(out$severity, check_severities)), , drop = FALSE]
  rownames(out) <- NULL
  class(out) <- c("atlantis_check", "data.frame")
  out
}

cli_escape <- function(x) {
  gsub("\\}", "}}", gsub("\\{", "{{", x))
}

nc_att <- function(nc, v, att, default) {
  a <- ncdf4::ncatt_get(nc, v, att)
  if (a$hasatt) a$value else default
}

# group table from a data frame or a groups CSV, with the columns needed
resolve_groups <- function(groups, needed) {
  if (is.character(groups)) {
    if (!file.exists(groups)) {
      cli::cli_abort("Cannot find the groups file {.path {groups}}.")
    }
    groups <- utils::read.csv(groups)
  }
  missing <- setdiff(needed, names(groups))
  if (length(missing)) {
    cli::cli_abort("{.arg groups} lacks column{?s} {.field {missing}}.")
  }
  groups
}

# the cells Atlantis uses: water layers 1 to numlayers and the sediment
# layers of every box with water
init_cells <- function(nc) {
  wcnz <- ncdf4::ncatt_get(nc, 0, "wcnz")$value
  sednz <- ncdf4::ncatt_get(nc, 0, "sednz")$value
  nl <- ncdf4::ncvar_get(nc, "numlayers", collapse_degen = FALSE)
  nl <- as.vector(nl)[seq_len(nc$dim$b$len)]
  # the fill value of numlayers is 0
  nl[is.na(nl)] <- 0
  nz <- nc$dim$z$len
  wc <- outer(seq_len(nz), nl, `<=`)
  sed <- outer(seq_len(nz) > wcnz & seq_len(nz) <= wcnz + sednz, nl > 0, `&`)
  list(numlayers = nl, wc = wc, sed = sed, valid = wc | sed)
}

# the values of a variable in the cells Atlantis uses (first time step)
init_values <- function(nc, v, cells) {
  x <- ncdf4::ncvar_get(nc, v, collapse_degen = FALSE)
  dims <- vapply(nc$var[[v]]$dim, \(d) d$name, character(1))
  if ("z" %in% dims) {
    x <- x[, , 1]
    inwc <- nc_att(nc, v, "inwc", 1) != 0
    insed <- nc_att(nc, v, "insed", 1) != 0
    # vertebrate tracers have neither flag set
    mask <- if (inwc || insed) {
      (cells$wc & inwc) | (cells$sed & insed)
    } else {
      cells$valid
    }
    x[mask]
  } else {
    x <- x[, 1]
    x[cells$numlayers > 0]
  }
}

check_init_groups <- function(file, groups, values, nc, ratio) {
  findings <- list()
  on <- groups[groups$IsTurnedOn == 1, ]
  pools <- list()
  for (i in seq_len(nrow(on))) {
    g <- on$Name[i]
    nums <- grep(paste0("^", g, "[0-9]+_Nums$"), names(values), value = TRUE)
    pool <- grep(paste0("^", g, "_N[0-9]*$"), names(values), value = TRUE)
    if (length(nums)) {
      total <- vapply(nums, \(v) sum(values[[v]]), numeric(1))
      if (sum(total) == 0) {
        findings[[length(findings) + 1]] <- check_finding(
          file, "zero", "warning", g,
          "switched on but has no individual in any cell."
        )
      }
      for (v in nums) {
        for (tr in c("StructN", "ResN")) {
          w <- sub("_Nums$", paste0("_", tr), v)
          if (is.null(values[[w]])) next
          if (length(values[[w]]) != length(values[[v]])) next
          bad <- values[[v]] > 0 & values[[w]] == 0
          if (any(bad)) {
            findings[[length(findings) + 1]] <- check_finding(
              file, "zero", "error", w,
              "0 in {sum(bad)} cell{?s} with individuals."
            )
          }
        }
      }
    } else if (length(pool)) {
      for (v in pool) {
        if (sum(values[[v]]) == 0) {
          findings[[length(findings) + 1]] <- check_finding(
            file, "zero", "warning", v,
            "{g} is switched on but this is 0 in every cell."
          )
        }
        nz <- values[[v]][values[[v]] > 0]
        if (length(nz)) {
          pools[[v]] <- data.frame(
            variable = v,
            family = paste(
              sub("^(LAB|REF)_DET$|^CARRION$", "DET", on$GroupType[i]),
              nc_att(nc, v, "units", "")
            ),
            typical = stats::median(nz)
          )
        }
      }
    } else {
      findings[[length(findings) + 1]] <- check_finding(
        file, "missing", "error", g,
        "switched on but has no variable in the file."
      )
    }
  }
  pools <- do.call(rbind, pools)
  for (fam in unique(pools$family)) {
    p <- pools[pools$family == fam, ]
    if (nrow(p) < 2) next
    for (j in seq_len(nrow(p))) {
      # the median of the family, or the other pool if only two
      ref <- if (nrow(p) > 2) stats::median(p$typical) else p$typical[-j]
      fold <- p$typical[j] / ref
      if (fold > ratio || fold < 1 / ratio) {
        sisters <- p$variable[-j]
        findings[[length(findings) + 1]] <- check_finding(
          file, "sisters", "warning", p$variable[j],
          "typical value {signif(p$typical[j], 3)}, x{signif(fold, 2)} the
          {if (nrow(p) > 2) 'median' else 'value'} of its sisters
          ({signif(ref, 3)}; {.field {sisters}})."
        )
      }
    }
  }
  findings
}

# scan a parameter file line by line: one row per key with the line, the
# value, the count of an array and the number of values given, and the unit
# after the value
scan_prm <- function(path) {
  raw <- readLines(path, warn = FALSE)
  lines <- sub("\r$", "", raw)
  code <- stringr::str_squish(sub("#.*$", "", lines))
  tok <- strsplit(code, "[[:blank:]]+")
  is_key <- grepl("^[A-Za-z]", code)
  is_row <- grepl("^[-+]?([0-9]|\\.[0-9])", code)
  keys <- which(is_key)
  out <- data.frame(
    line = keys,
    key = vapply(tok[keys], `[`, character(1), 1L),
    value = vapply(tok[keys], \(x) if (length(x) > 1) x[2] else NA_character_, character(1)),
    unit = vapply(tok[keys], \(x) {
      if (length(x) > 2 && !is.na(suppressWarnings(as.numeric(x[2]))) &&
        tolower(x[3]) %in% prm_units) {
        x[3]
      } else {
        NA_character_
      }
    }, character(1)),
    n_given = NA_integer_
  )
  # an array: the next non-empty line holds numbers
  for (k in seq_along(keys)) {
    nxt <- keys[k] + 1L
    while (nxt <= length(code) && !nzchar(code[nxt])) nxt <- nxt + 1L
    if (nxt <= length(code) && is_row[nxt]) {
      out$n_given[k] <- length(tok[[nxt]])
    }
  }
  # readLines() drops the carriage returns: count them in the bytes
  attr(out, "crlf") <- sum(readBin(path, "raw", file.size(path)) == as.raw(13))
  attr(out, "tabs") <- sum(grepl("\t", lines[is_key | is_row]))
  out
}

# time units Atlantis converts after a value (e.g. `dt 12 hour`)
prm_units <- c(
  "s", "sec", "secs", "second", "seconds", "min", "mins", "minute", "minutes",
  "h", "hr", "hrs", "hour", "hours", "d", "day", "days", "week", "weeks",
  "month", "months", "y", "yr", "yrs", "year", "years"
)

# a time of a parameter file in seconds, with its unit read as Atlantis does
# (strtosecs() in sjwlib/time.c): case-insensitive, optional trailing "s",
# seconds when there is no unit
prm_seconds <- function(path, key, default = NULL) {
  lines <- sub("\r$", "", readLines(path, warn = FALSE))
  code <- stringr::str_squish(sub("#.*$", "", lines))
  tok <- strsplit(code, "[[:blank:]]+")
  hit <- Filter(\(x) length(x) > 1 && x[1] == key, tok)
  if (!length(hit)) {
    if (!is.null(default)) {
      return(default)
    }
    cli::cli_abort("{.field {key}} not found in {.path {path}}.")
  }
  x <- hit[[length(hit)]]
  value <- suppressWarnings(as.numeric(x[2]))
  unit <- if (length(x) > 2) sub("^(.{2,})s$", "\\1", tolower(x[3])) else "s"
  if (is.na(value) || !unit %in% names(atlantis_seconds)) {
    cli::cli_abort(
      "Cannot read {.field {key}} {paste(x[-1], collapse = ' ')} in
      {.path {path}} as a time."
    )
  }
  value * atlantis_seconds[[unit]]
}

atlantis_seconds <- c(
  us = 1e-6, usec = 1e-6, ms = 1e-3, msec = 1e-3, s = 1, sec = 1, second = 1,
  min = 60, minute = 60, h = 3600, hr = 3600, hour = 3600, d = 86400,
  day = 86400, week = 604800
)

prm_value <- function(scan, key, default = NA) {
  v <- scan$value[scan$key == key]
  if (!length(v)) {
    return(default)
  }
  suppressWarnings(as.numeric(v[length(v)]))
}

check_prm_file <- function(file, scan, type) {
  findings <- list()
  n_declared <- suppressWarnings(as.numeric(scan$value))
  bad <- which(!is.na(scan$n_given) & n_declared != scan$n_given)
  for (k in bad) {
    findings[[length(findings) + 1]] <- check_finding(
      file, "count", "error", scan$key[k],
      "line {scan$line[k]} declares {n_declared[k]} value{?s} but the next
      line has {scan$n_given[k]}."
    )
  }
  for (key in unique(scan$key[duplicated(scan$key)])) {
    findings[[length(findings) + 1]] <- check_finding(
      file, "duplicate", "warning", key,
      "given {sum(scan$key == key)} times (lines
      {scan$line[scan$key == key]})."
    )
  }
  if (attr(scan, "crlf")) {
    findings[[length(findings) + 1]] <- check_finding(
      file, "line_endings", "warning", "",
      "Windows (CRLF) line endings on {attr(scan, 'crlf')} line{?s}."
    )
  }
  if (attr(scan, "tabs")) {
    findings[[length(findings) + 1]] <- check_finding(
      file, "tabs", "note", "",
      "tabs as separators on {attr(scan, 'tabs')} line{?s}."
    )
  }
  units <- which(!is.na(scan$unit))
  if (length(units)) {
    with_unit <- paste(scan$key[units], scan$value[units], scan$unit[units])
    findings[[length(findings) + 1]] <- check_finding(
      file, "units", "note", "",
      "{length(units)} value{?s} followed by a unit, which Atlantis converts
      but read_prm() drops (to the comments): {with_unit}."
    )
  }
  if (type == "run") {
    ref <- system.file("parameters", "run.yaml", package = "atlantio") |>
      yaml::read_yaml() |>
      vapply(\(x) x$Name, character(1))
    unknown <- setdiff(scan$key, ref)
    if (length(unknown)) {
      findings[[length(findings) + 1]] <- check_finding(
        file, "unknown", "note", "",
        "{length(unknown)} key{?s} not in the run template: {.field {unknown}}."
      )
    }
  }
  findings
}

check_stocking <- function(bio, bio_file, force, force_path) {
  findings <- list()
  codes <- function(prefix, value) {
    k <- grep(paste0("^", prefix, "[A-Za-z0-9]+$"), bio$key, value = TRUE)
    k <- k[vapply(k, \(x) isTRUE(prm_value(bio, x) == value), logical(1))]
    sub(prefix, "", k)
  }
  flag_stock <- codes("flagstocking", 1)
  flag_ts <- codes("flagrecruit", 18)
  for (g in intersect(flag_stock, flag_ts)) {
    findings[[length(findings) + 1]] <- check_finding(
      bio_file, "stocked_twice", "error", g,
      "{.field flagstocking{g}} 1 and {.field flagrecruit{g}} 18 both add the
      MultRects series: the stocking is delivered twice."
    )
  }
  stocked <- union(flag_stock, flag_ts)
  if (!length(stocked)) {
    return(findings)
  }
  if (isTRUE(prm_value(bio, "flagrandom") == 1)) {
    findings[[length(findings) + 1]] <- check_finding(
      bio_file, "random_spawn", "warning", "flagrandom",
      "1 moves the spawn day by up to 14 days, but the stocking series of
      {.field {stocked}} {?is/are} read on the spawn day only."
    )
  }
  if (is.null(force)) {
    return(findings)
  }
  n_ts <- prm_value(force, "nMultRects", 0)
  interpolate <- isTRUE(prm_value(force, "typeMultRects", 0) == 0)
  ts <- lapply(seq_len(n_ts) - 1, \(i) {
    f <- force$value[force$key == paste0("MultRects", i, ".data")]
    if (!length(f)) {
      return(NULL)
    }
    p <- file.path(dirname(force_path), f[1])
    if (!file.exists(p)) {
      p <- f[1]
    }
    if (!file.exists(p)) {
      findings[[length(findings) + 1]] <<- check_finding(
        basename(force_path), "spawn_day", "warning", f[1],
        "time series not found, stocking timing not checked."
      )
      return(NULL)
    }
    read_ts_file(p)
  })
  ts <- Filter(Negate(is.null), ts)
  year <- 365 * 86400
  for (g in stocked) {
    spawn <- prm_value(bio, paste0(g, "_Time_Spawn"))
    series <- Filter(\(d) g %in% names(d), ts)
    if (is.na(spawn) || !length(series)) next
    stocked_years <- 0
    delivered <- 0
    for (d in series) {
      o <- order(d[[1]])
      time <- d[[1]][o]
      value <- d[[g]][o]
      years <- unique(floor(time[value > 0] / year))
      stocked_years <- stocked_years + length(years)
      for (y in years) {
        # every hour of the spawn day
        t <- y * year + spawn * 86400 + seq(0, 86399, by = 3600)
        v <- stats::approx(
          time,
          value,
          t,
          method = if (interpolate) "linear" else "constant",
          rule = 2,
          f = 0,
          ties = "ordered"
        )$y
        delivered <- delivered + any(v > 0)
      }
    }
    if (delivered < stocked_years) {
      findings[[length(findings) + 1]] <- check_finding(
        basename(force_path), "spawn_day",
        if (delivered == 0) "error" else "warning", g,
        "{stocked_years - delivered} of {stocked_years} box-year{?s} of
        stocking {?has/have} no value on the spawn day ({spawn}), the only day
        the series is read: {if (delivered == 0) 'no fish is delivered' else
        'these are lost'}."
      )
    }
  }
  findings
}

# an Atlantis .ts file: the columns named in the header, time in seconds
read_ts_file <- function(path) {
  lines <- sub("\r$", "", readLines(path, warn = FALSE))
  hdr <- stringr::str_match(lines, "^##\\s*COLUMN([0-9]+)\\.name\\s+(\\S+)")
  hdr <- hdr[!is.na(hdr[, 1]), , drop = FALSE]
  nms <- hdr[order(as.integer(hdr[, 2])), 3]
  units <- stringr::str_match(lines, "^##\\s*COLUMN1\\.units\\s+(\\S+)")[, 2]
  units <- units[!is.na(units)][1]
  data <- lines[!grepl("^#", lines) & nzchar(trimws(lines))]
  out <- utils::read.table(
    text = data,
    col.names = nms,
    check.names = FALSE
  )
  if (isTRUE(grepl("^day", units))) {
    out[[1]] <- out[[1]] * 86400
  }
  out
}
