# modules/server_demographics.R

# --- 1. KPI STATISTICS (NEW) ---
output$demo_kpis <- renderUI({
  df <- get_data(query_demo_kpis)
  
  # Helper for KPI Box
  kpi_box <- function(title, value, icon_name, color) {
    div(style = paste0("background: ", color, "; padding: 15px; border-radius: 10px; text-align: center; box-shadow: 0 5px 15px rgba(0,0,0,0.3); color: white;"),
        h3(icon(icon_name), style = "font-size: 32px; margin-top: 5px;"),
        h4(value, style = "font-weight: bold; font-size: 24px; margin: 5px 0;"),
        span(title, style = "font-size: 14px; opacity: 0.8; text-transform: uppercase;")
    )
  }
  
  fluidRow(
    column(4, kpi_box("Total Players Tracked", format(df$total_players, big.mark=","), "users", "#3498DB")), # Blue
    column(4, kpi_box("Countries Represented", df$total_countries, "globe", "#E74C3C")), # Red
    column(4, kpi_box("Top Int'l Source", df$top_intl_country, "flag", "#F1C40F")) # Gold
  )
})

# --- 2. DARK THEME WORLD MAP ---
output$plot_world_map <- renderPlotly({
  df <- get_data(query_country_map)
  
  plot_geo(df) %>%
    add_trace(
      z = ~player_count,
      color = ~player_count,
      colors = "YlOrRd", # Yellow to Red Heatmap
      text = ~country,
      locations = ~country,
      locationmode = 'country names',
      marker = list(line = list(color = "#272B30", width = 0.5)) # Dark borders
    ) %>%
    colorbar(title = "Players", tickfont = list(color = "#BDC3C7")) %>%
    layout(
      geo = list(
        showframe = FALSE,
        showcoastlines = FALSE,
        projection = list(type = 'natural earth'),
        bgcolor = "#272B30",
        lakecolor = "#272B30",
        landcolor = "#34495E", # Dark Land
        showland = TRUE,
        showlakes = TRUE
      ),
      paper_bgcolor = "#272B30",
      font = list(color = "#ECF0F1"),
      margin = list(l=0, r=0, t=0, b=0)
    )
})

# --- 3. TOP COLLEGES (Lollipop Chart) ---
output$plot_colleges <- renderPlotly({
  df <- get_data(query_top_colleges)
  df$college <- factor(df$college, levels = df$college[order(df$player_count)]) # Sort
  
  p <- ggplot(df, aes(x = college, y = player_count, text = paste("Players:", player_count))) +
    geom_segment(aes(x = college, xend = college, y = 0, yend = player_count), color = "#BDC3C7") + # The Stick
    geom_point(size = 4, color = "#F1C40F") + # The Lollipop Head
    coord_flip() + # Horizontal
    labs(x = "", y = "Number of Players") +
    theme_minimal() +
    theme(
      plot.background = element_rect(fill = "#272B30", color = NA),
      panel.background = element_rect(fill = "#272B30", color = NA),
      text = element_text(color = "#ECF0F1"),
      axis.text = element_text(color = "#BDC3C7"),
      panel.grid.major.y = element_blank(), # Clean Look
      panel.grid.major.x = element_line(color = "#34495E", linetype = "dashed")
    )
  
  ggplotly(p, tooltip = "text") %>% layout(plot_bgcolor = "#272B30", paper_bgcolor = "#272B30") %>% config(displayModeBar = FALSE)
})

# --- 4. INTERNATIONAL TREND (Stacked Area) ---
output$plot_intl_trend <- renderPlotly({
  df <- get_data(query_international_trend)
  df_long <- df %>% pivot_longer(cols = c(usa_players, intl_players), names_to = "Origin", values_to = "Count")
  df_long$Origin <- recode(df_long$Origin, "usa_players" = "USA", "intl_players" = "International")
  
  p <- ggplot(df_long, aes(x = decade, y = Count, fill = Origin, group = Origin)) +
    geom_area(alpha = 0.8) + # Smooth Area
    scale_fill_manual(values = c("#E74C3C", "#34495E")) + 
    labs(x = "", y = "Total Players", fill = "") +
    theme_minimal() +
    theme(
      plot.background = element_rect(fill = "#272B30", color = NA),
      panel.background = element_rect(fill = "#272B30", color = NA),
      text = element_text(color = "#ECF0F1"),
      axis.text = element_text(color = "#BDC3C7"),
      panel.grid = element_blank(),
      legend.position = "bottom"
    )
  
  ggplotly(p) %>% layout(plot_bgcolor = "#272B30", paper_bgcolor = "#272B30") %>% config(displayModeBar = FALSE)
})