library(tidyverse)
library(readxl)
library(glue)
library(janitor)
library(jsonlite)
library(rlang)

################################################################################
# Forecast deaths by STP
################################################################################
# the SNPP data from ons gives us forecast deaths by age group and local
# authority, but we need to be able to produce this at an STP level. There is
# not a direct mapping between LA and STP, so we take the following approach:
#
#  - load the population estimates by LSOA (SAPE21)
#  - load the OA->LSOA->LA mappings
#  - load the LSOA->STP mappings
#  - use these mappings to create a dataset that has population by LSOA with the
#    LA and STP of that LSOA
#  - use this to calculate the percentage of the LA's population by STP
#
# we can then take the forecast deaths, join to the above dataset, and multiply
# by the percentage to get the STP's forecast deaths
################################################################################

# grab reference files if they do not exist
if (!file.exists(file.path("data",
                           "reference",
                           "2018 SNPP Deaths females.csv"),
                 file.path("data",
                           "reference",
                           "2018 SNPP Deaths males.csv")) %>% all()) {
  local({
    snpp2018 <- glue("https://www.ons.gov.uk/file?uri=",
                     "%2fpeoplepopulationandcommunity",
                     "%2fpopulationandmigration",
                     "%2fpopulationprojections",
                     "%2fdatasets",
                     "%2fdeathsz4",
                     "%2f2018based/2018snppdeaths.zip")
    tf_snpp <- tempfile(fileext = str_match(snpp2018,
                                            "\\.[a-zA-Z0-9]+$")[[1]])
    download.file(snpp2018, tf_snpp, mode = "wb")
    unzip(tf_snpp,
          c("2018 SNPP Deaths females.csv",
            "2018 SNPP Deaths males.csv"),
          exdir = file.path("data", "reference"))
  })

  stopifnot("SNPP files not created" =
              file.exists(file.path("data",
                                    "reference",
                                    "2018 SNPP Deaths females.csv"),
                          file.path("data",
                                    "reference",
                                    "2018 SNPP Deaths males.csv")) %>% all())
}

sapefile <- file.path("data",
                      "reference",
                      glue("SAPE21DT1a-mid-2018-on-2019-LA-lsoa-syoa-estimates",
                           "-formatted.xlsx"))

if (!file.exists(sapefile)) {
  local({
    sape2018 <- glue("https://www.ons.gov.uk/file?uri=",
                     "%2fpeoplepopulationandcommunity",
                     "%2fpopulationandmigration",
                     "%2fpopulationestimates",
                     "%2fdatasets",
                     "%2flowersuperoutputareamidyearpopulationestimates",
                     "%2fmid2018sape21dt1a",
                     "/sape21dt1amid2018on2019lalsoasyoaestimatesformatted.zip")
    tf_sape <- tempfile(fileext = str_match(sape2018, "(\\.[a-zA-Z0-9]+$")[[1]])
    download.file(sape2018, tf_sape, mode = "wb")
    unzip(tf_sape,
          exdir = file.path("data", "reference"))
  })

  stopifnot("SAPE file not created" = file.exists(sapefile))
}

est_deaths <- file.path("data", "reference") %>%
  dir(pattern = "^2018 SNPP Deaths .*\\.csv$",
      full.names = TRUE) %>%
  map_dfr(read_csv,
          col_types = paste(c(rep("c", 5),
                              rep("n", 25)),
                            collapse = "")) %>%
  pivot_longer(cols = matches("\\d{4}"),
               names_to = "year",
               values_to = "est_deaths") %>%
  mutate_at("year", as.numeric) %>%
  clean_names() %>%
  filter(age_group != "All ages") %>%
  mutate_at("age_group",
            compose(as.numeric, str_replace),
            "^(\\d+).*$", "\\1") %>%
  select(-component) %>%
  filter(area_code %>% str_detect("E0[6-9]"))

pop_est <- excel_sheets(sapefile) %>%
  subset(., str_detect(., "Mid-2018 (M|Fem)ales")) %>%
  set_names(str_replace(., "Mid-2018 ", "") %>% str_to_lower()) %>%
  map_dfr(read_excel,
          path = sapefile,
          skip = 4,
          .id = "sex") %>%
  drop_na(LSOA) %>%
  select(sex, lsoa11cd = `Area Codes`, pop = `All Ages`) %>%
  filter(str_starts(lsoa11cd, "E"))

# grab data from ONS geoportal
load_data_from_geoportal <- function(x, col_a, col_b) {
  arcgis_api <- "https://opendata.arcgis.com/datasets/"

  glue("{arcgis_api}{x}_0.geojson") %>%
    fromJSON() %>%
    pluck("features") %>%
    pluck("properties") %>%
    as_tibble() %>%
    clean_names() %>%
    distinct({{col_a}}, {{col_b}})
}

lsoa_to_lad17 <- read_csv("https://opendata.arcgis.com/datasets/f0095af162f749ad8231e6226e1b7e30_0.csv",
                          col_types = "c______c__") %>%
  clean_names()

lsoa_to_stp_lookup <- read_csv("https://opendata.arcgis.com/datasets/1631beea57ff4e9fb90d75f9c764ce26_0.csv",
                               col_types = "_c____c_____") %>%
  clean_names() %>%
  inner_join(lsoa_to_lad17, by = "lsoa11cd")

# create lookup
lad20_to_stp_pop <- lsoa_to_stp_lookup %>%
  inner_join(pop_est, by = "lsoa11cd") %>%
  group_by(sex, lad18cd, stp20cd) %>%
  summarise(across(pop, sum), .groups = "drop_last") %>%
  mutate(pop_pcnt = pop / sum(pop)) %>%
  ungroup()

stp_to_nhser <- read_csv("data/reference/stp20cd_to_nhser20cd.csv", col_types = "c_c_")

forecast_deaths <- est_deaths %>%
  inner_join(lad20_to_stp_pop, by = c("area_code" = "lad18cd", "sex")) %>%
  inner_join(stp_to_nhser, by = "stp20cd") %>%
  mutate(across(est_deaths, ~.x * pop_pcnt)) %>%
  group_by(year, sex, age_group, region = nhser20cd, stp = stp20cd) %>%
  summarise(across(est_deaths, sum), .groups = "drop_last") %>%
  bind_rows(.,
            summarise(., across(est_deaths, sum), .groups = "drop") %>%
              mutate(stp = "Region")) %>%
  ungroup() %>%
  mutate(across(sex, str_replace, "s$", "")) %>%
  arrange(year, sex, age_group, stp)

write_csv(forecast_deaths,
          file.path("data", "reference", "forecast_deaths.csv"))
