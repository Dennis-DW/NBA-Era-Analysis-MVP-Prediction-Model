# ui.R
# Libraries are loaded in global.R

navbarPage(
  title = span(
    icon("basketball-ball", style = "color: #E67E22; margin-right: 5px;"),
    strong("NBA MONEYBALL", style = "font-family: 'Impact', sans-serif; letter-spacing: 1px;"),
    "DB"
  ),
  theme = shinytheme("slate"),
  windowTitle = "NBA Dashboard",
  
  # --- CUSTOM CSS ---
  header = tags$head(tags$style(
    HTML(
      "
      /* 1. Player Profile Card */
      .player-card {
        background: linear-gradient(135deg, #2C3E50, #4CA1AF);
        border-radius: 15px; padding: 20px; color: white;
        box-shadow: 0 10px 20px rgba(0,0,0,0.3);
        text-align: center;
      }
      .player-name { font-family: 'Impact', sans-serif; font-size: 28px; margin-bottom: 5px; letter-spacing: 1px; }
      .player-team { font-size: 18px; color: #BDC3C7; margin-bottom: 15px; font-weight: bold; }
      .stat-grid { display: flex; justify-content: space-around; margin-top: 20px; }
      .stat-box { background: rgba(0,0,0,0.3); padding: 10px; border-radius: 8px; width: 30%; }
      .stat-val { font-size: 24px; font-weight: bold; color: #F1C40F; }
      .stat-label { font-size: 12px; color: #ECF0F1; text-transform: uppercase; }

      /* 2. DREAM TEAM CARDS */
      .dream-container { display: flex; flex-direction: column; align-items: center; gap: 15px; padding-top: 10px; }
      .formation-row { display: flex; justify-content: center; gap: 20px; width: 100%; }

      .dream-card {
        width: 160px;
        background: linear-gradient(145deg, #F1C40F, #B7950B);
        border: 2px solid #FFF; border-radius: 10px;
        padding: 10px; text-align: center; color: #1C1E22;
        box-shadow: 0 0 15px rgba(241, 196, 15, 0.4);
        transition: transform 0.2s ease;
      }
      .dream-card:hover { transform: scale(1.05); z-index: 10; box-shadow: 0 0 25px rgba(241, 196, 15, 0.8); }

      .dc-header { display: flex; justify-content: space-between; border-bottom: 2px solid #1C1E22; padding-bottom: 5px; margin-bottom: 5px; font-weight: bold; font-family: 'Impact', sans-serif; }
      .dc-pos { font-size: 18px; }
      .dc-score { font-size: 18px; background: #1C1E22; color: #F1C40F; padding: 0 5px; border-radius: 4px; }

      .dc-name {
        font-family: 'Impact', sans-serif; font-size: 16px; text-transform: uppercase;
        margin-bottom: 5px; line-height: 1.1; white-space: normal; overflow-wrap: break-word;
        min-height: 36px; display: flex; align-items: center; justify-content: center;
      }
      .dc-year { font-size: 12px; font-weight: bold; margin-bottom: 10px; opacity: 0.8; }
      .dc-stats { background: rgba(255,255,255,0.2); border-radius: 5px; padding: 5px; display: flex; justify-content: space-between; font-size: 12px; font-weight: bold; }
      "
    )
  )),
  
  # --- NEW TAB: HOME (UPDATED TEXT) ---
  tabPanel(
    "Home",
    icon = icon("home"),
    fluidRow(
      # HERO IMAGE
      column(
        width = 12,
        align = "center",
        img(src = "nba_all.webp", style = "width: 100%; max-width: 1000px; border-radius: 10px; margin-bottom: 30px; box-shadow: 0 0 25px rgba(0,0,0,0.6);")
      )
    ),
    fluidRow(column(
      width = 8,
      offset = 2,
      div(
        style = "background-color: #272B30; padding: 40px; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.4); text-align: center;",
        
        # --- PROJECT CREDITS ---
        h2("🏀 NBA Moneyball DB", style = "color: #E67E22; font-family: 'Impact', sans-serif; letter-spacing: 1px; font-size: 36px;"),
        h4("Solution to: NBA Player Stats – Who’s the Real MVP?", style = "color: #BDC3C7; margin-top: 5px; font-weight: 300;"),
        h5(
          a(
            "Project by AnalystBuilder.com",
            href = "https://analystbuilder.com",
            target = "_blank",
            style = "color: #3498DB; text-decoration: none;"
          )
        ),
        h3("Created by Dennis Wambua", style = "color: #F1C40F; font-family: 'Impact', sans-serif; letter-spacing: 1px; margin-top: 20px;"),
        
        hr(style = "border-color: #34495E; margin: 30px 0;"),
        
        # MISSION STATEMENT (UPDATED TO 'I AM')
        p(
          style = "font-size: 18px; line-height: 1.6; color: #ECF0F1; text-align: justify;",
          "I am a Data Analyst for a sports media company. I was given a comprehensive dataset covering NBA players across many seasons.
              This data includes age, height, weight, draft position, and advanced metrics like usage rate and shooting efficiency."
        ),
        p(
          style = "font-size: 18px; line-height: 1.6; color: #F1C40F; font-weight: bold; text-align: justify;",
          "My task was to dig into this dataset to uncover trends in player performance, evaluate which metrics really define 'greatness,' and nominate a 'Data MVP' for a given season or all time."
        ),
        
        br(),
        
        # DASHBOARD GUIDE
        h3("📊 How to Use This Dashboard", style = "color: #3498DB; margin-bottom: 25px;"),
        
        fluidRow(column(
          6,
          div(
            style = "margin-bottom: 20px; text-align: left;",
            h4(icon("history"), " Era Analysis", style = "color: #BDC3C7;"),
            p(
              "Explore how the game has evolved. Are players getting taller? Is scoring skyrocketing? Compare how Rookies fare against Veterans.",
              style = "color: #95A5A6;"
            )
          ),
          div(
            style = "margin-bottom: 20px; text-align: left;",
            h4(icon("chart-line"), " Player Performance", style = "color: #BDC3C7;"),
            p(
              "The Deep Dive. Search for any player to see their animated profile card, career history, and discover the 'Most Improved' players in history.",
              style = "color: #95A5A6;"
            )
          )
        ), column(
          6,
          div(
            style = "margin-bottom: 20px; text-align: left;",
            h4(icon("trophy"), " MVP & Dream Team", style = "color: #BDC3C7;"),
            p(
              "The Algorithm's Choice. We use advanced stats to calculate a 'Data MVP' score and build the perfect 10-man roster (Starters & Bench).",
              style = "color: #95A5A6;"
            )
          ),
          div(
            style = "margin-bottom: 20px; text-align: left;",
            h4(icon("globe"), " Demographics", style = "color: #BDC3C7;"),
            p(
              "Talent Origins. See which colleges are 'NBA Factories' and view an interactive map of the league's international expansion.",
              style = "color: #95A5A6;"
            )
          )
        ))
      )
    )),
    br(),
    br()
  ),
  
  # --- TAB 1: ERA ANALYSIS (IMPROVED) ---
  tabPanel(
    "Era Analysis",
    icon = icon("history"),
    
    # 1. HEADLINES (KPIs)
    div(style = "margin-bottom: 25px;", uiOutput("era_kpis")),
    
    # 2. STRATEGIC EVOLUTION (The Scoring Boom)
    fluidRow(column(
      width = 12,
      h3("The Strategic Revolution"),
      p(
        "How efficiency (True Shooting %) became the driving force behind the modern scoring explosion.",
        style = "color: #BDC3C7; font-style: italic; margin-bottom: 15px;"
      ),
      div(style = "background-color: #272B30; padding: 15px; border-radius: 5px; box-shadow: 0 4px 15px rgba(0,0,0,0.3);", plotlyOutput("plot_scoring_trend", height = "400px"))
    )),
    
    br(),
    
    # 3. PHYSICAL EVOLUTION & ROOKIES
    fluidRow(column(
      width = 8,
      h3("Physical Evolution"),
      p("Height (Line) vs Weight (Bars) by Decade.", style = "color: #BDC3C7; font-size: 12px;"),
      div(style = "background-color: #272B30; padding: 15px; border-radius: 5px;", plotOutput("plot_eras", height = "350px"))
    ), column(
      width = 4,
      h3("Rookies vs Veterans"),
      p("Who contributes more immediately?", style = "color: #BDC3C7; font-size: 12px;"),
      div(style = "background-color: #272B30; padding: 15px; border-radius: 5px; height: 350px; display: flex; align-items: center; justify-content: center;", tableOutput("table_rookies"))
    )),
    
    br(),
    
    # 4. TEAM HISTORY (Bottom)
    fluidRow(column(
      width = 12,
      h3("Franchise Histories"),
      div(
        style = "background-color: #272B30; padding: 15px; border-radius: 5px;",
        fluidRow(column(
          width = 4,
          selectInput(
            "team_selector",
            "Select Teams:",
            choices = NULL,
            multiple = TRUE,
            selectize = TRUE
          )
        ), column(
          width = 8,
          p("Compare franchise performance over time.", style = "color: #BDC3C7; margin-top: 25px; font-style: italic;")
        )),
        plotlyOutput("plot_team_trends", height = "400px")
      )
    ))
  ),
  
  # --- TAB 3: MVP & DREAM TEAM ---
  tabPanel(
    "MVP & Dream Team",
    icon = icon("trophy"),
    fluidRow(
      # BENCH (Left)
      column(
        width = 4,
        h3("The Bench"),
        div(style = "background-color: #272B30; padding: 15px; border-radius: 5px;", DTOutput("bench_table"))
      ),
      
      # STARTING LINEUP CARDS (Right)
      column(
        width = 8,
        h3("Starting Lineup", style = "text-align: center;"),
        div(style = "background-color: #272B30; padding: 15px; border-radius: 5px; min-height: 400px;", uiOutput("dream_team_cards"))
      )
    ),
    br(),
    fluidRow(column(
      width = 12,
      h3("Starters Comparison"),
      div(style = "background-color: #272B30; padding: 15px; border-radius: 5px;", plotlyOutput("mvp_comparison_plot", height = "350px"))
    ))
  ),
  # --- TAB 4: DEMOGRAPHICS (UPGRADED) ---
  tabPanel(
    "Demographics",
    icon = icon("globe"),
    
    # 1. KPI ROW (New Statistics Cards)
    div(style = "margin-bottom: 20px;", uiOutput("demo_kpis")),
    
    # 2. MAP ROW
    fluidRow(column(
      width = 12,
      h3("Global Reach"),
      div(style = "background-color: #272B30; padding: 15px; border-radius: 5px; box-shadow: 0 4px 15px rgba(0,0,0,0.3);", plotlyOutput("plot_world_map", height = "450px"))
    )),
    
    br(),
    
    # 3. CHARTS ROW
    fluidRow(
      # Colleges (Lollipop Chart)
      column(
        width = 6,
        h3("Top 'NBA Factory' Colleges"),
        div(style = "background-color: #272B30; padding: 15px; border-radius: 5px; box-shadow: 0 4px 15px rgba(0,0,0,0.3);", plotlyOutput("plot_colleges", height = "400px"))
      ),
      # Trend (Area Chart)
      column(
        width = 6,
        h3("International Expansion Trend"),
        div(style = "background-color: #272B30; padding: 15px; border-radius: 5px; box-shadow: 0 4px 15px rgba(0,0,0,0.3);", plotlyOutput("plot_intl_trend", height = "400px"))
      )
    ),
    br()
  )
)