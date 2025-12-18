# modules/ui_home.R

ui_home <- tabPanel(
  "Home",
  icon = icon("home"),
  
  # --- CUSTOM CSS ---
  tags$style(
    HTML(
      "
    /* 1. HERO SECTION */
    .hero-banner {
      position: relative;
      background: linear-gradient(rgba(0,0,0,0.7), rgba(0,0,0,0.9)), url('nba_all.webp');
      background-size: cover;
      background-position: center;
      height: 400px;
      border-radius: 0 0 20px 20px;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      text-align: center;
      box-shadow: 0 10px 30px rgba(0,0,0,0.5);
      margin-bottom: 40px;
    }

    .hero-title {
      font-family: 'Impact', sans-serif;
      font-size: 64px;
      color: white;
      text-transform: uppercase;
      letter-spacing: 4px;
      text-shadow: 0 5px 15px rgba(0,0,0,0.8);
      margin: 0;
      line-height: 1;
    }

    .hero-subtitle {
      font-family: 'Roboto', sans-serif;
      font-size: 18px;
      color: #F1C40F;
      font-weight: 300;
      margin-top: 10px;
      letter-spacing: 1px;
    }

    .hero-btn {
      margin-top: 25px;
      padding: 10px 30px;
      background: #E67E22;
      color: white;
      font-weight: bold;
      border-radius: 30px;
      text-decoration: none;
      transition: all 0.3s;
      border: 2px solid #E67E22;
    }
    .hero-btn:hover {
      background: transparent;
      color: #E67E22;
      transform: scale(1.05);
    }

    /* 2. CREATOR BADGE */
    .creator-badge {
      margin-top: 20px;
      background: rgba(255,255,255,0.1);
      padding: 5px 15px;
      border-radius: 20px;
      font-size: 12px;
      color: #BDC3C7;
      backdrop-filter: blur(5px);
    }

    /* 3. FEATURE CARDS */
    .feature-card {
      background: #272B30;
      padding: 30px;
      border-radius: 15px;
      text-align: center;
      border-top: 4px solid #34495E;
      transition: transform 0.3s, border-color 0.3s;
      height: 250px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.3);
    }
    .feature-card:hover {
      transform: translateY(-10px);
    }
    .feature-card:hover.card-era { border-color: #3498DB; }
    .feature-card:hover.card-vs { border-color: #E74C3C; }
    .feature-card:hover.card-mvp { border-color: #F1C40F; }

    .feat-icon { font-size: 40px; margin-bottom: 20px; color: #ECF0F1; }
    .feat-title { font-weight: bold; font-size: 18px; color: white; margin-bottom: 10px; text-transform: uppercase; }
    .feat-desc { font-size: 14px; color: #95A5A6; line-height: 1.5; }
  "
    )
  ),
  
  # --- HERO BANNER ---
  fluidRow(column(
    12, style = "padding: 0;", div(
      class = "hero-banner",
      h1("NBA MONEYBALL DB", class = "hero-title"),
      p("UNCOVERING GREATNESS THROUGH DATA", class = "hero-subtitle"),
      
      div(
        class = "creator-badge",
        "Created by Dennis Wambua | Solution for AnalystBuilder.com"
      )
    )
  )),
  
  # --- FEATURES GRID ---
  fluidRow(
    # Feature 1: Era Analysis
    column(4, div(
      class = "feature-card card-era",
      icon("history", class = "feat-icon", style = "color: #3498DB;"),
      h3("ERA ANALYSIS", class = "feat-title"),
      p(
        "Track the evolution of the game. See how the 3-point revolution changed scoring, height trends, and efficiency from the 90s to today.",
        class = "feat-desc"
      )
    )),
    
    # Feature 2: Versus Arena
    column(4, div(
      class = "feature-card card-vs",
      icon("fist-raised", class = "feat-icon", style = "color: #E74C3C;"),
      h3("VERSUS ARENA", class = "feat-title"),
      p(
        "Head-to-head combat. Select any two players in history and compare their 'Skill DNA' and peak stats in a video-game style matchup.",
        class = "feat-desc"
      )
    )),
    
    # Feature 3: Dream Team
    column(4, div(
      class = "feature-card card-mvp",
      icon("trophy", class = "feat-icon", style = "color: #F1C40F;"),
      h3("MVP & DREAM TEAM", class = "feat-title"),
      p(
        "Who is the GOAT? view our algorithmically selected 'All-Time Starting V' and see which players statistically dominated their positions.",
        class = "feat-desc"
      )
    ))
  ),
  
  br(),
  br(),
  
  # --- FOOTER ---
  fluidRow(column(
    12,
    align = "center",
    p(
      style = "color: #7F8C8D; font-size: 12px;",
      "Data Source: NBA Player Stats Dataset | Built with R Shiny & Plotly"
    )
  )),
  br()
)