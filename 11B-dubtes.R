load('10B-avaluacio.RData')
ID = 'u1979855'
dnotes_individuals %>%
  filter(id == ID)

dassignments %>%
  filter(id == ID)

corr %>%
  filter(id == ID) %>%
  select(hora, id, id_treb) %>%
  knitr::kable()


##  Modificacions
dnotes_individuals = dnotes_individuals %>%
  mutate(
    no_corr = if_else(id == 'u1979855', 0, no_corr),
    nota_treball = 0.5 * p1 + 0.5 * p2 + 0.75 * p3 + 1.5 * p4 + 0.75 * p5 + p6 - 0.25 * (1-intro) - 0.25 * (1-raonament) - 0.25 * (1-anonim),
    nota_treball_2 = ceiling((nota_treball - 0.25 * no_corr)*20)/20 )
notes_finals = dnotes_individuals %>%
  arrange(id) %>%
  select(id, p1:anonim, `treballs no corregits o mal corregits` = no_corr, `Nota treball` = nota_treball_2)

notes_finals %>%
  filter(id == ID)

save.image('10B-avaluacio-mods.RData')
writexl::write_xlsx(notes_finals, path = 'treball2-mods.xlsx')

rmarkdown::render("10B-avaluacio.Rmd", output_file = "docs/2021/avaluacio_2.html")
