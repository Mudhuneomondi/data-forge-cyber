install.packages(c("curl", "httr", "httr2", "tidyverse", "pdftools", "gt"))

library(tidyverse)

tibble(dataset = character(), file_name = character(), url = character(),
       downloaded_on = character(), downloaded_by = character(),
       period_covered = character(), terms_of_use = character(),
       notes = character()) |>
  write_csv("docs/source_log.csv")
log <- read_csv("docs/source_log.csv")
View(log)


library(pdftools)
txt <- pdf_text("data/raw/ca_reports/CA_cyber_2025-10.pdf")
cat(txt[1:3]) # look at the first three pages
