Package
-------

Extract variables of potential interest from linelist
-----------------------------------------------------

    extracted_linelist <- suppressMessages(readr::read_csv("raw-data/linelist.csv")) %>%
      dplyr::as_tibble() %>%
      dplyr::select(country, city, province, date_confirmation, travel_history_location) %>%
      dplyr::mutate(import_status = dplyr::if_else(is.na(travel_history_location) |
                                                     travel_history_location == "", "local", "imported"))

    ## Warning: 656 parsing failures.
    ##  row                     col           expected actual                    file
    ## 5835 data_moderator_initials 1/0/T/F/TRUE/FALSE     SL 'raw-data/linelist.csv'
    ## 5836 data_moderator_initials 1/0/T/F/TRUE/FALSE     SL 'raw-data/linelist.csv'
    ## 5837 data_moderator_initials 1/0/T/F/TRUE/FALSE     SL 'raw-data/linelist.csv'
    ## 5838 data_moderator_initials 1/0/T/F/TRUE/FALSE     SL 'raw-data/linelist.csv'
    ## 5839 data_moderator_initials 1/0/T/F/TRUE/FALSE     SL 'raw-data/linelist.csv'
    ## .... ....................... .................. ...... .......................
    ## See problems(...) for more details.

Estimate fraction that are imported
-----------------------------------

-   Based on linelist data alone. Only countries with at least 20 total
    cases present are shown.

<!-- -->

    ## Based on linelist data
    prop_cases_imported <- extracted_linelist %>%
      dplyr::count(country, import_status) %>%
      tidyr::spread(key = "import_status", value = "n") %>%
      dplyr::mutate_at(.vars = c("local", "imported"), ~ replace(., is.na(.), 0)) %>%
      dplyr::mutate(linelist_total = imported + local,
                    frac_imported = round(imported / linelist_total, 2)) %>%
      dplyr::filter(linelist_total >= 15, !country %in% c("", "China")) %>%
      dplyr::arrange(desc(frac_imported))

-   Based on linelist data and WH0 sit reps

<!-- -->

    countries <- prop_cases_imported$country
    names(countries) <- prop_cases_imported$country

    countries["South Korea"] <- "RepublicofKorea"
    countries["United Arab Emirates"] <- "UnitedArabEmirates"
    countries["United States"] <- "UnitedStatesofAmerica"
    countries["Vietnam"] <- "VietNam"
    countries["United Kingdom"] <- "UnitedKingdom"
    countries <- countries[!is.na(countries)]

    country_cases <- countries %>% 
      purrr::map_dfr(~ get_who_cases(., daily = TRUE), .id = "country")

    total_cases <- country_cases %>% 
      dplyr::count(country, wt = cases) %>% 
      dplyr::rename(who_total = n)

    prop_cases_imported_who <- prop_cases_imported %>% 
      dplyr::full_join(total_cases, by = "country") %>% 
      dplyr::mutate(who_frac_imported = round(imported / who_total, 2)) %>% 
      dplyr::arrange(desc(who_frac_imported)) %>% 
      ## Drop USA and thailand
      dplyr::filter(!country %in% c("United States", "Thailand", "Iran"))

-   Summarise and report

<!-- -->

    tab_cases_imported <- prop_cases_imported_who %>% 
      dplyr::select(Country = country, Cases = who_total, `Fraction imported (linelist only)` = frac_imported,
                    `Fraction imported (WHO sit reps)` = who_frac_imported)

    saveRDS(tab_cases_imported, "output-data/cases_imported.rds")

    knitr::kable(tab_cases_imported)

