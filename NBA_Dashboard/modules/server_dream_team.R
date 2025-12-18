# modules/server_dream_team.R

# --- 3. DREAM TEAM DATA ---
dream_team_data <- reactive({ get_data(query_dream_team) })

# --- A. RENDER CARDS (2-2-1 FORMATION) ---
output$dream_team_cards <- renderUI({
  df <- dream_team_data()
  
  # 1. Separate Starters by Position
  starters <- df %>% filter(role == "Starter")
  guards   <- starters %>% filter(position == "Guard")
  forwards <- starters %>% filter(position == "Forward")
  centers  <- starters %>% filter(position == "Center")
  
  # 2. Helper function to make a single card
  create_card <- function(p) {
    # Shorten Name (e.g., "L. James")
    short_name <- sub("^(\\w)\\w+\\s", "\\1. ", p$player_name)
    
    div(class = "dream-card",
        div(class = "dc-header",
            div(class = "dc-pos", substr(p$position, 1, 1)),
            div(class = "dc-score", round(p$mvp_score, 1))
        ),
        div(class = "dc-name", short_name),
        div(class = "dc-year", p$season),
        div(class = "dc-stats",
            span(paste(p$pts, "PTS")),
            span(paste(p$reb, "REB")),
            span(paste(p$ast, "AST"))
        )
    )
  }
  
  # 3. Render the 2-2-1 Layout
  div(class = "dream-container",
      
      # ROW 1: GUARDS (2 Players)
      div(class = "formation-row",
          lapply(1:nrow(guards), function(i) create_card(guards[i, ]))
      ),
      
      # ROW 2: FORWARDS (2 Players)
      div(class = "formation-row",
          lapply(1:nrow(forwards), function(i) create_card(forwards[i, ]))
      ),
      
      # ROW 3: CENTER (1 Player)
      div(class = "formation-row",
          lapply(1:nrow(centers), function(i) create_card(centers[i, ]))
      )
  )
})

# --- B. RADAR CHART (Kept same) ---
output$mvp_comparison_plot <- renderPlotly({
  df <- dream_team_data() %>% filter(role == "Starter")
  
  radar_data <- df %>% select(player_name, pts, reb, ast, net_rating, ts_pct)
  scale_max <- function(x) { x / max(x) }
  
  radar_scaled <- radar_data %>%
    mutate(
      pts_norm = scale_max(pts),
      reb_norm = scale_max(reb),
      ast_norm = scale_max(ast),
      net_norm = scale_max(net_rating),
      ts_norm  = scale_max(ts_pct)
    )
  
  fig <- plot_ly(type = 'scatterpolar', fill = 'toself')
  colors <- c("#E74C3C", "#3498DB", "#F1C40F", "#9B59B6", "#2ECC71")
  
  for(i in 1:nrow(radar_scaled)) {
    row <- radar_scaled[i, ]
    raw <- radar_data[i, ]
    short_name <- sub("^(\\w)\\w+\\s", "\\1. ", row$player_name)
    
    fig <- fig %>%
      add_trace(
        r = c(row$pts_norm, row$reb_norm, row$ast_norm, row$net_norm, row$ts_norm, row$pts_norm),
        theta = c("Points", "Rebounds", "Assists", "Net Rating", "Efficiency", "Points"),
        name = short_name,
        mode = "lines+markers",
        line = list(color = colors[i]),
        fillcolor = paste0(colors[i], "33"),
        hoverinfo = "text",
        text = paste0("<b>", row$player_name, "</b><br>PTS: ", raw$pts)
      )
  }
  
  fig %>%
    layout(
      polar = list(radialaxis = list(visible = TRUE, range = c(0, 1), showticklabels = FALSE), bgcolor = "#272B30"),
      plot_bgcolor = "#272B30", paper_bgcolor = "#272B30",
      font = list(color = "#BDC3C7"),
      legend = list(orientation = "h", x = 0.1, y = 1.1),
      margin = list(t = 30, b = 30)
    ) %>%
    config(displayModeBar = FALSE)
})

# --- C. BENCH TABLE (Kept same) ---
output$bench_table <- renderDT({
  datatable(
    dream_team_data() %>% 
      filter(role == "Bench") %>% 
      select(Pos = position, Player = player_name, Year = season, MVP = mvp_score), 
    style = "bootstrap", 
    options = list(dom = 't', pageLength = 5, lengthChange = FALSE)
  )
})