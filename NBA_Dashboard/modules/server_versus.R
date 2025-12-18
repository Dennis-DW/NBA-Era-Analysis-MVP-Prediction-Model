# modules/server_versus.R

# --- HELPER: ROBUST DATA CLEANER (The Fix) ---
clean_versus_data <- function(df) {
  if (is.null(df) || nrow(df) == 0) return(NULL)
  
  n <- names(df)
  # 1. Standardize Column Names
  if ("team_abbreviation" %in% n) names(df)[names(df) == "team_abbreviation"] <- "team"
  if ("tm" %in% n) names(df)[names(df) == "tm"] <- "team"
  
  if ("height" %in% n) names(df)[names(df) == "height"] <- "player_height"
  if ("weight" %in% n) names(df)[names(df) == "weight"] <- "player_weight"
  
  if ("true_shooting_percentage" %in% n) names(df)[names(df) == "true_shooting_percentage"] <- "ts_pct"
  if ("ts_percent" %in% n) names(df)[names(df) == "ts_percent"] <- "ts_pct"
  
  if ("points" %in% n) names(df)[names(df) == "points"] <- "pts"
  if ("rebounds" %in% n) names(df)[names(df) == "rebounds"] <- "reb"
  if ("trb" %in% n) names(df)[names(df) == "trb"] <- "reb"
  if ("assists" %in% n) names(df)[names(df) == "assists"] <- "ast"
  
  # 2. FORCE NUMERICS (Critical Fix for Blank Charts)
  # We loop through all potential stats columns and force them to be numbers
  numeric_cols <- c("player_height", "player_weight", "pts", "reb", "ast", "ts_pct", "net_rating", "gp")
  
  for(col in numeric_cols) {
    if(col %in% names(df)) {
      df[[col]] <- as.numeric(df[[col]])
    }
  }
  
  return(df)
}

# --- 1. INITIALIZE SEARCH INPUTS ---
all_players_pos <- reactive({
  # Efficiently fetch names and heights
  query <- "SELECT player_name, AVG(player_height) as h1 FROM nba_seasons GROUP BY player_name"
  
  df <- tryCatch({ get_data(query) }, error = function(e) {
    # Fallback if column is named 'height'
    get_data("SELECT player_name, AVG(height) as h1 FROM nba_seasons GROUP BY player_name")
  })
  
  if(is.null(df)) return(NULL)
  
  # Categorize Position
  df$pos <- dplyr::case_when(
    df$h1 > 208 ~ "Center",
    df$h1 > 198 ~ "Forward",
    TRUE ~ "Guard"
  )
  return(df)
})

observe({
  req(all_players_pos())
  df <- all_players_pos()
  
  # Filter Left
  if (!is.null(input$p1_pos_filter) && input$p1_pos_filter != "All") {
    df_p1 <- df[df$pos == input$p1_pos_filter, ]
  } else { df_p1 <- df }
  
  selected1 <- "LeBron James"
  if (!selected1 %in% df_p1$player_name) selected1 <- df_p1$player_name[1]
  updateSelectizeInput(session, "p1_search", choices = df_p1$player_name, selected = selected1, server = TRUE)
  
  # Filter Right
  if (!is.null(input$p2_pos_filter) && input$p2_pos_filter != "All") {
    df_p2 <- df[df$pos == input$p2_pos_filter, ]
  } else { df_p2 <- df }
  
  selected2 <- "Stephen Curry"
  if (!selected2 %in% df_p2$player_name) selected2 <- df_p2$player_name[1]
  updateSelectizeInput(session, "p2_search", choices = df_p2$player_name, selected = selected2, server = TRUE)
})

# --- 2. FETCH DATA HELPER ---
get_peak_stats <- function(player_name) {
  if (is.null(player_name) || player_name == "") return(NULL)
  
  safe_name <- gsub("'", "''", player_name)
  # Use SELECT * to get all columns, then clean them
  query <- paste0("SELECT * FROM nba_seasons WHERE player_name = '", safe_name, "'")
  
  df <- get_data(query)
  df <- clean_versus_data(df) # Apply Robust Cleaning
  
  if (is.null(df) || nrow(df) == 0) return(NULL)
  
  # Default Missing Values to 0 to prevent crashes
  if (!"pts" %in% names(df)) df$pts <- 0
  if (!"reb" %in% names(df)) df$reb <- 0
  if (!"ast" %in% names(df)) df$ast <- 0
  if (!"ts_pct" %in% names(df)) df$ts_pct <- 0
  if (!"net_rating" %in% names(df)) df$net_rating <- 15 # Default average impact
  if (!"player_height" %in% names(df)) df$player_height <- 200
  
  # Find PEAK season
  df$fantasy_score <- df$pts + df$reb + df$ast
  peak_season <- df[which.max(df$fantasy_score), ]
  
  return(peak_season)
}

