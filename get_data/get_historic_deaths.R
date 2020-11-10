library(tidyverse)
library(dbplyr)
library(DBI)
library(odbc)
library(janitor)
library(fst)

tryCatch({
  con <- dbConnect(odbc(), Driver = "SQL Server", server = "PRODNHSESQL101", Database = "NHSE_BB_5008")

  con %>%
    tbl(in_schema("[GEM\\JWiltshire]", "HistoricalDeathsOutput")) %>%
    filter(STPCode != "#N/A") %>%
    collect() %>%
    pivot_longer(cols = matches("D\\d{4}"),
                 names_to = "year",
                 values_to = "deaths") %>%
    mutate_at("year",
              compose(as.numeric, str_sub),
              start = 2) %>%
    clean_names() %>%
    mutate_at("sex", str_replace, "s$", "") %>%
    write_fst(file.path("data", "sensitive", "historic_deaths.fst"))
}, finally = {
  dbDisconnect(con)
  con <- NULL
  rm(con)
})
