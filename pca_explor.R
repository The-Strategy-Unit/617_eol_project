source("setup.R")
load_data("E54000016") # need to set an stp, but using region data

library(FactoMineR)
library(explor)

activity_summary <- inner_join(
  activity_region %>%
    group_by(su_pat_id) %>%
    # select(su_pat_id, proximity_to_death_days) %>%
    arrange(su_pat_id, desc(proximity_to_death_days)) %>%
    mutate(time_between = c(NA, -diff(proximity_to_death_days))) %>%
    summarise(#"Total Activity" = n(),
      "Earliest Activity" = max(proximity_to_death_days),
      "Average Time Between Activity" = mean(time_between, na.rm = TRUE)),

  activity_region %>%
    group_by(su_pat_id) %>%
    count(pod_type) %>%
    pivot_wider(names_from = pod_type, values_from = n) %>%
    mutate_at(vars(-su_pat_id), replace_na, 0),

  by = "su_pat_id"
) %>%
  left_join(activity_region %>%
              mutate_at("proximity_to_death",
                        cut, seq(0, 24, 6), right = FALSE) %>%
              count(su_pat_id, proximity_to_death) %>%
              arrange(proximity_to_death) %>%
              mutate_at("proximity_to_death", ~paste0("pxd_", .x)) %>%
              pivot_wider(names_from = proximity_to_death, values_from = n),
            by = "su_pat_id") %>%
  modify_at(vars(matches("^pxd_.+$")), replace_na, 0) %>%
  inner_join(mpi_region %>%
               select(su_pat_id,
                      age,
                      imd_decile,
                      ethnic_group,
                      group,
                      location_type),
             by = "su_pat_id")

pxd_pcnt <- activity_summary %>%
  pivot_longer(matches("^pxd_.+$"),
               names_to = "pxdn",
               values_to = "pxdv") %>%
  group_by(su_pat_id) %>%
  mutate_at("pxdv", ~.x / sum(.x)) %>%
  mutate_at("pxdn", paste0, "%") %>%
  select(su_pat_id, pxdn, pxdv) %>%
  pivot_wider(names_from = pxdn, values_from = pxdv)

activity_summary_pca <- activity_summary %>%
  inner_join(pxd_pcnt, by = "su_pat_id") %>%
  filter(group != "(Missing)") %>%
  mutate_at("ethnic_group", ~ifelse(.x == "White", "White", "Other")) %>%
  drop_na(`Average Time Between Activity`, imd_decile)

pca <- activity_summary_pca %>%
  select(-su_pat_id) %>%
  mutate(cluster = as.factor(kmc$cluster)) %>%
  PCA(X = .,
      quanti.sup = which(colnames(.) == "imd_decile"),
      quali.sup = which(map_lgl(., ~is.character(.x) | is.factor(.x))),
      graph = FALSE)

explor(pca)
