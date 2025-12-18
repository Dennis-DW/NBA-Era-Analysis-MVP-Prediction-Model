# modules/server_player.R

# --- 1. SETUP SEARCH ---
# Fetch list of all players using the global helper
all_players <- reactive({
  get_data(query_all_players)
})

# Update the dropdown (Server-side is faster for long lists)
observe({
  req(all_players())
  players <- all_players()$player_name
  updateSelectizeInput(
    session,
    "player_search",
    choices = players,
    selected = "Stephen Curry", # DEFAULT SELECTION
    server = TRUE
  )
})

# --- 2. FETCH SELECTED PLAYER DATA ---
player_stats <- reactive({
  req(input$player_search)
  
  # Handle parameter injection safely for the text query
  safe_name <- gsub("'", "''", input$player_search)
  clean_query <- gsub("?", paste0("'", safe_name, "'"), query_player_career, fixed = TRUE)
  
  get_data(clean_query)
})

# --- 3. RENDER PROFILE CARD ---
output$player_profile_card <- renderUI({
  df <- player_stats()
  req(df)
  
  latest <- tail(df, 1)
  
  div(
    class = "player-card",
    div(class = "player-name", input$player_search),
    div(class = "player-team", paste(latest$team, "|", latest$season)),
    
    # Info Grid
    div(style = "margin-bottom: 15px; font-size: 14px; color: #BDC3C7;",
        paste0("Height: ", latest$height, " cm | Weight: ", latest$weight, " kg | Age: ", latest$age)
    ),
    
    # Stats Grid
    div(class = "stat-grid",
        div(class = "stat-box", div(class = "stat-val", latest$pts), div(class = "stat-label", "PTS")),
        div(class = "stat-box", div(class = "stat-val", latest$reb), div(class = "stat-label", "REB")),
        div(class = "stat-box", div(class = "stat-val", latest$ast), div(class = "stat-label", "AST"))
    )
  )
})

# --- 4. RENDER HISTORY CHART ---
output$plot_player_history <- renderPlotly({
  df <- player_stats()
  req(df)
  
  df <- df %>% mutate(hover_text = paste0("<b>Season: ", season, "</b><br>Team: ", team, "<br>PTS: ", pts, "<br>TS%: ", round(ts_pct * 100, 1), "%"))
  
  p <- ggplot(df, aes(x = season, y = pts, group = 1, text = hover_text)) +
    geom_area(fill = "#3498DB", alpha = 0.3) +
    geom_line(color = "#3498DB", linewidth = 1.2) +
    geom_point(color = "#F1C40F", size = 3) +
    labs(x = "", y = "Points Per Game") +
    theme_minimal() +
    theme(
      plot.background = element_rect(fill = "#272B30", color = NA),
      panel.background = element_rect(fill = "#272B30", color = NA),
      text = element_text(color = "#ECF0F1"),
      axis.text.x = element_text(angle = 45, hjust = 1, color = "#BDC3C7"),
      axis.text.y = element_text(color = "#BDC3C7"),
      panel.grid.major = element_line(color = "#34495E"),
      panel.grid.minor = element_blank()
    )
  
  ggplotly(p, tooltip = "text") %>% layout(plot_bgcolor = "#272B30", paper_bgcolor = "#272B30") %>% config(displayModeBar = FALSE)
})

# --- 5. SCORING KINGS CHART ---
output$plot_leaders <- renderPlotly({
  df_leaders <- get_data(query_season_leaders) %>% mutate(hover_text = paste0("<b>", player_name, "</b><br>Season: ", season, "<br>PPG: ", pts))
  
  p <- ggplot(df_leaders, aes(x = season, y = pts, color = factor(rank_num), text = hover_text)) +
    geom_point(size = 3, alpha = 0.8) + 
    scale_color_manual(values = c("#F1C40F", "#BDC3C7", "#E67E22")) +
    theme_minimal() + 
    theme(
      plot.background = element_rect(fill = "#272B30", color = NA),
      panel.background = element_rect(fill = "#272B30", color = NA),
      text = element_text(color = "#ECF0F1"),
      axis.text.x = element_text(angle = 90, hjust = 1, color = "#BDC3C7"),
      axis.text.y = element_text(color = "#BDC3C7"),
      panel.grid.major = element_line(color = "#34495E"),
      legend.position = "none"
    )
  
  ggplotly(p, tooltip = "text") %>% layout(plot_bgcolor = "#272B30", paper_bgcolor = "#272B30") %>% config(displayModeBar = FALSE)
})

# --- 6. EFFICIENCY CHART ---
output$plot_efficiency <- renderPlotly({
  df_eff <- get_data(query_efficiency) %>% mutate(hover_text = paste0("<b>", player_name, "</b><br>Usage: ", usage_rate * 100, "%<br>TS%: ", shooting_efficiency * 100, "%"))
  
  p <- ggplot(df_eff, aes(x = usage_rate, y = shooting_efficiency, size = pts, text = hover_text)) +
    geom_point(color = "#2ECC71", alpha = 0.7) +
    labs(x = "Usage Rate", y = "True Shooting %") +
    theme_minimal() + 
    theme(
      plot.background = element_rect(fill = "#272B30", color = NA),
      panel.background = element_rect(fill = "#272B30", color = NA),
      text = element_text(color = "#ECF0F1"),
      axis.text = element_text(color = "#BDC3C7"),
      panel.grid.major = element_line(color = "#34495E"),
      legend.position = "none"
    )
  
  ggplotly(p, tooltip = "text") %>% layout(plot_bgcolor = "#272B30", paper_bgcolor = "#272B30") %>% config(displayModeBar = FALSE)
})

# --- 7. MOST IMPROVED CHART (MISSING PIECE ADDED) ---
output$plot_improved_chart <- renderPlotly({
  df <- get_data(query_top_improved_chart)
  
  # Check if df is empty (prevents crashes if DB is missing data)
  validate(need(nrow(df) > 0, "No data available for Improved Players chart."))
  
  # Label creation
  df$label <- paste0(df$player_name, " (", df$season, ")")
  df$label <- factor(df$label, levels = df$label[order(df$ppg_increase)])
  
  df <- df %>% mutate(hover_text = paste0("<b>", player_name, "</b><br>Season: ", season, "<br>Jump: +", ppg_increase, " PPG<br>Previous: ", prev_pts, "<br>Current: ", current_pts))
  
  p <- ggplot(df, aes(x = ppg_increase, y = label, fill = ppg_increase, text = hover_text)) +
    geom_col() +
    scale_fill_gradient(low = "#F39C12", high = "#E74C3C") +
    labs(x = "PPG Increase", y = "") +
    theme_minimal() +
    theme(
      plot.background = element_rect(fill = "#272B30", color = NA),
      panel.background = element_rect(fill = "#272B30", color = NA),
      text = element_text(color = "#ECF0F1"),
      axis.text = element_text(color = "#BDC3C7"),
      panel.grid.major.x = element_line(color = "#34495E"),
      panel.grid.major.y = element_blank(),
      legend.position = "none"
    )
  
  ggplotly(p, tooltip = "text") %>% layout(plot_bgcolor = "#272B30", paper_bgcolor = "#272B30") %>% config(displayModeBar = FALSE)
})

# --- 8. IMPROVED PLAYERS TABLE ---
output$table_improved <- renderDT({
  datatable(
    get_data(query_most_improved),
    style = "bootstrap",
    options = list(pageLength = 5, lengthChange = FALSE, dom = 'tp', scrollX = TRUE)
  )
})