# generate reports for Midlands STPs

library(tidyverse)
library(rmarkdown)
library(cli)
library(tictoc)
library(furrr)
library(parallel)

if (!dir.exists("output")) {
  dir.create("output")
}

cat("Starting R Sessions: ")
tic()

cl <- makePSOCKcluster(24, rscript_args = "--no-init-file")
plan(cluster, workers = cl)

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

    withr::local_file(paste0(filename, ".Rmd"), {
      file.copy("eol_report.Rmd", paste0(filename, ".Rmd"))
        render(input = paste0(filename, ".Rmd"),
               output_format = "StrategyUnitTheme::su_document",
               output_file = paste0(filename, ".docx"),
               output_dir = "output",
               envir = new.env(),
               params = list(stp = stp18cd, region_report = region_report))
    })
  })
  stp18cd
}

stps <- bind_rows(
  file.path("data", "reference", "stps.csv") %>%
    read_csv(col_types = "cc") %>%
    mutate(region_report = FALSE),

  file.path("data", "reference", "stp18cd_to_nhser18cd.csv") %>%
    read_csv(col_types = "cc") %>%
    inner_join(file.path("data", "reference", "nhser18.csv") %>%
                 read_csv(col_types = "cc"),
               by = "nhser18cd") %>%
    group_by(nhser18cd) %>%
    summarise(across(everything(), first)) %>%
    transmute(stp18cd, stp18nm = nhser18nm, region_report = TRUE)
)

# Run individually ----
{
  tic()
  res <- future_pmap(stps, safely(render_report), .options = furrr_options(seed = 1437)) %>%
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
stopCluster(cl)
