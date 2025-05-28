library(tidyverse)
library(here)

data <- read.delim(here("data/penguins.tsv"), sep = "\t") |>
  as_tibble() |>
  filter(complete.cases(sex))

species <- sort(unique(data$species))
clrs <- c("#515A79", "#A36267", "#E99973")[1:length(species)] |>
  set_names(nm = species)

p <- ggplot(data = data, aes(x = sex, y = body_mass_g)) +
  geom_boxplot(aes(fill = species)) +
  scale_fill_manual(values = clrs) +
  scale_y_continuous("body mass", labels = \(x) {
    sprintf("%.0f kg", x * 1e-3)
  }) +
  labs(subtitle = "created with R4") +
  theme(legend.position = "bottom")

ggsave(
  plot = p,
  filename = here("results/img/plot_r4.png"),
  height = 4,
  width = 5
)
