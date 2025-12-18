# Project Report: NBA Moneyball DB

**Project Title:** NBA Player Stats – Who’s the Real MVP?
**Author:** Dennis Wambua
**Platform:** AnalystBuilder.com

---

## 1. Executive Summary

**Role:** Data Analyst for a Sports Media Company.

The **NBA Moneyball DB** is an interactive analytical dashboard built to explore the evolution of the NBA from 1996 to 2023. Unlike standard box-score trackers, this tool leverages advanced metrics (True Shooting %, Usage Rate, Net Rating) to uncover trends, visualize the "Scoring Revolution," and algorithmically determine the "Dream Team" lineup based on peak statistical performance.

The project demonstrates proficiency in **R, Shiny, SQL, Data Visualization, and UI/UX Design**.

---

## 2. Technical Architecture

The dashboard is built using a modular architecture to ensure performance and scalability.

* **Language:** R
* **Web Framework:** R Shiny (UI/Server)
* **Database:** SQLite (Data was migrated from CSV to SQL for efficient querying).
* **Visualization Libraries:**
* `Plotly`: For interactive charts (Zoom, Pan, Hover).
* `ggplot2`: For complex statistical layering.
* `DT`: For interactive data tables.


* **Frontend:** HTML/CSS (Custom styling for "Player Cards" and Dark Mode).

---

## 3. Data Source & Preparation

* **Source:** `new_cleaned_nba_seasons.csv`
* **Scope:** NBA Seasons 1996 – 2023.
* **Key Metrics:**
* **Physical:** Age, Height, Weight.
* **Traditional:** Points (PTS), Rebounds (REB), Assists (AST).
* **Advanced:** Net Rating, True Shooting % (TS%), Usage % (USG%).



**Data Transformation (SQL):**
Raw CSV data was converted into a relational SQLite database (`nba_seasons.db`). SQL Window Functions (`ROW_NUMBER`, `RANK`, `LAG`) were utilized extensively to calculate year-over-year improvements and positional rankings.

---

## 4. Dashboard Features & Analysis

### Tab 1: Home (The Landing Page)

* **Objective:** Sets the narrative context and guides the user.
* **Features:**
* Professional "Hero Image" visualization.
* Role-play scenario description ("I am a Data Analyst...").
* Navigation guide explaining the four main analytical modules.



### Tab 2: Era Analysis (Evolution of the Game)

* **Objective:** To answer the question: *"How has the NBA changed over 30 years?"*
* **Key Visualizations:**
* **KPI Cards:** Highlights Peak Scoring Era, Peak Efficiency, and Tallest Era.
* **The Strategic Revolution (Dual-Axis Chart):** A powerful visual comparing Average Points (Line) vs. Shooting Efficiency (Bars).
* *Insight:* Shows that the modern scoring boom is driven by efficiency (TS%), not just volume.


* **Physical Evolution:** Tracks the decline in player weight and the fluctuation in height, signaling the "Small Ball" era.
* **Franchise History:** Interactive line charts tracking specific teams (e.g., LAL, CHI, BOS) over decades.



### Tab 3: Player Performance (Deep Dive)

* **Objective:** Granular analysis of individual players and identifying breakout stars.
* **Key Visualizations:**
* **Player Profile Card:** A custom CSS-styled card showing real-time stats for any searched player.
* **Career Trajectory:** Area chart mapping a player's scoring output over their entire career.
* **Efficiency Elite:** A Scatter Plot plotting **Usage Rate vs. True Shooting %**.
* *Insight:* Identifies players who maintain high efficiency even with a heavy offensive workload.


* **Biggest Breakout Seasons:**
* *Logic:* Used SQL `LAG()` function to calculate the biggest year-over-year PPG jump.
* *Visual:* Bar chart of the top 10 "Most Improved" seasons in history.





###  Tab 4: MVP & Dream Team (The Algorithm)

* **Objective:** To algorithmically select the best 10-man roster (Starters & Bench) based on data, not opinion.
* **The Algorithm:**
* *Formula:* `MVP Score = PTS + REB + AST + Net Rating`.
* *Constraints:* Must select distinct players (using their single best season), enforcing a roster of 2 Guards, 2 Forwards, and 1 Center.


* **Key Visualizations:**
* **Ultimate Team Cards:** A "FIFA/2K-style" UI layout displaying the starters in a 2-2-1 formation.
* **Radar Chart (Spider Plot):** Compares the 5 starters across 5 axes (PTS, REB, AST, Net Rating, Efficiency) to visualize team balance.
* **Bench Table:** A clean list of the 5 backups who made the cut.



###  Tab 5: Demographics (Talent Pipeline)

* **Objective:** Analyzing the geographical and educational origins of NBA talent.
* **Key Visualizations:**
* **Interactive World Map:** A Dark-themed heatmap showing the global density of NBA players.
* **International Trends:** Stacked Area chart showing the growth of non-USA players over the decades.
* **"NBA Factory" Colleges:** Lollipop chart highlighting universities (e.g., Kentucky, Duke) that produce the most pro players.



---

## 5. SQL Implementation Highlights

The dashboard relies heavily on complex SQL queries. Examples include:

1. **Ranking Peaks (Window Functions):**
```sql
ROW_NUMBER() OVER(PARTITION BY player_name ORDER BY mvp_score DESC)

```


*Used to ensure Lebron James only appears once (his best season) in the Dream Team, rather than taking up 3 spots.*
2. **Calculating Improvement (Lag Functions):**
```sql
LAG(pts) OVER (PARTITION BY player_name ORDER BY season)

```


*Used to compare a player's current stats to their previous season to find the "Most Improved."*

---

## 6. Conclusion

The **NBA Moneyball DB** successfully transforms raw sports data into actionable insights. By combining the calculation power of SQL with the interactivity of R Shiny, the dashboard provides a holistic view of the league—from broad historical trends to granular individual metrics.

The analysis confirms that the NBA has evolved into a league defined by **high-efficiency scoring** and **global talent sourcing**, moving away from the purely physical, defensive game of the 1990s.