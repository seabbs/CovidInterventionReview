
# Get packages ------------------------------------------------------------

## Get required packages - managed using pacman
if (!require(pacman)) install.packages("pacman"); library(pacman)
p_load("dplyr")
p_load("readr")



# Read in raw data --------------------------------------------------------

cum_cases_in_countries <- readr::read_csv("raw-data/cumulative-counts.csv")

# Get date of first report ------------------------------------------------




first_cases <- cum_cases_in_countries %>% 
  dplyr::group_by(country) %>% 
  dplyr::filter(cases > 0) %>% 
  dplyr::filter(cases == min(cases), date == min(date)) %>% 
  dplyr::ungroup() %>% 
  dplyr::arrange(date) %>% 
  dplyr::select(Country = country, `Date of first case report` = date)

readr::write_csv(first_cases, "output-data/first-cases.csv")



# Get case count data -----------------------------------------------------

cases_in_countries <- cum_cases_in_countries %>% 
  dplyr::group_by(country) %>% 
  ## Cumulative?
  dplyr::mutate(cases = cases - dplyr::lag(cases)) %>% 
  dplyr::ungroup()

cases_in_countries <- cases_in_countries %>% 
  dplyr::filter(!country %in% "Taiwan") %>% 
  dplyr::mutate(
    cases = ifelse(country %in% "Japan", 
                   ifelse(date == "2020-02-05", 3, 
                          ifelse(date == "2020-02-06", 2, cases)), cases)
  ) %>% 
  dplyr::mutate(country = country %>% 
                  factor(levels = first_cases$Country))

readr::write_csv(cum_cases_in_countries, "output-data/counts.csv")