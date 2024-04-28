
needs(fingertipsR, tidyverse, mgcv, broom, broom.mixed)

gp_inds <- indicator_areatypes(AreaTypeID = 7) |>
    pluck("IndicatorID")

inds_gp <- indicators()

dm_inds <- inds_gp |>
    filter(IndicatorID %in% gp_inds) |>
    filter(str_detect(IndicatorName, "[Dd]iabetes")) |>
    pluck("IndicatorID")

dm_inds

dm_data <- fingertips_data(IndicatorID = dm_inds,  AreaTypeID = 7)

## check indicators

dm_data$IndicatorName |>
    unique()

dm_data |>
    count(IndicatorID, IndicatorName, TimeperiodSortable, AreaType, Age, Sex,) |>
    filter(str_detect(AreaType, "GP")) |>
    mutate(year = str_sub(TimeperiodSortable, 1, 4)) |>
    ggplot(aes(year, IndicatorName, fill = n)) +
    geom_tile() +
    scale_fill_viridis_c()


dm_filtered <- dm_data |>
    mutate(year = str_sub(TimeperiodSortable, 1, 4)) |>
    filter(year == 2019, str_detect(AreaType, "GP")) |>
    select(AreaCode, IndicatorID, IndicatorName, TimeperiodSortable, AreaType, Age, Sex, Value, Denominator) |>
    group_by(IndicatorID, IndicatorName, TimeperiodSortable, AreaType, Age, Sex) |>
    mutate(n = n()) |>
    filter(n > 5000)

dm_codes <- dm_filtered |>
    ungroup() |>
    select(contains("Indicator")) |>
    distinct()

dm_codes |>
    print(n = 46)

dm_filtered |>
    ggplot(aes(IndicatorName, Value)) +
    geom_boxplot() +
    coord_flip()

dm_filtered_wide <- dm_filtered |>
    ungroup() |>
    select(IndicatorName, AreaCode, Value) |>
    pivot_wider(names_from = IndicatorName, values_from = Value)

map(dm_filtered_wide, \(x) mean(is.na(x)))

dm_filtered_wide <- dm_filtered_wide |>
    mutate_if(is.numeric, \(x) ifelse(is.na(x), median(x, na.rm = TRUE), x))

dm_correl <- dm_filtered_wide |>
    keep(is.numeric) |>
    cor() |>
    corrplot::corrplot(method = "square", order = "hclust", tl.col = "black")

needs(umap, Rtsne, dbscan, factoextra, FactoMineR)

dm_umap <- dm_filtered_wide |>
    keep(is.numeric) |>
    umap()

set.seed(321)
dm_dim <- dm_umap$layout |>
    data.frame() 

dm_dim |>
    ggplot() +
    geom_point(aes(X1, X2))

dm_cluster <- dm_dim |>
    hdbscan(minPts = 9)

## cluster plot
dm_dim |>
    cbind(cluster = dm_cluster$cluster) |>
    ggplot() +
    geom_point(aes(X1, X2, colour = factor(cluster))) +
    scale_colour_viridis_d(option = "turbo") +
    theme(panel.background = element_blank())


dm_pca <- PCA(dm_filtered_wide |>
        keep(is.numeric) |> scale())

vegan::rda(dm_filtered_wide |>
               keep(is.numeric) |> scale()) |>
    
    plot()

## modelling
## 

## select model variables
## 
mod_vars <- dm_codes |>
    filter(str_detect(IndicatorName, "type 2|prev|educ|foot|cvd"))

mod_vars <- mod_vars$IndicatorName

colnames(dm_filtered_wide |> janitor::clean_names())

mod_df <- dm_filtered_wide |>
    select(all_of(mod_vars)) |>
    janitor::clean_names()
    
mod1 <- lm(people_with_type_2_diabetes_who_achieved_all_three_treatment_targets ~ ., data = mod_df |> 
               select(-contains("cholesterol"), 
                      -contains("type_1"), 
                      -contains("level"),
                      -contains("less")))

gtsummary::tbl_regression(mod1) |> gtsummary::add_glance_source_note()
glance(mod1)

out
