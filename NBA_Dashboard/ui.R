# ui.R
# Libraries are loaded in global.R

# --- SOURCE UI MODULES ---
source("modules/ui_home.R", local = TRUE)
source("modules/ui_era.R", local = TRUE)
source("modules/ui_player.R", local = TRUE)
source("modules/ui_dream_team.R", local = TRUE)
source("modules/ui_demographics.R", local = TRUE)

navbarPage(
  title = span(
    icon("basketball-ball", style = "color: #E67E22; margin-right: 5px;"),
    strong("NBA MONEYBALL", style = "font-family: 'Impact', sans-serif; letter-spacing: 1px;"),
    "DB"
  ),
  theme = shinytheme("slate"),
  windowTitle = "NBA Dashboard",
  
  # --- GLOBAL CSS ---
  header = tags$head(tags$style(
    HTML("
      /* 1. STICKY NAVBAR (Applies to all tabs) */
      .navbar {
        position: sticky;
        top: 0;
        z-index: 1000;
        width: 100%;
        box-shadow: 0 4px 10px rgba(0,0,0,0.5);
        border: none;
      }
      
      /* 2. GLOBAL FONTS & UTILS */
      body { overflow-x: hidden; } /* Prevent horizontal scroll */
      
      /* 3. SHARED ANIMATIONS (Used in Versus & Dream Team) */
      @keyframes float { 0% { transform: translateY(0px); } 50% { transform: translateY(-15px); } 100% { transform: translateY(0px); } }
      @keyframes shadow-pulse { 0% { transform: scale(1); opacity: 0.5; } 50% { transform: scale(0.8); opacity: 0.2; } 100% { transform: scale(1); opacity: 0.5; } }
      
      .float-left { animation: float 3s infinite ease-in-out; }
      .float-right { animation: float 3.5s infinite ease-in-out; }
      
      /* 4. AVATAR SHADOWS (Used in Player & Versus) */
      .avatar-shadow { width: 60px; height: 10px; background: rgba(0,0,0,0.5); border-radius: 50%; margin: 0 auto; animation: shadow-pulse 2s infinite; }
      ")
  )),
  
  # --- ASSEMBLE TABS ---
  ui_home,
  ui_era,
  ui_player,
  ui_dream_team,
  ui_demographics
)