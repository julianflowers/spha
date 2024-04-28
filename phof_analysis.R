needs(data.table, tidyverse, ggpubr, ggridges, plotly, corrr, ggcorrplot)

phof_summary <- fread("data/phof_summary.csv")
phof_wide <- fread("data/phof_wide.csv")

phof_wide |>
    glimpse()

fingertipsR::profiles() |>
    filter(str_detect(ProfileName, "Dia"))

fingertipsR::area_types()

diabetes_data <- fingertipsR::fingertips_data(ProfileID = 139, AreaTypeID = "All" )


diabetes_data <- fread("data/diabetes_data.csv")

diabetes_data <- setDT(diabetes_data) |>
    janitor::clean_names()

## diabetes
## 

england_diabetes_data <- diabetes_data[area_type == "England",]
area_diabetes_data <- diabetes_data[,.N, by = .(area_type, indicator_name, timeperiod_sortable)][order( timeperiod_sortable)] |>
    pivot_wider(names_from = timeperiod_sortable, values_from = N) |>
    arrange(area_type)

area_diabetes_data$indicator_name |>
    unique()

diabetes_data[area_type == "ICBs" & indicator_name == "Diabetes: QOF prevalence (17+ yrs)" , .(area_name, timeperiod_sortable, indicator_name, value)] |>
    ggplot(aes(y= factor(desc(timeperiod_sortable)), 
               x = value, 
               height = stat(density))) +
    geom_density_ridges_gradient(quantile_lines = TRUE, stat = "density") +
    scale_fill_viridis_c() +
    theme_ridges()
    

type_2 <- diabetes_data[str_detect(indicator_name, "People with type 2 diabetes|[Pp]rev|Depr"), .(area_name, area_code, indicator_name, area_type, value, count, denominator, timeperiod_sortable)]

type_2 |>
    fwrite("data/dm_2.csv")


## obesity

obesity <- phof_wide |>aTyoe
    select(DomainName, AreaName, AreaType, TimeperiodSortable, contains("obes"))

diabetes <- phof_wide |>
    select(DomainName, AreaName, AreaType, TimeperiodSortable, contains("diabe"))

obes_wide <- obesity |> 
    pivot_longer(names_to = "inds", values_to = "vals",  cols = 5:last_col()) |>
    arrange(TimeperiodSortable) |>
    filter(!is.na(vals)) |>
    pivot_wider(names_from = inds, values_from = vals) |>
    setDT()

obes_wide$AreaType |> unique()

obes_wide[str_detect(AreaType, "ICBs"),] |>
    ggplot(aes(y= factor(-TimeperiodSortable), 
               x = `Year 6 prevalence of overweight (including obesity) 10-11 yrs Persons`, 
               fill = stat(x))) +
    geom_density_ridges_gradient(quantile_lines = TRUE) +
    scale_fill_viridis_c()


obes_wide[str_detect(AreaType, "Count"),] |>
    ggplot(aes(y= factor(-TimeperiodSortable), 
               x = `Year 6 prevalence of overweight (including obesity) 10-11 yrs Persons`, 
               height = stat(density))) +
    geom_density_ridges_gradient(quantile_lines = TRUE, stat = "density") +
    scale_fill_viridis_c() +
    theme_ridges()


obes_wide[str_detect(AreaType, "Count"),] |>
    ggplot(aes(y= factor(-TimeperiodSortable), 
               x = `Year 6 prevalence of overweight (including obesity) 10-11 yrs Persons`) 
           ) +
    geom_boxplot() 

obes_wide[str_detect(AreaType, "Dist"),] |>
    ggplot(aes(y= factor(-TimeperiodSortable), 
               x = `Percentage of adults (aged 18 plus) classified as overweight or obese 18+ yrs Persons`, 
               fill = stat(x))) +
    geom_density_ridges_gradient(quantile_lines = TRUE) +
    scale_fill_viridis_c()

as_obes <- obes_wide[str_detect(AreaType, "England"),] |>
    select(TimeperiodSortable, contains("Person")) |>
    filter(TimeperiodSortable > 20140000) |>
    pivot_longer(names_to = "ind", values_to = "vals", 2:last_col()) |>
    ggplot(aes(x = TimeperiodSortable, 
               y = vals, 
               colour = ind
           )) +
    geom_smooth(method = "lm") +
    geom_point()

ggplotly(as_obes)

obes_wide[str_detect(AreaType, "England"),] |>
    select(TimeperiodSortable, contains("Person")) |>
    filter(TimeperiodSortable > 20140000) %>%
    select(-TimeperiodSortable) |>
    cor(use = "na.or.complete") |>
    corrplot::corrplot(method = "circle", tl.cex = .5, tl.col = "black", order = "FPC", addrect = 4)
## smoking
## 

smoking <- phof_wide |>
    select(DomainName, AreaName, AreaType, TimeperiodSortable, contains("Smok"))

colnames(smoking)


smoking_wide <- smoking |> 
    pivot_longer(names_to = "inds", values_to = "vals",  cols = 5:last_col()) |>
    arrange(TimeperiodSortable) |>
    pivot_wider(names_from = TimeperiodSortable, values_from = vals) |>
    setDT()

england_smoking <- cbind(smoking_wide[1:19, .(inds, AreaName)], 
    smoking_wide[1:19, .SD, .SDcols = `20110000`:`20220000`]) |>
    pivot_longer(names_to = "period", values_to = "vals", cols = 3:last_col()) 

es <- england_smoking |>
    ggplot() +
    geom_point(aes(period, vals, group = inds, colour = inds)) +
    geom_smooth(aes(period, vals, group = inds, colour = inds), se = FALSE) 

ggplotly(es)



smoking |>
    group_by(AreaType, DomainName) |>
    filter(TimeperiodSortable == max(TimeperiodSortable)) |>
    summarise_all( \(x) mean(is.na(x))) |>
    filter(`Smoking Prevalence in adults (18+) - current smokers (APS) 18+ yrs Male` < 1)
