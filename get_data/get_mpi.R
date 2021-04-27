library(tidyverse)
library(fst)
library(dbplyr)
library(DBI)
library(odbc)

# ref data we need to load first
# icd10 <- readRDS(file.path("data", "icd10.rds"))

ethnicity_lookup <- read_csv(file.path("data", "reference", "ethnicity.csv"),
                             col_types = "ccc") %>%
  mutate_at(vars(ethnic_group), fct_inorder)

# Load the data from the DB server in this chunk: the results are cached so we
# don't have to reload the data each time the report is knitted.

# handle all of the loading of data here, and always close the database
# connection
tryCatch({
  # create connection to DB server
  con <- dbConnect(odbc(), Driver = "SQL Server", server = "PRODNHSESQL101", Database = "NHSE_BB_5008")

  tbl(con, sql("SELECT * FROM [GEM\\JWiltshire].MPI")) %>%
    select(su_pat_id = SUPatID,
           age = DER_AGE_AT_DEATH,
           sex = DEC_SEX,
           ccg = CCGResponsible,
           stp = STP18CD,
           lsoa = LSOA_OF_RESIDENCE_CODE,
           imd = IndexofMultipleDeprivationIMDDecile,
           dod = REG_DATE_OF_DEATH,
           location_type = LocationType,
           primary_cod = S_UNDERLYING_COD_ICD10,
           group = CauseGroupLL,
           ethnicity = Ethnic,
           carer_support = CarerSuport,
           lives_alone = LivesAlone,
           died_in_critical_care = DiedInCriticalCare) %>%
    collect() %>%
    mutate_at(vars(primary_cod),
              ~ifelse(str_length(.x) == 3,
                      paste0(.x, "X"),
                      .x)) %>%
    mutate_if(is.character, str_trim) %>%
    mutate_at(vars(group), fct_explicit_na) %>%
    mutate_at(vars(sex), fct_recode, "male" = "1", "female" = "2") %>%
    mutate_at(vars(lives_alone), ~case_when(
      .x == 0 ~ FALSE,
      .x == 1 ~ TRUE,
      TRUE ~ NA
    )) %>%
    mutate_at(vars(age), as.numeric) %>%
    mutate_at(vars(location_type),
              fct_recode,
              "Elsewhere" = "Elsewhere/Other") %>%
    mutate_at(vars(location_type),
              fct_relevel,
              "Elsewhere",
              "Hospital",
              "Hospice",
              "Care Home",
              "Home") %>%
    mutate_at(vars(primary_cod, ethnicity, carer_support), as_factor) %>%
    mutate(age_band = cut(age,
                          c(0,18,65,75,85,Inf),
                          c("0-17","18-64","65-74","75-84","85+"),
                          right = FALSE,
                          ordered_result = TRUE)) %>%
    mutate_at(vars(ethnicity), str_replace, "\\*", "") %>%
    mutate_at(vars(ethnicity), ~ifelse(.x %in% ethnicity_lookup$ethnic_code,
                                       .x, "99")) %>%
    rename(ethnic_code = ethnicity) %>%
    inner_join(ethnicity_lookup, by = "ethnic_code") %>%
    rename(imd_decile = imd) %>%
    mutate(imd_quintile = floor((imd_decile-1)/2)+1) %>%
    mutate_at(vars(su_pat_id), as.numeric) %>%
    mutate_at("group",
              fct_relevel,
              "Frailty",
              "Cancer",
              "Organ Failure",
              "Sudden Death",
              "Other Terminal Illness") %>%
    mutate_at("location_type",
              fct_recode,
              "Elsewhere" = "Unknown") %>%
    write_fst(file.path("data", "sensitive", "mpi.fst"))
}, finally = {
  dbDisconnect(con)
  # remove connection
  con <- NULL
  rm(con)
})

