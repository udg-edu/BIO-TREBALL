library(tidyverse)
if(!exists(".ID")) .ID = '000000'

.SEED = strtoi(substr(digest::sha1(.ID), 1, 5), base = 16)
load('03-dades.RData')
dades = l_env.pair[[sample(1:length(l_env.pair), 1)]]

SPECIE1 = names(dades)[2]
SPECIE2 = names(dades)[3]

SPECIE1.LONG = pull(filter(spe.names, Specie == SPECIE1), Specie_long)
SPECIE2.LONG = pull(filter(spe.names, Specie == SPECIE2), Specie_long)

NUM_RND = sample(c('PhysD', 'Slope'))
CAT_RND = sample(c('Form', 'ZoogD'))

save(dades, SPECIE1, SPECIE2, SPECIE1.LONG, SPECIE2.LONG, NUM_RND, CAT_RND, file = sprintf('04-dades_aleatori/%s.RData', .ID))

# Enunciat
library(writexl)
writexl::write_xlsx(dades, path = sprintf("05-enunciat/%s.xlsx", .ID))
