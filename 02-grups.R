suppressMessages(library(tidyverse))
library(googlesheets4)
source('00-config.R')
group_file = "https://docs.google.com/spreadsheets/d/1wEShudrzTE2Zy9E6qGE0UGZcabT8IZmtT_nola7-H4w/edit?usp=sharing"
gs4_deauth()
groups = read_sheet(group_file, col_names = c('time', 'id1', 'id2', 'id3', 'id4'), skip = 1)

if(file.exists('02-grups.RData')){
  load('02-grups.RData')
  groups_clean_old = groups_clean
}else{
  groups_clean_old = tibble(time = as.POSIXct(double(0)),
                         id_group_long = character(0),
                         id_group = character(0),
                         name = character(0),
                         id = character(0))
  pokemon_used = c()
}

set.seed(YEAR)
library(stringi)
pokemon = pull(read_csv('pokemon.csv', col_types = cols()), name)
valid = stri_enc_isascii(pokemon) & !str_detect(pokemon, " |-|\\?|'")
pokemon = tolower(stri_enc_toascii(pokemon[valid]))
pokemon = setdiff(pokemon, pokemon_used)

library(dplyr)
library(tidyr)
groups_clean = groups %>%
  pivot_longer(cols = starts_with('id'), values_to = 'id') %>%
  filter(!is.na(id)) %>%
  group_by(id) %>%
  slice_max(time, n = 1) %>%
  ungroup() %>%
  arrange(time, name) %>%
  pivot_wider(names_from = name, values_from = id, values_fill = "") %>%
  mutate(id_group_long = mapply(function(x1,x2,x3,x4) paste0(sort(c(x1,x2,x3,x4)), collapse=''), 
                                id1, id2, id3, id4)) %>%
  pivot_longer(matches("^id.$")) %>%
  select(time, id_group_long, name, id = value)  %>%
  filter(id != "") %>%
  group_by(id_group_long) %>%
  # filter(n() > 1) %>%
  ungroup()

groups_clean_differ = groups_clean %>%
  anti_join(groups_clean_old, by = 'id_group_long')

if(nrow(groups_clean_differ) > 0){ # hi ha modificacions
  groups_clean_old_keep = groups_clean %>%
    inner_join(select(groups_clean_old, id_group_long, id_group, id), by = c('id_group_long', 'id'))
  
  groups_clean_new = groups_clean %>%
    anti_join(groups_clean_old, by = 'id_group_long') %>%
    pivot_wider(names_from = name, values_from = id) %>%
    mutate(id_group = pokemon[1:n()]) %>%
    pivot_longer(matches("^id.$")) %>%
    select(time, id_group_long, id_group, name, id = value) %>%
    filter(id != "") %>%
    group_by(id_group) %>%
    # filter(n() > 1) %>%
    ungroup()
  
  pokemon_used = c(pokemon_used, unique(groups_clean_new$id_group))
  group_new_n = groups_clean_new %>%
    count(id_group_long, name = 'n_old')
  
  groups_clean = bind_rows(groups_clean_old, left_join(groups_clean_new, group_new_n, by = 'id_group_long'))
  
  # S'elimina una persona que ja estigués en un altre grup.
  groups_clean = groups_clean %>%
    group_by(id) %>%
    slice_max(time, n = 1) %>%
    group_by(id_group_long) %>%
    mutate(n = n()) %>%
    filter(n == n_old) %>%
    ungroup()
  
  save(groups_clean, pokemon_used, file = '02-grups.RData')
  writeLines(sprintf("2002963 %s", paste(unique(groups_clean$id_group), collapse = ' ')), con = 'udg_codis_grup.txt')
  rmarkdown::render("02-grups.Rmd", output_file = sprintf("docs/%d/grups.html", YEAR), quiet = TRUE)
  
  cat(crayon::green(sprintf("Nous grups creats: %s.\n", paste(unique(groups_clean_new$id_group), collapse=', '))))
}else{
  cat(crayon::blue("Cap grup nou.\n"))
}


