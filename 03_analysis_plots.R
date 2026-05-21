library(tidyverse)
library(ggrepel)

co2_clean <- read_csv("data/co2_clean.csv")
co2_population <- read_csv("data/co2_population.csv")


library(ggrepel)
library(ggthemes)
co2_clean <- read_csv("data/co2_clean.csv")

top10_23 <- co2_clean |>
  arrange(desc(emissions_2023)) |>
  slice(1:10)

top10_plot_23 <- ggplot(top10_23, aes(
  x = reorder(country, emissions_2023),
  y = emissions_2023
)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Top 10 CO2 emitters in 2023",
    x = "",
    y = "Million tonnes CO2"
  ) +
  theme_economist()

top10_plot_23

ggsave("figs/top10_emitters23.png", top10_plot, width = 8, height = 5)

top10_00 <- co2_clean |>
  arrange(desc(emissions_2000)) |>
  slice(1:10)

top10_plot_00 <- ggplot(top10_00, aes(
  x = reorder(country, emissions_2000),
  y = emissions_2000
)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Top 10 CO2 emitters in 2000",
    x = "",
    y = "Million tonnes CO2"
  ) +
  theme_economist()

top10_plot_00

ggsave("figs/top10_emitters00.png", top10_plot, width = 8, height = 5)

top10_countries_2023 <- co2_clean |>
  arrange(desc(emissions_2023)) |>
  slice(1:10) |>
  pull(country)

top10_2023_total <- co2_clean |>
  filter(country %in% top10_countries_2023) |>
  mutate(country = factor(country, levels = rev(top10_countries_2023))) |>
  select(country, emissions_2000, emissions_2023) |>
  pivot_longer(
    cols = c(emissions_2000, emissions_2023),
    names_to = "year",
    values_to = "emissions"
  ) |>
  mutate(
    year = recode(
      year,
      emissions_2000 = "2000",
      emissions_2023 = "2023"
    )
  )

ggplot(top10_2023_total, aes(
  x = country,
  y = emissions,
  fill = year
)) +
  geom_col(position = "dodge") +
  coord_flip() +
  labs(
    title = "Top 10 CO2 emitters in 2023",
    subtitle = "Emissions in 2000 and 2023",
    x = "",
    y = "Million tonnes CO2",
    fill = "Year"
  ) +
  theme_minimal()

ggsave("figs/top10_emitters00-23.png", top10_plot, width = 8, height = 5)


#Per capita

top10_pc_2023 <- co2_population |>
  arrange(desc(co2_per_capita_2023)) |>
  slice(1:10)

ggplot(top10_pc_2023, aes(
  x = reorder(country, co2_per_capita_2023),
  y = co2_per_capita_2023
)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Top 10 CO2 emissions per capita in 2023",
    x = "",
    y = "Tonnes CO2 per person"
  ) +
  theme_minimal()

top10_pc_2000 <- co2_population |>
  arrange(desc(co2_per_capita_2000)) |>
  slice(1:10)

ggplot(top10_pc_2000, aes(
  x = reorder(country, co2_per_capita_2000),
  y = co2_per_capita_2000
)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Top 10 CO2 emissions per capita in 2000",
    x = "",
    y = "Tonnes CO2 per person"
  ) +
  theme_minimal()

top10_pc_countries_2023 <- co2_population |>
  arrange(desc(co2_per_capita_2023)) |>
  slice(1:10) |>
  pull(country)

top10_pc_both_years <- co2_population |>
  filter(country %in% top10_pc_countries_2023) |>
  mutate(country = factor(country, levels = rev(top10_pc_countries_2023))) |>
  select(country, co2_per_capita_2000, co2_per_capita_2023) |>
  pivot_longer(
    cols = c(co2_per_capita_2000, co2_per_capita_2023),
    names_to = "year",
    values_to = "co2_per_capita"
  ) |>
  mutate(
    year = recode(
      year,
      co2_per_capita_2000 = "2000",
      co2_per_capita_2023 = "2023"
    )
  )

ggplot(top10_pc_both_years, aes(
  x = country,
  y = co2_per_capita,
  fill = year
)) +
  geom_col(position = "dodge") +
  coord_flip() +
  labs(
    title = "Top 10 CO2 emissions per capita in 2023",
    subtitle = "Per capita emissions in 2000 and 2023",
    x = "",
    y = "Tonnes CO2 per person",
    fill = "Year"
  ) +
  theme_minimal()

# 2000 sammenlignet med 2023, farvekodet i fht. regioner samlet.

library(ggrepel)

emissions_scatter <- ggplot(co2_diff, aes(
  x = emissions_2000,
  y = emissions_2023,
  color = region
)) +
  geom_point(alpha = 0.7) +
  geom_abline(
    slope = 1,
    intercept = 0,
    linetype = "dashed"
  ) +
  geom_text_repel(
    data = top_abs_change,
    aes(label = country),
    size = 3,
    show.legend = FALSE
  ) +
  labs(
    title = "CO2 emissions: 2000 vs 2023",
    subtitle = "Countries with largest absolute changes labeled",
    x = "Emissions in 2000",
    y = "Emissions in 2023",
    color = "Region"
  ) +
  theme_minimal()

