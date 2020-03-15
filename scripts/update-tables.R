
# Packages ----------------------------------------------------------------

## Get required packages - managed using pacman
if (!require(pacman)) install.packages("pacman"); library(pacman)
p_load("dplyr")
p_load("readr")
p_load("lubridate")

# Functions ---------------------------------------------------------------

source("functions/summarise_interventions.R")

# Load data ---------------------------------------------------------------

interventions <- readr::read_csv("output-data/interventions.csv")


# Summarise social distancing interventions -------------------------------

social_distance_inst <- interventions %>% 
  dplyr::filter(social_distancing %in% "yes") %>% 
  summarise_interventions()


readr::write_csv(social_distance_inst, "output-data/summarised-social-distancing-ints.csv")

# Summarise non-social distancing interventions ---------------------------

non_social_distance_inst <- interventions %>% 
  dplyr::filter(social_distancing %in% "no") %>% 
  summarise_interventions()
  
readr::write_csv(non_social_distance_inst, "output-data/summarised-non-social-distancing-ints.csv")
