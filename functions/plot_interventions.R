plot_interventions <- function(cases = NULL, interventions = NULL, 
                               intervention_type = NULL , 
                               linetype = "Scale", scales = "free_y") {
  
  interventions <- interventions %>% 
    dplyr::filter(social_distancing %in% intervention_type)

  
  # jitter interventions by a day if stacked
  interventions <- interventions %>%
    group_by(country, date) %>%
    dplyr::mutate(new_date = date +
                   lubridate::days((dplyr::n() - 1))) %>%
    dplyr::ungroup() %>% 
    dplyr::mutate(date = new_date)
    
  
  plot <- cases %>% 
    ggplot2::ggplot(ggplot2::aes(x = date, y = cases, col = type)) + 
    ggplot2::geom_vline(data = tidyr::drop_na(interventions, type),
                        ggplot2::aes_string(xintercept = "date", 
                                            col = "type",
                                            linetype = linetype),
                        size = 1.2) +
    ggplot2::geom_col(col = NA, alpha = 0.6) +
    ggplot2::scale_fill_viridis_d(na.value = "grey") +
    ggplot2::scale_colour_viridis_d(option = "plasma") +
    ggplot2::scale_linetype_manual(values = c(2,1)) +
    ggplot2::facet_wrap(~ country, scales = scales, ncol = 1) +
    cowplot::theme_cowplot() +
    labs(x = "Date", y = "Daily cases") +
    theme(legend.position = "bottom", legend.box="vertical") +
    labs(col = "Intervention", fill = NULL, linetype = linetype)
  
  return(plot)
}