emissions_scatter

# Sammenligning af 2000 og 2023 per capita 

percap_scatter <- ggplot(pc_diff, aes(
  x = co2_per_capita_2000,
  y = co2_per_capita_2023,
  color = region
)) +
  geom_point(alpha = 0.7) +
  geom_abline(
    slope = 1,
    intercept = 0,
    linetype = "dashed"
  ) +
  geom_text_repel(
    data = top_abs_pc_change,
    aes(label = country),
    size = 3,
    show.legend = FALSE
  ) +
  labs(
    title = "CO2 emissions per capita: 2000 vs 2023",
    subtitle = "Countries with largest absolute per capita changes labeled",
    x = "Tonnes CO2 per person in 2000",
    y = "Tonnes CO2 per person in 2023",
    color = "Region"
  ) +
  theme_minimal()

percap_scatter

ggsave(
  "figs/emissions_scatter.png",
  plot = emissions_scatter,
  width = 10,
  height = 7
)

ggsave(
  "figs/percap_scatter.png",
  plot = percap_scatter,
  width = 10,
  height = 7
)

ggsave(
  "figs/emissions_scatter.pdf",
  plot = emissions_scatter,
  width = 10,
  height = 7
)

pdf("figs/co2_analysis_2000_2023.pdf",
    width = 10,
    height = 7)
emissions_scatter
percap_scatter

dev.off()


# logaritmiske akser
emissions_scatter_log <- ggplot(co2_diff, aes(
  x = emissions_2000,
  y = emissions_2023,
  color = region
)) +
  geom_point(alpha = 0.7) +
  
  geom_abline(
    slope = 1,
    intercept = 0,
    linetype = "dashed"
  ) +
  
  geom_text_repel(
    data = top_abs_change,
    aes(label = country),
    size = 3,
    show.legend = FALSE
  ) +
  
  scale_x_log10() +
  scale_y_log10() +
  
  labs(
    title = "CO2 emissions: 2000 vs 2023 (log scale)",
    subtitle = "Countries with largest absolute changes labeled",
    x = "Emissions in 2000 (log scale)",
    y = "Emissions in 2023 (log scale)",
    color = "Region"
  ) +
  
  theme_minimal()

emissions_scatter_log

percap_scatter_log <- ggplot(pc_diff, aes(
  x = co2_per_capita_2000,
  y = co2_per_capita_2023,
  color = region
)) +
  geom_point(alpha = 0.7) +
  
  geom_abline(
    slope = 1,
    intercept = 0,
    linetype = "dashed"
  ) +
  
  geom_text_repel(
    data = top_abs_pc_change,
    aes(label = country),
    size = 3,
    show.legend = FALSE
  ) +
  
  scale_x_log10() +
  scale_y_log10() +
  
  labs(
    title = "CO2 emissions per capita: 2000 vs 2023 (log scale)",
    subtitle = "Countries with largest absolute per capita changes labeled",
    x = "CO2 per capita in 2000 (log scale)",
    y = "CO2 per capita in 2023 (log scale)",
    color = "Region"
  ) +
  
  theme_minimal()



percap_scatter_log <- ggplot(pc_diff, aes(
  x = co2_per_capita_2000,
  y = co2_per_capita_2023,
  color = region
)) +
  geom_point(alpha = 0.7) +
  
  geom_abline(
    slope = 1,
    intercept = 0,
    linetype = "dashed"
  ) +
  
  geom_text_repel(
    data = top_abs_pc_change,
    aes(label = country),
    size = 3,
    show.legend = FALSE
  ) +
  
  scale_x_log10() +
  scale_y_log10() +
  
  labs(
    title = "CO2 emissions per capita: 2000 vs 2023 (log scale)",
    subtitle = "Countries with largest absolute per capita changes labeled",
    x = "CO2 per capita in 2000 (log scale)",
    y = "CO2 per capita in 2023 (log scale)",
    color = "Region"
  ) +
  
  theme_minimal()

percap_scatter_log

#regional total udledning
regional_scatter <- ggplot(co2_diff, aes(
  x = emissions_2000,
  y = emissions_2023,
  color = region
)) +
  geom_point(alpha = 0.7) +
  
  geom_abline(
    slope = 1,
    intercept = 0,
    linetype = "dashed"
  ) +
  
  scale_x_log10() +
  scale_y_log10() +
  
  facet_wrap(~ region) +
  
  labs(
    title = "CO2 emissions by region: 2000 vs 2023",
    subtitle = "Log scales with 45-degree reference line",
    x = "Emissions in 2000",
    y = "Emissions in 2023"
  ) +
  
  theme_minimal()

