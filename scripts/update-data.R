
# Get packages ------------------------------------------------------------

## Get required packages - managed using pacman
if (!require(pacman)) install.packages("pacman"); library(pacman)
p_load("data.table")
p_load("dplyr")
p_load("tidyr")
p_load("purrr")
p_load("tibble")
p_load("ggplot2")
p_load("lubridate")


# Get functions -----------------------------------------------------------

source("functions/get_who_cases.R")

# Update country of interest case counts ----------------------------------

who_cases <- get_who_cases() %>% 
  tibble::as_tibble() %>% 
  dplyr::mutate(date = as.Date(Date)) %>% 
  dplyr::select_if(~is.numeric(.) | lubridate::is.Date(.))

update_country_names <- function(countries) {
  countries %>% 
    stringr::str_replace_all("RepublicofKorea", "Republic of Korea") %>% 
    stringr::str_replace_all("UnitedStatesofAmerica", "United States") %>% 
    stringr::str_replace_all("China-HongKongSAR", "Hong Kong") %>% 
    stringr::str_replace_all("China-Hubei", "Wuhan") %>% 
    stringr::str_replace_all("China-Taiwan", "Taiwan")
}

countries_of_interest <- who_cases %>% 
  dplyr::filter(SituationReport == max(SituationReport)) %>% 
  dplyr::select(-SituationReport, -date) %>% 
  tidyr::gather(key = "country", value = "cases") %>%
  dplyr::filter(country %in% c("RepublicofKorea", "UnitedStatesofAmerica",
                               "Italy", "Iran", "Japan", "Singapore",
                               "Thailand", "China-Taiwan", "China-HongKongSAR", "China-Hubei")) %>% 
  dplyr::mutate(country = country %>% 
                  update_country_names())

cum_cases_in_countries <- who_cases %>% 
  dplyr::select(-SituationReport) %>% 
  tidyr::gather(key = "country", value = "cases", -date) %>% 
  dplyr::mutate(country = country %>% 
                  update_country_names()) %>% 
  dplyr::filter(country %in% countries_of_interest$country)

wuhan <- readr::read_csv("raw-data/wuhan_20200303.csv") %>% 
  dplyr::rename(cases = total_case) %>% 
  dplyr::add_row(date = as.Date("2020-01-14"), cases = 0) %>% 
  dplyr::mutate(country = "Wuhan") %>% 
  dplyr::select(date, country, cases) %>% 
  dplyr::arrange(date) 

cum_cases_in_countries <- cum_cases_in_countries  %>% 
  dplyr::filter(!country %in% "Wuhan") %>% 
  dplyr::bind_rows(wuhan) %>% 
  dplyr::mutate(country = country %>% 
                  factor(levels = countries_of_interest$country))


readr::write_csv(cum_cases_in_countries, "raw-data/countries_of_interest_counts.csv")


# Update intervention data ------------------------------------------------


