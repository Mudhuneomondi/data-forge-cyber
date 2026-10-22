install.packages(c("curl", "httr", "httr2", "tidyverse", "pdftools", "gt"))

library(tidyverse)

tibble(dataset = character(), file_name = character(), url = character(),
       downloaded_on = character(), downloaded_by = character(),
       period_covered = character(), terms_of_use = character(),
       notes = character()) |>
  write_csv("docs/source_log.csv")
log <- read_csv("docs/source_log.csv")
View(log)
