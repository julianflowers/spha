## AA example
## 

library(needs)
needs(tidyverse, data.table, ggpubr)

data.table::setDTthreads(6)

aa_data <- read_csv("~/spha/data/Death rates for hospitals carrying out AAA operations - Data.csv", 
                    skip = 1
                    ) |>
    janitor::clean_names() |>
    mutate_at(.vars = 2:20, as.numeric)

eaa_death_rates <- aa_data |>
    select(c(1, 8:9)) |>
    mutate(rate = total_deaths_2006_2008_8/no_of_operations_2006_2008_9)
    
eaa_death_rates |>
    write_csv("data/aa.csv")

eaa_death_rates |>
    arrange(-rate)

funnel_data <- read_csv("~/spha/data/PHE funnel plot tool for proportions.csv") |>
    janitor::clean_names()

f <- funnel_data |>
    ggplot() +
    geom_line(aes(`population_x_axis`, lower_2s_0_025_limit), lty = "dotted") +
    geom_line(aes(`population_x_axis`, lower_3s_0_001_limit)) +
    geom_line(aes(population_x_axis, upper_2s_0_025_limit), lty = "dotted") +
    geom_line(aes(population_x_axis, upper_3s_0_001_limit)) +
    geom_point(aes(no_of_operations_2006_2008_9, 100 * rate), data = eaa_death_rates) +
    geom_smooth(aes(no_of_operations_2006_2008_9, 100 * rate), data = eaa_death_rates, se = FALSE, method = "lm") +
    
    ggrepel::geom_text_repel(aes(no_of_operations_2006_2008_9, 100 * rate, label = trusts_which_perform_abdominal_ayortic_aneurysms_no_data_means_did_not_supply_information_to_guardian,), 
                             data = eaa_death_rates |> filter(str_detect(trusts_which_perform_abdominal_ayortic_aneurysms_no_data_means_did_not_supply_information_to_guardian, 
                             "Scar|Gateshe|Hull|Leeds|Penine|Medw|Peter|Eliot|Wirral")), colour = "red", size = 3, seed = 123) +
    labs(x = "Number of procedures 2006-8", 
         y = "Fatality rate (%)", 
         title = "Hospital mortality following elective aortic aneurysm surgery") + 
    theme(plot.title.position = "plot", 
          text = element_text(size = 9), 
          title = element_text(size = 14)) 
    
para <- paste("There is a weak inverse relationship between surgical volume and mortality (blue line). Although mortality in Scarborough is statistically high, mortality in Gateshead and Hull is also high at much higher surgical volume.", 
          sep = " ") 
    
text.p <- ggparagraph(text = para, size = 11, color = "black")

ggarrange(f, text.p, nrow = 2, heights = c(2, 0.5, 0.3))



    

                    