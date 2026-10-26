# Turns the yearly NVD files into one table, one row per CVE, and saves it as
# data/processed/nvd_cves.rds. Takes about 25 minutes, so start it and leave it.
# Needs scripts/02_download_nvd.R to have been run first.

source("R/parse_nvd.R")

dir.create("data/interim/nvd_years", recursive = TRUE, showWarnings = FALSE)
files <- list.files("data/raw/nvd", pattern = "\\.json\\.xz$", full.names = TRUE)

# 1. Parse one year at a time and keep each result in data/interim/nvd_years/,
#    so if R stops halfway, a rerun skips the years already done
for (f in files) {
  out <- file.path("data/interim/nvd_years", sub("\\.json\\.xz$", ".rds", basename(f)))
  if (file.exists(out)) {
    cat(basename(f), "already parsed\n")
    next
  }
  t0 <- Sys.time()
  cat("Parsing", basename(f), "... ")
  saveRDS(parse_nvd_year(f), out)
  gc()                                     # free the memory used by the big JSON file
  cat(round(as.numeric(difftime(Sys.time(), t0, units = "mins")), 1), "min\n")
}

# 2. Stack the years into one table
nvd <- list.files("data/interim/nvd_years", pattern = "\\.rds$", full.names = TRUE) |>
  map(readRDS) |>
  bind_rows()

# 3. Quick checks: each CVE should appear once
cat("\nCVEs:", nrow(nvd), "\n")
cat("Duplicate CVE IDs:", sum(duplicated(nvd$cve_id)), "\n")
cat("No CVSS v3 score:", sum(is.na(nvd$cvss_score)), "\n")

saveRDS(nvd, "data/interim/nvd_cves.rds")