<table>
<thead>
<tr class="header">
<th style="text-align: left;">Country</th>
<th style="text-align: right;">Cases</th>
<th style="text-align: right;">Fraction imported (linelist only)</th>
<th style="text-align: right;">Fraction imported (WHO sit reps)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">Vietnam</td>
<td style="text-align: right;">17</td>
<td style="text-align: right;">0.69</td>
<td style="text-align: right;">0.65</td>
</tr>
<tr class="even">
<td style="text-align: left;">Kuwait</td>
<td style="text-align: right;">58</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">0.64</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Bahrain</td>
<td style="text-align: right;">49</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">0.41</td>
</tr>
<tr class="even">
<td style="text-align: left;">Canada</td>
<td style="text-align: right;">51</td>
<td style="text-align: right;">0.75</td>
<td style="text-align: right;">0.29</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Singapore</td>
<td style="text-align: right;">130</td>
<td style="text-align: right;">0.34</td>
<td style="text-align: right;">0.25</td>
</tr>
<tr class="even">
<td style="text-align: left;">Australia</td>
<td style="text-align: right;">62</td>
<td style="text-align: right;">0.88</td>
<td style="text-align: right;">0.24</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Iraq</td>
<td style="text-align: right;">44</td>
<td style="text-align: right;">0.44</td>
<td style="text-align: right;">0.18</td>
</tr>
<tr class="even">
<td style="text-align: left;">United Arab Emirates</td>
<td style="text-align: right;">45</td>
<td style="text-align: right;">0.35</td>
<td style="text-align: right;">0.16</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Malaysia</td>
<td style="text-align: right;">83</td>
<td style="text-align: right;">0.65</td>
<td style="text-align: right;">0.13</td>
</tr>
<tr class="even">
<td style="text-align: left;">India</td>
<td style="text-align: right;">31</td>
<td style="text-align: right;">0.14</td>
<td style="text-align: right;">0.13</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Japan</td>
<td style="text-align: right;">408</td>
<td style="text-align: right;">0.07</td>
<td style="text-align: right;">0.13</td>
</tr>
<tr class="even">
<td style="text-align: left;">Netherlands</td>
<td style="text-align: right;">128</td>
<td style="text-align: right;">0.67</td>
<td style="text-align: right;">0.09</td>
</tr>
<tr class="odd">
<td style="text-align: left;">United Kingdom</td>
<td style="text-align: right;">167</td>
<td style="text-align: right;">0.59</td>
<td style="text-align: right;">0.06</td>
</tr>
<tr class="even">
<td style="text-align: left;">Spain</td>
<td style="text-align: right;">374</td>
<td style="text-align: right;">0.44</td>
<td style="text-align: right;">0.06</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Norway</td>
<td style="text-align: right;">113</td>
<td style="text-align: right;">0.25</td>
<td style="text-align: right;">0.04</td>
</tr>
<tr class="even">
<td style="text-align: left;">Germany</td>
<td style="text-align: right;">639</td>
<td style="text-align: right;">0.32</td>
<td style="text-align: right;">0.03</td>
</tr>
<tr class="odd">
<td style="text-align: left;">France</td>
<td style="text-align: right;">613</td>
<td style="text-align: right;">0.20</td>
<td style="text-align: right;">0.01</td>
</tr>
<tr class="even">
<td style="text-align: left;">Italy</td>
<td style="text-align: right;">4636</td>
<td style="text-align: right;">0.02</td>
<td style="text-align: right;">0.00</td>
</tr>
<tr class="odd">
<td style="text-align: left;">South Korea</td>
<td style="text-align: right;">6767</td>
<td style="text-align: right;">0.02</td>
<td style="text-align: right;">0.00</td>
</tr>
<tr class="even">
<td style="text-align: left;">Austria</td>
<td style="text-align: right;">66</td>
<td style="text-align: right;">0.00</td>
<td style="text-align: right;">0.00</td>
</tr>
<tr class="odd">
<td style="text-align: left;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.58</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

Plot cases over time
--------------------

-   Wrangle for countries of interest (with at least 40 cases)

<!-- -->

    cum_cases_in_countries <- readr::read_csv("raw-data/countries_of_interest_counts.csv") %>% 
        dplyr::filter(!country %in% c("United States", "Thailand", "Iran"))

    ## Parsed with column specification:
    ## cols(
    ##   date = col_date(format = ""),
    ##   country = col_character(),
    ##   cases = col_double()
    ## )

