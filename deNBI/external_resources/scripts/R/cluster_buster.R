# script to create the cluster_buster data set
library(tidyverse)
library(here)
# always
set.seed(42)

# function to generate centroid positions,
# located at corners & center of a pentagon
generate_centroid <- \(idx, nmax = 5, scale = 1, xshift = 0, yshift = 0) {
  tibble(tau = 2 * pi * (idx - 1) / (nmax), x = sin(tau), y = cos(tau)) |>
    bind_rows(tibble(tau = NA, x = 0, y = 0)) |>
    mutate(x = x * scale + xshift, y = y * scale + yshift)
}

# scatter data points randomly around a centroid
random_data <- \(x_centroid = 0, y_centroid = 0, n = 10, sd = 1) {
  tibble(
    x = rnorm(n = n, mean = x_centroid, sd = sd),
    y = rnorm(n = n, mean = y_centroid, sd = sd)
  )
}

# recursively create centroids for
# main clusters, sub-clusters, subsub-clusters, ...
# (four levels deep)
# nr of centroids: 6, 36, 216, 1296
centroids <- generate_centroid(1:5, scale = 3.5) |>
  select(xshift = x, yshift = y) |>
  pmap_dfr(generate_centroid, idx = 1:5) |>
  select(xshift = x, yshift = y) |>
  pmap_dfr(generate_centroid, idx = 1:5, scale = .3) |>
  select(xshift = x, yshift = y) |>
  pmap_dfr(generate_centroid, idx = 1:5, scale = .095)

# generate scatterd data around all centroids
data <- centroids |>
  select(x_centroid = x, y_centroid = y) |>
  pmap_dfr(random_data, sd = .015)

# visual check of density
# (balance degree of separation within /
#  between clusters at different levels)
p <- data |>
  ggplot(aes(x, y)) +
  geom_point(size = .1) +
  coord_equal()

# export control plot
ggsave(
  plot = p,
  filename = here("results/img/cluster_generation.pdf"),
  width = 6,
  height = 6,
  device = cairo_pdf
)

# export final data set
write_tsv(data, file = here("data/cluster_buster.tsv"))
