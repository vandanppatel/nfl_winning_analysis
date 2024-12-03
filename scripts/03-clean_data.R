#### Preamble ####
# Purpose: Clean raw data of NFL 2023 season for team and starter quarterbacks
# Author: Vandan Patel
# Date: December 3, 2024
# Contact: vandanp.patel@mail.utoronto.ca
# License: MIT
# Pre-requisites: Install `arrow` library for Parquet


#### Workspace setup ####
library(tidyverse)
library(janitor)
library(arrow)  # For writing Parquet files

#### Load raw data ####
raw_data <- read_csv("data/01-raw_data/pbp_data_2023.csv")

### Step 1: Filter Data for Regular Season ###
filtered_data <- 
  raw_data |>
  # Standardize column names
  janitor::clean_names() |>  
  # Regular season, valid posteam, and 2023 games
  filter(season_type == "REG", !is.na(posteam), season == 2023)  

### Step 2: Calculate Wins Correctly ###
# Group by game_id to ensure each game is uniquely counted
game_results <- 
  filtered_data |>
  group_by(game_id) |>
  summarize(
    home_team = first(home_team),
    away_team = first(away_team),
    home_score = max(total_home_score, na.rm = TRUE),
    away_score = max(total_away_score, na.rm = TRUE),
    winning_team = case_when(
      home_score > away_score ~ home_team,
      away_score > home_score ~ away_team,
      TRUE ~ "Tie"  # In case of a tie
    ),
    .groups = "drop"
  )

# Join the results back to the team-level stats
team_wins <- 
  game_results |>
  filter(winning_team != "Tie") |>  # Exclude ties from win counts
  count(winning_team, name = "total_wins") |>
  rename(posteam = winning_team)

# Merge the total wins with team-level stats
team_stats <- 
  filtered_data |>
  group_by(posteam) |>
  summarize(
    total_points_scored = sum(posteam_score, na.rm = TRUE),
    total_points_allowed = sum(defteam_score, na.rm = TRUE),
    avg_score_differential = mean(posteam_score - defteam_score, na.rm = TRUE),
    games_played = n_distinct(game_id),
    .groups = "drop"
  ) |>
  left_join(team_wins, by = "posteam") |>  # Add the total wins
  mutate(total_wins = replace_na(total_wins, 0))  # Replace missing wins with 0

### Step 3: Add Playoff Status ###
# Manually define the playoff teams
playoff_teams <- c("KC", "PHI", "BUF", "CIN", "SF", "JAX", "DAL", "NYG", "SEA", 
                   "BAL", "LAC", "MIA", "TB", "MIN")

team_stats <- 
  team_stats |>
  mutate(playoff_status = if_else(posteam %in% playoff_teams, "Made Playoffs", 
                                  "Missed Playoffs"))

#### Save cleaned team stats ####
write_parquet(team_stats, "data/02-analysis_data/cleaned_team_stats_2023.parquet")

### Step 4: Clean Quarterback Stats ###
# Step 1: Clean column names
cleaned_data <- raw_data |> 
  clean_names()

# Step 2: Aggregate quarterback statistics
qb_stats <- cleaned_data |> 
  filter(!is.na(passer_player_name)) |> # Filter rows with QB passing plays
  group_by(passer_player_name, posteam) |> 
  summarize(
    total_passing_yards = sum(passing_yards, na.rm = TRUE),
    total_touchdowns = sum(pass_touchdown, na.rm = TRUE),
    total_interceptions = sum(interception, na.rm = TRUE),
    games_played = n_distinct(game_id),
    total_team_score = sum(total_home_score[posteam == home_team] 
                           + total_away_score[posteam == away_team], 
                           na.rm = TRUE),
    total_opponent_score = sum(total_home_score[posteam != home_team] 
                               + total_away_score[posteam != away_team], 
                               na.rm = TRUE),
    .groups = "drop"
  ) |> 
  mutate(
    avg_score_differential = (total_team_score - total_opponent_score) / games_played,
    avg_passing_yards_per_game = total_passing_yards / games_played,
    avg_touchdowns_per_game = total_touchdowns / games_played,
    avg_interceptions_per_game = total_interceptions / games_played
  )

# Step 3: Identify starting QBs
# Assume starting QBs are those who played the most games for their team
starting_qbs <- qb_stats |> 
  group_by(posteam) |> 
  filter(games_played == max(games_played)) |> 
  ungroup()

#### Save cleaned quarterback stats ####
write_parquet(starting_qbs, "data/02-analysis_data/cleaned_starting_qb_stats_2023.parquet")
