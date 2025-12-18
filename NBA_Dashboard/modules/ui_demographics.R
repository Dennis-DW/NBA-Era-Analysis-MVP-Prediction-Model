# modules/ui_demographics.R

ui_demographics <- tabPanel(
  "Demographics",
  icon = icon("globe-americas"),
  
  # --- CUSTOM CSS ---
  tags$style(
    HTML(
      "
    /* 1. DEMO CARDS (KPIs) */
    .demo-card {
      background: linear-gradient(135deg, #2C3E50, #000000);
      border-left: 4px solid #3498DB;
      padding: 15px; border-radius: 10px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.3);
      display: flex; align-items: center; justify-content: space-between;
    }
    .demo-val { font-family: 'Impact'; font-size: 24px; color: white; }
    .demo-lbl { font-size: 10px; text-transform: uppercase; color: #BDC3C7; }
    .demo-icon { font-size: 24px; color: #3498DB; opacity: 0.5; }

    /* 2. CHART CONTAINERS */
    .map-box {
      background: #272B30; padding: 15px; border-radius: 10px;
      height: 450px; /* Big map */
      box-shadow: 0 5px 15px rgba(0,0,0,0.3); border: 1px solid #34495E;
    }
    .trend-box {
      background: #272B30; padding: 15px; border-radius: 10px;
      height: 350px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.3); border: 1px solid #34495E;
    }

    /* 3. CONTROL PANEL */
    .control-panel {
      background: rgba(255, 255, 255, 0.05);
      padding: 15px; border-radius: 10px;
      margin-bottom: 20px; border: 1px solid #34495E;
    }
  "
    )
  ),
  
  # --- HEADER & CONTROLS ---
  fluidRow(
    column(3, div(
      class = "control-panel",
      h4("FILTER ERA", style = "color: #F1C40F; font-size: 12px; font-weight: bold; margin-top: 0;"),
      sliderInput(
        "demo_season_range",
        NULL,
        min = 1996,
        max = 2023,
        value = c(2000, 2023),
        sep = "",
        step = 1,
        width = "100%"
      ),
      p("Adjust range to see the globalization of the league.", style =
          "color: #7F8C8D; font-size: 10px; margin: 0;")
    )),
    
    # KPI CARDS
    column(3, div(
      class = "demo-card", div(
        div(class = "demo-val", textOutput("total_countries")),
        div(class = "demo-lbl", "COUNTRIES REPRESENTED")
      ), icon("flag", class = "demo-icon")
    )),
    column(
      3,
      div(
        class = "demo-card",
        style = "border-color: #2ECC71;",
        div(
          div(class = "demo-val", textOutput("intl_pct")),
          div(class = "demo-lbl", "% INTERNATIONAL PLAYERS")
        ),
        icon("globe", class = "demo-icon", style = "color: #2ECC71;")
      )
    ),
    column(
      3,
      div(
        class = "demo-card",
        style = "border-color: #E74C3C;",
        div(
          div(class = "demo-val", textOutput("top_country")),
          div(class = "demo-lbl", "TOP NON-US NATION")
        ),
        icon("trophy", class = "demo-icon", style = "color: #E74C3C;")
      )
    )
  ),
  
  # --- MAIN CONTENT ---
  fluidRow(
    # WORLD MAP
    column(8, div(
      class = "map-box",
      h4("GLOBAL PLAYER ORIGIN MAP", style = "color: #BDC3C7; font-size: 12px; letter-spacing: 2px; margin-top: 0;"),
      plotlyOutput("plot_world_map", height = "400px")
    )),
    
    # TOP COLLEGES BAR CHART
    column(4, div(
      class = "map-box",
      # Reuse style
      h4("TOP COLLEGES (NCAA FEEDERS)", style = "color: #BDC3C7; font-size: 12px; letter-spacing: 2px; margin-top: 0;"),
      plotlyOutput("plot_colleges", height = "400px")
    ))
  ),
  
  br(),
  
  # --- TREND ROW ---
  fluidRow(column(
    12, div(
      class = "trend-box",
      h4("THE INTERNATIONAL TAKEOVER TREND", style = "color: #BDC3C7; font-size: 12px; letter-spacing: 2px; margin-top: 0; text-align: center;"),
      plotlyOutput("plot_intl_trend", height = "300px")
    )
  ))
)