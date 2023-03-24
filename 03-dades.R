library(palmerpenguins)
penguins = na.omit(penguins)

library(tidyverse)
library(broom)
set.seed(1)
dpenguins = tibble(
  ds = rerun(10000, sample_n(penguins, size = 150)))

dpenguins = dpenguins %>%
  mutate(
    p1_test_1 = map(ds, ~tidy(with(.x, t.test(bill_length_mm, bill_depth_mm * 2.5, paired = TRUE)))),
    p1_var = map(ds, ~var.test(bill_depth_mm~sex, data = .x)),
    p1_var_equal = map_lgl(p1_var, ~(.x$p.value > 0.05)),
    p1_test_2 = map2(ds, p1_var_equal, ~tidy(t.test(bill_depth_mm~sex, data = .x, var.equal = .y))),
    p2_table = map(ds, ~table(with(.x, sex, species))),
    p2_table_min = map_int(p2_table, ~min(.x)),
    p2_test = map(p2_table, ~tidy(chisq.test(.x, correct = FALSE))),
    p3_ds = map(ds, filter, species == 'Adelie'),
    p3_var = map(p3_ds, ~bartlett.test(body_mass_g~island, data = .x)),
    p3_var_equal = map_lgl(p3_var, ~(.x$p.value > 0.05)),
    p3_test = map2(p3_ds, p3_var_equal, ~suppressWarnings(tidy(oneway.test(body_mass_g~island, data = .x, var.equal = .y)))),
    p3_norm = map(p3_ds, ~tidy(shapiro.test(residuals(lm(body_mass_g~island, data = .x)))))
  ) 
v_p1_var_equal = dpenguins %>%
  pull(p1_var_equal)
v_p3_var = dpenguins %>%
  pull(p3_var_equal) 
v_p3_norm = dpenguins %>%
  unnest(p3_norm) %>%
  pull(p.value)


dpenguins = dpenguins %>%
  filter(v_p1_var_equal, v_p3_var, v_p3_norm > 0.05)

save.image(file = "03-dades.RData")
# library(writexl)
# lapply(1:length(l_env.pair), function(i){
#   data = l_env.pair[[i]]
#   writexl::write_xlsx(data, path = sprintf("03-dades/dades-%03d.xlsx", i))
# })
