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
  env$region_code <- region[1,]$nhser18cd
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
    as_tibble() %>%
    semi_join(mpi_region, by = "su_pat_id")

  env$activity <- semi_join(env$activity_region, mpi, by = "su_pat_id")

  env$forecast_activity <- file.path("data",
                                     "sensitive",
                                     "forecast_activity.fst") %>%
    read_fst() %>%
    as_tibble()

  env$forecast_activity <- if (region_report) {
    env$forecast_activity %>%
      filter(stp %in% region) %>%
      group_by(age_band,
               year,
               pod_type,
               pod_summary_group,
               stp = env$region_code) %>%
      summarise(across(c(est_deaths, activity), sum))
  } else {
    filter(env$forecast_activity, stp == {{stp}})
  }

  env$historical_deaths <- file.path("data",
                                     "sensitive",
                                     "historic_deaths.fst") %>%
    read_fst() %>%
    as_tibble() %>%
    select(stp = stp_code, sex, year, deaths)

  env$historical_deaths <- if (region_report) {
    env$historical_deaths %>%
      filter(stp_code %in% region) %>%
      group_by(stp = env$region_code,
               sex,
               year) %>%
      sumamrise(across(deaths, sum), .groups = "drop")
  } else {
    filter(env$historical_deaths, stp == {{stp}})
  }


  env$forecast_deaths <- file.path("data",
                                   "reference",
                                   "forecast_deaths.csv") %>%
    read_csv(col_types = "ncncnc")

  env$forecast_deaths <- if (region_report) {
    env$forecast_deaths %>%
      filter(region == .env$region) %>%
      group_by(year, sex, age_group, stp = env$region_code) %>%
      summarise(across(est_deaths, sum))
  } else {
    env$forecast_deaths %>%
      filter(stp == {{stp}}) %>%
      select(-region)
  }

  if (region_report) {
    env$mpi <- env$mpi_region
    env$activity <- env$activity_region

    env$stp_name <- env$region_name
    env$region_name <- "NA"
  }

  # ambulance activity isn't used
  # env$activity_ambulance <- file.path("data",
  #                                     "sensitive",
  #                                     "activity_ambulance.fst") %>%
  #   read_fst() %>%
  #   as_tibble() %>%
  #   filter((region_report & stp18cd %in% region) |
  #            stp18cd == stp) %>%
  #   select(-stp18cd) %>%
  #   group_by_at(vars(-n)) %>%
  #   summarise_at("n", sum) %>%
  #   ungroup() %>%
  #   mutate_at("arrival_mode", ~ifelse(.x == "1", "ambulance", NA) %>%
  #               replace_na("other")) %>%
  #   rename(group = cause_group_ll) %>%
  #   mutate_at("group", fct_explicit_na) %>%
  #   mutate_at("group", fct_relevel, levels(mpi$group))

  env$activity_costs_region <- file.path("data", "sensitive", "activity_costs.fst") %>%
    read_fst() %>%
    as_tibble() %>%
    semi_join(mpi_region, by = "su_pat_id")

  if (nrow(env$activity_costs_region) > 0) {
    env$activity_costs_region <- env$activity_costs_region %>%
      mutate_at("ss_flag", fct_recode, "Spec. Services" = "SS") %>%
      mutate(across(pod_type, factor, levels = unique(c(
        levels(pod_type),
        "CriticalCare",
        "BED",
        "PlannedContact",
        "PlannedEvent",
        "Unplanned"
      )))) %>%
      mutate_at("pod_type",
                fct_recode,
                "Critical Care" = "CriticalCare",
                "Bed" = "BED",
                "Planned Contact" = "PlannedContact",
                "Planned Admission" = "PlannedEvent",
                "Urgent Service Event" = "Unplanned") %>%
      mutate_at("pod_type",
                fct_relevel,
                "Urgent Service Event",
                "Planned Contact",
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
      mutate_at("pod_summary_group",
                ~ifelse(pod_type == "Critical Care" & .x == "Day Case Admission",
                        "Elective Admission",
                        as.character(.x)) %>%
                  fct_relevel(levels(.x))) %>%
      mutate_at("pod_type", fct_explicit_na) %>%
      rename(cost = final_cost) %>%
      modify_at("cost", replace_na, 0)

    # update levels of ss_flag
    env$activity_costs_region <- env$activity_costs_region %>%
      mutate("simple_ss_flag" = fct_collapse(ss_flag, "Other" = activity_costs_region %>%
                                               group_by(ss_flag) %>%
                                               summarise_at("cost", sum) %>%
                                               filter((cost / sum(cost)) <= 0.01) %>%
                                               pull(ss_flag) %>%
                                               as.character())) %>%
      mutate(across(pod_type, factor, levels = c(levels(pod_type), "CC", "Unknown", "(Missing)"))) %>%
      mutate_at("pod_type",
                fct_recode,
                "Critical Care" = "CC",
                "Other" = "Unknown",
                "Other" = "(Missing)")
  }

  env$activity_costs <- env$activity_costs_region %>%
    semi_join(env$mpi, by = "su_pat_id")

  env$money_format <- comma_format(prefix = "£", scale = 1e-6, suffix = "m", accuracy =  1)

  env
}
