summarise_interventions <- function(interventions) {
  interventions %>% 
    dplyr::select(-date) %>% 
    dplyr::group_by(country, intervention) %>% 
    dplyr::slice(1) %>% 
    dplyr::ungroup() %>% 
    dplyr::count(type) %>% 
    tidyr::drop_na(type) %>% 
    dplyr::arrange(desc(n)) 
}