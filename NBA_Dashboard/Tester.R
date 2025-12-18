# 1. Define the list of packages you need
required_packages <- c("shiny", "shinydashboard", "tidyverse", "DT", "DBI", "RSQLite")

# 2. Check which ones are missing
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

# 3. Install only the missing ones
if(length(new_packages)) install.packages(new_packages)

# 4. Load all packages
lapply(required_packages, library, character.only = TRUE)

print("All packages installed and loaded successfully!")

library(DBI)
library(RSQLite)

# Connect
con <- dbConnect(RSQLite::SQLite(), "nba_db")

# List all tables
print(dbListTables(con))

# Disconnect
dbDisconnect(con)