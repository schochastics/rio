.docall <- function(.fcn, ..., args = NULL, alwaysArgs = NULL, .functions = list(.fcn),
                    .ignoreUnusedArgs = TRUE) {
    ## the same as R.utils::doCall, only with default option
    R.utils::doCall(.fcn = .fcn, ..., args = args, alwaysArgs = alwaysArgs, .functions = .functions,
                    .ignoreUnusedArgs = getOption("rio.ignoreunusedargs", default = TRUE))
}

.remap_tidy_convention <- function(func, file, which, header, ...) {
    dots <- list(...)
    if ("path" %in% names(dots)) {
        dots[["path"]] <- NULL
    }
    if ("sheet" %in% names(dots)) {
        which <- dots[["sheet"]]
        dots[["sheet"]] <- NULL
    }
    if ("col_names" %in% names(dots)) {
        header <- dots[["col_names"]]
        dots[["col_names"]] <- NULL
    }
    .docall(func, args = c(dots, list(path = file, sheet = which, col_names = header)))
}

import_delim <- function(file, which = 1, sep = "auto", header = "auto", stringsAsFactors = FALSE, data.table = FALSE, ...) {
    .docall(data.table::fread, ..., args = list(input = file, sep = sep, header = header,
                  stringsAsFactors = stringsAsFactors,
                  data.table = data.table))
}

#' @export
.import.rio_dat <- function(file, which = 1, ...) {
    message(sprintf("Ambiguous file format ('.dat'), but attempting 'data.table::fread(\"%s\")'", file))
    import_delim(file = file, ...)
}

#' @export
.import.rio_tsv <- function(file, sep = "auto", which = 1, fread = lifecycle::deprecated(), dec = if (sep %in% c("\t", "auto")) "." else ",", ...) {
    if (lifecycle::is_present(fread)) {
        lifecycle::deprecate_warn(when = "0.5.31", what = "import(fread)", details = "tsv will always be read by `data.table:fread()`. The parameter `fread` will be dropped in v2.0.0.")
    }
    import_delim(file = file, sep = sep, dec = dec, ...)
}

#' @export
.import.rio_txt <- function(file, sep = "auto", which = 1, fread = lifecycle::deprecated(), dec = if (sep %in% c(",", "auto")) "." else ",", ...) {
    if (lifecycle::is_present(fread)) {
        lifecycle::deprecate_warn(when = "0.5.31", what = "import(fread)", details = "txt will always be read by `data.table:fread()`. The parameter `fread` will be dropped in v2.0.0.")
    }
    import_delim(file = file, sep = sep, dec = dec, ...)
}

#' @export
.import.rio_csv <- function(file, sep = ",", which = 1, fread = lifecycle::deprecated(), dec = if (sep %in% c(",", "auto")) "." else ",", ...) {
    if (lifecycle::is_present(fread)) {
        lifecycle::deprecate_warn(when = "0.5.31", what = "import(fread)", details = "csv will always be read by `data.table:fread()`. The parameter `fread` will be dropped in v2.0.0.")
    }
    import_delim(file = file, sep = if (sep == ",") "auto" else sep, dec = dec, ...)
}

#' @export
.import.rio_csv2 <- function(file, sep = ";", which = 1, fread = lifecycle::deprecated(), dec = if (sep %in% c(";", "auto")) "," else ".", ...) {
    if (lifecycle::is_present(fread)) {
        lifecycle::deprecate_warn(when = "0.5.31", what = "import(fread)", details = "csv2 will always be read by `data.table:fread()`. The parameter `fread` will be dropped in v2.0.0.")
    }
    import_delim(file = file, sep = if (sep == ";") "auto" else sep, dec = dec, ...)
}

#' @export
.import.rio_csvy <- function(file, sep = ",", which = 1, fread = lifecycle::deprecated(), dec = if (sep %in% c(",", "auto")) "." else ",", yaml = TRUE, ...) {
    if (lifecycle::is_present(fread)) {
        lifecycle::deprecate_warn(when = "0.5.31", what = "import(fread)", details = "csvy will always be read by `data.table:fread()`. The parameter `fread` will be dropped in v2.0.0.")
    }
    import_delim(file = file, sep = if (sep == ",") "auto" else sep, dec = dec, yaml = yaml, ...)
}