-   Get date of first report

<!-- -->

    first_cases <- cum_cases_in_countries %>% 
      dplyr::group_by(country) %>% 
      dplyr::filter(cases > 0) %>% 
      dplyr::filter(cases == min(cases), date == min(date)) %>% 
      dplyr::ungroup() %>% 
      dplyr::arrange(date) %>% 
      dplyr::select(Country = country, `Date of first case report` = date)

    first_cases %>% 
      knitr::kable()

<table>
<thead>
<tr class="header">
<th style="text-align: left;">Country</th>
<th style="text-align: left;">Date of first case report</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">Wuhan</td>
<td style="text-align: left;">2020-01-15</td>
</tr>
<tr class="even">
<td style="text-align: left;">Republic of Korea</td>
<td style="text-align: left;">2020-01-20</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Japan</td>
<td style="text-align: left;">2020-01-20</td>
</tr>
<tr class="even">
<td style="text-align: left;">Taiwan</td>
<td style="text-align: left;">2020-01-21</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Hong Kong</td>
<td style="text-align: left;">2020-01-23</td>
</tr>
<tr class="even">
<td style="text-align: left;">Singapore</td>
<td style="text-align: left;">2020-01-24</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Italy</td>
<td style="text-align: left;">2020-01-31</td>
</tr>
</tbody>
</table>

-   Get case counts

<!-- -->

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

Get interventions
-----------------

-   Plot overall interventions

<!-- -->

    interventions <- readr::read_csv("raw-data/intervention_dates.csv") %>% 
      dplyr::select(date = date_intervention, intervention, country, social_distancing) %>% 
      dplyr::mutate(date = date %>% 
                      stringr::str_replace_all("/", "-")) %>% 
      dplyr::mutate(date = as.Date(date)) %>% 
      dplyr::mutate(country = country %>% 
                      stringr::str_replace_all("south korea", "Republic of Korea") %>% 
                      stringr::str_replace_all("Usa", "United States") %>%
                      stringr::str_to_title() %>% 
                      stringr::str_replace_all("Usa", "United States") %>% 
                      stringr::str_replace_all("Republic Of Korea", "Republic of Korea")) %>% 
      dplyr::mutate(intervention = intervention %>% 
                      stringr::str_replace_all("_", " ") %>% 
                      stringr::str_to_sentence() %>%
                      stringr::str_replace("School restictions", "School restrictions") %>% 
                      stringr::str_replace("Communciation distancing", "Communication distancing")) %>% 
          dplyr::filter(!country %in% c("United States", "Thailand", "Iran")) %>% 
      tidyr::drop_na(intervention)

    ## Warning: Missing column names filled in: 'X8' [8]

    ## Parsed with column specification:
    ## cols(
    ##   date_intervention = col_date(format = ""),
    ##   intervention = col_character(),
    ##   social_distancing = col_character(),
    ##   country = col_character(),
    ##   notes = col_character(),
    ##   ref1 = col_character(),
    ##   ref2 = col_character(),
    ##   X8 = col_character()
    ## )

    c_grepl <- purrr::partial(grepl, ignore.case = TRUE)

    ## Add detail to interventions
    interventions <- interventions %>% 
      dplyr::mutate(intervention_cat = case_when(
        c_grepl("School", intervention) | c_grepl("University", intervention) ~ "Education",
        c_grepl("Mass gathering", intervention) ~ "Mass gathering",
        c_grepl("Travel", intervention) | c_grepl("flights", intervention) |
          c_grepl("Border", intervention) ~ "Travel", 
        c_grepl("Surveillance", intervention) | c_grepl("Contact tracing", interventions) |
          c_grepl("Government on alert", intervention) ~ "Surveillance",
        c_grepl("Quarantine", intervention) ~ "Quarantine",
        c_grepl("information", intervention) | c_grepl("awareness", intervention) |
          c_grepl("annoucement", intervention) | grepl("Communication", intervention) ~ "Information",
        c_grepl("health", intervention) | c_grepl("Enhanced care", intervention) ~ "Healthcare",
        c_grepl("work", intervention) ~ "Workplace",
        c_grepl("Lockdown", intervention) ~ "Lockdown",
        c_grepl("Isolation", intervention) ~ "Isolation",
        TRUE ~ "Other"
      ),
    intervention_scale = case_when(
      c_grepl("awareness", intervention) | c_grepl("advisory", intervention) ~ "Advice",
      c_grepl("ban", intervention) ~ "Restriction",
      c_grepl("closure", intervention) ~ "Closure",
      c_grepl("surveillance", intervention) | c_grepl("isolation", intervention) |
        c_grepl("contact tracing", intervention) ~ "Public health",
      TRUE ~ "Other"
    )) %>% 
      dplyr::mutate(country = country %>% 
                      factor(levels = first_cases$Country))

    ## Warning in c_grepl("Surveillance", intervention) | c_grepl("Contact tracing", :
    ## longer object length is not a multiple of shorter object length

    readr::write_csv(interventions, "output-data/interventions.csv")

    summarise_ints <- function(df) {
      df %>% 
      dplyr::select(-date) %>% 
      dplyr::group_by(country, intervention) %>% 
      dplyr::slice(1) %>% 
      dplyr::ungroup() %>% 
      dplyr::count(intervention) %>% 
      tidyr::drop_na(intervention) %>% 
      dplyr::arrange(desc(n)) %>% 
      dplyr::select(Intervention = intervention, 
                    `Countries that have implemented` = n)
    }


    summarise_interventions <- interventions %>% 
      summarise_ints()



    saveRDS(summarise_interventions, "output-data/intervention_freq.rds")

