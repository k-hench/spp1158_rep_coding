#!/usr/bin/env Rscript
# --- header ---
# Rscript meta_summary.R <n_clusters>
# "copy and paste"-template with one instance
# (to be used during design of the script)
# args <- c("6 36 216 1296") # all n cluster values [ 6, 36, 216, 1296 ]
# --- actual script ---
# load required R packagesdata
library(tidyverse)
library(here)
library(glue)
library(patchwork)
library(ggforce)
library(prismatic)

# read in arguments from the command line
args <- commandArgs(trailingOnly = TRUE)
# parse cluster numbers from character to vector
nclusts <- unlist(str_split(args[[1]], pattern = " "))

# loop over cluster numbers and read in summary table
data <- nclusts |>
  map_dfr(
    # ad-hoc import function
    \(n) {
      read_tsv(here(glue("results/summary/kmeans_{n}.tsv")))
    }
  )

# create summary plot of the distance stats
# (first row of final figure)
p1 <- data |>
  pivot_longer(n:sd_distance, names_to = "param") |>
  ggplot(aes(x = factor(n_clust), y = value)) +
  geom_jitter(height = 0, width = .3, size = .2, color = "gray60") +
  geom_boxplot(alpha = .4) +
  facet_wrap(param ~ ., scales = "free") +
  labs(
    subtitle = "cluster statistics based on cluster level",
    x = "number of assigned clusters",
    y = "parameter value"
  )

# re-import the prepared cluster-assignment plots
# (looping over cluster levels)
subplots_1 <- nclusts |>
  map(
    \(n) {
      # re-import prepared ggplot objects
      readRDS(here(glue("results/img/R/assigned_{n}_clusters.Rds"))) +
        # add plot title to indicate cluster level
        labs(subtitle = glue("n clusters: {n}"))
    }
  )

# prepare imported subplot-layout
# (second row of final figure)
pw1 <- wrap_plots(subplots_1, nrow = 1) &
  coord_equal(xlim = c(-5, 5), ylim = c(-5, 5))

# plotting function for spatial plot
# of distance stats
plot_cluster_summary <- \(nclust) {
  data |>
    # subset data to specific cluster level
    filter(n_clust == nclust) |>
    ggplot() +
    # add cicle showing the average distance from centroid
    geom_circle(
      aes(
        x0 = centroid_x,
        y0 = centroid_y,
        r = avg_distance,
        color = factor(cluster),
        fill = after_scale(clr_alpha(color, .1))
      ),
      linetype = 3,
      show.legend = "none"
    ) +
    # add location of centroid
    geom_point(
      aes(
        x = centroid_x,
        y = centroid_y,
        color = factor(cluster),
        fill = after_scale(clr_alpha(color))
      ),
      shape = 21,
      size = 3,
      show.legend = "none"
    )
}

# loop over plotting function
subplots_2 <- map(nclusts, plot_cluster_summary)

# assemble third row of the final figure
pw2 <- wrap_plots(subplots_2, nrow = 1) &
  labs(x = "x", y = "y") &
  coord_equal(xlim = c(-5, 5), ylim = c(-5, 5))

# final figure assembly
pw_out <- p1 +
  pw1 +
  pw2 +
  plot_annotation(tag_levels = "a") +
  plot_layout(ncol = 1) &
  theme_minimal() &
  theme(legend.position = "none")

# final figure export
ggsave(
  filename = here("results/img/cluster_summary.pdf"),
  plot = pw_out,
  width = 12,
  height = 10,
  device = cairo_pdf
)
