# modules/server_player.R

# --- 1. INITIALIZATION ---
observe({
  players <- get_data("SELECT DISTINCT player_name FROM nba_seasons ORDER BY player_name")
  if(!is.null(players)) {
    selected <- if("LeBron James" %in% players$player_name) "LeBron James" else players$player_name[1]
    updateSelectizeInput(session, "player_search", choices = players$player_name, selected = selected, server = TRUE)
  }
})

# --- 2. DATA FETCHER ---
player_stats <- reactive({
  req(input$player_search)
  safe_name <- gsub("'", "''", input$player_search)
  query <- paste0("SELECT * FROM nba_seasons WHERE player_name = '", safe_name, "' ORDER BY season")
  df <- tryCatch({ get_data(query) }, error = function(e) NULL)
  
  if(is.null(df)) return(NULL)
  
  # Standardize Names (Just in case)
  n <- names(df)
  if ("team_abbreviation" %in% n) names(df)[names(df) == "team_abbreviation"] <- "team"
  if ("tm" %in% n) names(df)[names(df) == "tm"] <- "team"
  if ("player_height" %in% n) df$player_height <- as.numeric(df$player_height)
  
  return(df)
})

# --- 3. FILTER LOGIC (Calculates Stats Based on Selection) ---
filtered_stats <- reactive({
  df <- player_stats()
  req(df)
  
  mode <- input$player_filter_mode
  
  if (mode == "PEAK") {
    # Peak based on PTS
    df$pts <- as.numeric(df$pts)
    return(df[which.max(df$pts), ]) 
  } else if (mode == "LAST 5") {
    return(tail(df, 5)) 
  } else {
    return(df) # CAREER (All rows)
  }
})

# --- 4. AVATAR & BADGES ---
output$player_hero_avatar <- renderUI({
  df <- player_stats()
  req(df)
  latest <- tail(df, 1)
  
  h <- as.numeric(latest$player_height)
  if(is.na(h)) h <- 200
  img_filename <- ifelse(h > 208, "center.png", ifelse(h > 198, "forward.png", "guard.png"))
  
  div(style="text-align: center; position: relative; top: -10px;",
      img(src = img_filename, height = "160px", style = "filter: drop-shadow(0 0 10px rgba(255,255,255,0.3));"),
      h2(latest$player_name, style = "color: white; font-family: 'Impact'; margin: 0; letter-spacing: 1px; font-size: 24px;"),
      p(paste(latest$team, "|", latest$season), style = "color: #BDC3C7; font-size: 12px; margin: 0;")
  )
})

output$player_badges <- renderUI({
  df <- player_stats()
  req(df)
  latest <- tail(df, 1)
  ht <- if(!is.na(latest$player_height)) round(as.numeric(latest$player_height)) else "N/A"
  wt <- if(!is.null(latest$player_weight)) round(as.numeric(latest$player_weight)) else "N/A"
  
  div(style="text-align: right; padding-top: 30px;",
      h4(paste(ht, "cm"), style="color: #ECF0F1; margin: 0; font-size: 18px; font-weight: bold;"),
      h5("HEIGHT", style="color: #7F8C8D; font-size: 9px; margin-top: 0; margin-bottom: 8px;"),
      h4(paste(wt, "kg"), style="color: #ECF0F1; margin: 0; font-size: 18px; font-weight: bold;"),
      h5("WEIGHT", style="color: #7F8C8D; font-size: 9px; margin-top: 0;")
  )
})

# --- 5. MONEYBALL RINGS (REAL DATA) ---
format_pct <- function(val_list) {
  val <- mean(as.numeric(val_list), na.rm=TRUE)
  if(is.na(val) || is.infinite(val)) return("0%")
  # If data is 0.55 -> 55%, if it's 55.0 -> 55%
  if(val < 1.0 && val > 0) val <- val * 100
  return(paste0(round(val, 1), "%"))
}

# Ring 1: True Shooting %
output$val_ts <- renderText({ 
  df <- filtered_stats()
  req(df)
  if("ts_pct" %in% names(df)) format_pct(df$ts_pct) else "N/A"
})

# Ring 2: Usage Rate
output$val_usg <- renderText({ 
  df <- filtered_stats()
  req(df)
  if("usg_pct" %in% names(df)) format_pct(df$usg_pct) else "N/A"
})

# Ring 3: Assist Percentage
output$val_ast <- renderText({ 
  df <- filtered_stats()
  req(df)
  if("ast_pct" %in% names(df)) format_pct(df$ast_pct) else "N/A"
})

# --- 6. CHARTS ---
output$player_radar <- renderPlotly({
  df <- player_stats()
  req(df)
  
  df$pts <- as.numeric(df$pts)
  df$reb <- as.numeric(df$reb)
  df$ast <- as.numeric(df$ast)
  df$fantasy <- df$pts + df$reb + df$ast
  peak <- df[which.max(df$fantasy), ]
  
  # Normalize
  norm <- function(val, max_v) { pmin(ifelse(is.na(val), 0, val) / max_v, 1) }
  
  # Check if TS% exists for radar
  ts_val <- if("ts_pct" %in% names(peak)) peak$ts_pct * 100 else 50
  
  plot_ly(type = 'scatterpolar', mode = "lines+markers") %>%
    add_trace(
      r = c(norm(peak$pts, 35), norm(peak$reb, 15), norm(peak$ast, 12), norm(ts_val, 65), norm(peak$pts, 35)),
      theta = c("Scoring", "Rebounding", "Playmaking", "Efficiency", "Scoring"),
      name = peak$player_name,
      fill = 'toself', fillcolor = 'rgba(231, 76, 60, 0.5)', line = list(color = '#E74C3C')
    ) %>%
    add_trace(
      r = c(0.4, 0.3, 0.3, 0.5, 0.4), 
      theta = c("Scoring", "Rebounding", "Playmaking", "Efficiency", "Scoring"),
      name = "League Avg",
      line = list(color = '#7F8C8D', dash = 'dash'), marker = list(opacity = 0)
    ) %>%
    layout(
      polar = list(radialaxis = list(visible = F), bgcolor = "rgba(0,0,0,0)"),
      paper_bgcolor = "rgba(0,0,0,0)", plot_bgcolor = "rgba(0,0,0,0)",
      legend = list(orientation = "h", x=0.3, y=-0.1, font = list(color="white")),
      margin = list(t=10, b=10, l=20, r=20)
    ) %>% config(displayModeBar = FALSE)
})

output$plot_career_curve <- renderPlotly({
  df <- player_stats()
  req(df)
  
  plot_ly(df, x = ~season, y = ~pts, type = 'scatter', mode = 'lines+markers',
          line = list(color = '#3498DB', width = 3, shape = 'spline'),
          marker = list(size = 8, color = '#2C3E50', line = list(color = '#3498DB', width = 2)),
          name = "Points",
          hovertemplate = '<b>Season:</b> %{x}<br><b>PPG:</b> %{y:.1f}<extra></extra>'
  ) %>%
    layout(
      paper_bgcolor = "rgba(0,0,0,0)", plot_bgcolor = "rgba(0,0,0,0)",
      xaxis = list(title = "", color = "#BDC3C7", showgrid = F),
      yaxis = list(title = "Points Per Game", color = "#BDC3C7", gridcolor = "#34495E"),
      margin = list(t=30, r=20)
    ) %>% config(displayModeBar = FALSE)
})