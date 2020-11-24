# create an environment to store things that are created only for the setup of
# the report, e.g. not data
setup_env <- new.env()

# library calls ----
library(extrafont)
library(tidyverse)
library(scales)
library(DescTools)
library(glue)
library(shadowtext)
library(fst)
library(ggrepel)
library(rlang)
library(StrategyUnitTheme)

# load fonts ----

if (!"Segoe UI" %in% fonts()) {
  extrafont::font_import(prompt = FALSE, pattern = "(?i).*segoe.*")
}

# reset the default ggplot colour/fill scales with the su theme.
setup_env$scale_fill_continuous <- partial(scale_fill_su, discrete = FALSE)
setup_env$scale_fill_discrete <- partial(scale_fill_su, discrete = TRUE)
setup_env$scale_colour_continuous <- partial(scale_colour_su, discrete = FALSE)
setup_env$scale_colour_discrete <- partial(scale_colour_su, discrete = TRUE)

setup_env$scale_imd <- function(..., quintiles = FALSE) {
  if (quintiles) {
    breaks <- c(1, 5)
  } else {
    breaks <- c(1, 10)
  }

  labels <- paste(c("Most", "Least"), "Deprived", sep = "\n")
  scale_x_continuous(breaks = breaks,
                     labels = labels,
                     ...)
}

setup_env$scale_x_proximity_to_death_days <- function(months_every = 6, ...) {
  scale_x_continuous(trans = reverse_trans(),
                     breaks = seq(0, 2*365, months_every*365/12),
                     labels = function(x) floor(x*12/365),
                     ...)
}

# set the default theme
setup_env$theme_report <- theme_get() +
  theme(text = element_text(family = "Segoe UI"),
        panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.line = element_line(colour = su_theme_cols("charcoal")),
        axis.title.y.right = element_text(margin = margin(0, 0, 0, 10)),
        strip.background = element_blank(),
        legend.background = element_blank(),
        legend.key = element_blank())

theme_set(setup_env$theme_report)

# recreate all of the data files
if (!dir.exists("data/sensitive")) {
  stop("Data files do not exist: run get_data/get_data.R first")
}

# load additional files
source("load_data.R")
source("mekko_chart.R")
source("place_of_death_fill.R")

attach(setup_env)
