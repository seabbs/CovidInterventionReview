# Packages ----------------------------------------------------------------

## Get required packages - managed using pacman
if (!require(pacman)) install.packages("pacman"); library(pacman)
p_load("dplyr")
p_load("readr")
p_load("lubridate")
p_load("ggplot2")
p_load("cowplot")

# Functions ---------------------------------------------------------------

source("functions/plot_interventions.R")

# Load data ---------------------------------------------------------------

cases <- readr::read_csv("output-data/counts.csv")
interventions <- readr::read_csv("output-data/interventions.csv")
first_cases <- readr::read_csv("output-data/first-cases.csv")

cases <- cases %>% 
  dplyr::mutate(country = country %>% 
                  factor(levels = first_cases$Country))

interventions <- interventions %>% 
  dplyr::mutate(country = country %>% 
                  factor(levels = first_cases$Country))

# Make plots --------------------------------------------------------------

## Social distancing interventions
social_plot <- plot_interventions(cases, interventions, "yes", 
                                  linetype = "Scale", scales = "free_y")

ggsave("figures/social-plot.png", social_plot, width = 12, height = 12, dpi = 330)

## Social distancing interventions
non_social_plot <- plot_interventions(cases, interventions, "no", 
                                  linetype = "Scale", scales = "free_y")


ggsave("figures/non-social-plot.png", non_social_plot, width = 12, height = 12, dpi = 330)

# Make enforced plots -----------------------------------------------------

## Social distancing interventions
enforced_social_plot <- plot_interventions(cases, interventions, "yes", 
                                  linetype = "Enforced", scales = "free_y")


ggsave("figures/enforced-non-social-plot.png", enforced_social_plot, width = 12, height = 12, dpi = 330)

## Social distancing interventions
enforced_non_social_plot <- plot_interventions(cases, interventions, "no", 
                                      linetype = "Enforced", scales = "free_y")

ggsave("figures/enforced-non-social-plot.png", enforced_non_social_plot, width = 12, height = 12, dpi = 330)

