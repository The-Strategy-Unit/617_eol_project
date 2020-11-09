
# 617_eol_project

<!-- badges: start -->
<!-- badges: end -->

This project contains the R code to generate the [Health service use in the last two years of life](https://www.strategyunitwm.nhs.uk/publications/health-service-use-last-two-years-life) reports.

This code must be run on the [NCDR](https://data.england.nhs.uk/ncdr/about/) data science server, and you must have
access to the database on the NCDR Sql Server.

In order to run this code, you first need to clone the repository in [RStudio](https://happygitwithr.com/rstudio-git-github.html#clone-the-new-github-repository-to-your-computer-via-rstudio).

Once you have cloned the repository, first run `renv::install()` to set up the environment. Then, run the file
`get_data/get_data.R` to get the data for the reports.

Once this data has been created, the entire report is stored in `eol_report.Rmd`. The final, published reports include
extra text and analysis that was stitched in manually after.
