# server.R
# Note: Libraries are loaded in global.R

function(input, output, session) {
  
  # --- 1. GLOBAL LOGIC (Team Trends used across tabs) ---
  team_trend_data <- reactive({
    get_data(query_team_trends)
  })
  
  observe({
    df <- team_trend_data()
    req(df)
    # Safely find the team column (it might be 'team' or 'team_abbreviation')
    col_name <- if("team_abbreviation" %in% names(df)) "team_abbreviation" else "team"
    
    if (col_name %in% names(df)) {
      teams <- sort(unique(df[[col_name]]))
      updateSelectInput(
        session,
        "team_selector",
        choices = teams,
        selected = c("CHI", "LAL", "GSW")
      )
    }
  })
  
  # --- 2. IMPORT MODULES ---
  # Loads the logic for every tab
  source("modules/server_era.R", local = TRUE)
  source("modules/server_player.R", local = TRUE)
  source("modules/server_versus.R", local = TRUE)  
  source("modules/server_dream_team.R", local = TRUE)
  source("modules/server_demographics.R", local = TRUE)
  
}