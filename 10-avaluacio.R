library(tidyverse)
library(googlesheets4)
corr_file = "https://docs.google.com/spreadsheets/d/1GW4HxFa5LC0RNSzC9AaauT6a0BxcULquOcBxs1OyiD4/edit?usp=sharing"
gs4_deauth()
corr0 = read_sheet(corr_file)
names(corr0)
corr = corr0 %>%
  transmute(
    hora = `Timestamp`,
    id = unlist(`El teu codi d'estudiant (amb la \"u\" inicial)`),
    id = if_else(str_starts(id, 'u'), id, str_c('u', id)),
    id_treb = unlist(`El nom del grup del treball que estàs corregint (posa el nom del grup en minúscula)`),
    id_treb = if_else(str_starts(id_treb, 'u'), str_sub(id_treb, 2, -1), id_treb),
    p1 = `Marca en cas afirmatiu. Si la pregunta no aplica, no marqueu la casella....4`,
    p2 = `Marca en cas afirmatiu. Si la pregunta no aplica, no marqueu la casella....6`,
    p3a = `La proporció de pingüins mascle i femella és la mateixa.`,
    p3b = `La profunditat del bec és la mateixa en funció del sexe del pingüí.`,
    p3c = `La distribució del sexe dels pingüins és la mateixa en funció de l’espècie.`,
    p4 = `Marca en cas afirmatiu. Si la pregunta no aplica, no marqueu la casella....12`,
    pg = `Marca si creus que aplica.`,
    nota = `De manera subjectiva, com puntuaries del 0 al 10 el treball corregit.`)

# > corr
# # A tibble: 949 × 11

corr_alumnes = corr %>%
  filter(sapply(id_treb, is.character)) %>%
  mutate(id_treb = unlist(id_treb)) %>%
  group_by(id, id_treb) %>%
  slice_max(hora) %>% # Per cada corrector i treball s'agafa la darrera correcció
  ungroup() %>%
  arrange(id, hora)

dcorr_alumnes = lapply(1:10, function(i)
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
  select(id, id_group, treb1:treb3) %>%
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

TREBALLS_INCORRECTES = c('slowpoke')
dcorr_alumnes_no_fetes = dassignments %>%
  select(id_treb, id) %>%
  anti_join(dcorr_alumnes, by = c('id', 'id_treb')) %>%
  group_by(id) %>%
  filter(!(id_treb %in% TREBALLS_INCORRECTES & 
             n() == sum(id_treb %in% TREBALLS_INCORRECTES))) %>% # si un treball no es correcte no es té en compte si és l'únic
  ungroup() %>%
  count(id, name = 'no_corr')

############ PUNTUACIó
dcorr_individual_preguntes = dcorr_alumnes %>%
  filter(!id_treb %in% TREBALLS_INCORRECTES) %>%
  pivot_longer(p1_1:p4_3) %>%
  group_by(id_treb, name) %>%
  mutate(correc = n(),
         p.global = mean(value),
         p.invidi = value,
         p.diff = correc * abs(p.global - p.invidi)) %>%
  ungroup() %>%
  arrange(desc(p.diff), id)

dcorr_individual_preguntes_summ = dcorr_individual_preguntes %>%
  group_by(id) %>%
  summarise(
    n.1 = sum(p.diff + 1 == correc),
    n.2 = sum(p.diff + 2 >= correc),
    n.3 = sum(p.diff + 3 >= correc)
  ) %>%
  arrange(desc(n.2))

dcorr_individual_nota = dcorr_alumnes %>%
  filter(!id_treb %in% TREBALLS_INCORRECTES) %>%
  select(id_treb, id, nota) %>%
  arrange(id) %>%
  group_by(id_treb) %>%
  mutate(nota.m = median(nota),
         nota.diff = abs(nota - nota.m)) %>%
  group_by(id) %>%
  summarise(nota.diff = mean(nota.diff)) %>%
  arrange(desc(nota.diff), id)

# daleatori = dcorr_individual %>%
#   count(id) %>%
#   arrange(desc(n)) %>%
#   filter(n > 20)
# 
# left_join(daleatori, dcorr_individual, by = 'id') %>%
#   select(id, pregunta = name, marcat = value) %>%
#   mutate(pregunta = sprintf("Pregunta %s, ítem %s", str_sub(pregunta, 2, 2), str_sub(pregunta, -1, -1)))

dpuntuacions = dcorr_alumnes %>%
  filter(!id_treb %in% TREBALLS_INCORRECTES) %>%
  pivot_longer(nota:p4_3) %>%
  group_by(id_treb, name) %>%
  summarise(value = median(value)) %>%
  pivot_wider(names_from = name, values_from = value)

in_01_range = function(x){
  pmax(pmin(x, 1), 0)
}
  


dpuntuacions_manual = bind_rows(
  tibble(id_treb = "rapidash", p1 = 0.5, p2 = 1, p3a = 0.5, p3b = 1, p3c = 1, p4 = 1),
  tibble(id_treb = "slowpoke", p1 = 0.5, p2 = 1, p3a = 1, p3b = 1, p3c = 0.75, p4 = 1))

dnotes_treballs  = dpuntuacions %>%
  transmute(
    id_treb,
    p1 = (p1_2 + 1) * (p1_3 + p1_4 + 2 * p1_5) / 8,
    p2 = (p2_1 + 1) * (p2_2 + p2_3 + 2 * p2_4) / 8,
    p3a = (p3a_1 + p3a_2 + 2 * p3a_3) / 4,
    p3b = (p3b_1 + p3b_2 + 2 * p3b_3) / 4,
    p3c = (p3c_1 + p3c_2 + 2 * p3c_3) / 4,
    p4 = (2 * p4_1 + p4_2 + p4_3)/4) %>%
  bind_rows(dpuntuacions_manual) %>%
  mutate(nota_treball = 1.5 * p1 + 2 * p2 + p3a + p3b + p3c + 2 * p4)

dnotes_individuals = dassignments %>%
  distinct(id, id_group) %>%
  inner_join(dnotes_treballs, by = c('id_group' = 'id_treb')) %>%
  left_join(dcorr_alumnes_no_fetes, by = 'id') %>%
  replace_na(list(no_corr = 0L)) %>%
  left_join(dcorr_individual_preguntes_summ, by = 'id') %>%
  left_join(dcorr_individual_nota, by = 'id') %>%
  arrange(desc(nota_treball)) %>%
  mutate(
    nota_correccio = 0.5 * (3 - no_corr),
    nota_final = nota_treball + nota_correccio,
    nota_final_round = ceiling(2*nota_final)/2
  )


notes_finals = dnotes_individuals %>%
  arrange(id) %>%
  select(id, p1:p4, `Treball (8.5)` = nota_treball, `Correcció (1.5)` = nota_correccio, `Nota final` = nota_final_round)

save.image(file = '10-avaluacio.RData')

load(file = '10-avaluacio.RData')

writexl::write_xlsx(notes_finals, path = 'avaluacio_1.xlsx')

rmarkdown::render("10-avaluacio.Rmd", output_file = "docs/2022/avaluacio_1.html")

