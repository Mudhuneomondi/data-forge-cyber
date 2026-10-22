install.packages(c(
"tidyverse", "lubridate", "janitor", "httr2", "jsonlite",
"pdftools", "tidymodels", "themis", "ranger", "xgboost",
"vip", "urltools", "scales", "patchwork", "gt",
"shiny", "renv"
))
Then the lead runs renv::init() once and commits the renv.lock file. That file records
every package version, so everyone gets the same results. When a teammate clones the
repo, they run renv::restore() .

## Package	What it's used for:

 1.tidyverse ->	Data manipulation and visualization

 2.lubridate ->	Working with dates and times
 
 3.jsonlite ->	Reading and writing JSON data
 
 4.pdftools ->	Extracting text from PDF files
 
 5.tidymodels ->	Building machine learning models
 
 6.xgboost ->	Training machine learning models
 
 7.shiny ->	Building interactive web applications in R
 
 8. renv ->	Managing package versions for a project