if (!exists("setup_env")) {
  stop("must be called from within setup.R")
}

setup_env$place_of_death_fill <- function(reverse = FALSE) {
  su_theme_cols("charcoal", "red", "blue", "orange", "grey") %>%
    set_names(rev(levels(mpi$location_type))) %>%
    scale_fill_manual(values = .,
                      guide = guide_legend(reverse = reverse))
}
