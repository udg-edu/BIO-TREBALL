library(tidyverse)
load('06B-treballs.RData')

set.seed(2)
assignments = rerun(100, correctors %>%
  group_by(id_group) %>%
  sample_frac(1) %>%
  slice(1) %>%
  ungroup() %>%
  sample_frac(1) %>%
  mutate(
    treb1 = id_group[((0+1:n()) %% n()) + 1],
    treb2 = id_group[((1+1:n()) %% n()) + 1],
    treb3 = id_group[((2+1:n()) %% n()) + 1])) %>%
  bind_rows(.id = 'it')  %>%
  group_by(id) %>%
  slice(1) %>%
  ungroup()


assignments %>%
  pivot_longer(matches('treb.')) %>%
  count(value) %>%
  arrange(n)

save(assignments, file = '07B-correccio.RData')

I = 2
assignment = assignments %>%
  slice(I)