#' @export
.import.rio_psv <- function(file, sep = "|", which = 1, fread = lifecycle::deprecated(), dec = if (sep %in% c("|", "auto")) "." else ",", ...) {
    if (lifecycle::is_present(fread)) {
        lifecycle::deprecate_warn(when = "0.5.31", what = "import(fread)", details = "psv will always be read by `data.table:fread()`. The parameter `fread` will be dropped in v2.0.0.")
    }
    import_delim(file = file, sep = if (sep == "|") "auto" else sep, dec = dec, ...)
}

#' @export
.import.rio_fwf <-
    function(file,
             which = 1,
             widths,
             header = FALSE,
             col.names,
             comment = "#",
             readr = lifecycle::deprecated(),
             progress = getOption("verbose", FALSE),
             ...) {
        if (lifecycle::is_present(readr)) {
            lifecycle::deprecate_warn(when = "0.5.31", what = "import(readr)", details = "fwt will always be read without `readr`. The parameter `readr` will be dropped in v2.0.0.")
        }
        if (missing(widths)) {
            stop("Import of fixed-width format data requires a 'widths' argument. See ? read.fwf().")
        }
        if (!missing(col.names)) {
            read.fwf2(file = file, widths = widths, header = header, col.names = col.names, ...)
        } else {
            read.fwf2(file = file, widths = widths, header = header, ...)
        }
    }

#' @export
.import.rio_r <- function(file, which = 1, ...) {
    dget(file = file, ...)
}

#' @export
.import.rio_dump <- function(file, which = 1, envir = new.env(), ...) {
    source(file = file, local = envir)
    if (length(list(...)) > 0) {
        warning("File imported using load. Arguments to '...' ignored.")
    }
    if (missing(which)) {
        if (length(ls(envir)) > 1) {
            warning("Dump file contains multiple objects. Returning first object.")
        }
        which <- 1
    }
    if (is.numeric(which)) {
        get(ls(envir)[which], envir)
    } else {
        get(ls(envir)[grep(which, ls(envir))[1]], envir)
    }
}

#' @export
.import.rio_rds <- function(file, which = 1, ...) {
    if (length(list(...)) > 0) {
        warning("File imported using readRDS. Arguments to '...' ignored.")
    }
    readRDS(file = file)
}

#' @export
.import.rio_rdata <- function(file, which = 1, envir = new.env(), ...) {
    load(file = file, envir = envir)
    if (length(list(...)) > 0) {
        warning("File imported using load. Arguments to '...' ignored.")
    }
    if (missing(which)) {
        if (length(ls(envir)) > 1) {
            warning("Rdata file contains multiple objects. Returning first object.")
        }
        which <- 1
    }
    if (is.numeric(which)) {
        get(ls(envir)[which], envir)
    } else {
        get(ls(envir)[grep(which, ls(envir))[1]], envir)
    }
}

#' @export
.import.rio_rda <- .import.rio_rdata

#' @export
.import.rio_feather <- function(file, which = 1, ...) {
    .check_pkg_availability("feather")
    arrow::read_feather(file = file, ...)
}

#' @export
.import.rio_fst <- function(file, which = 1, ...) {
    .check_pkg_availability("fst")
    fst::read.fst(path = file, ...)
}

#' @export
.import.rio_matlab <- function(file, which = 1, ...) {
    .check_pkg_availability("rmatio")
    rmatio::read.mat(filename = file)
}

#' @export
.import.rio_dta <- function(file, haven = lifecycle::deprecated(),
                            convert.factors = lifecycle::deprecated(), which = 1, ...) {
    if (lifecycle::is_present(haven) || lifecycle::is_present(convert.factors)) {
        lifecycle::deprecate_warn(when = "0.5.31", what = "import(haven)", details = "dta will always be read by `haven`. The parameter `haven` will be dropped in v2.0.0.")
    }
    standardize_attributes(.docall(haven::read_dta, ..., args = list(file = file)))
}

