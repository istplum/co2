library(tidyverse)
library(rvest)

url <- "https://en.wikipedia.org/wiki/List_of_countries_by_carbon_dioxide_emissions"

h <- read_html(url)

tables <- h |> html_elements("table")

co2_raw <- tables[[1]] |> html_table(fill = TRUE)

# Se kolonner
names(co2_raw)

# Vælg de første 5 kolonner via position
co2_clean <- co2_raw[, 1:5]

names(co2_clean) <- c(
  "country",
  "share_global_total",
  "emissions_2023",
  "emissions_2000",
  "change_from_2000"
)

co2_clean <- co2_clean |>
  filter(
    country != "Location",
    country != "World",
    change_from_2000 != "no change%"
  ) |>
  mutate(
    emissions_2023 = parse_number(as.character(emissions_2023)),
    emissions_2000 = parse_number(as.character(emissions_2000)),
    change_from_2000 = parse_number(as.character(change_from_2000))
  ) |>
  filter(!is.na(emissions_2023))
top10 <- co2_clean |>
  arrange(desc(emissions_2023)) |>
  slice(1:10)

top10


co2_clean |>
  filter(country != "World") |>
  arrange(desc(emissions_2023)) |>
  slice(1:10) |>
  ggplot(aes(
    x = reorder(country, emissions_2023),
    y = emissions_2023
  )) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Top 10 CO2 emitters",
    x = "",
    y = "Million tonnes CO2"
  ) +
  theme_minimal()

co2_clean |>
  filter(country != "World") |>
  arrange(desc(emissions_2023)) |>
  slice(1:30) |>
  ggplot(aes(
    x = reorder(country, emissions_2023),
    y = emissions_2023
  )) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Top 30 CO2 Emitters",
    x = "",
    y = "Million tonnes CO2"
  ) +
  theme_minimal()

# CHANGE FROM 2000 - 2023
install.packages("ggrepel")

ggplot(co2_clean,
       aes(x = emissions_2000,
           y = emissions_2023)) +
  geom_point(alpha = 0.7) +
  geom_abline(
    slope = 1,
    intercept = 0,
    linetype = "dashed"
  ) +
  labs(
    title = "CO2 emissions: 2000 vs 2023",
    x = "Emissions in 2000",
    y = "Emissions in 2023"
  ) +
  theme_minimal()

library(ggrepel)
co2_diff <- co2_clean |>
  mutate(
    abs_change = abs(emissions_2023 - emissions_2000)
  )
top_change <- co2_diff |>
  arrange(desc(abs_change)) |>
  slice(1:15)

ggplot(co2_clean,
       aes(x = emissions_2000,
           y = emissions_2023)) +
  geom_point(alpha = 0.5) +
  
  geom_abline(
    slope = 1,
    intercept = 0,
    linetype = "dashed"
  ) +
  
  geom_text_repel(
    data = top_change,
    aes(label = country),
    size = 3
  ) +
  
  labs(
    title = "CO2 emissions: 2000 vs 2023",
    subtitle = "Countries with largest absolute changes labeled",
    x = "Emissions in 2000",
    y = "Emissions in 2023"
  ) +
  
  theme_minimal()

#Relative ændringer

