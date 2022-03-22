library(ade4)
library(tidyverse)
data(aravo)
spe = as_tibble(aravo$spe, rownames = "Site")
env = as_tibble(aravo$env, rownames = "Site") %>%
  mutate(
    Form = factor(Form, labels = c("convexity", "convex slope", "right slope", "concave slope", "concavity"))) %>%
  select(-Aspect, -Snow)
traits = as_tibble(aravo$traits, rownames = "Specie")
spe.names = as_tibble(aravo$spe.names, rownames = "Specie") %>%
  rename(Specie_long = value)

C = combn(ncol(spe)-1, 2)
l_env.pair0 = lapply(1:ncol(C), function(i){
  ind = C[,i]
  dat = merge(spe[c(1, 1+ind)], env)
  orig.names = names(dat)[2:3]
  names(dat)[2:3] = c('c1', 'c2')
  m1 = glm(c1~Slope+Form+PhysD+ZoogD, data = dat[,-1], family = 'quasipoisson')
  m2 = glm(c2~Slope+Form+PhysD+ZoogD, data = dat[,-1], family = 'quasipoisson')
  dat$c1 = 4 * predict(m1, type = 'response')
  dat$c2 = 4 * predict(m2, type = 'response')
  names(dat)[2:3] = orig.names
  dat
})

# Es selecciona el casos en què es pot construïr una taula de contingència amb mínim de 5 elements per cel·la.
# 
SEL4.chisq = sapply(l_env.pair0, function(d){
  tab = table(d[,2] > 1, d[,3] > 1)
  c(min(tab), length(tab))
})
l_env.pair = l_env.pair0[SEL4.chisq[1,] > 4 & SEL4.chisq[2,] == 4]


SEL2.t_test = sapply(l_env.pair, function(d){
  (t.test(d[,2]~(d$PhysD > 50))$p.value > 0.001) + 2*(t.test(d[,3]~(d$PhysD > 50))$p.value > 0.01)
})

SEL3.anova = sapply(l_env.pair, function(d){
  (summary(aov(lm(d[,2]~ZoogD, data = d)))[[1]][1,5] > 0.01) + 2*(summary(aov(lm(log(d[,2])~ZoogD, data = d)))[[1]][1,5] > 0.01)
})

l_env.pair = l_env.pair[SEL2.t_test > 0 & SEL3.anova >= 2]

correlations = sapply(l_env.pair0, function(d) cor(log(d[,2]), log(d[,3])))
SEL1.cor = correlations > 0.5 | correlations < -0.5 


# dades = spe %>%
#   pivot_longer(-Site, names_to = "Specie", values_to = "Abund") %>%
#   left_join(traits, by = "Specie") %>%
#   left_join(env, by = "Site") %>%
#   left_join(spe.names, by = "Specie") %>%
#   select(Site, Aspect:Snow, Specie, Specie_long, Abund, Height:Seed) %>%
#   mutate(
#     Form = factor(Form, labels = c("convexity", "convex slope", "right slope", "concave slope", "concavity"))) %>%
#   filter(Abund > 0)

save.image(file = "03-dades.RData")
# library(writexl)
# lapply(1:length(l_env.pair), function(i){
#   data = l_env.pair[[i]]
#   writexl::write_xlsx(data, path = sprintf("03-dades/dades-%03d.xlsx", i))
# })