#' @export
.import.rio_dbf <- function(file, which = 1, as.is = TRUE, ...) {
    foreign::read.dbf(file = file, as.is = as.is)
}

#' @export
.import.rio_dif <- function(file, which = 1, ...) {
    utils::read.DIF(file = file, ...)
}

#' @export
.import.rio_sav <- function(file, which = 1, haven = lifecycle::deprecated(), to.data.frame = lifecycle::deprecated(), use.value.labels = lifecycle::deprecated(), ...) {
    if (lifecycle::is_present(haven) || lifecycle::is_present(to.data.frame) || lifecycle::is_present(use.value.labels)) {
        lifecycle::deprecate_warn(when = "0.5.31", what = "import(haven)", details = "sav will always be read by `haven`. The parameter `haven` will be dropped in v2.0.0.")
    }
    standardize_attributes(haven::read_sav(file = file))
}

#' @export
.import.rio_zsav <- function(file, which = 1, ...) {
    standardize_attributes(haven::read_sav(file = file))
}

#' @export
.import.rio_spss <- function(file, which = 1, ...) {
    standardize_attributes(haven::read_por(file = file))
}

#' @export
.import.rio_sas7bdat <- function(file, which = 1, column.labels = FALSE, ...) {
    standardize_attributes(haven::read_sas(data_file = file, ...))
}

#' @export
.import.rio_xpt <- function(file, which = 1, haven = lifecycle::deprecated(), ...) {
    if (lifecycle::is_present(haven)) {
        lifecycle::deprecate_warn(when = "0.5.31", what = "import(haven)", details = "xpt will always be read by `haven`. The parameter `haven` will be dropped in v2.0.0.")
    }
    standardize_attributes(haven::read_xpt(file = file, ...))
}

#' @export
.import.rio_mtp <- function(file, which = 1, ...) {
    foreign::read.mtp(file = file, ...)
}

#' @export
.import.rio_syd <- function(file, which = 1, ...) {
    foreign::read.systat(file = file, to.data.frame = TRUE, ...)
}

#' @export
.import.rio_json <- function(file, which = 1, ...) {
    .check_pkg_availability("jsonlite")
    jsonlite::fromJSON(txt = file, ...)
}

#' @export
.import.rio_rec <- function(file, which = 1, ...) {
    foreign::read.epiinfo(file = file, ...)
}

#' @export
.import.rio_arff <- function(file, which = 1, ...) {
    foreign::read.arff(file = file)
}

#' @export
.import.rio_xls <- function(file, which = 1, header = TRUE, ...) {
    .remap_tidy_convention(readxl::read_xls, file = file, which = which, header = header, ...)
}

#' @export
.import.rio_xlsx <- function(file, which = 1, header = TRUE, readxl = lifecycle::deprecated(), ...) {
    if (lifecycle::is_present(readxl)) {
        lifecycle::deprecate_warn(
            when = "0.5.31",
            what = "import(readxl)",
            details = "xlsx will always be read by `readxl`. The parameter `readxl` will be dropped in v2.0.0."
        )
    }
    .remap_tidy_convention(readxl::read_xlsx, file = file, which = which, header = header, ...)
}

#' @export
.import.rio_fortran <- function(file, which = 1, style, ...) {
    if (missing(style)) {
        stop("Import of Fortran format data requires a 'style' argument. See ? utils::read.fortran().")
    }
    utils::read.fortran(file = file, format = style, ...)
}

#' @export
.import.rio_ods <- function(file, which = 1, header = TRUE, ...) {
    .check_pkg_availability("readODS")
    .remap_tidy_convention(readODS::read_ods, file = file, which = which, header = header, ...)
}

