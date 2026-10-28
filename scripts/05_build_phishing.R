# scripts/05_build_phishing.R
library(tidyverse)

phish <- read_csv("data/raw/phishing/PhiUSIIL_Phishing_URL_Dataset.csv") |>
  mutate(is_phishing = factor(if_else(label == 0, "phishing", "legitimate"),
                              levels = c("phishing", "legitimate")))

count(phish, is_phishing)   # legitimate should be 134,850

dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
saveRDS(phish, "data/processed/phishing.rds")