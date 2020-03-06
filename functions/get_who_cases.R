get_who_cases <- function(country = NULL, daily = FALSE) {
  
  
  who_cases <- data.table::fread("https://raw.githubusercontent.com/eebrown/data2019nCoV/master/data-raw/WHO_SR.csv")
  
  
  if (!is.null(country)) {
    who_cases <- who_cases[, c("Date", country), with = FALSE]
    colnames(who_cases) <- c("date", "cases")
    
  }
  
  if (daily) {
    cols <- colnames(who_cases)
    cols <- cols[!colnames(who_cases) %in% c("Date", "date", "SituationReport")]
    safe_diff <- purrr::safely(diff)
    
    who_cases <- dplyr::mutate_at(who_cases,
                                  .vars = cols,
                                  ~ . - dplyr::lag(., default = 0))
  }
  
  return(who_cases)
}