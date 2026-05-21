library(tidyverse)
library(countrycode)

co2_raw <- readRDS("rdas/co2_raw.rds")

co2_clean <- co2_raw[, 1:5]

names(co2_clean) <- c(
  "country",
  "share_global_total",
  "emissions_2023",
  "emissions_2000",
  "change_from_2000"
)

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
  filter(
    country != "Location",
    country != "World",
    change_from_2000 != "no change%"
  ) |>
  mutate(
    emissions_2023 = parse_number(as.character(emissions_2023)),
    emissions_2000 = parse_number(as.character(emissions_2000)),
    change_from_2000 = parse_number(as.character(change_from_2000)),
    region = countrycode(
      country,
      origin = "country.name",
      destination = "region",
      custom_match = custom_regions
    )
  ) |>
  filter(!is.na(emissions_2023))

write_csv(co2_clean, "data/co2_clean.csv")