-   Summarise interventions by category

<!-- -->

    sum_intervention_cats <- interventions %>% 
      dplyr::group_by(intervention_cat, social_distancing) %>% 
      dplyr::summarise(interventions = paste(unique(intervention), collapse = ", "))

-   Social categories

<!-- -->

    sum_intervention_cats %>% 
      dplyr::filter(social_distancing %in% "yes") %>% 
      dplyr::select(-social_distancing) %>% 
      knitr::kable()

<table>
<thead>
<tr class="header">
<th style="text-align: left;">intervention_cat</th>
<th style="text-align: left;">interventions</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">Education</td>
<td style="text-align: left;">School closure, University closure, School closure (not related to outbreak), Prevention measures school, School restrictions, [Extension] school and work closure</td>
</tr>
<tr class="even">
<td style="text-align: left;">Healthcare</td>
<td style="text-align: left;">Healthcare restrictions</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Information</td>
<td style="text-align: left;">Communication distancing</td>
</tr>
<tr class="even">
<td style="text-align: left;">Isolation</td>
<td style="text-align: left;">Isolation</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Lockdown</td>
<td style="text-align: left;">Lockdown</td>
</tr>
<tr class="even">
<td style="text-align: left;">Mass gathering</td>
<td style="text-align: left;">Mass gathering advisory, Mass gathering cancellation</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Other</td>
<td style="text-align: left;">Social distancing misc, Reduced shop hours, Social event cancellation</td>
</tr>
<tr class="even">
<td style="text-align: left;">Quarantine</td>
<td style="text-align: left;">Mandatory quarantine, Quarantine</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Surveillance</td>
<td style="text-align: left;">Quarantine, Mandatory quarantine, Remote working, Contact tracing, Work closure (not related to outbreak), Lockdown</td>
</tr>
<tr class="even">
<td style="text-align: left;">Travel</td>
<td style="text-align: left;">Travel advice, Travel restriction</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Workplace</td>
<td style="text-align: left;">Remote working, Work closure (not related to outbreak)</td>
</tr>
</tbody>
</table>

-   Non-social categories

