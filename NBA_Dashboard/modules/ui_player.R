# modules/ui_player.R

ui_player <- tabPanel("Player Performance & Arena", icon = icon("user-ninja"),
                      
                      # --- MERGED CSS (Player + Versus) ---
                      tags$style(HTML("
    /* --- 1. GLOBAL UTILS --- */
    .section-divider {
      border-top: 1px solid rgba(255,255,255,0.1);
      margin: 40px 0 30px 0;
      text-align: center;
      position: relative;
    }
    .section-divider span {
      background: #272B30;
      padding: 0 15px;
      color: #E67E22;
      font-family: 'Impact';
      font-size: 24px;
      letter-spacing: 2px;
      position: relative;
      top: -14px;
    }

    /* --- 2. PLAYER SCOUTING CSS --- */
    .hero-card {
      background: linear-gradient(135deg, #2C3E50, #000000);
      border-bottom: 3px solid #E74C3C;
      padding: 15px 20px;
      border-radius: 0 0 20px 20px;
      box-shadow: 0 10px 20px rgba(0,0,0,0.5);
      margin-bottom: 25px;
      display: flex; align-items: center; justify-content: center;
      height: 200px;
    }
    .stat-ring { 
      background: rgba(255,255,255,0.05); border-radius: 50%; width: 65px; height: 65px;
      margin: 0 6px; display: inline-flex; flex-direction: column; justify-content: center; align-items: center;
      border: 2px solid #3498DB; box-shadow: 0 0 10px rgba(52, 152, 219, 0.3); transition: transform 0.3s ease; vertical-align: top;
    }
    .stat-ring:hover { transform: scale(1.1); }
    .stat-ring-val { font-size: 14px; font-weight: bold; color: white; font-family: 'Impact'; }
    .stat-ring-label { font-size: 8px; text-transform: uppercase; color: #BDC3C7; margin-top: 2px; }
    .rings-container { display: flex; justify-content: flex-end; align-items: center; margin-top: 15px; }
    .chart-box { background: #272B30; padding: 15px; border-radius: 10px; height: 400px; box-shadow: 0 5px 15px rgba(0,0,0,0.3); border: 1px solid #34495E; }
    
    /* Filter Buttons (Scouting) */
    .shiny-options-group { display: flex; gap: 5px; margin-top: 10px; }
    .radio-btn-custom .radio-inline { padding: 0; margin: 0; }
    .radio-btn-custom input[type='radio'] { display: none; }
    .radio-btn-custom span { background: rgba(255,255,255,0.1); border: 1px solid #7F8C8D; color: #BDC3C7; font-size: 10px; padding: 4px 12px; border-radius: 12px; cursor: pointer; display: inline-block; transition: all 0.2s; letter-spacing: 1px; }
    .radio-btn-custom input[type='radio']:checked + span { background: #E74C3C; color: white; border-color: #E74C3C; font-weight: bold; box-shadow: 0 0 8px rgba(231, 76, 60, 0.5); }

    /* --- 3. VERSUS ARENA CSS --- */
    .p1-box { background: linear-gradient(145deg, rgba(231, 76, 60, 0.1), rgba(0, 0, 0, 0.8)); border: 1px solid rgba(231, 76, 60, 0.5); box-shadow: 0 0 20px rgba(231, 76, 60, 0.2); border-radius: 15px; padding: 15px; text-align: center; height: 580px; }
    .p2-box { background: linear-gradient(145deg, rgba(52, 152, 219, 0.1), rgba(0, 0, 0, 0.8)); border: 1px solid rgba(52, 152, 219, 0.5); box-shadow: 0 0 20px rgba(52, 152, 219, 0.2); border-radius: 15px; padding: 15px; text-align: center; height: 580px; }
    .center-hud { background: rgba(0, 0, 0, 0.6); backdrop-filter: blur(10px); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 15px; padding: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); height: auto; min-height: 450px; }
    .vs-badge { font-family: 'Impact', sans-serif; font-size: 48px; background: -webkit-linear-gradient(#F1C40F, #E67E22); -webkit-background-clip: text; -webkit-text-fill-color: transparent; filter: drop-shadow(0 0 10px rgba(241, 196, 15, 0.8)); margin: 0; line-height: 1; }
    .vs-row { display: flex; justify-content: space-between; align-items: center; background: rgba(255, 255, 255, 0.05); border-bottom: 1px solid rgba(255, 255, 255, 0.05); padding: 6px 10px; margin-bottom: 4px; border-radius: 4px; min-height: 30px; }
    .vs-row:hover { background: rgba(255, 255, 255, 0.1); }
    .vs-label { font-family: 'Roboto Mono', monospace; font-size: 10px; color: #95A5A6; text-transform: uppercase; letter-spacing: 1px; flex: 1; text-align: center; }
    .vs-cell-left { font-family: 'Impact'; font-size: 16px; width: 30%; text-align: left; color: #E74C3C; text-shadow: 0 0 5px rgba(231, 76, 60, 0.3); }
    .vs-cell-right { font-family: 'Impact'; font-size: 16px; width: 30%; text-align: right; color: #3498DB; text-shadow: 0 0 5px rgba(52, 152, 219, 0.3); }
    
    /* --- FIX: VERSUS BUTTONS (Compact & Wrapping) --- */
    .vs-radio-group .shiny-options-group { 
       display: flex; 
       flex-wrap: wrap;       /* Allow wrapping if too wide */
       justify-content: center; 
       gap: 5px; 
       margin-bottom: 10px; 
    }
    .vs-radio-group .radio-inline { margin: 0 !important; padding: 0 !important; }
    .vs-radio-group input[type='radio'] { display: none; } /* Hide the blue dot */
    
    .vs-radio-group span { 
       background: rgba(0,0,0,0.3); 
       border: 1px solid #34495E; 
       padding: 3px 8px;      /* Smaller padding */
       border-radius: 15px; 
       font-size: 9px;        /* Smaller font */
       color: #BDC3C7; 
       text-transform: uppercase; 
       cursor: pointer; 
       display: inline-block; 
       white-space: nowrap;
    }
    .vs-radio-group span:hover { border-color: white; color: white; }
    .vs-radio-group input[type='radio']:checked + span { 
       background: #F1C40F; 
       color: #1C1E22; 
       font-weight: bold; 
       border-color: #F1C40F; 
       box-shadow: 0 0 8px rgba(241, 196, 15, 0.5); 
    }
  ")),
                      
                      # =========================================
                      # SECTION 1: PLAYER SCOUTING REPORT
                      # =========================================
                      fluidRow(
                        div(class = "hero-card",
                            column(4, 
                                   div(style="text-align: left; padding-left: 10px;",
                                       h5("SCOUTING REPORT", style="color: #E74C3C; letter-spacing: 2px; margin: 0 0 5px 0; font-weight: bold; font-size: 14px;"),
                                       selectizeInput("player_search", NULL, choices = NULL, width = "90%"),
                                       div(class = "radio-btn-custom",
                                           radioButtons("player_filter_mode", label = NULL, choices = c("CAREER", "PEAK", "LAST 5"), selected = "CAREER", inline = TRUE)
                                       )
                                   )
                            ),
                            column(4, uiOutput("player_hero_avatar")), 
                            column(4, 
                                   div(style="text-align: right; padding-right: 10px;",
                                       uiOutput("player_badges"), 
                                       div(class="rings-container",
                                           div(class="stat-ring", div(class="stat-ring-val", textOutput("val_ts")), div(class="stat-ring-label", "TS%")),
                                           div(class="stat-ring", style="border-color: #F1C40F;", div(class="stat-ring-val", textOutput("val_usg")), div(class="stat-ring-label", "USG%")),
                                           div(class="stat-ring", style="border-color: #2ECC71;", div(class="stat-ring-val", textOutput("val_ast")), div(class="stat-ring-label", "AST%"))
                                       )
                                   )
                            )       
                        )
                      ),
                      
                      fluidRow(
                        column(5,
                               div(class = "chart-box", style = "text-align: center;",
                                   h4("SKILL DNA", style = "color: #BDC3C7; font-size: 12px; letter-spacing: 2px; opacity: 0.8; margin-bottom: 15px;"),
                                   plotlyOutput("player_radar", height = "350px")
                               )
                        ),
                        column(7,
                               div(class = "chart-box",
                                   h4("CAREER TRAJECTORY", style = "color: #BDC3C7; font-size: 12px; letter-spacing: 2px; text-align: center; opacity: 0.8; margin-bottom: 15px;"),
                                   plotlyOutput("plot_career_curve", height = "350px")
                               )
                        )
                      ),
                      
                      # =========================================
                      # DIVIDER
                      # =========================================
                      div(class = "section-divider", span("VERSUS ARENA")),
                      
                      # =========================================
                      # SECTION 2: VERSUS ARENA
                      # =========================================
                      fluidRow(
                        # PLAYER 1 (LEFT)
                        column(3, 
                               div(class = "p1-box",
                                   h3("CHALLENGER 1", style = "color: #E74C3C; font-family: 'Impact'; letter-spacing: 2px; margin-top: 0; font-size: 18px;"),
                                   
                                   # Added class 'vs-radio-group' for targeted CSS fix
                                   div(class="vs-radio-group", 
                                       radioButtons("p1_pos_filter", NULL, choices = c("All", "Guard", "Forward", "Center"), inline = TRUE, selected = "All")
                                   ),
                                   
                                   selectizeInput("p1_search", NULL, choices = NULL),
                                   div(style = "margin-top: 20px; position: relative;", uiOutput("p1_avatar"))
                               )
                        ),
                        
                        # CENTER HUD
                        column(6, 
                               div(style = "text-align: center; margin-bottom: 5px;",
                                   h1("VS", class = "vs-badge"),
                                   p("HEAD-TO-HEAD", style = "color: #95A5A6; font-size: 9px; letter-spacing: 3px; font-weight: bold; margin-top: 2px;")
                               ),
                               div(class = "center-hud",
                                   div(style = "position: relative; margin-bottom: 10px;",
                                       h4("SKILL MATRIX", style = "color: #BDC3C7; font-size: 9px; letter-spacing: 2px; margin: 0; opacity: 0.6;"),
                                       plotlyOutput("versus_radar", height = "180px") 
                                   ),
                                   hr(style = "border: 0; height: 1px; background-image: linear-gradient(to right, rgba(0, 0, 0, 0), rgba(241, 196, 15, 0.5), rgba(0, 0, 0, 0)); margin: 10px 0;"),
                                   h4("TALE OF THE TAPE", style = "color: #ECF0F1; font-size: 9px; letter-spacing: 2px; margin: 0 0 5px 0; opacity: 0.6;"),
                                   uiOutput("versus_table")
                               )
                        ),
                        
                        # PLAYER 2 (RIGHT)
                        column(3, 
                               div(class = "p2-box",
                                   h3("CHALLENGER 2", style = "color: #3498DB; font-family: 'Impact'; letter-spacing: 2px; margin-top: 0; font-size: 18px;"),
                                   
                                   # Added class 'vs-radio-group' for targeted CSS fix
                                   div(class="vs-radio-group", 
                                       radioButtons("p2_pos_filter", NULL, choices = c("All", "Guard", "Forward", "Center"), inline = TRUE, selected = "All")
                                   ),
                                   
                                   selectizeInput("p2_search", NULL, choices = NULL),
                                   div(style = "margin-top: 20px; position: relative;", uiOutput("p2_avatar"))
                               )
                        )
                      ),
                      br(), br()
)