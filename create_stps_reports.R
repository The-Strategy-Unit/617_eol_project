# generate reports for Midlands STPs

library(tidyverse)
library(rmarkdown)
library(cli)
library(tictoc)
library(furrr)

if (!dir.exists("output")) {
  dir.create("output")
}

cat("Starting R Sessions: ")
tic()
# disable renv starting up for each session
tryCatch({
  file.rename(".Rprofile", "~.Rprofile") ; file.create(".Rprofile")
  # start sessions
  plan(multiprocess, workers = 10)
}, finally = {
  # restore rprofile
  unlink(".Rprofile") ; file.rename("~.Rprofile", ".Rprofile")
})
toc()
cat("done: starting to render reports\n")

render_report <- function(stp18cd, stp18nm, region_report) {
  capture.output({
    if (region_report) {
      filename <- stp18nm
    } else {
      filename <- paste0(stp18cd, "-", stp18nm)
    }

    filename <- str_replace_all(filename, " ", "_")

    file.copy("eol_report.Rmd", paste0(filename, ".Rmd"))

    tryCatch({
      render(input = paste0(filename, ".Rmd"),
             output_format = "StrategyUnitTheme::su_document",
             output_file = paste0(filename, ".docx"),
             output_dir = "output",
             envir = new.env(),
             params = list(stp = stp18cd, region_report = region_report))
    }, finally = {
      unlink(paste0(filename, ".Rmd"))
    })
  })
  stp18cd
}

render_costing <- function(stp18cd, stp18nm, region_report) {
  capture.output({
    if (region_report) {
      filename <- stp18nm
    } else {
      filename <- paste0(stp18cd, "-", stp18nm)
    }

    filename <- paste0("costing-", str_replace_all(filename, " ", "_"))

    file.copy("costing.Rmd", paste0(filename, ".Rmd"))

    tryCatch({
      render(input = paste0(filename, ".Rmd"),
             output_format = "StrategyUnitTheme::su_document",
             output_file = paste0(filename, ".docx"),
             output_dir = "output",
             envir = new.env(),
             params = list(stp = stp18cd, region_report = region_report))
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
    by = "stp18cd") %>%
  mutate(region_report = FALSE) %>%
  bind_rows(.,
            head(., 1) %>%
              mutate(stp18nm = "Midlands", region_report = TRUE))

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

{
  tic()
  res <- future_pmap(stps, safely(render_costing)) %>%
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

plan(sequential)
