library(tidyverse)
if(!exists(".ID")) .ID = '2002963'

.SEED = strtoi(substr(digest::sha1(.ID), 1, 5), base = 16)
load(sprintf('04-dades_aleatori/%s.RData', .ID))

CONF_LEVEL = sample(c(0.9, 0.99))

save(dades, SPECIE1, SPECIE2, SPECIE1.LONG, SPECIE2.LONG, NUM_RND, CAT_RND, CONF_LEVEL, file = sprintf('04B-dades_aleatori/%s.RData', .ID))
