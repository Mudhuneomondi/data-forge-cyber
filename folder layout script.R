dirs <- c("data/raw", "data/interim","data/processed",
          "R", "scripts", "analysis","outputs/figures","outputs/tables",
          "report","dashboard","docs"
          )

for (d in dirs){
  dir.create(
    d,
    recursive = TRUE,
    showWarnings = FALSE
  )
  
  file.create(
    file.path(d,".gitkeep")
    )
}

# R packages Installation

install.packages(c(
  "tidyverse", "lubridate", "janitor", "httr2", "jsonlite",
  "pdftools", "tidymodels", "themis", "ranger", "xgboost",
  "vip", "urltools", "scales", "patchwork", "gt",
  "shiny", "renv"
))
