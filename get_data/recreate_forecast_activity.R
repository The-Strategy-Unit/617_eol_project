library(tidyverse)
library(fst)

forecast_deaths <- file.path("data", "sensitive", "forecast_deaths.fst") %>%
  read_fst() %>%
  as_tibble()

mpi_region <- read_fst(file.path("data", "sensitive", "mpi.fst")) %>%
  as_tibble() %>%
  filter(stp %in% unique(forecast_deaths$stp)) %>%
  mutate_at("su_pat_id", as.numeric)

activity <- file.path("data", "sensitive", "activity.fst") %>%
  read_fst() %>%
  as_tibble()

death_counts <- mpi_region %>%
  mutate_at("group", as.character) %>%
  mutate_at("sex", as.character) %>%
  mutate_at("age", ~case_when(.x > 90 ~ 90,
                              .x < 50 ~ 50,
                              TRUE ~ .x)) %>%
  count(stp, sex, age, name = "deaths")

activity_counts <- activity %>%
  inner_join(select(mpi_region, su_pat_id, sex, age, stp),
             by = "su_pat_id") %>%
  mutate(activity_year = as.numeric(proximity_to_death_days >= 365)) %>%
  mutate_at("age", ~case_when(.x > 90 ~ 90,
                              .x < 50 ~ 50,
                              TRUE ~ .x)) %>%
  mutate_if(is.factor, as.character) %>%
  count(stp, pod_type, pod_summary_group, activity_year, age, sex,
        name = "activity")

activity_column_combinations <- list(type = activity_counts %>%
                                       distinct(pod_type, pod_summary_group) %>%
                                       pmap(paste, sep = "|"),
                                     stp = unique(activity_counts$stp),
                                     activity_year = c(0, 1),
                                     age = 50:90,
                                     sex = c("female", "male")) %>%
  cross_df() %>%
  separate(type, c("pod_type", "pod_summary_group"), sep = "\\|")

utilisation_rates <- left_join(activity_column_combinations,
                               inner_join(activity_counts,
                                          death_counts,
                                          by = c("stp", "sex", "age")) %>%
                                 mutate(utilisation = activity/deaths),
                               by = colnames(activity_column_combinations)) %>%
  replace_na(list(utilisation = 0,
                  activity = 0,
                  deaths = 0))

forecast_activity <- inner_join(
  forecast_deaths %>%
    filter(age_group >= 18) %>%
    mutate(age = case_when(age_group < 50 ~ 50,
                           age_group > 90 ~ 90,
                           TRUE ~ age_group)) %>%
    group_by(stp, sex, age, year) %>%
    summarise_at("est_deaths", sum),
  utilisation_rates,
  by = c("stp", "age", "sex")
) %>%
  mutate(age_band = cut(age,
                        c(0,18,65,75,85,Inf),
                        c("0-17",
                          "18-64",
                          "65-74",
                          "75-84",
                          "85+"),
                        right = FALSE)) %>%
  mutate_at("year", ~.x - activity_year) %>%
  mutate(activity = est_deaths * utilisation) %>%
  group_by(age_band, year, pod_type, pod_summary_group, stp) %>%
  summarise_at(vars(est_deaths, activity), sum) %>%
  filter(year > 2019, year < 2041)

forecast_activity <- bind_rows(
  forecast_activity,
  forecast_activity %>%
    summarise_at(vars(est_deaths, activity), sum) %>%
    mutate(stp = "Region")
)

forecast_activity %>%
  ungroup() %>%
  mutate_at("pod_type",
            fct_relevel, levels(activity$pod_type)) %>%
  mutate_at("pod_summary_group",
            fct_relevel, levels(activity$pod_summary_group)) %>%
  write_fst(file.path("data", "sensitive", "forecast_activity.fst"))
