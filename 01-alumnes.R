library(tidyverse)
alumnes = read_csv("courseid_32554_participants.csv", col_types = 'cccc') %>%
  set_names(c('nom', 'cognom', 'id', 'mail')) %>%
  filter(str_starts(id, "1")) %>%
  mutate(id = str_c('u',id))

cat(paste(pull(alumnes, id), collapse='|'))
save(alumnes, file = '01-alumnes.RData')
