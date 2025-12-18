# modules/ui_dream_team.R

ui_dream_team <- tabPanel(
  "MVP & Dream Team",
  icon = icon("trophy"),
  
  # --- GLASSMORPHISM CSS ---
  tags$style(
    HTML(
      "
    /* 1. CONTAINER LAYOUT */
    .lineup-container {
      display: flex;
      justify-content: center;
      gap: 15px;
      margin-bottom: 30px;
      flex-wrap: wrap;
    }

    /* 2. PLAYER CARD (Glass Style) */
    .starter-card {
      width: 220px; /* Fixed width for uniformity */
      background: rgba(30, 30, 30, 0.6);
      backdrop-filter: blur(10px);
      border: 1px solid rgba(255, 255, 255, 0.1);
      border-top: 3px solid #F1C40F; /* Gold Top Border */
      border-radius: 12px;
      padding: 15px;
      text-align: center;
      box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
      transition: transform 0.3s ease, box-shadow 0.3s ease;
      position: relative;
      overflow: hidden;
    }
    .starter-card:hover {
      transform: translateY(-10px);
      box-shadow: 0 15px 40px rgba(241, 196, 15, 0.2);
      border-color: #F1C40F;
    }

    /* 3. CARD CONTENT */
    .sc-pos {
      font-size: 10px; font-weight: bold; letter-spacing: 2px; color: #7F8C8D; margin-bottom: 5px; text-transform: uppercase;
    }
    .sc-img-box {
      height: 100px; display: flex; align-items: center; justify-content: center; margin-bottom: 10px;
    }
    .sc-img-box img {
      max-height: 100%; filter: drop-shadow(0 5px 5px rgba(0,0,0,0.5));
    }
    .sc-name {
      font-family: 'Impact'; font-size: 18px; color: #ECF0F1; margin: 0; letter-spacing: 0.5px; line-height: 1.1;
    }
    .sc-year {
      font-size: 11px; color: #BDC3C7; margin-bottom: 10px;
    }

    /* 4. MVP BADGE */
    .sc-mvp-badge {
      background: linear-gradient(45deg, #F1C40F, #D35400);
      color: white; font-weight: bold; font-size: 12px;
      padding: 4px 10px; border-radius: 15px;
      display: inline-block;
      box-shadow: 0 2px 5px rgba(0,0,0,0.3);
      margin-bottom: 10px;
    }

    /* 5. MINI STATS GRID */
    .sc-stats {
      display: flex; justify-content: space-between;
      border-top: 1px solid rgba(255,255,255,0.1);
      padding-top: 10px;
    }
    .sc-stat-item { text-align: center; width: 33%; }
    .sc-val { display: block; font-weight: bold; font-size: 13px; color: #fff; }
    .sc-lbl { font-size: 8px; color: #7F8C8D; }

    /* 6. BOTTOM SECTIONS */
    .bench-panel {
      background: #272B30; padding: 20px; border-radius: 10px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.3); height: 100%;
    }
  "
    )
  ),
  
  # --- HEADER ---
  fluidRow(div(
    style = "text-align: center; margin-bottom: 30px;",
    h1("ALL-TIME STARTING V", style = "font-family: 'Impact'; color: white; letter-spacing: 3px; text-shadow: 0 0 10px rgba(255,255,255,0.3); margin-bottom: 5px;"),
    p("THE ABSOLUTE PEAK SEASONS IN NBA HISTORY", style =
        "color: #F1C40F; font-size: 10px; letter-spacing: 2px; font-weight: bold;")
  )),
  
  # --- TOP ROW: THE STARTING 5 CARDS ---
  uiOutput("dream_starters_row"),
  
  br(),
  
  # --- BOTTOM ROW: BENCH & RADAR ---
  fluidRow(
    # Left: The Bench Table
    column(7, div(
      class = "bench-panel",
      h4("THE DEEP ROTATION (BENCH)", style =
           "color: #BDC3C7; margin-top: 0; font-size: 14px; letter-spacing: 1px; border-bottom: 1px solid #34495E; padding-bottom: 10px; margin-bottom: 15px;"),
      DTOutput("table_bench")
    )),
    
    # Right: Team DNA Radar
    column(
      5,
      div(
        class = "bench-panel",
        style = "text-align: center;",
        h4("STARTERS VS BENCH DNA", style =
             "color: #BDC3C7; margin-top: 0; font-size: 14px; letter-spacing: 1px; margin-bottom: 10px;"),
        plotlyOutput("dream_radar", height = "350px")
      )
    )
  )
)