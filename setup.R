# create an environment to store things that are created only for the setup of
# the report, e.g. not data
setup_env <- new.env()

# library calls ----
library(extrafont)
library(tidyverse)
library(scales)
library(DescTools)
library(Cairo) # not needed to be library'd, but needed for rendering
library(knitr)
library(sf)
library(glue)
library(shadowtext)
library(fst)
library(treemapify)
library(ggrepel)
library(patchwork)
library(rlang)
library(ggridges)

# knitr options ----
opts_chunk$set(echo = FALSE, eval.after = "fig.cap")

if (!knitr::is_latex_output()) {
  knitr::opts_chunk$set(dpi = 300,
                        dev.args = list(type = "cairo"))
}

# load fonts ----
loadfonts(device = "win", quiet = TRUE)

if (length(fonts()) == 0) {
  stop("no fonts loaded, run font_install.R")
}

if (!"Segoe UI" %in% fonts()) {
  stop("Segoe UI font not installed!")
}

# Set up Strategy Unit Theme ----

# Install the Strategy Unit Theme from
#devtools::install_local(file.path(path, "StrategyUnitTheme", sep = "\\"))
library(StrategyUnitTheme)

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

setup_env$scale_x_proximity_to_death_days <- function(...) {
  scale_x_continuous(trans = reverse_trans(),
                     breaks = seq(0, 2*365, 6*365/12),
                     labels = function(x) floor(x/(365/12)),
                     ...)
}

# set the default theme
setup_env$theme_report <- theme_get() +
  theme(text = element_text(family = "Segoe UI"),
        panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.line = element_line(colour = su_theme_cols("charcoal")),
        strip.background = element_rect(fill = su_theme_cols("light_grey"),
                                        colour = NA))

theme_set(setup_env$theme_report)

attach(setup_env)
