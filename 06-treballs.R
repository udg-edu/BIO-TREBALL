library(tidyverse)

unzip("3103G000842021 Estadística aplicada-TREBALL 1r lliurament-1168811.zip", exdir = 'treballs')
treballs = tibble(
  'fitxer' = list.files('treballs', recursive = TRUE, full.names = TRUE)) %>%
  mutate(
    nom_usuari = str_match(fitxer, "treballs/(.*)_\\d{7}_assignsubmission_file_/(.*)$")[,2],
    nom_arxiu = str_match(fitxer, "treballs/(.*)_\\d{7}_assignsubmission_file_/(.*)$")[,3]
  ) %>% left_join(read_csv('courseid_29686_participants.csv') %>%
                    transmute(
                      udg_id = paste0('u', `Número ID`),
                      nom_complet = paste(Cognoms, Nom)
                    ), by = c('nom_usuari' = 'nom_complet'))

load('02-grups-individuals.RData')
treballs_entregats = groups_clean %>%
  inner_join( treballs, by = c('id' = 'udg_id') ) %>%
  group_by(id_group) %>%
  slice(1) %>%
  ungroup()

correctors = groups_clean %>%
  semi_join(treballs_entregats, by = 'id_group')

with(treballs_entregats, walk2(id_group, fitxer, function(id, fname){
  file.copy(fname, sprintf("06-treballs/treball_%d.pdf", id))
}))

save(treballs_entregats, correctors, file = '06-treballs.RData')
writeLines(sprintf("%s", paste(unique(correctors$id), collapse = ' ')), con = 'udg_codis_correctors.txt')

rmarkdown::render("06-treballs.Rmd", output_file = "docs/2021/treballs.html")

# 
# ########
# #######33
# i_treballs = treballs_entregats$id_group
# correctors = groups_clean %>%
#   semi_join(treballs_entregats, by = 'id_group') %>%
#   mutate(
#     treballs_corr = map(id_group, ~setdiff(i_treballs, .x))
#   )
# 
# N_CORR = n_distinct(correctors$id)
# N_TREB = n_distinct(treballs_entregats$id_group)
# N_ratio = floor(N_CORR / N_TREB)
# 
# N_CORREGITS = 2
# N_MIN_CORREGITS = 2
# 
# set.seed(1)
# REPEAT = TRUE
# while(REPEAT){
#   REPEAT  = FALSE
#   dcor = unnest(correctors, treballs_corr) %>% group_by(treballs_corr) %>% sample_n(N_MIN_CORREGITS) %>% ungroup() %>%
#     select(id, treball_corr = treballs_corr)
#   
#   if( (dcor %>% count(id) %>% {max(.$n)}) > N_CORREGITS) REPEAT  = TRUE
# }
# 
# treballs_assignats = correctors %>%
#   left_join(dcor) %>%
#   group_by(id_group, id) %>%
#   mutate(n_corr = N_CORREGITS  - length(na.omit(treball_corr))) %>%
#   summarise(
#     treballs = na.omit(c(treball_corr, sample(first(treballs_corr), first(n_corr))))
#   ) %>% arrange(id_group)
# 
# treballs_assignats$treballs %>% table()
# treballs_assignats$id %>% table()
# 
# set.seed(1)
# treballs_assignats = treballs_assignats %>%
#   mutate(codi = map_chr(id, ~paste(sample(LETTERS, 5, replace = TRUE), collapse = '')))
# 
# save(treballs_entregats, correctors, treballs, treballs_assignats, file = 'treballs.RData')
# writeLines(sprintf("%s", paste(unique(treballs_assignats$id), collapse = ' ')),
#            con = 'udg_codis_correctors.txt')
# 
# with(treballs_assignats, walk2(treballs, codi, function(x,y){
#   fname = treballs_entregats %>% filter(id_group == x) %>% pull(fitxer)
#   file.copy(fname, sprintf("docs/treball_%d.html", x))
#   file.copy(fname, sprintf("docs/%s.html", y))
#   file.copy(sprintf("docs/solucio_%s.pdf", x), sprintf("docs/solucio_%s.pdf", y))
#   cat(sprintf("%s %s\n", x,y))
# }))
