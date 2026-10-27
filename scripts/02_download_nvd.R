# Downloads the NVD vulnerability records, one file per CVE year (2016-2026).
# Source: fkie-cad/nvd-json-data-feeds on GitHub, a community project that
# rebuilds the official NVD API data every day. It is not run by NIST.
# The files are too big for GitHub, so they are ignored by git; copy the
# data/raw/nvd folder to the shared Drive after running this.

dir.create("data/raw/nvd", recursive = TRUE, showWarnings = FALSE)
dir.create("docs", showWarnings = FALSE)
options(timeout = 1800)   # the default 60 seconds is too short for the bigger years

years <- 2016:2026

# 1. Find the current release, so every file comes from the same daily build
#    and the source log can say exactly which build we used
release <- jsonlite::fromJSON("https://api.github.com/repos/fkie-cad/nvd-json-data-feeds/releases/latest")
tag  <- release$tag_name
base <- paste0("https://github.com/fkie-cad/nvd-json-data-feeds/releases/download/", tag, "/")
cat("Using release", tag, "\n\n")

# 2. A real .xz file starts with these six bytes; anything else is a failed download
is_xz <- function(f) file.exists(f) && file.size(f) > 100000 &&
  identical(readBin(f, "raw", 6), as.raw(c(0xFD, 0x37, 0x7A, 0x58, 0x5A, 0x00)))

# 3. Download each year and record what happened
files <- data.frame(year = years, file = paste0("CVE-", years, ".json.xz"),
                    new = FALSE, ok = FALSE)
for (i in seq_len(nrow(files))) {
  dest <- file.path("data/raw/nvd", files$file[i])
  if (is_xz(dest)) {                        # skip files you already have
    cat(files$file[i], "already downloaded\n")
    files$ok[i] <- TRUE
    next
  }
  cat("Downloading", files$file[i], "... ")
  try(download.file(paste0(base, files$file[i]), dest, mode = "wb", quiet = TRUE), silent = TRUE)
  files$ok[i]  <- is_xz(dest)
  files$new[i] <- files$ok[i]
  if (!files$ok[i] && file.exists(dest)) file.remove(dest)
  cat(ifelse(files$ok[i], paste0("ok (", round(file.size(dest) / 1e6, 1), " MB)\n"), "FAILED\n"))
}

# 4. Add only the NEW downloads to the source log (no duplicates on reruns)
new <- files[files$new, ]
if (nrow(new) > 0) {
  log_rows <- data.frame(
    dataset = "NVD", file_name = new$file, url = paste0(base, new$file),
    downloaded_on = as.character(Sys.Date()), downloaded_by = "Nathan",
    period_covered = paste0("CVE IDs from ", new$year),
    terms_of_use = "see nvd.nist.gov terms of use; credit NVD and state it does not endorse this work",
    notes = paste("community rebuild of the NVD API by fkie-cad, not NIST; release", tag)
  )
  write.table(log_rows, "docs/source_log.csv", sep = ",", row.names = FALSE,
              col.names = !file.exists("docs/source_log.csv"), append = TRUE)
}

# 5. Anything listed here failed and needs a rerun
cat("\nTotal size:", round(sum(file.size(file.path("data/raw/nvd", files$file[files$ok]))) / 1e6), "MB\n")
cat("Failed:", if (any(!files$ok)) files$file[!files$ok] else "none", "\n")
