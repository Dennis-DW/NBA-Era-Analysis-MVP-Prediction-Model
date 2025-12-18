# modules/server_era.R

# --- 0. REACTIVE DATA FILTER (ROBUST) ---
era_data <- reactive({
  # 1. Fetch ALL data
  df <- get_data("SELECT * FROM nba_seasons")
  
  if (is.null(df) || nrow(df) == 0) return(NULL)
  
  # 2. STANDARDIZE COLUMN NAMES (The Fix)
  # We check for common variations and rename them to standard names
  n <- names(df)
  
  # Team
  if ("team_abbreviation" %in% n) names(df)[names(df) == "team_abbreviation"] <- "team"
  if ("tm" %in% n) names(df)[names(df) == "tm"] <- "team"
  
  # Height
  if ("height" %in% n) names(df)[names(df) == "height"] <- "player_height"
  if ("player_height" %in% n) names(df)[names(df) == "player_height"] <- "player_height" # Keep if exists
  
  # Weight
  if ("weight" %in% n) names(df)[names(df) == "weight"] <- "player_weight"
  
  # True Shooting % (Common cause of blank charts)
  if ("true_shooting_percentage" %in% n) names(df)[names(df) == "true_shooting_percentage"] <- "ts_pct"
  if ("ts_percent" %in% n) names(df)[names(df) == "ts_percent"] <- "ts_pct"
  
  # Rebounds
  if ("rebounds" %in% n) names(df)[names(df) == "rebounds"] <- "reb"
  if ("trb" %in% n) names(df)[names(df) == "trb"] <- "reb"
  
  # Assists
  if ("assists" %in% n) names(df)[names(df) == "assists"] <- "ast"
  
  # 3. FORCE NUMERIC TYPES (Safety check)
  # Sometimes CSV/SQL imports numbers as text ("205 cm"). This fixes that.
  if("player_height" %in% names(df)) df$player_height <- as.numeric(df$player_height)
  if("player_weight" %in% names(df)) df$player_weight <- as.numeric(df$player_weight)
  if("ts_pct" %in% names(df)) df$ts_pct <- as.numeric(df$ts_pct)
  if("pts" %in% names(df)) df$pts <- as.numeric(df$pts)
  
  # 4. FILTER BY SEASON
  start_year <- input$era_season_range[1]
  end_year <- input$era_season_range[2]
  
  # Handle Season String (e.g., "1996-97")
  df$year_numeric <- as.numeric(substr(df$season, 1, 4))
  
  df_filtered <- df %>%
    filter(year_numeric >= start_year & year_numeric <= end_year)
  
  return(df_filtered)
})

# --- 1. KPI HEADLINES ---
output$era_kpis <- renderUI({
  df <- era_data()
  if (is.null(df) || nrow(df) == 0) return(NULL)
  
  # Safely calc means even if column missing
  avg_pts <- if("pts" %in% names(df)) mean(df$pts, na.rm = TRUE) else 0
  avg_ts <- if("ts_pct" %in% names(df)) mean(df$ts_pct, na.rm = TRUE) else 0
  total_players <- length(unique(df$player_name))
  
  fluidRow(
    column(4, div(class = "stat-box", style="width: 100%;", div(class = "stat-val", round(avg_pts, 1)), div(class = "stat-label", "Era Avg PPG"))),
    column(4, div(class = "stat-box", style="width: 100%;", div(class = "stat-val", paste0(round(avg_ts*100, 1), "%")), div(class = "stat-label", "Era Avg TS%"))),
    column(4, div(class = "stat-box", style="width: 100%;", div(class = "stat-val", total_players), div(class = "stat-label", "Active Players")))
  )
})

# --- 2. SCORING TREND ---
output$plot_scoring_trend <- renderPlotly({
  df <- era_data()
  validate(need(nrow(df) > 0, "No data."))
  
  # Check if columns exist before grouping
  validate(need("ts_pct" %in% names(df), "Column 'ts_pct' or 'true_shooting_percentage' not found in DB."))
  
  plot_df <- df %>% 
    group_by(season) %>% 
    summarise(
      avg_pts = mean(pts, na.rm=T),
      avg_ts = mean(ts_pct, na.rm=T)
    )
  
  p <- ggplot(plot_df, aes(x = season)) +
    geom_line(aes(y = avg_pts, group = 1), color = "#E74C3C", linewidth = 1.2) + 
    theme_minimal() +
    theme(
      plot.background = element_rect(fill = "#272B30", color = NA),
      panel.background = element_rect(fill = "#272B30", color = NA),
      text = element_text(color = "#ECF0F1"),
      axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
      panel.grid.major = element_line(color = "#34495E", linewidth = 0.2),
      panel.grid.minor = element_blank()
    ) +
    labs(x = "", y = "Average Points")
  
  ggplotly(p) %>% layout(plot_bgcolor = "#272B30", paper_bgcolor = "#272B30") %>% config(displayModeBar = FALSE)
})

# --- 3. PHYSICAL EVOLUTION ---
output$plot_eras <- renderPlot({
  df <- era_data()
  validate(need(nrow(df) > 0, "No data."))
  validate(need("player_height" %in% names(df), "Column 'height' not found."))
  
  plot_df <- df %>% 
    group_by(season) %>% 
    summarise(
      avg_h = mean(player_height, na.rm=T),
      avg_w = if("player_weight" %in% names(df)) mean(player_weight, na.rm=T) else 0
    )
  
  coeff <- 2 
  
  ggplot(plot_df, aes(x = season)) +
    geom_col(aes(y = avg_w / coeff), fill = "#34495E", alpha = 0.6) +
    geom_line(aes(y = avg_h, group = 1), color = "#F1C40F", linewidth = 1.5) + 
    theme_minimal() +
    theme(
      plot.background = element_rect(fill = "#272B30"),
      panel.background = element_rect(fill = "#272B30"),
      text = element_text(color = "white"),
      axis.text.x = element_text(angle = 90, size = 8),
      panel.grid = element_blank()
    ) +
    labs(y = "Height (cm) - Line", x = "")
})

