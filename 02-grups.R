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
  filter(!is.na(id))

save(groups, groups_clean, file = '02-grups.RData')
writeLines(sprintf("2002963 %s", paste(unique(groups_clean$id_group), collapse = ' ')), con = 'udg_codis_grup.txt')

rmarkdown::render("02-grups.Rmd", output_file = "docs/2021/grups.html")