#' @export
.import.rio_xml <- function(file, which = 1, stringsAsFactors = FALSE, ...) {
    .check_pkg_availability("xml2")
    x <- xml2::as_list(xml2::read_xml(unclass(file)))[[1L]]
    d <- do.call("rbind", c(lapply(x, unlist)))
    row.names(d) <- seq_len(nrow(d))
    d <- as.data.frame(d, stringsAsFactors = stringsAsFactors)
    tc2 <- function(x) {
        out <- utils::type.convert(x, as.is = FALSE)
        if (is.factor(out)) {
            x
        } else {
            out
        }
    }
    if (!isTRUE(stringsAsFactors)) {
        d[] <- lapply(d, tc2)
    } else {
        d[] <- lapply(d, utils::type.convert)
    }
    d
}

# This is a helper function for .import.rio_html
extract_html_row <- function(x, empty_value) {
    ## Both <th> and <td> are valid for table data, and <th> may be used when
    ## there is an accented element (e.g. the first row of the table)
    to_extract <- x[names(x) %in% c("th", "td")]
    ## Insert a value into cells that eventually will become empty cells (or they
    ## will be dropped and the table will not be generated).  Note that this more
    ## complex code for finding the length is required because of html like
    ## <td><br/></td>
    unlist_length <- vapply(lapply(to_extract, unlist), length, integer(1))
    to_extract[unlist_length == 0] <- list(empty_value)
    unlist(to_extract)
}

#' @export
.import.rio_html <- function(file, which = 1, stringsAsFactors = FALSE, ..., empty_value = "") {
    # find all tables
    tables <- xml2::xml_find_all(xml2::read_html(unclass(file)), ".//table")
    if (which > length(tables)) {
        stop(paste0("Requested table exceeds number of tables found in file (", length(tables), ")!"))
    }
    x <- xml2::as_list(tables[[which]])
    if ("tbody" %in% names(x)) {
        # Note that "tbody" may be specified multiple times in a valid html table
        x <- unlist(x[names(x) %in% "tbody"], recursive = FALSE)
    }
    # loop row-wise over the table and then rbind()
    ## check for table header to use as column names
    col_names <- NULL
    if ("th" %in% names(x[[1]])) {
        col_names <- extract_html_row(x[[1]], empty_value = empty_value)
        # Drop the first row since column names have already been extracted from it.
        x <- x[-1]
    }
    out <- do.call("rbind", lapply(x, extract_html_row, empty_value = empty_value))
    colnames(out) <-
        if (is.null(col_names)) {
            paste0("V", seq_len(ncol(out)))
        } else {
            col_names
        }
    out <- as.data.frame(out, ..., stringsAsFactors = stringsAsFactors)
    # set row names
    rownames(out) <- seq_len(nrow(out))
    # type.convert() to numeric, etc.
    out[] <- lapply(out, utils::type.convert, as.is = TRUE)
    out
}

#' @export
.import.rio_yml <- function(file, which = 1, stringsAsFactors = FALSE, ...) {
    .check_pkg_availability("yaml")
    as.data.frame(yaml::read_yaml(file, ...), stringsAsFactors = stringsAsFactors)
}

#' @export
.import.rio_eviews <- function(file, which = 1, ...) {
    .check_pkg_availability("hexView")
    hexView::readEViews(file, ...)
}

#' @export
.import.rio_clipboard <- function(file = "clipboard", which = 1, header = TRUE, sep = "\t", ...) {
    .check_pkg_availability("clipr")
    clipr::read_clip_tbl(x = clipr::read_clip(), header = header, sep = sep, ...)
}

#' @export
.import.rio_pzfx <- function(file, which = 1, ...) {
    .check_pkg_availability("pzfx")
    dots <- list(...)
    if ("path" %in% names(dots)) {
        dots[["path"]] <- NULL
    }
    if ("table" %in% names(dots)) {
        which <- dots[["table"]]
        dots[["table"]] <- NULL
    }
    .docall(pzfx::read_pzfx, args = c(dots, list(path = file, table = which)))
}

#' @export
.import.rio_parquet <- function(file, which = 1, as_data_frame = TRUE, ...) {
    .check_pkg_availability("arrow")
    arrow::read_parquet(file = file, as_data_frame = TRUE, ...)
}

#' @export
.import.rio_qs <- function(file, which = 1, ...) {
    .check_pkg_availability("qs")
    qs::qread(file = file, ...)
}
