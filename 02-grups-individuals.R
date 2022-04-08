library(tidyverse)
load('01-alumnes.RData')
load('02-grups.RData')
alumnes
id_individuals = setdiff(pull(alumnes, id), pull(groups_clean, id))
groups_clean = groups_clean %>%
  bind_rows(tibble(
    time = lubridate::now(),
    id_group = parse_number(id_individuals),
    id = id_individuals
  ))

save(groups_clean, file = '02-grups-individuals.RData')
writeLines(sprintf("2002963 %s", paste(unique(groups_clean$id_group), collapse = ' ')), con = 'udg_codis_grup.txt')

rmarkdown::render("02-grups.Rmd", output_file = "docs/2021/grups.html")
