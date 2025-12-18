# 1. Load Libraries (Make sure these are all run!)
library(shiny)
library(shinydashboard)
library(tidyverse)
library(DT)
library(DBI)
library(RSQLite)

# 2. Connect to the Database
# Ensure 'nba_db.db' is in the same folder as this app.R file
con <- dbConnect(RSQLite::SQLite(), "nba_db")
nba_data <- dbReadTable(con, "nba_seasons")
dbDisconnect(con)

# 3. Quick Data Prep
nba_data <- nba_data %>%
  mutate(
    season_start = as.numeric(substr(season, 1, 4))
  )

# --- PART A: THE UI ---
ui <- dashboardPage(
  skin = "blue",
  
  dashboardHeader(title = "NBA Stat Explorer (SQL)"),
  
  dashboardSidebar(
    selectInput("selected_season", "Select Season:", 
                choices = sort(unique(nba_data$season), decreasing = TRUE), 
                selected = "2022-23"),
    
    selectInput("selected_team", "Select Team:", 
                choices = sort(unique(nba_data$team_abbreviation)), 
                selected = "LAL")
  ),
  
  dashboardBody(
    fluidRow(
      box(title = "Player Efficiency vs. Volume", status = "primary", solidHeader = TRUE, width = 8,
          plotOutput("stat_plot")),
      valueBoxOutput("avg_pts_box", width = 4)
    ),
    fluidRow(
      box(title = "Roster Stats", width = 12, DTOutput("player_table"))
    )
  )
)

# --- PART B: THE SERVER ---
server <- function(input, output) {
  
  # Reactive Data Filter
  filtered_data <- reactive({
    nba_data %>%
      filter(season == input$selected_season,
             team_abbreviation == input$selected_team)
  })
  
  # Plot Output
  output$stat_plot <- renderPlot({
    req(nrow(filtered_data()) > 0)
    ggplot(filtered_data(), aes(x = pts, y = reb)) +
      geom_point(aes(color = player_name), size = 5, alpha = 0.8) +
      geom_text(aes(label = player_name), vjust = -1, size = 3, check_overlap = TRUE) +
      labs(x = "Points", y = "Rebounds", title = paste(input$selected_team, "-", input$selected_season)) +
      theme_minimal() + theme(legend.position = "none")
  })
  
  # Value Box Output
  output$avg_pts_box <- renderValueBox({
    avg <- round(mean(filtered_data()$pts, na.rm = TRUE), 1)
    valueBox(avg, "Team Avg Points", icon = icon("basketball-ball"), color = "orange")
  })
  
  # Table Output
  output$player_table <- renderDT({
    filtered_data() %>%
      select(Player = player_name, PTS = pts, REB = reb, AST = ast, Country = country)
  })
}

# --- PART C: RUN APP ---
shinyApp(ui, server)
