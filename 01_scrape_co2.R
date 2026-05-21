library(tidyverse)
library(rvest)

url <- "https://en.wikipedia.org/wiki/List_of_countries_by_carbon_dioxide_emissions"

h <- read_html(url)
tables <- h |> html_elements("table")
co2_raw <- tables[[1]] |> html_table(fill = TRUE)

saveRDS(co2_raw, "rdas/co2_raw.rds")