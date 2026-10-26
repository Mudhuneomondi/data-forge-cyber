# scripts/01_download_kev.R
library(tidyverse)

url <- "https://www.cisa.gov/sites/default/files/csv/known_exploited_vulnerabilities.csv"

dir.create("data/raw/kev", recursive = TRUE, showWarnings = FALSE)
dest <- paste0("data/raw/kev/kev_", Sys.Date(), ".csv")

download.file(url, dest, mode = "wb")

kev <- read_csv(dest)
glimpse(kev)   # expect cveID, vendorProject, product, dateAdded, knownRansomwareCampaignUse, cwes ...
nrow(kev)      # note this number for your source log