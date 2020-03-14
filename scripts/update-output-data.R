
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
  dplyr::filter(cases == min(cases), date == min(date),
                !country %in% "Taiwan") %>% 
  dplyr::ungroup() %>% 
  dplyr::arrange(date) %>% 
  dplyr::select(Country = country, `Date of first case report` = date)

readr::write_csv(first_cases, "output-data/first-cases.csv")



# Get case count data -----------------------------------------------------

cases_in_countries <- cum_cases_in_countries %>% 
  dplyr::group_by(country) %>% 
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

readr::write_csv(cases_in_countries, "output-data/counts.csv")



# Clean interventions -----------------------------------------------------

interventions <-  readr::read_csv("raw-data/intervention-dates-2020-03-13.csv") %>% 
  dplyr::select(date = date_intervention, intervention, type = intervention_type,
                enforced, social_distancing, national_local, country)  %>% 
  dplyr::mutate(date = lubridate::dmy(date),
                intervention = intervention %>% 
                  stringr::str_replace_all("_", " ") %>% 
                  stringr::str_to_sentence(),
                type = type %>% 
                  stringr::str_replace_all("_", " ") %>% 
                  stringr::str_to_sentence() %>% 
                  stringr::str_replace_all("Ppe", "PPE") %>% 
                  stringr::str_replace("School closure$", "School closures") %>% 
                  stringr::str_replace("Workplace closure$", "Workplace closures") %>% 
                  stringr::str_replace_all("Avoiding crowding", "Crowding"),
                national_local = national_local %>% 
                  stringr::str_replace_all("lcoal", "local") %>% 
                  stringr::str_to_sentence(),
                country = country %>% 
                  stringr::str_to_title() %>% 
                  stringr::str_replace_all("South Korea", "Republic of Korea") %>% 
                  factor(levels = first_cases$Country)) %>% 
  arrange(country) %>% 
  rename(Enforced = enforced,
         Scale = national_local)

readr::write_csv(interventions, "output-data/interventions.csv")

