# modules/server_demographics.R

# --- 1. REACTIVE DATA (Robust) ---
demo_data <- reactive({
  # Fetch all data once
  df <- get_data("SELECT * FROM nba_seasons")
  
  if (is.null(df) || nrow(df) == 0)
    return(NULL)
  
  # Filter by Season Slider
  start_year <- input$demo_season_range[1]
  end_year <- input$demo_season_range[2]
  
  # Handle Year Logic
  df$year_numeric <- as.numeric(substr(df$season, 1, 4))
  df <- df %>% filter(year_numeric >= start_year &
                        year_numeric <= end_year)
  
  # Standardize Country Column
  # (Some datasets might have NULL countries for USA, assume USA if missing or "USA")
  if (!"country" %in% names(df))
    df$country <- "USA" # Fallback
  df$country[is.na(df$country) | df$country == ""] <- "USA"
  
  return(df)
})

# --- 2. KPI CALCULATIONS ---
output$total_countries <- renderText({
  df <- demo_data()
  if (is.null(df))
    return("0")
  length(unique(df$country))
})

output$intl_pct <- renderText({
  df <- demo_data()
  if (is.null(df))
    return("0%")
  
  # Count Unique Players (not just rows)
  unique_players <- df %>% select(player_name, country) %>% distinct()
  
  total <- nrow(unique_players)
  intl <- sum(unique_players$country != "USA")
  
  paste0(round((intl / total) * 100, 1), "%")
})

output$top_country <- renderText({
  df <- demo_data()
  if (is.null(df))
    return("N/A")
  
  # Find most common country besides USA
  top <- df %>%
    filter(country != "USA") %>%
    group_by(country) %>%
    summarise(count = n_distinct(player_name)) %>%
    arrange(desc(count)) %>%
    head(1)
  
  if (nrow(top) == 0)
    return("None")
  return(top$country)
})

# --- 3. WORLD MAP (Plotly Choropleth) ---
output$plot_world_map <- renderPlotly({
  df <- demo_data()
  validate(need(nrow(df) > 0, "No data."))
  
  # Aggregate by Country
  map_data <- df %>%
    group_by(country) %>%
    summarise(count = n_distinct(player_name))
  
  # Plotly Map
  plot_ly(
    map_data,
    type = 'choropleth',
    locationmode = 'country names',
    locations =  ~ country,
    z =  ~ count,
    colorscale = "Viridis",
    marker = list(line = list(color = "rgba(0,0,0,0.5)", width = 1))
  ) %>%
    layout(
      geo = list(
        bgcolor = "rgba(0,0,0,0)",
        paper_bgcolor = "rgba(0,0,0,0)",
        showframe = FALSE,
        showcoastlines = TRUE,
        projection = list(type = 'natural earth'),
        lakecolor = "#272B30",
        landcolor = "#34495E",
        showocean = TRUE,
        oceancolor = "#1C1E22"
      ),
      paper_bgcolor = "rgba(0,0,0,0)",
      margin = list(
        l = 0,
        r = 0,
        t = 0,
        b = 0
      )
    ) %>% config(displayModeBar = FALSE)
})

# --- 4. TOP COLLEGES CHART ---
output$plot_colleges <- renderPlotly({
  df <- demo_data()
  validate(need(nrow(df) > 0, "No data."))
  
  # Filter & Count
  colleges <- df %>%
    filter(!is.na(college) & college != "" & college != "None") %>%
    group_by(college) %>%
    summarise(count = n_distinct(player_name)) %>%
    arrange(desc(count)) %>%
    head(10)
  
  plot_ly(
    colleges,
    x = ~ count,
    y = ~ reorder(college, count),
    type = 'bar',
    orientation = 'h',
    marker = list(
      color = '#F1C40F',
      line = list(color = 'white', width = 1)
    )
  ) %>%
    layout(
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor = "rgba(0,0,0,0)",
      xaxis = list(
        title = "",
        color = "#BDC3C7",
        showgrid = TRUE,
        gridcolor = "#34495E"
      ),
      yaxis = list(title = "", color = "white"),
      margin = list(t = 10, b = 10, l = 100) # Left margin for long college names
    ) %>% config(displayModeBar = FALSE)
})

# --- 5. INTERNATIONAL TREND CHART ---
output$plot_intl_trend <- renderPlotly({
  df <- demo_data()
  validate(need(nrow(df) > 0, "No data."))
  
  # Group by Season -> Calculate % Non-USA
  trend <- df %>%
    group_by(season) %>%
    summarise(
      total_players = n_distinct(player_name),
      intl_players = n_distinct(player_name[country != "USA"]),
      pct = (intl_players / total_players) * 100
    )
  
  plot_ly(
    trend,
    x = ~ season,
    y = ~ pct,
    type = 'scatter',
    mode = 'lines+markers',
    line = list(color = '#3498DB', width = 3),
    marker = list(
      color = '#2C3E50',
      size = 6,
      line = list(color = '#3498DB', width = 2)
    ),
    fill = 'tozeroy',
    fillcolor = 'rgba(52, 152, 219, 0.1)'
  ) %>%
    layout(
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor = "rgba(0,0,0,0)",
      xaxis = list(
        title = "",
        color = "#BDC3C7",
        tickangle = 45
      ),
      yaxis = list(
        title = "% International Players",
        color = "#BDC3C7",
        gridcolor = "#34495E"
      ),
      margin = list(t = 20, b = 40)
    ) %>% config(displayModeBar = FALSE)
})