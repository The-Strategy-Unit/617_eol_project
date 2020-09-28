if (!exists("setup_env")) {
  stop("must be called from within setup.R")
}

setup_env$load_data <- function(stp, region_report = FALSE) {
  env <- global_env()

  # figure out what region the selected stp is a part of, as well as the other
  # stps in that region
  region <- inner_join(
    file.path("data", "reference", "nhser18.csv") %>%
      read_csv(col_types = "cc"),
    file.path("data", "reference", "stp18cd_to_nhser18cd.csv") %>%
      read_csv(col_types = "cc"),
    by = "nhser18cd"
  ) %>%
    group_by(nhser18cd) %>%
    filter(any(stp18cd == stp))

  if (nrow(region) == 0) {
    stop("stp code does not exist")
  }

  env$region_name <- region[1,]$nhser18nm
  # all codes from the region
  env$region <- region$stp18cd

  env$pop_raw_region <- file.path("data", "reference", "population.csv") %>%
    read_csv(col_types = cols(
      ccg18cd = col_character(),
      ccg18cdh = col_character(),
      stp18cd = col_character(),
      area_names = col_character(),
      all_ages = col_double(),
      age = col_double(),
      count = col_double()
    )) %>%
    mutate(is_region_stp = stp18cd %in% env$region,
           is_stp = stp18cd == stp) %>%
    filter(is_region_stp)

  env$pop_raw <- filter(env$pop_raw_region, is_stp)

  env$stps <- file.path("data", "reference", "stps.csv") %>%
    read_csv(col_types = "cc")

  env$stp_name <- filter(stps, stp18cd == stp)$stp18nm

  # Load MPI

  env$mpi_region <- file.path("data", "sensitive", "mpi.fst") %>%
    read_fst() %>%
    as_tibble() %>%
    mutate(is_region_stp = stp %in% env$region,
           # use curly-curly from rlang to ensure we are using the functions
           # argument
           is_stp = stp == {{stp}}) %>%
    filter(is_region_stp)

  env$mpi <- filter(env$mpi_region, is_stp)

  env$activity_region <- file.path("data", "sensitive", "activity.fst") %>%
    read_fst() %>%
    as_tibble()

  env$activity <- semi_join(env$activity_region, mpi, by = "su_pat_id")

  env$forecast_activity <- file.path("data",
                                     "sensitive",
                                     "forecast_activity.fst") %>%
    read_fst() %>%
    as_tibble() %>%
    filter(stp == ifelse({{region_report}}, "Region", {{stp}}))

  env$historical_deaths <- file.path("data",
                                     "sensitive",
                                     "historical_deaths.fst") %>%
    read_fst() %>%
    as_tibble() %>%
    filter(stp == ifelse({{region_report}}, "Region", {{stp}}))

  env$forecast_deaths <- file.path("data",
                                   "reference",
                                   "forecast_deaths.csv") %>%
    read_csv(col_types = "ncncn") %>%
    filter(stp == ifelse({{region_report}}, "Region", {{stp}}))

  if (region_report) {
    env$mpi <- env$mpi_region
    env$activity <- env$activity_region

    env$stp_name <- env$region_name
    env$region_name <- "NA"
  }

  env$activity_ambulance <- file.path("data",
                                      "sensitive",
                                      "activity_ambulance.fst") %>%
    read_fst() %>%
    as_tibble() %>%
    filter((region_report & stp18cd %in% region$stp18cd) |
             stp18cd == stp) %>%
    select(-stp18cd) %>%
    group_by_at(vars(-n)) %>%
    summarise_at("n", sum) %>%
    ungroup() %>%
    mutate_at("arrival_mode", ~ifelse(.x == "1", "ambulance", NA) %>%
                replace_na("other")) %>%
    rename(group = cause_group_ll) %>%
    mutate_at("group", fct_explicit_na) %>%
    mutate_at("group", fct_relevel, levels(mpi$group))

  env
}