<!-- -->

    sum_intervention_cats %>% 
      dplyr::filter(social_distancing %in% "no") %>% 
      dplyr::select(-social_distancing) %>% 
      knitr::kable()

<table>
<thead>
<tr class="header">
<th style="text-align: left;">intervention_cat</th>
<th style="text-align: left;">interventions</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">Healthcare</td>
<td style="text-align: left;">Health screening, Enhanced care</td>
</tr>
<tr class="even">
<td style="text-align: left;">Information</td>
<td style="text-align: left;">Public information, Communication general, Raise awareness healthcare staff, Raise awareness public</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Other</td>
<td style="text-align: left;">Containment to mitigation, Supply, Decontamination, Government announcement</td>
</tr>
<tr class="even">
<td style="text-align: left;">Surveillance</td>
<td style="text-align: left;">Government on alert, Surveillance, Raise awareness healthcare staff, Raise awareness public, Resumption public services, Medical surveillance, Health screening, Strengthening primary care response, Enhanced care</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Travel</td>
<td style="text-align: left;">Raise awareness flights, Travel ban, Border control, Travel advice, Suspending flights, Travel advisory, Travel restriction</td>
</tr>
</tbody>
</table>

-   Social scales

<!-- -->

    sum_intervention_scales <- interventions %>% 
      dplyr::group_by(intervention_scale, social_distancing) %>% 
      dplyr::summarise(interventions = paste(unique(intervention), collapse = ", "))

    sum_intervention_scales %>% 
      dplyr::filter(social_distancing %in% "no") %>% 
      dplyr::select(-social_distancing) %>% 
      knitr::kable()

<table>
<thead>
<tr class="header">
<th style="text-align: left;">intervention_scale</th>
<th style="text-align: left;">interventions</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">Advice</td>
<td style="text-align: left;">Raise awareness flights, Raise awareness healthcare staff, Raise awareness public, Travel advisory</td>
</tr>
<tr class="even">
<td style="text-align: left;">Other</td>
<td style="text-align: left;">Containment to mitigation, Government on alert, Public information, Communication general, Border control, Supply, Travel advice, Suspending flights, Resumption public services, Health screening, Travel restriction, Strengthening primary care response, Decontamination, Enhanced care, Government announcement</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Public health</td>
<td style="text-align: left;">Surveillance, Medical surveillance</td>
</tr>
<tr class="even">
<td style="text-align: left;">Restriction</td>
<td style="text-align: left;">Travel ban</td>
</tr>
</tbody>
</table>

-   Non-social scales

<!-- -->

    sum_intervention_scales %>% 
      dplyr::filter(social_distancing %in% "no") %>% 
      dplyr::select(-social_distancing) %>% 
      knitr::kable()

<table>
<thead>
<tr class="header">
<th style="text-align: left;">intervention_scale</th>
<th style="text-align: left;">interventions</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">Advice</td>
<td style="text-align: left;">Raise awareness flights, Raise awareness healthcare staff, Raise awareness public, Travel advisory</td>
</tr>
<tr class="even">
<td style="text-align: left;">Other</td>
<td style="text-align: left;">Containment to mitigation, Government on alert, Public information, Communication general, Border control, Supply, Travel advice, Suspending flights, Resumption public services, Health screening, Travel restriction, Strengthening primary care response, Decontamination, Enhanced care, Government announcement</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Public health</td>
<td style="text-align: left;">Surveillance, Medical surveillance</td>
</tr>
<tr class="even">
<td style="text-align: left;">Restriction</td>
<td style="text-align: left;">Travel ban</td>
</tr>
<tr class="odd">
<td style="text-align: left;">* Social intervention</td>
<td style="text-align: left;">s only</td>
</tr>
</tbody>
</table>

    social_interventions <- interventions %>% 
      dplyr::filter(social_distancing %in% "yes") %>% 
      summarise_ints() %>% 
      dplyr::filter(`Countries that have implemented` > 1)

    saveRDS(social_interventions, "output-data/social_interventions.rds")

    knitr::kable(social_interventions)

