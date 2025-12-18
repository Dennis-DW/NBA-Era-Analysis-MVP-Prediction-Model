# global.R
# This file runs once when the app starts. 
# It loads all libraries and helpers for the entire app.

# 1. Load Libraries
library(shiny)
library(shinythemes)
library(tidyverse)
library(DBI)
library(RSQLite)
library(DT)
library(ggplot2)
library(plotly)

# 2. Load Helper Scripts
source("R/sql_queries.R")

# 3. Define Database Helper Function
# This ensures 'get_data' is available in all your server files
get_data <- function(query) {
  # Connect to the DB
  con <- dbConnect(RSQLite::SQLite(), "nba_db")
  on.exit(dbDisconnect(con)) # Close connection automatically
  
  # Fetch data
  dbGetQuery(con, query)
}