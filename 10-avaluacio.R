library(tidyverse)
library(googlesheets4)
corr_file = "https://docs.google.com/spreadsheets/d/15CVm6tEYM6FN6kucXDn5A4SnxEKaEdP-mIqDH5BPZRo/edit?usp=sharing"
corr0 = read_sheet(corr_file)

corr = corr0 %>%
  transmute(
    hora = `Timestamp`,
    id = unlist(`El teu codi d'estudiant (amb la \"u\" inicial)`),
    id = if_else(str_starts(id, 'u'), id, str_c('u', id)),
    id_treb = unlist(`Posa el codi del treball que estàs corregint (sense la \"u\" inicial)`),
    id_treb = if_else(str_starts(id_treb, 'u'), str_sub(id_treb, 2, -1), id_treb),
    p1 = `Marca en cas afirmatiu...4`,
    p2 = `Marca en cas afirmatiu...5`,
    p3 = `Marca en cas afirmatiu...6`,
    p4 = `Marca en cas afirmatiu...7`,
    p5 = `Marca en cas afirmatiu...8`,
    pg = `Marca en cas afirmatiu...9`,
    nota = `De 0 a 10, com valoraries la claredat i la concisió en la presentació de resultats`)

corr_alumnes = corr %>%
  filter(sapply(id_treb, is.character)) %>%
  mutate(id_treb = unlist(id_treb)) %>%
  group_by(id, id_treb) %>%
  slice_max(hora) %>%
  ungroup() %>%
  arrange(id, hora)

dcorr_alumnes = lapply(0:10, function(i)
  corr_alumnes %>%
    select(p1:pg) %>%
    mutate_all(~replace_na(.x, "")) %>%
    transmute_all(~as.integer(str_detect(.x, str_c(i, ".-")))) %>%
    rename_all(function(x) str_c(x, "_", i))
) %>% bind_cols() %>%
  select_if(~sum(.x) > 0) %>%
  select(sort(names(.))) %>%
  {bind_cols(select(corr_alumnes, id, id_treb, nota), .)}

args = commandArgs(trailingOnly=TRUE)
if(length(args) > 0){
  corr_alumnes %>%
    select(hora, id, id_treb) %>%
    filter(str_detect(id, args)) %>%
    knitr::kable()
}

load('07-correccio.RData')
dassignments = assignments %>%
  mutate(id_group = as.character(id_group)) %>%
  pivot_longer(treb1:treb3, values_to = 'id_treb', values_transform = as.character)

# Nombre de correccions de cada treball
dn = dassignments %>%
  semi_join(dcorr_alumnes, by = 'id_treb') %>%
  count(id_treb)

dcorr_alumnes = dassignments %>%
  select(id_treb, id) %>%
  right_join(dcorr_alumnes, by = c('id', 'id_treb')) %>%
  arrange(id_treb, id)

dcorr_alumnes_no_fetes = dassignments %>%
  select(id_treb, id) %>%
  anti_join(dcorr_alumnes, by = c('id', 'id_treb')) %>%
  count(id, name = 'no_corr')

############ PUNTUACIó
dcorr_individual = dcorr_alumnes %>%
  pivot_longer(p1_0:p5_5) %>%
  group_by(id_treb, name) %>%
  mutate(n = n(),
         n1 = sum(value),
         n2 = sapply(1:n(), function(i) sum(value[-i]))) %>%
  filter(n >= 7, n1 + 2 >= n, n1 == n2) %>%
  ungroup()

daleatori = dcorr_individual %>%
  count(id) %>%
  arrange(desc(n)) %>%
  filter(n > 20)

left_join(daleatori, dcorr_individual, by = 'id') %>%
  select(id, pregunta = name, marcat = value) %>%
  mutate(pregunta = sprintf("Pregunta %s, ítem %s", str_sub(pregunta, 2, 2), str_sub(pregunta, -1, -1)))





dpuntuacions = dcorr_alumnes %>%
  pivot_longer(nota:pg_3) %>%
  group_by(id_treb, name) %>%
  summarise(value = median(value)) %>%
  pivot_wider(names_from = name, values_from = value)

in_01_range = function(x){
  pmax(pmin(x, 1), 0)
}
  
  
dnotes_treballs = dpuntuacions %>%
  transmute(
    id_treb,
    p1 = in_01_range(-0.25 * (1-p1_0) + 0.25 * p1_1 + 0.25 * p1_2 + 0.25 * p1_3 + 0.1 * p1_4 + 0.25 * p1_5),
    p2 = in_01_range(-0.25 * (1-p2_0) + 0.2 * p2_1 + 0.2 * p2_2 + 0.2 * p2_3 + 0.2 * p2_4 + 0.2 * p2_5),
    p3 = in_01_range(-0.25 * (1-p3_0) + 0.25 * p3_1 + 0.25 * p3_2 + 0.25 * p3_3 + 0.25 * p3_4),
    p4 = in_01_range(-0.25 * (1-p4_0) + (p4_1 + p4_2 + p4_3 + p4_4 + p4_5 + p4_6)/6),
    p5 = in_01_range(-0.25 * (1-p5_0) + (p5_1 + p5_2 + p5_3 + p5_4 + p5_5)/5),
    intro = pg_1,
    raonament = pg_2,
    anonim = pg_3,
    nota_treball = 0.5 * p1 + 0.5 * p2 + p3 + 1.5 * p4 + 1.5 * p5 - 0.25 * (1-intro) - 0.25 * (1-raonament) - 0.25 * (1-anonim)
  )  %>%
  arrange(nota_treball)

dnotes_individuals = dassignments %>%
  distinct(id, id_treb = id_group) %>%
  left_join(dnotes_treballs, by = 'id_treb') %>%
  left_join(dcorr_alumnes_no_fetes, by = 'id') %>%
  replace_na(list(no_corr = 0L)) %>%
  mutate(
    naleatori = as.integer(id %in% daleatori$id),
    no_corr = pmax(no_corr, naleatori * 3),
    nota_treball_2 = nota_treball - 0.25 * no_corr)

filter(dnotes_individuals, naleatori == 1)

notes_finals = dnotes_individuals %>%
  arrange(id) %>%
  select(id, p1:anonim, `treballs no corregits o mal corregits` = naleatori, `Nota treball` = nota_treball_2)

save.image(file = '10-avaluacio.RData')