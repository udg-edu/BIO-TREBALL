library(tidyverse)
library(googlesheets4)
# corr_file = "https://docs.google.com/spreadsheets/d/15CVm6tEYM6FN6kucXDn5A4SnxEKaEdP-mIqDH5BPZRo/edit?usp=sharing"
corr_file = "https://docs.google.com/spreadsheets/d/1TIAuNRcqJ6aJJ7K1PWwNdnNIkpUNSr7BuzMbbDg-DNY/edit?usp=sharing"
gs4_deauth()
corr0 = read_sheet(corr_file)
trebs_corregits = corr0 %>%
  transmute(
    hora = `Timestamp`,
    id = unlist(`El teu codi d'estudiant (amb la \"u\" inicial)`),
    id = if_else(str_starts(id, 'u'), id, str_c('u', id)),
    id_treb = unlist(`El nom del grup del treball que estàs corregint (posa el nom del grup en minúscula)`),
    id_treb = if_else(str_starts(id_treb, 'u'), str_sub(id_treb, 2, -1), id_treb))
corr_alumnes = trebs_corregits %>%
  filter(sapply(id_treb, is.character)) %>%
  mutate(id_treb = unlist(id_treb)) %>%
  group_by(id, id_treb) %>%
  slice_max(hora) %>% # Per cada corrector i treball s'agafa la darrera correcció
  ungroup() %>%
  arrange(id, hora)


load('07B-correccio.RData')
dassignments = assignments %>%
  select(id, id_group, treb1:treb3) %>%
  mutate(id_group = as.character(id_group)) %>%
  pivot_longer(treb1:treb3, values_to = 'id_treb', values_transform = as.character)

dcorr = dassignments %>%
  left_join(corr_alumnes, by = c('id', 'id_treb')) %>%
  group_by(id) %>%
  summarise(
    'Correccions fetes' = sum(!is.na(hora)),
    'Última correcció' = if_else(`Correccions fetes` == 0, "", format(max(hora, na.rm=TRUE))))

rmarkdown::render("10B-correccions_fetes.Rmd", output_file = "docs/2022/correccions_fetes_2.html")
