library(tidyverse)
if(!exists(".ID")) .ID = '000000'

.SEED = strtoi(substr(digest::sha1(.ID), 1, 5), base = 16)
load('03-dades.RData')
set.seed(.SEED)
I = sample(1:nrow(dpenguins), 1)
dades = dpenguins$ds[[I]]

dir.create('04-dades_aleatori', showWarnings = FALSE)
save(dades, I, .SEED, file = sprintf('04-dades_aleatori/%s.RData', .ID))

# Enunciat
library(writexl)
dir.create('05-enunciat', showWarnings = FALSE)
writexl::write_xlsx(dades, path = sprintf("05-enunciat/penguins_%s.xlsx", .ID))
