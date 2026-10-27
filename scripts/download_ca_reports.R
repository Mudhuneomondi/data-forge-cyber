# Downloads every KE-CIRT quarterly report from 2020 onwards.
# Uses the Wayback Machine's saved copies first, because the live
# KE-CIRT site is often unreachable. Falls back to the live link.

dir.create("data/raw/ca_reports", recursive = TRUE, showWarnings = FALSE)
dir.create("docs", showWarnings = FALSE)
options(timeout = 300)

# Some archived files come back gzip-compressed; this unpacks them in place
unzip_if_gzip <- function(f) {
  if (!file.exists(f) || file.size(f) < 3) return(invisible(f))
  bytes <- readBin(f, "raw", file.size(f))
  if (bytes[1] == as.raw(0x1f) && bytes[2] == as.raw(0x8b)) {
    bytes <- memDecompress(bytes, type = "gzip")
    writeBin(bytes, f)
  }
  invisible(f)
}

# 1. Read the archived copy of the list page
page_file <- tempfile(fileext = ".html")
download.file("https://web.archive.org/web/2026/https://ke-cirt.go.ke/quarterly-reports/",
              page_file, mode = "wb", quiet = TRUE)
unzip_if_gzip(page_file)
page <- paste(readLines(page_file, warn = FALSE), collapse = " ")
page <- iconv(page, from = "UTF-8", to = "ASCII", sub = "-")   # odd characters (and long dashes) become "-"
page[is.na(page)] <- ""

# 2. Find every PDF link, then read the "(JUL-SEP 2020)" label just after it
hits   <- gregexpr('href=["\']([^"\']+\\.pdf)["\']', page, perl = TRUE, ignore.case = TRUE)[[1]]
starts <- as.integer(hits)
lens   <- attr(hits, "match.length")
cat("PDF links found on the page:", sum(starts > 0), "\n")

info <- lapply(seq_along(starts), function(k) {
  if (starts[k] < 0) return(NULL)
  tag   <- substr(page, starts[k], starts[k] + lens[k] - 1)
  link  <- sub('href=["\']([^"\']+)["\']', "\\1", tag, perl = TRUE, ignore.case = TRUE)
  link  <- sub("^.*?/web/[^/]+/(https?://)", "\\1", link, perl = TRUE)        # strip archive prefix
  if (startsWith(link, "/")) link <- paste0("https://ke-cirt.go.ke", link)     # make relative links full
  after <- substr(page, starts[k] + lens[k], starts[k] + lens[k] + 1500)
  after <- gsub("<[^>]+>", " ", after, perl = TRUE)                           # drop HTML tags
  after <- gsub("&#821[12];|&ndash;|&mdash;", "-", after, perl = TRUE)
  m <- regmatches(after, regexec("(?i)\\b(jan|apr|jul|oct)[a-z]*\\.?\\s*-+\\s*[a-z]+\\.?\\s*(\\d{4})",
                                 after, perl = TRUE))[[1]]
  if (length(m) == 0) return(data.frame(link = link, start = NA, year = NA))
  data.frame(link = link, start = toupper(m[2]), year = m[3])
})
reports <- do.call(rbind, info)

if (is.null(reports) || all(is.na(reports$year))) {
  cat("\nCould not read the report labels. First PDF link area of the page:\n")
  first <- regexpr("\\.pdf", page, perl = TRUE, ignore.case = TRUE)
  cat(substr(page, max(1, first - 300), first + 600), "\n")
  stop("Send this output to Claude so the pattern can be adjusted.")
}

reports <- reports[!is.na(reports$year) & !duplicated(reports$link), ]
reports <- reports[as.integer(reports$year) >= 2020, ]
reports$month <- c(JAN = "01", APR = "04", JUL = "07", OCT = "10")[reports$start]
reports$file  <- paste0("CA_cyber_", reports$year, "-", reports$month, ".pdf")
reports <- reports[order(reports$file), ]
cat("Reports from 2020 onwards:", nrow(reports), "\n\n")

# 3. Download one report: archive first, then the live link
is_pdf <- function(f) file.exists(f) && file.size(f) > 10000 &&
  identical(readBin(f, "raw", 4), charToRaw("%PDF"))

get_pdf <- function(url, dest) {
  tries <- c(paste0("https://web.archive.org/web/2026id_/", url), url)
  for (u in tries) {
    options(timeout = if (grepl("web.archive.org", u)) 300 else 20)
    try(suppressWarnings(download.file(u, dest, mode = "wb", quiet = TRUE)), silent = TRUE)
    unzip_if_gzip(dest)
    if (is_pdf(dest)) return(u)
  }
  if (file.exists(dest)) file.remove(dest)
  NA_character_
}

# 4. Download them all and record what happened
reports$used_url <- NA_character_
reports$new      <- FALSE
for (i in seq_len(nrow(reports))) {
  dest <- file.path("data/raw/ca_reports", reports$file[i])
  if (is_pdf(dest)) {                       # skip files you already have
    cat(reports$file[i], "already downloaded\n")
    reports$used_url[i] <- reports$link[i]
    next
  }
  cat("Downloading", reports$file[i], "... ")
  reports$used_url[i] <- get_pdf(reports$link[i], dest)
  reports$new[i] <- !is.na(reports$used_url[i])
  cat(ifelse(is.na(reports$used_url[i]), "FAILED\n", "ok\n"))
}

# 5. Add only the NEW downloads to the source log (no duplicates on reruns)
ok <- reports[reports$new, ]
if (nrow(ok) > 0) {
  log_rows <- data.frame(
    dataset = "CA report", file_name = ok$file, url = ok$used_url,
    downloaded_on = as.character(Sys.Date()), downloaded_by = "Sophie",
    period_covered = paste0(ok$year, "-", ok$month), terms_of_use = "public report",
    notes = ifelse(grepl("web.archive.org", ok$used_url), "archived copy (Wayback Machine)", "")
  )
  write.table(log_rows, "docs/source_log.csv", sep = ",", row.names = FALSE,
              col.names = !file.exists("docs/source_log.csv"), append = TRUE)
}

# 6. Anything listed here still needs a manual download
cat("\nStill missing:\n")
print(reports[is.na(reports$used_url), c("file", "link")])
