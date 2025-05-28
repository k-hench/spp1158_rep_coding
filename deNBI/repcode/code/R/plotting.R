## --- Setup section ---
# Load required libraries
suppressPackageStartupMessages(library(tidyverse))   # For data manipulation and plotting
library(prismatic)   # For reading SVG images
library(patchwork)   # For arranging plots
library(ggforce)     # For plotting ellipses and circles
library(png)         # For reading images

# Set seed for reproducibility
set.seed(42)
fnt_sel <- "Arial"

# Set theme for plots
theme_set(theme_minimal(base_family = fnt_sel) %+replace%
            theme(panel.border = element_rect(linewidth = .3,
                                              fill = "transparent"),
                  legend.position = "none",
                  plot.subtitle = element_text(hjust = .5,
                                               margin = margin(b = 5))) )

# Function to read png files
read_png <- function(file_path){
  readPNG(file_path) |>
  grid::rasterGrob(interpolate=TRUE)
}

# Function to reformat column names for better visualization
reformat_names <- \(x){
  str_replace_all(x, "_", " ") |> 
    str_replace(" ([a-z])*$", " \\(\\1\\)")
}

# Define species names and corresponding cluster indices
species <- c("adelie", "chinstrap", "gentoo")
cluster_idx <- c(0, 2, 1) |> set_names(nm = species)

# Define cluster names and colors
cluster_names <- species |> set_names(nm = cluster_idx)
clrs <- c("#BC4743", "#76a8cc", "#0e6261") |> # "#5b898b")  |> #c("#F26C0DFF", "#BE60C5FF", "#0A6B70FF") |>
  set_names(nm = species)
clrs_cluster <- set_names(clrs, nm = cluster_idx[names(clrs)])

## --- Loading Data ---
# Read data for clustered penguins and centroids
data_samples <- read_tsv("results/clustered_penguins.tsv",
                         col_types = "cccddddcdddi") |> 
  mutate(correctly_assigned = cluster == cluster_idx[species])

data_centroids <- read_tsv("results/clustered_centroids.tsv",
                           col_types = "iddddddddd")

# Convert data to long format for plotting along facets
data_samples_long <- data_samples |> 
  pivot_longer(bill_length_mm:body_mass_g)

data_centroids_long <- data_centroids |> 
  select(cluster:centroid_body_mass_g) |> 
  set_names(nm = \(x){str_remove(x, "centroid_")})|> 
  pivot_longer(bill_length_mm:body_mass_g)

## --- Main Plots ---
# Plot 1: Feature measurements
p1 <- data_samples_long |> 
  ggplot(aes(y = species, x = value, color = species)) +
  geom_jitter(height = 0.25, width = 0,
              size = .5,
              alpha = .3)+
  geom_point(data = data_centroids_long,
             aes(y = cluster_names[as.character(cluster)],
                 color = cluster_names[as.character(cluster)]),
             size = 3, shape = 21, fill = clr_alpha("white", .75)) +
  scale_color_manual(values = clrs) +
  labs(subtitle = "feature measurements") +
  facet_grid(.~reformat_names(name), 
             scales = "free_x",switch = "x")+
  theme(axis.title = element_blank(),
        axis.text.y = element_blank(),
        strip.placement = "outside")

# Plot 2: PCA with actual species
p2 <- data_samples |> 
  ggplot(aes(x = PC1, y = PC2, color = species)) +
  geom_point(data = data_samples |> filter(!correctly_assigned),
             shape = 1, size = 3) +
  geom_point(size = .5, alpha = .3) +
  stat_ellipse(data = data_samples,
               mapping = aes(x = PC1, y = PC2, color = species),
               linewidth = .2) +
  scale_color_manual(values = clrs) +
  labs(subtitle = "actual species") +
  coord_fixed(xlim = c(-3,4),
              ylim = c(-2.5,3),
              ratio = 1)

# Plot 3: PCA with assigned clusters
p3 <- data_samples |> 
  ggplot(aes(x = PC1, y = PC2, color = factor(cluster))) +
  geom_point(data = data_samples |> filter(!correctly_assigned),
             shape = 1, size = 3) +
  geom_point(size = .5, alpha = .3) +
  scale_color_manual(values = clrs_cluster)+
  labs(subtitle = "assigned clusters") +
  coord_fixed(xlim = c(-3,4),
              ylim = c(-2.5,3),
              ratio = 1) +
  theme(axis.title.y = element_blank(),
        axis.text.y = element_blank())

# Plot 4: Cluster centroids and inertia
# (sum of squared distances of samples to their closest cluster center)
p4 <- ggplot() +
  geom_point(data = data_centroids,
             aes(x = centroid_PC1, y = centroid_PC2,
                 color = factor(cluster)),
             size = 4, shape = 21, fill = "white")+
  geom_ellipse(data = data_centroids,
               aes(x0 = centroid_PC1, y0 = centroid_PC2,
                   a = semi_major_axis,
                   b = semi_minor_axis,
                   angle = rotation_angle, color = factor(cluster)),
               linewidth = .2)+
  scale_fill_manual(values = clr_alpha(clrs,.2) |> 
                      set_names(nm = names(clrs))) +
  scale_color_manual(values = clrs_cluster) +
  labs(x = "PC1", y = "PC2",
       subtitle = "cluster centroids")+
  coord_fixed(xlim = c(-3,4),
              ylim = c(-2.5,3),
              ratio = 1) +
  theme(axis.title.y = element_blank(),
        axis.text.y = element_blank())

## --- Constructing the Legend ---
# Read SVG images for each species
images <- str_c("data/", species, ".c.png") |> 
  map(read_png) |>
  set_names(nm = species)

# Define data for species positions in the legend plot
data_species <- tibble(species = species,
                       y = c(.145, .5, .815),
                       y_adj = y + c(.175,.2,.175))

# Create legend plot
p_leg <- ggplot() +
  geom_text(data = data_species,
            aes(x = .67, y = y, label = species),
            size = 4, angle = -90, family = fnt_sel) +
  geom_circle(data = data_species,
              aes(x0 = .5, y0 = y, r = .12,
                  color = species,
                  fill = after_scale(clr_alpha(color)))) +
  annotation_custom(grob = images$chinstrap, ymin = 0.02,ymax = .31) +
  annotation_custom(grob = images$gentoo,   ymin = .35,ymax = .64) +
  annotation_custom(grob = images$adelie,   ymin = .68,ymax = .98) +
  scale_color_manual(values = clrs,
                     guide = "none") +
  labs(caption = "artwork by @allison_horst")+
  coord_equal(xlim = c(.3,.7), 
              ylim = c(0,1),
              expand = 0,
              clip = "off") +
  theme_void()+
  theme(plot.caption = element_text(size = 7,
                                    hjust = .5,
                                    family = fnt_sel))

## --- Final Plot Arrangement ---
# Design layout for combining plots
design <- "AAAE
           BCDE
           BCDE"

# Arrange plots using patchwork
patchwork <- p1 + p2 + p3 + p4  +
  p_leg  +
  plot_layout(design = design,tag_level = 'new') +
  plot_annotation(tag_levels = list(letters[1:4], '1'))

# Save combined plot to PDF
ggsave(filename = "results/cluster_results.pdf", 
       plot = patchwork,
       width = 9, height = 4.5,
       device = cairo_pdf)

# log session information
cat("R packages used:\n")
cat(str_c("run on the ", Sys.Date()))
cat("\n---------------\n")
sessionInfo()

