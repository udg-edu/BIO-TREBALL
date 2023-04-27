library(tidyverse)
load('06-treballs.RData')

set.seed(2)
treballs = correctors %>%
  distinct(id_group) %>%
  sample_n(n())
v = pull(treballs)
for(i in 1:nrow(treballs))  {
  v = lag(v, default = last(v))
  treballs[[sprintf("treb%d", i)]] = v
}

cyclic_assignment = lapply(1:4, function(i){
  treballs %>%
    select(1, (1+3*(i-1))+(1:3)) %>%
    set_names(c('id_group', 'treb1', 'treb2', 'treb3')) %>%
    mutate(name = paste0('id', i))
}) %>% bind_rows()


assignments = correctors %>%
  left_join(cyclic_assignment, by = c('id_group', 'name')) %>%
  arrange(id_group, name)


assignments %>%
  select(matches('treb.')) %>%
  pivot_longer(everything()) %>%
  count(value) %>%
  arrange(n) %>%
  count(n)

### Manual modifications to 'assignments'


save(assignments, file = '07-correccio.RData')

