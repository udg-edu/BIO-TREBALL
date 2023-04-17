library(tidyverse)
source('00-config.R')
unzip("3103G000842022 Estadística aplicada-TREBALL 1r lliurament-1329670.zip", exdir = 'treballs')
treballs = tibble(
  'fitxer' = list.files('treballs', recursive = TRUE, full.names = TRUE)) %>%
  mutate(
    nom_usuari = str_match(fitxer, "treballs/(.*)_\\d{7}_assignsubmission_file_/(.*)$")[,2],
    nom_arxiu = str_match(fitxer, "treballs/(.*)_\\d{7}_assignsubmission_file_/(.*)$")[,3]
  ) %>% left_join(read_csv('courseid_32554_participants.csv') %>%
                    transmute(
                      udg_id = paste0('u', `Número ID`),
                      nom_complet = paste(Cognoms, Nom, sep=', ')
                    ), by = c('nom_usuari' = 'nom_complet'))

load('02-grups.RData')
treballs_entregats = groups_clean %>%
  inner_join( treballs, by = c('id' = 'udg_id') ) %>%
  group_by(id_group) %>%
  slice(1) %>%
  ungroup()

correctors = groups_clean %>%
  semi_join(treballs_entregats, by = 'id_group')

dir.create("06-treballs", showWarnings = FALSE)
with(treballs_entregats, walk2(id_group, fitxer, function(id, fname){
  file.copy(fname, sprintf("06-treballs/treball_%s.pdf", id))
}))

save(treballs_entregats, correctors, file = '06-treballs.RData')
writeLines(sprintf("%s", paste(unique(correctors$id), collapse = ' ')), con = 'udg_codis_correctors.txt')
writeLines(sprintf("%s", paste(c('2002963',unique(treballs_entregats$id_group)), collapse = ' ')), con = 'codis_treballs.txt')


rmarkdown::render("06-treballs.Rmd", output_file = "docs/2022/treballs.html")
