
# run the first chunk of eol_report
library(tidyverse)
library(dbplyr)
library(DBI)
library(odbc)
library(janitor)
library(fst)

tryCatch({
  con <- dbConnect(odbc(), Driver = "SQL Server", server = "PRODNHSESQL101", Database = "NHSE_BB_5008")

  con %>%
    tbl(sql("SELECT * FROM [GEM\\JWiltshire].Activity1AllCost")) %>%
    select(-BB5008_Pseudo_ID) %>%
    collect() %>%
    clean_names() %>%
    mutate_at("su_pat_id", as.numeric) %>%
    select(-proximity_to_death_days_category,
           -cause_group_ll,
           -stp18cd,
           -location_type,
           -der_age_at_death,
           -age_group) %>%
    mutate_if(is.character, as.factor) %>%
    write_fst(file.path("data", "sensitive", "activity_costs.fst"))
}, finally = {
  dbDisconnect(con)
  con <- NULL
  rm(con)
})
