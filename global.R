library(shiny)
library(highcharter)
library(data.table)

# Define the range of seconds for the last X seconds (e.g., last 30 seconds)
n_last_secs <- 30

# Graph colors
colors <- c("#FFA622", "#434348")