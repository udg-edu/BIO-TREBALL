library(tidyverse)


load(file = '10B-avaluacio.RData')

dnotes_individuals = dassignments %>%
  distinct(id, id_group) %>%
  inner_join(dnotes_treballs, by = c('id_group' = 'id_treb')) %>%
  left_join(dcorr_alumnes_no_fetes, by = 'id') %>%
  replace_na(list(no_corr = 0L)) %>%
  left_join(dcorr_individual_preguntes_summ, by = 'id') %>%
  left_join(dcorr_individual_nota, by = 'id') %>%
  arrange(desc(nota_treball)) %>%
  mutate(
    nota_treball = if_else(id %in% c('u1990597', 'u1979629'), 0, nota_treball),
    no_corr = if_else(id %in% c("u1986921"), 0, no_corr),
    nota_correccio = 0.5 * (3 - no_corr),
    nota_final = nota_treball + nota_correccio,
    nota_final_round = ceiling(2*nota_final)/2
  )

notes_finals = dnotes_individuals %>%
  arrange(id) %>%
  select(id, 
         `p2 [1.47]` = p2, 
         `p3a [0.91]` = p3a, 
         `p3b [1.27]` = p3b, 
         `p3c [3.12]` = p3c, 
         `p4 [1.73]` = p4, 
         `Treball [8.5]` = nota_treball, 
         `Correcció [1.5]` = nota_correccio, 
         `Nota final [10]` = nota_final_round)

writexl::write_xlsx(notes_finals, path = 'avaluacio_2_mods.xlsx')

rmarkdown::render("10B-avaluacio.Rmd", output_file = "docs/2022/avaluacio_2.html")

