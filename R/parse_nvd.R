# Functions that turn one yearly NVD file (from fkie-cad) into a table
# with one row per CVE. Functions only: scripts/03_build_nvd.R runs them.
#
# Left out on purpose: every cisa... field and the ssvc "Exploitation" rating.
# They record whether a CVE was exploited, which is the answer we are trying
# to explain, so using them would be cheating.

library(tidyverse)
library(jsonlite)

or_na <- function(x) if (is.null(x) || length(x) == 0) NA else x

# Prefer NVD's own CVSS v3.1 score; fall back to v3.0, then to the reporter's score
pick_cvss3 <- function(metrics) {
  m <- metrics$cvssMetricV31
  if (is.null(m)) m <- metrics$cvssMetricV30
  if (is.null(m)) return(NULL)
  primary <- keep(m, ~ .x$type == "Primary")
  if (length(primary) > 0) primary[[1]] else m[[1]]
}

parse_one_cve <- function(item) {
  m <- pick_cvss3(item$metrics)
  d <- m$cvssData
  en <- keep(item$descriptions, ~ .x$lang == "en")
  cwes <- unique(unlist(map(item$weaknesses, ~ map_chr(.x$description, "value"))))
  cwes <- setdiff(cwes, c("NVD-CWE-Other", "NVD-CWE-noinfo"))
  cpes <- unlist(map(item$configurations, ~ map(.x$nodes, ~ map_chr(.x$cpeMatch, "criteria"))))
  cna_vendor <- or_na(item$affected[[1]]$affectedData[[1]]$vendor)

  list(
    cve_id              = item$id,
    reported_by         = item$sourceIdentifier,
    published           = as_date(ymd_hms(item$published)),
    nvd_status          = item$vulnStatus,
    description         = if (length(en) > 0) en[[1]]$value else NA,
    cvss_version        = or_na(d$version),
    cvss_score          = or_na(d$baseScore),
    severity            = or_na(d$baseSeverity),
    cvss_scored_by      = or_na(m$source),
    attack_vector       = or_na(d$attackVector),
    attack_complexity   = or_na(d$attackComplexity),
    privileges_required = or_na(d$privilegesRequired),
    user_interaction    = or_na(d$userInteraction),
    scope               = or_na(d$scope),
    confidentiality     = or_na(d$confidentialityImpact),
    integrity           = or_na(d$integrityImpact),
    availability        = or_na(d$availabilityImpact),
    cwe                 = if (length(cwes) > 0) cwes[1] else NA,
    vendor              = if (length(cpes) > 0) str_split_i(cpes[1], ":", 4) else str_to_lower(cna_vendor),
    product             = if (length(cpes) > 0) str_split_i(cpes[1], ":", 5) else NA,
    n_references        = length(item$references)   # never a model feature: references pile up after exploitation
  )
}

parse_nvd_year <- function(path) {
  feed <- fromJSON(path, simplifyVector = FALSE)
  map(feed$cve_items, parse_one_cve) |>
    bind_rows() |>
    filter(nvd_status != "Rejected")
}