library(ggrepel)
pct_diff <- co2_clean |>
  mutate(pct_change = (emissions_2023 - emissions_2000) / emissions_2000 * 100)
  
  top_pct_change <- pct_diff |>
  arrange(desc(pct_change)) |>
  slice(1:15)
  
  top_pct_change |>
    ggplot(aes(
      x = reorder(country, pct_change),
      y = pct_change
    )) +
    geom_col() +
    coord_flip() +
    labs(
      title = "Countries with largest relative increases in CO2 emissions",
      subtitle = "Percentage change from 2000 to 2023",
      x = "",
      y = "Relative change (%)"
    ) +
    theme_minimal()
  
  
  ggplot(pct_diff, aes(
    x = emissions_2000,
    y = emissions_2023
  )) +
    geom_point(alpha = 0.5) +
    geom_abline(
      slope = 1,
      intercept = 0,
      linetype = "dashed"
    ) +
    geom_text_repel(
      data = top_pct_change,
      aes(label = country),
      size = 3
    ) +
    labs(
      title = "CO2 emissions: 2000 vs 2023",
      subtitle = "Countries with largest relative increases labeled",
      x = "Emissions in 2000",
      y = "Emissions in 2023"
    ) +
    theme_minimal()
  
  
  #Her tilføjes regioner til datasættet. 
  install.packages("countrycode")
  library(countrycode)
  
  custom_regions <- c(
    "European Union" = "Europe",
    "International Aviation" = "Other",
    "International Shipping" = "Other",
    "Puerto Rico" = "Americas",
    "Réunion" = "Africa",
    "Western Sahara" = "Africa",
    "Saint Helena, Ascension and Tristan da Cunha" = "Africa",
    "France and  Monaco" = "Europe",
    "Italy,  San Marino and  Vatican City" = "Europe",
    "Spain and  Andorra" = "Europe",
    "Switzerland and  Liechtenstein" = "Europe",
    "Serbia and  Montenegro" = "Europe",
    "Israel and  Palestine" = "Asia"
  )
  
  co2_clean <- co2_clean |>
    mutate(
      region = countrycode(
        country,
        origin = "country.name",
        destination = "region",
        custom_match = custom_regions
      )
    )
  
  co2_clean |>
    filter(is.na(region)) |>
    select(country)
  
  co2_clean |>
    group_by(region) |>
    summarise(
      total_emissions = sum(emissions_2023, na.rm = TRUE)
    ) |>
    arrange(desc(total_emissions))
  
  co2_clean |>
    group_by(region) |>
    summarise(
      avg_emissions = mean(emissions_2023, na.rm = TRUE)
    )
  
  ggplot(co2_clean,
         aes(
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
    theme_minimal()
  
  
  ggplot(co2_clean, aes(x = emissions_2023)) +
    geom_histogram(bins = 30) +
    labs(
      title = "Distribution of CO2 emissions",
      x = "CO2 emissions",
      y = "Count"
    )
  
  ggplot(co2_clean, aes(x = emissions_2000)) +
    geom_histogram(bins = 30) +
    labs(
      title = "Distribution of CO2 emissions",
      x = "CO2 emissions",
      y = "Count"
    )
  
  
  #logaritmisk skala. 
  ggplot(co2_clean, aes(x = emissions_2000)) +
    geom_histogram(bins = 30) +
    scale_x_log10()
  ggplot(co2_clean, aes(x = emissions_2023)) +
    geom_histogram(bins = 30) +
    scale_x_log10()
  
  #Kina bruges som indeks 
  #2023
  china_emissions <- co2_clean |>
    filter(country == "China") |>
    pull(emissions_2023)
  
  co2_clean <- co2_clean |>
    mutate(
      china_index = emissions_2023 / china_emissions * 100
    )
  
  # top 20
  top20_china <- co2_clean |>
    arrange(desc(china_index)) |>
    slice(1:20)
  ggplot(top20_china,
         aes(
           x = reorder(country, china_index),
           y = china_index
         )) +
    geom_col() +
    coord_flip() +
    labs(
      title = "CO2 emissions indexed to China = 100",
      subtitle = "Top 20 countries/regions in 2023",
      x = "",
      y = "China index"
    ) +
    theme_minimal()
  
  #2000
  china_emissions <- co2_clean |>
    filter(country == "China") |>
    pull(emissions_2000)
  
  co2_clean <- co2_clean |>
    mutate(
      china_index = emissions_2000 / china_emissions * 100
    )
  
  # top 20
  top20_china_00 <- co2_clean |>
    arrange(desc(china_index)) |>
    slice(1:20)
  ggplot(top20_china_00,
         aes(
           x = reorder(country, china_index),
           y = china_index
         )) +
    geom_col() +
    coord_flip() +
    labs(
      title = "CO2 emissions indexed to China = 100",
      subtitle = "Top 20 countries/regions in 2000",
      x = "",
      y = "China index"
    ) +
    theme_minimal()

  ggplot(top20_china,
         aes(
           x = reorder(country, china_index),
           y = china_index,
           fill = region
         )) +
    geom_col() +
    coord_flip() +
    theme_minimal()
  
  ggplot(top20_china_00,
         aes(
           x = reorder(country, china_index),
           y = china_index,
           fill = region
         )) +
    geom_col() +
    coord_flip() +
    theme_minimal()
  
  # top 10 vs. resten af verden
  top10_share <- top10 |>
    summarise(
      top10_emissions = sum(emissions_2023, na.rm = TRUE)
    ) |>
    mutate(
      world_emissions = sum(co2_clean$emissions_2023, na.rm = TRUE),
      share_pct = top10_emissions / world_emissions * 100
    )
  
  top10_share
  
  share_data <- tibble(
    group = c("Top 10", "Rest of world"),
    emissions = c(
      sum(top10$emissions_2023),
      sum(co2_clean$emissions_2023) -
        sum(top10$emissions_2023)
    )
  )
  
  ggplot(share_data,
         aes(x = group,
             y = emissions,
             fill = group)) +
    geom_col() +
    labs(
      title = "Top 10 emitters vs Rest of World",
      y = "Million tonnes CO2",
      x = ""
    ) +
    theme_minimal()
  
  share_data <- tibble(
    group = c("Top 10", "Rest of world"),
    share = c(
      top10_share,
      100 - top10_share
    )
  )
  
  top10_share_value <- sum(top10$emissions_2023) /
    sum(co2_clean$emissions_2023) * 100
  
  share_data <- tibble(
    group = c("Top 10", "Rest of world"),
    share = c(
      top10_share_value,
      100 - top10_share_value
    )
  )
  
  share_data
  
  ggplot(share_data,
         aes(
           x = group,
           y = share,
           fill = group
         )) +
    geom_col() +
    labs(
      title = "Share of global CO2 emissions",
      subtitle = "Top 10 emitters vs Rest of world",
      x = "",
      y = "Share of global emissions (%)"
    ) +
    theme_minimal()
  #The West versus the rest. 
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
  
  #Samlet tabel, hvor både the west og the rest indgår for begge år. 
  
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
  
  ggplot(west_change_long, aes(
    x = west_vs_rest,
    y = emissions,
    fill = year
  )) +
    geom_col(position = "dodge") +
    labs(
      title = "CO2 emissions: West vs Rest",
      subtitle = "Total emissions in 2000 and 2023",
      x = "",
      y = "Million tonnes CO2",
      fill = "Year"
    ) +
    theme_minimal()
  
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
  
  
  #befolkningstal fra worldbank
  
  install.packages("WDI")
  library(WDI)
  library(countrycode)
  library(tidyverse)
  
  pop <- WDI(
    country = "all",
    indicator = "SP.POP.TOTL",
    start = 2000,
    end = 2023
  ) |>
    select(iso3c, country, year, population = SP.POP.TOTL) |>
    filter(!is.na(iso3c))
  
  pop_wide <- pop |>
    filter(year %in% c(2000, 2023)) |>
    pivot_wider(
      names_from = year,
      values_from = population,
      names_prefix = "population_"
    )
  co2_with_codes <- co2_clean |>
    mutate(
      iso3c = countrycode(
        country,
        origin = "country.name",
        destination = "iso3c",
        custom_match = c(
          "United States" = "USA",
          "Russia" = "RUS",
          
          "European Union" = NA,
          "International Aviation" = NA,
          "International Shipping" = NA,
          
          "France and  Monaco" = "FRA",
          "Italy,  San Marino and  Vatican City" = "ITA",
          "Spain and  Andorra" = "ESP",
          "Switzerland and  Liechtenstein" = "CHE",
          "Israel and  Palestine" = "ISR",
          "Serbia and  Montenegro" = "SRB"
        )
      )
    )
  
  co2_with_codes |>
    filter(is.na(iso3c)) |>
    select(country)
  
  co2_pop <- co2_with_codes |>
    filter(!is.na(iso3c)) |>
    left_join(pop_wide, by = "iso3c") |>
    
    rename(country = country.x) |>
    
    select(-country.y) |>
    
    mutate(
      co2_per_capita_2023 =
        emissions_2023 * 1000000 / population_2023,
      
      co2_per_capita_2000 =
        emissions_2000 * 1000000 / population_2000,
      
      co2_per_capita_change =
        co2_per_capita_2023 - co2_per_capita_2000
    )
  
  top15_pc <- co2_pop |>
    filter(!is.na(co2_per_capita_2023)) |>
    arrange(desc(co2_per_capita_2023)) |>
    slice(1:15)
  
  top15_pc |>
    select(country, region, emissions_2023, population_2023, co2_per_capita_2023)
  
  ggplot(top15_pc, aes(
    x = reorder(country, co2_per_capita_2023),
    y = co2_per_capita_2023
  )) +
    geom_col() +
    coord_flip() +
    labs(
      title = "Top 15 CO2 emitters per capita",
      subtitle = "2023",
      x = "",
      y = "Tonnes CO2 per person"
    ) +
    theme_minimal()
  
  west_pc <- co2_pop |>
    filter(!is.na(population_2023)) |>
    group_by(west_vs_rest) |>
    summarise(
      emissions_2023 = sum(emissions_2023, na.rm = TRUE),
      population_2023 = sum(population_2023, na.rm = TRUE),
      co2_per_capita_2023 = emissions_2023 * 1000000 / population_2023
    )
  
  west_pc
  
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