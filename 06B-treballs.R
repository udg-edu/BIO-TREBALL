library(tidyverse)
source('00-config.R')
unzip("3103G000842022 Estadística aplicada-TREBALL 2n lliurament-1329677.zip", exdir = 'treballsB')
treballs = tibble(
  'fitxer' = list.files('treballsB', recursive = TRUE, full.names = TRUE)) %>%
  mutate(
    nom_usuari = str_match(fitxer, "treballsB/(.*)_\\d{7}_assignsubmission_file_/(.*)$")[,2],
    nom_arxiu = str_match(fitxer, "treballsB/(.*)_\\d{7}_assignsubmission_file_/(.*)$")[,3]
  ) %>% left_join(read_csv('courseid_32554_participants.csv') %>%
                    transmute(
                      udg_id = paste0('u', `Número ID`),
                      nom_complet = paste(Cognoms, Nom, sep=', '),
                      nom_complet = gsub("Torrentà i Pato", "Pato i Torrentà", nom_complet),
                    ), by = c('nom_usuari' = 'nom_complet'))

load('10-avaluacio.RData')
groups_clean = dnotes_individuals %>% 
  select(id, id_group) %>%
  bind_rows(tibble('id' = "u1980918", 'id_group' = "2002963"))

treballs %>%
  anti_join(groups_clean , by = c('udg_id' = 'id') )

treballs_entregats = groups_clean %>%
  inner_join( treballs, by = c('id' = 'udg_id') ) %>%
  group_by(id_group) %>%
  slice(1) %>%
  ungroup()


correctors = groups_clean %>%
  semi_join(treballs_entregats, by = 'id_group')


with(treballs_entregats, walk2(id_group, fitxer, function(id, fname){
  file.copy(fname, sprintf("06B-treballs/treball_2_%s.pdf", id))
}))

save(treballs_entregats, correctors, file = '06B-treballs.RData')

writeLines(sprintf("%s", paste(unique(correctors$id), collapse = ' ')), con = 'udg_codis_correctors_B.txt')
writeLines(sprintf("%s", paste(unique(treballs_entregats$id_group), collapse = ' ')), con = 'codis_treballs_B.txt')

rmarkdown::render("06B-treballs.Rmd", output_file = "docs/2022/treballsB.html")
