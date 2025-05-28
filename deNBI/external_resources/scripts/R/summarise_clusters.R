#!/usr/bin/env Rscript
# --- header ---
# Rscript summarise_clusters.R <n_clusters>
# "copy and paste"-template with one instance
# (to be used during design of the script)
# args <- c("6") # possible n cluster values [ 6, 36, 216, 1296 ]
# --- actual script ---
# load required R packages
library(tidyverse)
library(here)
library(glue)

# read in arguments from the command line
args <- commandArgs(trailingOnly = TRUE)
# we only expect one argument
# (the number of cluster that we focus on in this case)
nclust <- args[[1]]

# import the data set with the assigned clusters
# matching the specified number of clusters
data <- read_tsv(here(glue("results/kmeans/cluster_{nclust}.tsv"))) |>
  # turn x & y into a single complex number for
  # quick calculation of centroid position
  # and distance from centroid
  mutate(complex = x + 1i * y) |>
  group_by(cluster) |>
  mutate(centroid = mean(complex), distance = Mod(complex - centroid)) |>
  ungroup()

# compute cluster statistics
# (number of assigned data points, distance measures)
data_summary <- data |>
  group_by(cluster) |>
  summarise(
    centroid = centroid[1],
    n = n(),
    avg_distance = mean(distance),
    sd_distance = sd(distance)
  ) |>
  mutate(
    n_clust = nclust,
    centroid_x = Re(centroid),
    centroid_y = Im(centroid)
  ) |>
  select(-centroid)

# export summary stats to file
data_summary |>
  write_tsv(here(glue("results/summary/kmeans_{nclust}.tsv")))

# plot cluster assignments
p <- data |>
  ggplot(aes(x, y, color = factor(cluster))) +
  geom_point(size = .2) +
  theme(legend.position = "none") +
  coord_equal()

# export plot as pdf file
ggsave(
  filename = here(glue("results/img/assigned_{nclust}_clusters.pdf")),
  plot = p,
  width = 6,
  height = 6,
  device = cairo_pdf
)

# also export the plot as R object
saveRDS(object = p, here(glue("results/img/R/assigned_{nclust}_clusters.Rds")))
