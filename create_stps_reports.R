system("%LOCALAPPDATA%\\Microsoft\\OneDrive\\OneDrive.exe /shutdown")

# generate reports for Midlands STPs

library(tidyverse)
library(rmarkdown)
library(cli)
library(tictoc)
library(furrr)

if (!dir.exists("output")) {
  dir.create("output")
}

plan(multiprocess)

render_report <- function(stp18cd, stp18nm) {
  capture.output({
    filename <- paste0(stp18cd, "_", stp18nm)

    file.copy("eol_report.Rmd", paste0(filename, ".Rmd"))

    tryCatch({
      render(paste0(filename, ".Rmd"),
             "StrategyUnitTheme::su_document",
             paste0("output/", filename, ".docx"),
             params = list(stp = stp18cd))
    }, finally = {
      unlink(paste0(filename, ".Rmd"))
    })
  })
  stp18cd
}

stps <- file.path("data", "reference", "stps.csv") %>%
  read_csv(col_types = "cc") %>%
  semi_join(file.path("data", "reference", "stp18cd_to_nhser18cd.csv") %>%
              read_csv(col_types = "cc") %>%
    semi_join(file.path("data", "reference", "nhser18.csv") %>%
                read_csv(col_types = "cc") %>%
                filter(nhser18nm == "Midlands"),
              by = "nhser18cd"),
    by = "stp18cd")

{
  tic()
  res <- future_pmap(stps, safely(render_report)) %>%
    map_chr("result")
  toc()

  errors <- stps %>% filter(!stp18cd %in% res)
  if (nrow(errors) == 0) {
    cat(col_green("All files generated successfully\n"))
  } else {
    cat(col_red("Errors:\n"))
    print(errors)
  }
}

system("%LOCALAPPDATA%\\Microsoft\\OneDrive\\OneDrive.exe")
