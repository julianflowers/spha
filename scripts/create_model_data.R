## prepare modelling data
## for assessing relationship between amputation rates and diabetes care processes

library(needs)
devtools::install_github("ropensci/fingertipsR) ## r package to extact data from the PHOF (fingertips) API
needs(fingertipsR, tidyverse)
options(digits = 2)

## Extract diabetes data for SICBs (area type 66)
data <- fingertips_data(ProfileID = 139, AreaTypeID = 66)

data |>
    filter(str_detect(IndicatorName, "ampu")) |>
    count(TimeperiodSortable)
 
dmmod <- data |>
    mutate(year = str_sub(TimeperiodSortable, 1, 4)) |>
    #count(year, IndicatorName) |>
    filter(year %in% c("2018", "2019", "2020"), 
           str_detect(IndicatorName, "type 2|score|ampu|[Pp]rev"),
           AreaCode != "E92000001") |>
    select(IndicatorID, IndicatorName, AreaCode, AreaName, Sex, Age, year, Value) |>
    mutate(index = paste(IndicatorName, Sex, Age, year, sep = "-")) |>
    select(index, AreaCode, AreaName, Value) |>
    pivot_wider(names_from = index, values_from = Value) |>
    janitor::clean_names() |>
    select(area_code:area_name, contains("type_2"), contains("imd"), contains("prev"), !contains("12_yrs")) |>
    filter(!is.na(deprivation_score_imd_2019_persons_all_ages_2019))

dim(dmmod)

colnames(dmmod)

## impute missing data
## with median values
dmmod <- dmmod |>
    mutate_if(is.numeric, \(x) ifelse(is.na(x), median(x, na.rm = TRUE), x))

## extract variable names and codes
codebook <- data.frame(ind = colnames(dmmod), code = paste0("ind_", 1:length(colnames(dmmod))))

dmmod |>
    write_csv("data/dm_model_data.csv")

codebook |>
    write_csv("data/dmmod_codebook.csv")



