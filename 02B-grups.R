library(googlesheets4)
group_file = "https://docs.google.com/spreadsheets/d/1pcuNJJxuYyiabXOsZNN7owQtA3YvadmuiFGK4Ec377A/edit?usp=sharing"
groups = read_sheet(group_file, col_names = c('time', 'udg1', 'udg2', 'udg3', 'udg4', 'udg5'), skip = 1)

library(dplyr)
library(tidyr)
groups_clean = groups %>%
  pivot_longer(cols = starts_with('udg'), values_to = 'id') %>%
  group_by(id) %>%
  slice_max(time, n = 1) %>%
  ungroup() %>%
  arrange(time, name) %>%
  group_by(time) %>%
  mutate(id_group = readr::parse_number(first(id))) %>%
  ungroup() %>%
  select(time, id_group, id) %>%
  filter(!is.na(id)) %>%
  group_by(id_group)

groups_clean = groups_clean %>%
  bind_rows(tibble(time = NA, id_group = 1979628, id = 'u1977843')) %>%
  group_by(id_group) %>%
  fill(time, .direction = 'updown') %>%
  ungroup()

library(readr)
load('01-alumnes.RData')
id_individuals = setdiff(pull(alumnes, id), pull(groups_clean, id))
groups_clean = groups_clean %>%
  bind_rows(tibble(
    time = lubridate::now(),
    id_group = parse_number(id_individuals),
    id = id_individuals
  ))

writeLines(sprintf("2002963 %s", paste(unique(groups_clean$id_group), collapse = ' ')), con = 'udg_codis_grupB.txt')

rmarkdown::render("02B-grups.Rmd", output_file = "docs/2021/grupsB.html")