# --- 4. ROOKIES TABLE ---
output$table_rookies <- renderDT({
  df <- era_data()
  validate(need(nrow(df) > 0, "No data."))
  
  # Fallback if Age is missing
  if(!"age" %in% names(df)) df$age <- 21 
  
  top_rookies <- df %>% 
    filter(age < 22) %>%
    arrange(desc(pts)) %>%
    select(Player = player_name, Season = season, PTS = pts, AST = ast, REB = reb)
  
  datatable(top_rookies,
            options = list(
              pageLength = 5,
              lengthChange = FALSE,
              searching = FALSE,
              dom = 'tp',
              info = FALSE
            ),
            style = "bootstrap",
            rownames = FALSE
  ) %>% 
    formatStyle(
      columns = names(top_rookies),
      backgroundColor = '#272B30',
      color = '#ECF0F1',
      border = '1px solid #34495E'
    )
})

# --- 5. TEAM TRENDS ---
output$plot_team_trends <- renderPlotly({
  req(input$team_selector)
  df <- era_data()
  
  plot_df <- df %>% 
    filter(team %in% input$team_selector) %>%
    group_by(season, team) %>% 
    summarise(pts = mean(pts, na.rm=T))
  
  validate(need(nrow(plot_df) > 0, "No data for selected teams."))
  
  p <- ggplot(plot_df, aes(x = season, y = pts, color = team, group = team)) +
    geom_line(linewidth = 1) + 
    geom_point(size = 2) +
    theme_minimal() +
    theme(
      plot.background = element_rect(fill = "#272B30", color = NA),
      panel.background = element_rect(fill = "#272B30", color = NA),
      text = element_text(color = "#ECF0F1"),
      axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
      legend.position = "none"
    ) + labs(x="", y="Team Avg PPG")
  
  ggplotly(p) %>% layout(plot_bgcolor = "#272B30", paper_bgcolor = "#272B30") %>% config(displayModeBar = FALSE)
})

# --- 6. UPDATE TEAM CHOICES ---
observe({
  # Try fetching abbreviations first, fallback to 'tm'
  raw_teams <- tryCatch({
    get_data("SELECT DISTINCT team_abbreviation FROM nba_seasons ORDER BY team_abbreviation")
  }, error = function(e) {
    get_data("SELECT DISTINCT tm FROM nba_seasons ORDER BY tm")
  })
  
  if (!is.null(raw_teams)) {
    # Get the first column regardless of name
    team_list <- raw_teams[[1]]
    updateSelectInput(session, "team_selector", choices = team_list, selected = c("LAL", "BOS", "GSW"))
  }
})
# --- 7. NEW: SCORING LEADERS LOGIC ---
observe({
  # Populate the "Scoring Kings" dropdown with available seasons
  seasons <- get_data("SELECT DISTINCT season FROM nba_seasons ORDER BY season DESC")
  if(!is.null(seasons)) {
    updateSelectInput(session, "leaders_season", choices = seasons$season)
  }
})

output$table_scoring_leaders <- renderDT({
  req(input$leaders_season)
  
  # Fetch data for specific season
  query <- paste0("SELECT player_name, team_abbreviation, pts, reb, ast FROM nba_seasons WHERE season = '", input$leaders_season, "' ORDER BY pts DESC LIMIT 10")
  df <- get_data(query)
  validate(need(nrow(df) > 0, "No data."))
  
  # Rename for display
  df <- df %>% select(Player = player_name, Team = team_abbreviation, PTS = pts, REB = reb, AST = ast)
  
  datatable(df,
            options = list(pageLength = 5, lengthChange = F, searching = F, dom = 'tp', info = F),
            style = "bootstrap", rownames = FALSE
  ) %>% 
    formatStyle(columns = names(df), backgroundColor = '#272B30', color = '#ECF0F1', border = '1px solid #34495E') %>%
    formatStyle("PTS", color = "#E74C3C", fontWeight = "bold") # Highlight Points in Red
})

# --- 8. NEW: BREAKOUT SEASONS LOGIC ---
output$table_breakouts <- renderDT({
  # Use the reactive 'era_data()' so it respects the main slider range
  df <- era_data()
  validate(need(nrow(df) > 0, "No data."))
  
  # Logic: Calculate PPG difference from previous season
  # We need to sort by Player and Season to use lag()
  breakout_df <- df %>%
    arrange(player_name, season) %>%
    group_by(player_name) %>%
    mutate(
      prev_pts = lag(pts),
      diff = pts - prev_pts
    ) %>%
    ungroup() %>%
    filter(!is.na(diff)) %>%
    arrange(desc(diff)) %>%
    head(10) %>%
    select(Player = player_name, Season = season, `Old PPG` = prev_pts, `New PPG` = pts, `+Improvement` = diff)
  
  datatable(breakout_df,
            options = list(pageLength = 5, lengthChange = F, searching = F, dom = 'tp', info = F),
            style = "bootstrap", rownames = FALSE
  ) %>% 
    formatStyle(columns = names(breakout_df), backgroundColor = '#272B30', color = '#ECF0F1', border = '1px solid #34495E') %>%
    formatStyle("+Improvement", color = "#F1C40F", fontWeight = "bold", background = "rgba(241, 196, 15, 0.1)") # Highlight Growth in Gold
})