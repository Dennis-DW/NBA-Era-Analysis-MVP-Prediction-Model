# modules/ui_era.R

ui_era <- tabPanel("Era Analysis", icon = icon("history"),
                   
                   # --- 1. CONTROLS & KPI ROW ---
                   fluidRow(
                     column(4, 
                            div(style = "background-color: #272B30; padding: 20px; border-radius: 10px; height: 120px; display: flex; align-items: center; box-shadow: 0 4px 15px rgba(0,0,0,0.3);",
                                sliderInput("era_season_range", "Filter History (Seasons):", 
                                            min = 1996, max = 2023, value = c(1996, 2023), 
                                            sep = "", step = 1, width = "100%")
                            )
                     ),
                     column(8, uiOutput("era_kpis"))
                   ),
                   
                   br(),
                   
                   # --- 2. ROW 1: CHARTS ---
                   fluidRow(
                     column(6, 
                            div(style = "background-color: #272B30; padding: 15px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.3);",
                                h4("The Efficiency Revolution", style = "color: #BDC3C7; margin-top: 0; font-size: 14px; text-transform: uppercase; letter-spacing: 1px;"),
                                plotlyOutput("plot_scoring_trend", height = "300px")
                            )
                     ),
                     column(6, 
                            div(style = "background-color: #272B30; padding: 15px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.3);",
                                h4("Physical Evolution", style = "color: #BDC3C7; margin-top: 0; font-size: 14px; text-transform: uppercase; letter-spacing: 1px;"),
                                plotOutput("plot_eras", height = "300px")
                            )
                     )
                   ),
                   
                   br(),
                   
                   # --- 3. ROW 2: TEAMS & ROOKIES ---
                   fluidRow(
                     column(6, 
                            div(style = "background-color: #272B30; padding: 15px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.3);",
                                fluidRow(
                                  column(8, h4("Franchise Histories", style = "color: #BDC3C7; margin-top: 0; font-size: 14px; text-transform: uppercase; letter-spacing: 1px;")),
                                  column(4, selectInput("team_selector", NULL, choices = NULL, multiple = TRUE, selectize = TRUE, width = "100%"))
                                ),
                                plotlyOutput("plot_team_trends", height = "300px")
                            )
                     ),
                     column(6, 
                            div(style = "background-color: #272B30; padding: 15px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.3); height: 380px; overflow-y: auto;",
                                h4("Top Rookies", style = "color: #BDC3C7; margin-top: 0; font-size: 14px; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 15px;"),
                                DTOutput("table_rookies")
                            )
                     )
                   ),
                   
                   br(),
                   
                   # --- 4. NEW ROW: HALL OF RECORDS ---
                   fluidRow(
                     # SCORING LEADERS
                     column(6,
                            div(style = "background: linear-gradient(145deg, #2C3E50, #000000); padding: 15px; border-radius: 10px; border-left: 4px solid #E74C3C; box-shadow: 0 5px 15px rgba(0,0,0,0.5);",
                                fluidRow(
                                  column(7, h3("SCORING KINGS", style="color: #E74C3C; font-family: 'Impact'; letter-spacing: 1px; margin-top: 0;")),
                                  column(5, selectInput("leaders_season", NULL, choices = NULL, width = "100%"))
                                ),
                                DTOutput("table_scoring_leaders")
                            )
                     ),
                     
                     # BREAKOUT SEASONS
                     column(6,
                            div(style = "background: linear-gradient(145deg, #2C3E50, #000000); padding: 15px; border-radius: 10px; border-left: 4px solid #F1C40F; box-shadow: 0 5px 15px rgba(0,0,0,0.5);",
                                h3("BIGGEST BREAKOUTS", style="color: #F1C40F; font-family: 'Impact'; letter-spacing: 1px; margin-top: 0; margin-bottom: 20px;"),
                                DTOutput("table_breakouts")
                            )
                     )
                   )
)