#### Preamble ####
# Purpose: Download and save NFL play-by-play data for specified seasons
# Author: [Your Name]
# Date: [Current Date]
# Contact: [Your Email]
# License: MIT
# Pre-requisites: None
# Any other information needed? None

#### Workspace setup ####
# Load the packages
library(nflfastR)
library(tidyverse)

#### Define seasons of interest ####
seasons <- 2019:2023

#### Download play-by-play data ####
pbp_data <- load_pbp(seasons)

# Save the play-by-play data
write_csv(pbp_data, "data/01-raw_data/pbp_data.csv")

#### Verify data ####
# View the first few rows of the data
head(pbp_data)

