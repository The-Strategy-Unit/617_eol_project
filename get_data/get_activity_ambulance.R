library(tidyverse)
library(dbplyr)
library(DBI)
library(odbc)
library(janitor)
library(fst)

tryCatch({
  con <- dbConnect(odbc(), Driver = "SQL Server", server = "PRODNHSESQL101",
                   Database = "NHSE_BB_5008")

  tbl(con,
      in_schema("[GEM\\JWiltshire]", "ActivityAE")) %>%
    filter(ProximityToDeathDays > 0) %>%
    count(arrival_mode = AEA_Arrival_Mode,
          ProximityToDeathDays,
          STP18CD,
          age = DER_AGE_AT_DEATH,
          LocationType,
          CauseGroupLL) %>%
    collect() %>%
    clean_names() %>%
    ungroup() %>%
    mutate_at(vars(proximity_to_death_days, age), as.numeric) %>%
    write_fst(file.path("data","sensitive","activity_ambulance.fst"))
}, finally = {
  dbDisconnect(con)
  con <- NULL
  rm(con)
})
