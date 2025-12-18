# server.R
# Note: Libraries are loaded in global.R

function(input, output, session) {
  # --- 1. GLOBAL LOGIC ---
  team_trend_data <- reactive({
    get_data(query_team_trends)
  })
  
  observe({
    df <- team_trend_data()
    req(df)
    teams <- sort(unique(df$team))
    updateSelectInput(
      session,
      "team_selector",
      choices = teams,
      selected = c("CHI", "LAL", "GSW")
    )
  })
  
  # --- 2. IMPORT MODULES (Updated Path) ---
  # source from 'modules/' instead of 'R/' to prevent auto-loading errors
  source("modules/server_era.R", local = TRUE)
  source("modules/server_player.R", local = TRUE)
  source("modules/server_dream_team.R", local = TRUE)
  source("modules/server_demographics.R", local = TRUE)
  
}