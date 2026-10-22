data-forge-cyber/
├── data/
│ ├── raw/ # downloads exactly as received, never edited
│ ├── interim/ # half-cleaned files
│ └── processed/ # final analysis tables
├── R/ # reusable functions (e.g. url_features.R)
├── scripts/ # numbered steps: 01_download_kev.R, 02_clean_kev.R ...
├── analysis/ # Quarto notebooks, one per part
├── outputs/
│ ├── figures/
│ └── tables/
├── report/ # final Quarto report
├── dashboard/ # optional Shiny or Quarto dashboard
├── docs/ # source_log.csv, data_dictionary.md, decisions.md
└── README.md