# --- 3. REACTION: GET STATS ---
p1_input <- reactive({ input$p1_search }) %>% debounce(500)
p2_input <- reactive({ input$p2_search }) %>% debounce(500)

p1_stats <- reactive({ req(p1_input()); get_peak_stats(p1_input()) })
p2_stats <- reactive({ req(p2_input()); get_peak_stats(p2_input()) })

# --- 4. RENDER AVATARS ---
render_avatar_html <- function(stats, side) {
  if (is.null(stats) || nrow(stats) == 0) return(div(""))
  
  h <- stats$player_height
  if (is.na(h)) h <- 200
  
  img_filename <- ifelse(h > 208, "center.png", ifelse(h > 198, "forward.png", "guard.png"))
  anim_class <- ifelse(side == "left", "float-left", "float-right")
  
  div(class = paste("avatar-container", anim_class),
      img(src = img_filename, height = "280px", style = "max-width: 100%; object-fit: contain;"),
      div(class = "avatar-shadow"),
      h4(stats$player_name, style = "margin-top: 10px; font-weight: bold; font-family: 'Impact'; color: white;")
  )
}

output$p1_avatar <- renderUI({ render_avatar_html(p1_stats(), "left") })
output$p2_avatar <- renderUI({ render_avatar_html(p2_stats(), "right") })

# --- 5. RENDER COMPARISON TABLE ---
output$versus_table <- renderUI({
  s1 <- p1_stats()
  s2 <- p2_stats()
  req(s1, s2)
  
  val_color <- function(v1, v2) {
    if (is.na(v1) || is.na(v2)) return("color: white;")
    if(v1 > v2) return("color: #2ECC71; font-weight: bold;") # Green
    if(v1 < v2) return("color: #E74C3C; opacity: 0.8;")      # Red
    return("color: white;")
  }
  
  create_row <- function(label, val1, val2, suffix="") {
    div(class = "vs-row",
        div(class = "vs-cell-left", style = val_color(val1, val2), paste0(val1, suffix)),
        div(class = "vs-label", label),
        div(class = "vs-cell-right", style = val_color(val2, val1), paste0(val2, suffix))
    )
  }
  
  ts1 <- round(s1$ts_pct*100, 1)
  ts2 <- round(s2$ts_pct*100, 1)
  
  div(class = "vs-table",
      create_row("Peak Season", s1$season, s2$season),
      create_row("Points", s1$pts, s2$pts),
      create_row("Rebounds", s1$reb, s2$reb),
      create_row("Assists", s1$ast, s2$ast),
      create_row("True Shooting", ts1, ts2, "%"),
      create_row("Height", s1$player_height, s2$player_height, " cm")
  )
})

# --- 6. RENDER RADAR CHART ---
output$versus_radar <- renderPlotly({
  s1 <- p1_stats()
  s2 <- p2_stats()
  req(s1, s2)
  
  norm <- function(val, max_v) { 
    if(is.null(val) || is.na(val)) return(0)
    pmin(val / max_v, 1) 
  }
  
  categories <- c("Scoring", "Reb", "Ast", "Eff", "Impact", "Scoring")
  
  fig <- plot_ly() %>%
    add_trace(
      type = 'scatterpolar',
      mode = "lines+markers",
      r = c(norm(s1$pts, 35), norm(s1$reb, 15), norm(s1$ast, 12), norm(s1$ts_pct*100, 65), norm(s1$net_rating, 30), norm(s1$pts, 35)),
      theta = categories,
      name = s1$player_name,
      fill = 'toself',
      fillcolor = 'rgba(231, 76, 60, 0.3)', 
      line = list(color = '#E74C3C', width = 2),
      marker = list(size = 4)
    ) %>%
    add_trace(
      type = 'scatterpolar',
      mode = "lines+markers", 
      r = c(norm(s2$pts, 35), norm(s2$reb, 15), norm(s2$ast, 12), norm(s2$ts_pct*100, 65), norm(s2$net_rating, 30), norm(s2$pts, 35)),
      theta = categories,
      name = s2$player_name,
      fill = 'toself',
      fillcolor = 'rgba(52, 152, 219, 0.3)', 
      line = list(color = '#3498DB', width = 2),
      marker = list(size = 4)
    )
  
  fig %>%
    layout(
      polar = list(
        radialaxis = list(visible = FALSE, range = c(0, 1)),
        angularaxis = list(tickfont = list(size = 10, color = "#BDC3C7"), rotation = 90),
        bgcolor = "rgba(0,0,0,0)"
      ),
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor = "rgba(0,0,0,0)",
      legend = list(orientation = "h", x = 0.5, y = -0.1, xanchor = "center", font = list(size=9, color="#BDC3C7")),
      margin = list(l=30, r=30, t=15, b=15)
    ) %>%
    config(displayModeBar = FALSE)
})