# R packages Installation

install.packages(c(
  "tidyverse", "lubridate", "janitor", "httr2", "jsonlite",
  "pdftools", "tidymodels", "themis", "ranger", "xgboost",
  "vip", "urltools", "scales", "patchwork", "gt",
  "shiny", "renv"
))

# Confirming Missing packages
packages <- c(
  "tidyverse", "lubridate", "janitor", "httr2", "jsonlite",
  "pdftools", "tidymodels", "themis", "ranger", "xgboost",
  "vip", "urltools", "scales", "patchwork", "gt",
  "shiny", "renv"
)

installed <- packages %in% rownames(installed.packages())

data.frame(
  Package = packages,
  Status = ifelse(installed, "Installed", "Missing")
)

install.packages(c(
  "tidyverse",
  "janitor",
  "httr2",
  "pdftools",
  "tidymodels",
  "themis",
  "ranger",
  "vip",
  "urltools",
  "patchwork",
  "gt",
  "shiny",
  "renv"
))
