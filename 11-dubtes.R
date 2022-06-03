load('10-avaluacio.RData')
ID_TREBALL = '1980294'
dnotes_treballs %>% 
  filter(id_treb == ID_TREBALL) %>%
  knitr::kable()
dcorr_alumnes %>% filter(id_treb == ID_TREBALL) %>% 
  select(starts_with('p3'), starts_with('p4'), starts_with('p5')) 

## Mirar anònim
dcorr_alumnes %>%
  filter(id_treb == 1977806) %>%
  select(starts_with('pg'))