regional_scatter

#Regional per capita
regional_percap <- ggplot(pc_diff, aes(
  x = co2_per_capita_2000,
  y = co2_per_capita_2023,
  color = region
)) +
  geom_point(alpha = 0.7) +
  
  geom_abline(
    slope = 1,
    intercept = 0,
    linetype = "dashed"
  ) +
  
  scale_x_log10() +
  scale_y_log10() +
  
  facet_wrap(~ region) +
  
  labs(
    title = "CO2 emissions per capita by region",
    subtitle = "2000 vs 2023 (log scale)",
    x = "Per capita emissions in 2000",
    y = "Per capita emissions in 2023"
  ) +
  
  theme_minimal()

regional_percap

#The west vs Rest, total
west <- c(
  "United States",
  "Canada",
  "United Kingdom",
  "Germany",
  "France",
  "Japan",
  "Australia"
)
co2_clean <- co2_clean |>
  mutate(
    west_vs_rest = if_else(
      country %in% west,
      "West",
      "Rest"
    )
  )
co2_clean |>
  group_by(west_vs_rest) |>
  summarise(
    total_emissions = sum(emissions_2023, na.rm = TRUE)
  )
co2_clean |>
  group_by(west_vs_rest) |>
  summarise(
    total_emissions = sum(emissions_2000, na.rm = TRUE)
  )


west_change <- co2_clean |>
  group_by(west_vs_rest) |>
  summarise(
    emissions_2000 = sum(emissions_2000, na.rm = TRUE),
    emissions_2023 = sum(emissions_2023, na.rm = TRUE)
  ) |>
  mutate(
    absolute_change = emissions_2023 - emissions_2000,
    pct_change = absolute_change / emissions_2000 * 100
  )

west_change

west_change_long <- west_change |>
  pivot_longer(
    cols = c(emissions_2000, emissions_2023),
    names_to = "year",
    values_to = "emissions"
  ) |>
  mutate(
    year = recode(
      year,
      emissions_2000 = "2000",
      emissions_2023 = "2023"
    )
  )

west_rest_long <- west_change |>
  pivot_longer(
    cols = c(emissions_2000, emissions_2023),
    names_to = "year",
    values_to = "emissions"
  )

ggplot(west_rest_long,
       aes(
         x = west_vs_rest,
         y = emissions,
         fill = year
       )) +
  geom_col(position = "dodge") +
  labs(
    title = "West vs Rest: CO2 emissions",
    y = "Million tonnes CO2",
    x = ""
  ) +
  theme_minimal()

#Samlet ændring
ggplot(west_change, aes(
  x = west_vs_rest,
  y = absolute_change
)) +
  geom_col() +
  labs(
    title = "Change in CO2 emissions from 2000 to 2023",
    subtitle = "West vs Rest",
    x = "",
    y = "Change in million tonnes CO2"
  ) +
  theme_minimal()


#West vs Rest per capita

# West vs Rest per capita

co2_population <- co2_population |>
  mutate(
    west_vs_rest = if_else(
      country %in% west,
      "West",
      "Rest"
    )
  )

west_pc <- co2_population |>
  group_by(west_vs_rest) |>
  summarise(
    emissions_2000 = sum(emissions_2000, na.rm = TRUE),
    emissions_2023 = sum(emissions_2023, na.rm = TRUE),
    population_2000 = sum(population_2000, na.rm = TRUE),
    population_2023 = sum(population_2023, na.rm = TRUE)
  ) |>
  mutate(
    co2_per_capita_2000 = emissions_2000 * 1000000 / population_2000,
    co2_per_capita_2023 = emissions_2023 * 1000000 / population_2023
  )

west_pc

west_pc_long <- west_pc |>
  select(west_vs_rest, co2_per_capita_2000, co2_per_capita_2023) |>
  pivot_longer(
    cols = c(co2_per_capita_2000, co2_per_capita_2023),
    names_to = "year",
    values_to = "co2_per_capita"
  ) |>
  mutate(
    year = recode(
      year,
      co2_per_capita_2000 = "2000",
      co2_per_capita_2023 = "2023"
    )
  )

west_pc_plot <- ggplot(west_pc_long, aes(
  x = west_vs_rest,
  y = co2_per_capita,
  fill = year
)) +
  geom_col(position = "dodge") +
  labs(
    title = "CO2 emissions per capita",
    subtitle = "West vs Rest, 2000 and 2023",
    x = "",
    y = "Tonnes CO2 per person",
    fill = "Year"
  ) +
  theme_minimal()

west_pc_plot

ggplot(west_pc, aes(
  x = west_vs_rest,
  y = co2_per_capita_2023
)) +
  geom_col() +
  labs(
    title = "CO2 emissions per capita",
    subtitle = "West vs Rest, 2023",
    x = "",
    y = "Tonnes CO2 per person"
  ) +
  theme_minimal()