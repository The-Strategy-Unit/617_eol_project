library(tidyverse)
library(fst)
library(janitor)

if (!file.exists("data/sensitive/mpi_raw.fst")) {
  file.copy("data/sensitive/mpi.fst", "data/sensitive/mpi_raw.fst")
}

mpi <- read_fst("data/sensitive/mpi_raw.fst") %>%
  as_tibble()

ccg_stp_20 <- read_csv("https://opendata.arcgis.com/datasets/9562c37c8d094ad9bb881e44b4d38c1a_0.csv",
                       col_types = "_cc_c__") %>%
  clean_names()

if (!file.exists("data/reference/ccg_successors.csv")) {
  NHSRtools::ods_get_successors() %>%
    filter(effective_date < lubridate::ymd(20210401)) %>%
    select(old_ccg = old_code, ccg20cdh = new_code) %>%
    semi_join(ccg_stp_20, by = "ccg20cdh") %>%
    write_csv("data/reference/ccg_successors.csv")
}

ccg_successors <- read_csv("data/reference/ccg_successors.csv", col_types = "cc")

ccg18_20 <- distinct(mpi, ccg) %>%
  left_join(ccg_successors, by = c("ccg" = "old_ccg")) %>%
  mutate(across(ccg20cdh, ~ifelse(is.na(.x), ccg, .x)))

mpi %>%
  inner_join(ccg18_20, by = "ccg") %>%
  left_join(ccg_stp_20, by = "ccg20cdh") %>%
  mutate(ccg = ccg20cdh, stp = stp20cd) %>%
  select(-ccg20cd, -ccg20cdh, -stp20cd) %>%
  write_fst("data/sensitive/mpi.fst")


if (!file.exists("data/sensitive/historic_deaths_raw.fst")) {
  file.copy("data/sensitive/historic_deaths.fst", "data/sensitive/historic_deaths_raw.fst")
}

read_fst("data/sensitive/historic_deaths_raw.fst") %>%
  as_tibble() %>%
  select(-stp_name) %>%
  mutate(stp_code = ifelse(stp_code == "E54000033", "E54000053", stp_code)) %>%
  write_fst("data/sensitive/historic_deaths.fst")

