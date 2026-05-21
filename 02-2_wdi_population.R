library(tidyverse)
library(WDI)
library(countrycode)

co2_clean <- read_csv("data/co2_clean.csv")

pop <- WDI(
  country = "all",
  indicator = "SP.POP.TOTL",
  start = 2000,
  end = 2023
) |>
  select(
    iso3c,
    country_wdi = country,
    year,
    population = SP.POP.TOTL
  ) |>
  filter(!is.na(iso3c))

pop_wide <- pop |>
  filter(year %in% c(2000, 2023)) |>
  pivot_wider(
    names_from = year,
    values_from = population,
    names_prefix = "population_"
  )

custom_iso <- c(
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

co2_population <- co2_clean |>
  mutate(
    iso3c = countrycode(
      country,
      origin = "country.name",
      destination = "iso3c",
      custom_match = custom_iso
    )
  ) |>
  filter(!is.na(iso3c)) |>
  left_join(pop_wide, by = "iso3c") |>
  mutate(
    co2_per_capita_2023 = emissions_2023 * 1000000 / population_2023,
    co2_per_capita_2000 = emissions_2000 * 1000000 / population_2000,
    co2_per_capita_change =
      co2_per_capita_2023 - co2_per_capita_2000
  )

write_csv(pop_wide, "data/wdi_population.csv")
write_csv(co2_population, "data/co2_population.csv")
