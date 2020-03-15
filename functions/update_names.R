update_names <- function(countries) {
  countries %>% 
    stringr::str_replace_all("RepublicofKorea", "Republic of Korea") %>% 
    stringr::str_replace_all("UnitedStatesofAmerica", "United States") %>% 
    stringr::str_replace_all("China-HongKongSAR", "Hong Kong") %>% 
    stringr::str_replace_all("China-Hubei", "Wuhan") %>% 
    stringr::str_replace_all("China-Taiwan", "Taiwan")
}