<table>
<thead>
<tr class="header">
<th style="text-align: left;">Intervention</th>
<th style="text-align: right;">Countries that have implemented</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">Quarantine</td>
<td style="text-align: right;">3</td>
</tr>
<tr class="even">
<td style="text-align: left;">Remote working</td>
<td style="text-align: right;">3</td>
</tr>
<tr class="odd">
<td style="text-align: left;">School closure</td>
<td style="text-align: right;">3</td>
</tr>
<tr class="even">
<td style="text-align: left;">School closure (not related to outbreak)</td>
<td style="text-align: right;">3</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Lockdown</td>
<td style="text-align: right;">2</td>
</tr>
<tr class="even">
<td style="text-align: left;">Mandatory quarantine</td>
<td style="text-align: right;">2</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Mass gathering cancellation</td>
<td style="text-align: right;">2</td>
</tr>
<tr class="even">
<td style="text-align: left;">Social event cancellation</td>
<td style="text-align: right;">2</td>
</tr>
<tr class="odd">
<td style="text-align: left;">University closure</td>
<td style="text-align: right;">2</td>
</tr>
<tr class="even">
<td style="text-align: left;">Work closure (not related to outbreak)</td>
<td style="text-align: right;">2</td>
</tr>
</tbody>
</table>

-   Non-social interventions

<!-- -->

    non_social_interventions <- interventions %>% 
      dplyr::filter(social_distancing %in% "no") %>% 
      summarise_ints() %>% 
      dplyr::filter(`Countries that have implemented` > 1)

    saveRDS(non_social_interventions, "output-data/non_social_interventions.rds")

    knitr::kable(non_social_interventions)

<table>
<thead>
<tr class="header">
<th style="text-align: left;">Intervention</th>
<th style="text-align: right;">Countries that have implemented</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">Health screening</td>
<td style="text-align: right;">4</td>
</tr>
<tr class="even">
<td style="text-align: left;">Travel restriction</td>
<td style="text-align: right;">3</td>
</tr>
</tbody>
</table>

-   Plot social interventions

<!-- -->

    plot_interventions <- function(intervention_type , scales = "free_y") {
      plot_df <- cases_in_countries %>% 
      dplyr::left_join(interventions %>% 
                         dplyr::filter(social_distancing %in% intervention_type),
                       by = c("date", "country")) %>% 
      dplyr::group_by(country, date) %>% 
      dplyr::mutate(cases = cases / dplyr::n())
      
      plot_df %>% 
      ggplot2::ggplot(ggplot2::aes(x = date, y = cases, col= intervention_cat)) +
      ggplot2::geom_vline(data = tidyr::drop_na(plot_df, intervention_cat),
                          aes(xintercept = date, col = intervention_cat,
                              linetype = intervention_scale), 
                          size = 1.2) +
      ggplot2::geom_col(col = NA, alpha = 0.6) +
      ggplot2::scale_fill_brewer(palette = "Dark2", na.value = "grey") +
      ggplot2::facet_wrap(~ country, scales = scales, ncol = 1) +
      cowplot::theme_cowplot() +
      labs(x = "Date", y = "Cases") +
      theme(legend.position = "bottom", legend.box="vertical") +
      labs(col = "Type", fill = NULL, linetype = "Scale")
    }


    plot_interventions("yes", scales = "free_y")

    ## Warning: Removed 8 rows containing missing values (position_stack).

![](figures/social-all-time-1.png)

    plot_interventions("yes", scales = "free")

    ## Warning: Removed 8 rows containing missing values (position_stack).

![](figures/social-norm-time-1.png)

-   Plot non-social interventions

<!-- -->

    plot_interventions("no", scales = "free_y")

    ## Warning: Removed 8 rows containing missing values (position_stack).

![](figures/non-social-all-time-1.png)

    plot_interventions("no", scales = "free")

    ## Warning: Removed 8 rows containing missing values (position_stack).

![](figures/non-social-norm-time-1.png)
