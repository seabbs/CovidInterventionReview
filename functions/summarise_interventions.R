summarise_interventions <- function(interventions) {
  interventions %>% 
    dplyr::select(-date) %>% 
    dplyr::group_by(country, type) %>% 
    dplyr::slice(1) %>% 
    dplyr::ungroup() %>% 
    group_by(type) %>% 
    dplyr::summarise(`Number of regions that have implemented` = dplyr::n(), 
                     `National (%)` =  paste0(round(100 *sum(Scale %in% "National") / dplyr::n(), 1), "%"),
                     `Enforced (%)` = paste0(round(100 *sum(Enforced %in% "yes") / dplyr::n(), 1), "%"),
                      Regions = paste(country, collapse = ", ")) %>% 
    dplyr::ungroup() %>% 
    tidyr::drop_na(type) %>% 
    dplyr::arrange(desc(`Number of regions that have implemented`)) %>% 
    dplyr::rename(`Intervention type` = type)
}
