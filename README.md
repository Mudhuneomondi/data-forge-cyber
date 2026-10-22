# A Data-Driven Analysis of the Changing Cyber Threat Landscape in Kenya

Kenya records billions of detected cyber threat events every quarter, and organisations cannot fix every weakness at once. This project uses public data to show how threats in Kenya are changing, what makes a software vulnerability likely to be exploited, and which vulnerabilities organisations should patch first. It also tests whether a globally trained phishing detector works on Kenyan websites.

---

## Research questions

1. **Kenya trends:** How have detected cyber threat categories in Kenya changed quarter to quarter and year to year?
2. **What gets exploited:** Which severity scores, technical characteristics and products are associated with vulnerabilities that are actively exploited?
3. **What to fix first:** Can a model rank vulnerabilities by risk better than the CVSS severity score and the EPSS exploit prediction score?
4. **Phishing:** Which URL features separate phishing from legitimate URLs, and does a globally trained model wrongly flag legitimate Kenyan websites?

An exploratory section also compares Kenyan threat trends with global vulnerability trends.

---

## Data sources

| Source | What it provides | Format |
| --- | --- | --- |
| [National KE-CIRT/CC, Communications Authority of Kenya](https://ke-cirt.go.ke/quarterly-reports/) | Quarterly counts of detected cyber threat events in Kenya, by category | PDF reports, entered by hand |
| [CISA Known Exploited Vulnerabilities (KEV)](https://www.cisa.gov/known-exploited-vulnerabilities-catalog) | Vulnerabilities confirmed as exploited in the wild | CSV |
| [National Vulnerability Database (NVD)](https://nvd.nist.gov/), via [fkie-cad/nvd-json-data-feeds](https://github.com/fkie-cad/nvd-json-data-feeds) | All published vulnerabilities (CVEs) with severity scores, weakness types and affected products | JSON, one file per year |
| [FIRST EPSS](https://www.first.org/epss/data_stats) | Daily probability that each CVE will be exploited | CSV |
| [PhiUSIIL Phishing URL Dataset (UCI)](https://archive.ics.uci.edu/dataset/967/phiusiil+phishing+url+dataset) | 235,795 labelled phishing and legitimate URLs | CSV |
| Kenyan URL list (collected for this project) | 300 to 500 legitimate Kenyan website URLs across sectors | CSV |

Every download is recorded in `docs/source_log.csv` with its link, date, who downloaded it and its terms of use.

---

## Folder structure

```text
data-forge-cyber/
├── data/
│   ├── raw/
│   ├── interim/
│   └── processed/
├── R/
├── scripts/
├── analysis/
├── outputs/
│   ├── figures/
│   └── tables/
├── report/
├── dashboard/
├── docs/
├── .gitignore
├── renv.lock
└── README.md
```

### What each folder is for

| Folder | Purpose | Rules |
| --- | --- | --- |
| `data/raw/` | Original files exactly as downloaded: CA report PDFs, KEV, NVD, EPSS, PhiUSIIL and the Kenyan URL list. | Never edit these files. All changes happen in code. Large files (NVD, EPSS, PhiUSIIL) are kept out of GitHub and stored in the shared Drive folder. |
| `data/interim/` | Half-cleaned files produced along the way, such as the combined NVD table and the agreed CA data entry sheet. | Always created by a script, never by hand. Safe to delete and rebuild. |
| `data/processed/` | Final, clean analysis tables that every analysis notebook reads: `ca_quarterly.csv`, `vulns.rds`, `phishing.rds`. | Created only by scripts in `scripts/`. |
| `R/` | Reusable functions that other files call, for example `parse_nvd.R` (reads NVD files) and `url_features.R` (computes URL features). | Functions only. No code that runs on its own. |
| `scripts/` | Numbered steps that download and clean data, run in order: `01_download_kev.R`, `02_download_nvd.R`, `03_build_nvd.R` and so on. | Each script does one job. The number shows the order to run them in. |
| `analysis/` | Quarto notebooks: one for exploratory data analysis per dataset, and one for each part of the project (`part1_kenya_trends.qmd` to `part4_phishing.qmd`). | Each notebook reads from `data/processed/` and saves its charts and tables to `outputs/`. |
| `outputs/figures/` | Charts saved as PNG files for the report and slides. | Created by the notebooks. Every chart title states a finding. |
| `outputs/tables/` | Result tables saved as CSV files. | Created by the notebooks. |
| `report/` | The final written report as a Quarto file (`report.qmd`), with its references. | Numbers in the report come from code, never typed by hand. |
| `dashboard/` | Optional Quarto dashboard that presents the main results on one web page. | Built after the four parts are complete. |
| `docs/` | Project records: `source_log.csv` (every download), `data_dictionary.md` (every column explained), `decisions.md` (every judgement call and why), `ca_category_map.csv` (how renamed CA categories are matched over time). | Update these as you work, not at the end. |

---

## Getting started

### 1. Install the tools

- R 4.4 or newer: <https://cran.r-project.org>
- RStudio Desktop: <https://posit.co/download/rstudio-desktop/>
- Git: <https://git-scm.com>

**Linux users only:** install these system libraries first, or several R packages will fail to install:

```bash
sudo apt update
sudo apt install -y libcurl4-openssl-dev libssl-dev libxml2-dev libpoppler-cpp-dev \
  libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev \
  libpng-dev libjpeg-dev libtiff-dev libnode-dev
```

### 2. Clone the repository

In RStudio: **File > New Project > Version Control > Git**, then paste:

```text
https://github.com/Sophie-Muchiri12/data-forge-cyber
```

GitHub asks for a personal access token, not your account password. Create one at <https://github.com/settings/tokens> (classic token, with the `repo` box ticked).

### 3. Install the R packages

Run this once in the RStudio Console. It installs the exact package versions recorded in `renv.lock`, so everyone gets the same results:

```r
install.packages("renv")
renv::restore()
```

### 4. Get the large data files

Copy the `nvd`, `epss` and `phishing` folders from the shared Drive into `data/raw/`, or re-run the download scripts in `scripts/`.

---

## How to run the project

Run the scripts in `scripts/` in number order, then render the notebooks in `analysis/`. Each step reads the output of the step before it.

1. **Download** the raw data (`scripts/01_...` to `02_...`).
2. **Clean and combine** it into the processed tables (`scripts/03_...` onwards).
3. **Explore** each dataset (`analysis/eda_*.qmd`).
4. **Analyse** each part (`analysis/part1_...` to `part4_...`).
5. **Render** the report (`report/report.qmd`).

A full run from a clean copy must give the same numbers as the report. Someone who did not write the code checks this before submission.

---

## How to contribute with Git

1. Click **Pull** before starting work, so you have the latest changes.
2. Work on your own branch, named after your task, for example `kev-cleaning`.
3. Commit often, with clear messages: "Add KEV download script", not "update".
4. Open a pull request on GitHub. Another contributor reviews it before it is merged into `main`.
5. Never commit passwords, API keys or tokens. Store the NVD API key in a `.Renviron` file, which is listed in `.gitignore`, and read it with `Sys.getenv("NVD_API_KEY")`.

---

## Ethics and limitations

- All data used is public. No personal information is collected.
- CA figures count **detected threat events**, mostly blocked scans and attempts. They are not confirmed breaches, and the report describes them that way.
- KEV mainly lists products used by US government agencies, so results describe *known* exploitation, not all exploitation.
- The PhiUSIIL dataset is global, not Kenyan. The Kenyan URL list contains only legitimate public pages. No phishing pages were visited at any point.
- The project does not claim that any vulnerability caused a specific attack in Kenya.

---

## Acknowledgements

Data is provided by the National KE-CIRT/CC under the Communications Authority of Kenya, the US National Institute of Standards and Technology (NVD), the Cybersecurity and Infrastructure Security Agency (KEV), FIRST (EPSS), and Prasad and Chandra (PhiUSIIL, UCI Machine Learning Repository).
