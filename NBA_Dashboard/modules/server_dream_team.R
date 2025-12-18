# modules/server_dream_team.R

# --- 1. DATA FETCHING ---
dream_data <- reactive({
  # Fetches the Dream Team data using the query from sql_queries.R
  df <- get_data(query_dream_team)
  
  if(!is.null(df)) {
    # Clean MVP Score (Round to 2 decimals)
    df$mvp_score <- round(as.numeric(df$mvp_score), 2)
    # Ensure numeric stats
    df$pts <- as.numeric(df$pts)
    df$reb <- as.numeric(df$reb)
    df$ast <- as.numeric(df$ast)
    df$ts_pct <- as.numeric(df$ts_pct)
  }
  return(df)
})

# --- 2. RENDER STARTERS (HORIZONTAL ROW) ---
output$dream_starters_row <- renderUI({
  df <- dream_data()
  req(df)
  
  # Filter Starters
  starters <- df %>% filter(role == "Starter") %>% arrange(desc(mvp_score))
  
  # Helper to create HTML Card
  create_starter_card <- function(player) {
    # Determine Image
    img_file <- "guard.png" # Default
    if(grepl("Center", player$position)) img_file <- "center.png"
    if(grepl("Forward", player$position)) img_file <- "forward.png"
    
    div(class = "starter-card",
        div(class = "sc-pos", player$position),
        
        # Image Area
        div(class = "sc-img-box",
            img(src = img_file)
        ),
        
        # Name & Info
        h3(class = "sc-name", player$player_name),
        div(class = "sc-year", paste0(player$team_abbreviation, " '", substr(player$season, 3, 7))),
        
        # MVP Score Badge
        div(class = "sc-mvp-badge", paste0("MVP SCORE: ", player$mvp_score)),
        
        # Stats Grid
        div(class = "sc-stats",
            div(class="sc-stat-item", span(class="sc-val", round(player$pts,1)), span(class="sc-lbl", "PTS")),
            div(class="sc-stat-item", span(class="sc-val", round(player$reb,1)), span(class="sc-lbl", "REB")),
            div(class="sc-stat-item", span(class="sc-val", round(player$ast,1)), span(class="sc-lbl", "AST"))
        )
    )
  }
  
  # Return the Flex Container with all 5 cards
  div(class = "lineup-container",
      lapply(1:nrow(starters), function(i) {
        create_starter_card(starters[i, ])
      })
  )
})

# --- 3. BENCH TABLE ---
output$table_bench <- renderDT({
  df <- dream_data()
  validate(need(nrow(df) > 0, "Loading..."))
  
  bench <- df %>% 
    filter(role == "Bench") %>%
    select(Pos = position, Player = player_name, Year = season, MVP = mvp_score) %>%
    head(10)
  
  datatable(bench,
            options = list(pageLength = 5, lengthChange = F, searching = F, dom = 'tp', info = F),
            style = "bootstrap", rownames = FALSE
  ) %>% 
    formatStyle(names(bench), backgroundColor = '#272B30', color = '#ECF0F1', border = '1px solid #34495E') %>%
    formatStyle("MVP", color = "#F1C40F", fontWeight = "bold")
})

# --- 4. RADAR CHART ---
output$dream_radar <- renderPlotly({
  df <- dream_data()
  validate(need(nrow(df) > 0, "No data."))
  
  # Calculate Avgs
  s_avg <- df %>% filter(role == "Starter") %>% summarise(p=mean(pts), r=mean(reb), a=mean(ast), e=mean(ts_pct*100))
  b_avg <- df %>% filter(role == "Bench") %>% summarise(p=mean(pts), r=mean(reb), a=mean(ast), e=mean(ts_pct*100))
  
  norm <- function(v, m) { pmin(v/m, 1) }
  
  plot_ly(type = 'scatterpolar', mode = "lines+markers") %>%
    add_trace(
      r = c(norm(s_avg$p, 35), norm(s_avg$r, 15), norm(s_avg$a, 12), norm(s_avg$e, 70), norm(s_avg$p, 35)),
      theta = c("Scoring", "Reb", "Ast", "Eff", "Scoring"),
      name = "Starters", fill = 'toself', fillcolor = 'rgba(241, 196, 15, 0.3)', line = list(color = '#F1C40F')
    ) %>%
    add_trace(
      r = c(norm(b_avg$p, 35), norm(b_avg$r, 15), norm(b_avg$a, 12), norm(b_avg$e, 70), norm(b_avg$p, 35)),
      theta = c("Scoring", "Reb", "Ast", "Eff", "Scoring"),
      name = "Bench", fill = 'toself', fillcolor = 'rgba(127, 140, 141, 0.3)', line = list(color = '#95A5A6')
    ) %>%
    layout(
      polar = list(radialaxis = list(visible = F), bgcolor = "rgba(0,0,0,0)"),
      paper_bgcolor = "rgba(0,0,0,0)", plot_bgcolor = "rgba(0,0,0,0)",
      legend = list(orientation = "h", x=0.5, y=-0.1, font = list(color="white")),
      margin = list(t=10, b=10)
    ) %>% config(displayModeBar = F)
})