#### Preamble ####
# Purpose: Explore data for quarterback and team stats
# Author: Vandan Patel
# Date: December 3, 2024
# Contact: vandanp.patel@mail.utoronto.ca
# License: MIT
# Pre-requisites: Clean data available in Parquet files

#### Workspace setup ####
library(tidyverse)
library(ggplot2)
library(arrow)  # To read Parquet files

#### Read cleaned data ####
# Load QB stats
qb_data <- read_parquet("data/02-analysis_data/cleaned_starting_qb_stats_2023.parquet")

# Load Team stats
team_data <- read_parquet("data/02-analysis_data/cleaned_team_stats_2023.parquet")

#### Part 1: Quarterback Metrics ####

# Plot 1: Total Passing Yards by QB
ggplot(qb_data, aes(x = reorder(paste(passer_player_name, posteam, sep = " ("), total_passing_yards), 
                    y = total_passing_yards, fill = posteam)) +
  geom_bar(stat = "identity", color = "black") +
  coord_flip() +
  labs(title = "Total Passing Yards by Starting Quarterback",
       x = "Quarterback (Team)", y = "Total Passing Yards") +
  theme_minimal() +
  theme(legend.position = "none")

# Plot 2: Total Passing Touchdowns by QB
ggplot(qb_data, aes(x = reorder(paste(passer_player_name, posteam, sep = " ("), total_touchdowns), 
                    y = total_touchdowns, fill = posteam)) +
  geom_bar(stat = "identity", color = "black") +
  coord_flip() +
  labs(title = "Total Passing Touchdowns by Starting Quarterback",
       x = "Quarterback (Team)", y = "Total Passing Touchdowns") +
  theme_minimal() +
  theme(legend.position = "none")

# Plot 3: Total Interceptions by QB
ggplot(qb_data, aes(x = reorder(paste(passer_player_name, posteam, sep = " ("), total_interceptions), 
                    y = total_interceptions, fill = posteam)) +
  geom_bar(stat = "identity", color = "black") +
  coord_flip() +
  labs(title = "Total Interceptions by Starting Quarterback",
       x = "Quarterback (Team)", y = "Total Interceptions") +
  theme_minimal() +
  theme(legend.position = "none")

#### Part 2: Team Metrics ####

# Plot 4: Total Wins by Team
ggplot(team_data, aes(x = reorder(posteam, total_wins), y = total_wins, fill = posteam)) +
  geom_bar(stat = "identity", color = "black") +
  coord_flip() +
  labs(title = "Total Wins by Team",
       x = "Team", y = "Total Wins") +
  theme_minimal() +
  theme(legend.position = "none")

# Plot 5: Average Score Differential by Team
ggplot(team_data, aes(x = reorder(posteam, avg_score_differential), y = avg_score_differential, fill = posteam)) +
  geom_bar(stat = "identity", color = "black") +
  coord_flip() +
  labs(title = "Average Score Differential by Team",
       x = "Team", y = "Average Score Differential") +
  theme_minimal() +
  theme(legend.position = "none")

# Plot 6: Playoff Status with counts
ggplot(team_data, aes(x = playoff_status, fill = playoff_status)) +
  geom_bar(stat = "count", color = "black") +
  labs(title = "Playoff Status Count",
       x = "Playoff Status", y = "Count of Teams", fill = "Playoff Status") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0, hjust = 0.5),
        legend.position = "none") +
  scale_fill_manual(values = c("Missed Playoffs" = "red", "Made Playoffs" = "green"))
