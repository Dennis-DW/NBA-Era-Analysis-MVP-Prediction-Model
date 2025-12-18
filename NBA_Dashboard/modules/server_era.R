# modules/server_era.R

# --- 1. ERA KPI CARDS ---
output$era_kpis <- renderUI({
  df <- get_data(query_era_kpis)
  
  kpi_box <- function(title, value, subtext, icon_name, color) {
    div(
      style = paste0(
        "background: ", color, "; padding: 15px; border-radius: 10px; text-align: center; box-shadow: 0 5px 15px rgba(0,0,0,0.3); color: white; height: 100%;"
      ),
      h3(icon(icon_name), style = "font-size: 28px; margin-top: 5px; opacity: 0.9;"),
      h4(value, style = "font-weight: bold; font-size: 22px; margin: 5px 0;"),
      span(title, style = "font-size: 13px; opacity: 0.8; text-transform: uppercase; letter-spacing: 0.5px;"),
      div(subtext, style = "font-size: 11px; margin-top: 5px; opacity: 0.7; font-style: italic;")
    )
  }
  
  fluidRow(
    column(4, kpi_box("Peak Scoring Era", df$high_score_szn, paste("Avg:", df$max_pts, "PPG"), "fire", "#E74C3C")), 
    column(4, kpi_box("Peak Efficiency", df$efficient_szn, paste("TS%:", df$max_ts, "%"), "bullseye", "#2ECC71")), 
    column(4, kpi_box("Tallest Era", df$tall_szn, paste("Avg:", df$max_ht, "cm"), "ruler-vertical", "#3498DB"))
  )
})

# --- 2. SCORING & EFFICIENCY TREND (Fixed Axis Angle) ---
output$plot_scoring_trend <- renderPlotly({
  df <- get_data(query_scoring_efficiency)
  
  plot_ly(df) %>%
    add_trace(
      x = ~season, y = ~avg_efficiency, type = 'bar', name = 'Efficiency (TS%)',
      yaxis = "y2", marker = list(color = '#3498DB', opacity = 0.3)
    ) %>%
    add_trace(
      x = ~season, y = ~avg_pts, type = 'scatter', mode = 'lines+markers', name = 'Points (PPG)',
      line = list(color = '#E74C3C', width = 3),
      marker = list(size = 6, color = '#E74C3C')
    ) %>%
    layout(
      title = list(text = "<b>The Efficiency Engine:</b> Better Shooting (Bars) = More Points (Line)", font = list(size = 14, color = "#BDC3C7")),
      yaxis = list(title = "Points Per Game (Avg)", showgrid = TRUE, gridcolor = "#34495E"),
      yaxis2 = list(title = "True Shooting %", overlaying = "y", side = "right", showgrid = FALSE, range = c(45, 60)), 
      plot_bgcolor = "#272B30",
      paper_bgcolor = "#272B30",
      font = list(color = "#BDC3C7"),
      margin = list(l=50, r=50, t=50, b=80), # Increased bottom margin for labels
      legend = list(orientation = "h", x = 0.3, y = 1.1),
      xaxis = list(
        showgrid = FALSE, 
        tickangle = -45 # <--- FIXED: Rotates labels 45 degrees
      )
    ) %>%
    config(displayModeBar = FALSE)
})

# --- 3. PHYSICAL EVOLUTION PLOT ---
output$plot_eras <- renderPlot({
  df <- get_data(query_era_analysis)
  
  ggplot(df, aes(x = decade)) +
    geom_col(aes(y = avg_weight), fill = "#34495E", alpha = 0.7) +
    geom_line(aes(y = avg_height * 0.45), color = "#F1C40F", size = 2, group = 1) +
    geom_point(aes(y = avg_height * 0.45), color = "#F1C40F", size = 4) +
    scale_y_continuous(name = "Avg Weight (lbs)", sec.axis = sec_axis(~./0.45, name = "Avg Height (cm)")) +
    labs(x = "") +
    theme_minimal() +
    theme(
      plot.background = element_rect(fill = "#272B30", color = NA),
      panel.background = element_rect(fill = "#272B30", color = NA),
      text = element_text(color = "#ECF0F1"),
      axis.text = element_text(color = "#BDC3C7"),
      panel.grid.major = element_line(color = "#34495E", linetype = "dashed"),
      panel.grid.minor = element_blank()
    )
})

# --- 4. ROOKIE TABLE ---
output$table_rookies <- renderTable({
  get_data(query_rookies_vets)
}, digits = 1, width = "100%", hover = TRUE, bordered = TRUE, striped = TRUE, align = 'c')


# --- 5. FRANCHISE HISTORY CHART (Fixed Axis Angle) ---
output$plot_team_trends <- renderPlotly({
  req(input$team_selector)
  
  df <- get_data(query_team_trends) %>% 
    filter(team %in% input$team_selector)
  
  validate(need(nrow(df) > 0, "Select a team to see their history."))
  
  p <- ggplot(df, aes(x = season, y = avg_pts, group = team, color = team)) +
    geom_line(size = 1.2) + 
    geom_point(size = 2) +
    labs(x = "", y = "Avg Points Per Game", color = "Team") +
    theme_minimal() +
    theme(
      plot.background = element_rect(fill = "#272B30", color = NA),
      panel.background = element_rect(fill = "#272B30", color = NA),
      text = element_text(color = "#ECF0F1"),
      axis.text.y = element_text(color = "#BDC3C7"),
      
      # <--- FIXED: Rotates X labels 45 degrees so they don't overlap
      axis.text.x = element_text(angle = 45, hjust = 1, color = "#BDC3C7", size = 10),
      
      panel.grid.major = element_line(color = "#34495E"),
      legend.position = "bottom"
    )
  
  ggplotly(p) %>% 
    layout(plot_bgcolor = "#272B30", paper_bgcolor = "#272B30") %>% 
    config(displayModeBar = FALSE)
})

# --- 6. POPULATE TEAM SELECTOR ---
observe({
  teams <- get_data("SELECT DISTINCT team_abbreviation FROM nba_seasons ORDER BY team_abbreviation")
  updateSelectInput(session, "team_selector", 
                    choices = teams$team_abbreviation, 
                    selected = c("LAL", "BOS", "CHI", "GSW")) 
})