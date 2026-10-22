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
| `data/raw/` | Original files exactly as downloaded: CA report PDFs, KEV, NVD, EPSS, PhiUSIIL and the Kenyan URL list. | Never edit these files. All changes happen in code. Large
