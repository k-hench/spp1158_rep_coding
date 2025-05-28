# importing required r packages
library(tidyverse) # for data handling & plotting
library(here) # to specify paths relative to .Rproj file
library(glue) # for error message formatting

# wrapper function to allow the script to continue
# also in case of errors during the file import
try_read_tsv <- \(file, ...) {
  tryCatch(
    {
      # case whithout errors
      read_tsv(file)
    },
    # case in which the data import creates an error
    error = function(e) {
      print(
        glue("Error while reading the file {file}:\n"),
        e$message
      )
    }
  )
}

# trying to read in data, assuming the working directory is `project_folder`
data_plain_path <- try_read_tsv("data/dd_masked.tsv")

# reading in data while setting the working directory explicitly to `project_folder`
# (location of the .Rproj file)
# importing the mysterious "masked" data set
data_masked <- read_tsv(here("data/dd_masked.tsv"))
# importing the key to the "masked" data set
data_key <- read_tsv(here("data/dd_key.tsv"))

# combine the key and the original data
data <- data_masked |>
  left_join(data_key) |>
  arrange(row_number)

# plotting the data set for which the import
# should have worked in any case
p <- data |>
  ggplot(aes(x = x, y = y)) +
  geom_point(size = 0.25) +
  facet_wrap(class ~ .) +
  theme_minimal()

# export the plot with a generic file name
ggsave(
  filename = "plot_standard.pdf",
  width = 6,
  height = 6,
  device = cairo_pdf
)

# export the plot, while securing the
# output path within the project_folder
ggsave(
  filename = here("results/plot_here.pdf"),
  width = 6,
  height = 6,
  device = cairo_pdf
)

# log session information
cat("R packages used:\n")
cat(str_c("run on the ", Sys.Date()))
cat("\n---------------\n")
sessionInfo()
