library(tidyverse)
library(dbplyr)
library(DBI)
library(odbc)
library(janitor)
library(fst)

mpi <- read_fst(file.path("tmp", "data", "sensitive", "mpi.fst")) %>%
  as_tibble()

tryCatch({
  con <- dbConnect(odbc(), Driver = "SQL Server", server = "PRODNHSESQL101",
                   Database = "NHSE_BB_5008")

  activity <- tbl(con,
                  in_schema("[GEM\\JWiltshire]", "Activity0AllMIDS")) %>%
    select(-BB5008_Pseudo_ID,
           -ProximityToDeathDaysCategory,
           -Act,
           -CauseGroupLL,
           -STP18CD,
           -LocationType,
           -AgeGroup,
           -DER_AGE_AT_DEATH) %>%
    collect() %>%
    clean_names() %>%
    filter(proximity_to_death_days > 0) %>%
    mutate_if(is.character, as.factor) %>%
    mutate_at("su_pat_id", as.numeric) %>%
    mutate_at("pod_type",
              fct_recode,
              "Bed" = "BED",
              "Planned Contact" = "PlannedContact",
              #"Planned Event" = "PlannedEvent"
              "Planned Admission" = "PlannedEvent",
              "Urgent Service Event" = "Unplanned") %>%
    mutate_at("pod_type",
              fct_relevel,
              #"Unplanned",
              "Urgent Service Event",
              "Planned Contact",
              #"Planned Event",
              "Planned Admission",
              "Bed",
              "Critical Care Bed Day") %>%

    mutate(cc_pod_summary_group = ifelse(pod_type == "Critical Care Bed Day",
                                         as.character(pod_summary_group),
                                         NA)) %>%
    mutate_at("cc_pod_summary_group",
              fct_recode,
              "Elective Admission" = "EL",
              "Elective Admission" = "DC",
              "Emergency Admission" = "EM") %>%
    mutate_at("pod_summary_group",
              ~case_when(pod_type == "Critical Care Bed Day" ~ "CCBD",
                         pod_type == "Bed" ~ paste0(as.character(.x), "BD"),
                         TRUE ~ as.character(.x))) %>%
    mutate_at("pod_summary_group",
              fct_relevel,
              "EM", "AE", "111",
              "OP", "MH", "IAPT",
              "DC", "RA", "EL",
              "EMBD", "ELBD", "CCBD") %>%
    mutate_at("pod_summary_group",
              fct_recode,
              "Emergency Admission" = "EM",
              "A&E Attendance" = "AE",
              "111 Call" = "111",
              "Outpatient Attendance" = "OP",
              "Mental Health Contact" = "MH",
              "IAPT Contact" = "IAPT",
              "Day Case Admission" = "DC",
              "Regular Attendance Admission" = "RA",
              "Elective Admission" = "EL",
              "Emergency Admission Bed Day" = "EMBD",
              "Elective Admission Bed Day" = "ELBD",
              "Critical Care Bed Day" = "CCBD") %>%
    mutate_at("pod_type", fct_recode, "Bed" = "Critical Care Bed Day") %>%
    # fix date of death
    inner_join(select(mpi, su_pat_id, dod), by = "su_pat_id") %>%
    mutate_at("discharge_date", pmin, quo(dod)) %>%
    select(-dod) %>%
    write_fst(file.path("data", "sensitive", "activity.fst"))
}, finally = {
  dbDisconnect(con)
  con <- NULL
  rm(con)
})
