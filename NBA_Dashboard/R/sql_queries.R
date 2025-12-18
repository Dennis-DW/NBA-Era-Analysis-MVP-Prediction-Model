# R/sql_queries.R

# 1. Era Analysis (Decade Trends)
query_era_analysis <- "
SELECT 
    CASE 
        WHEN CAST(SUBSTR(season, 1, 4) AS INT) BETWEEN 1990 AND 1999 THEN '1990s'
        WHEN CAST(SUBSTR(season, 1, 4) AS INT) BETWEEN 2000 AND 2009 THEN '2000s'
        WHEN CAST(SUBSTR(season, 1, 4) AS INT) BETWEEN 2010 AND 2019 THEN '2010s'
        ELSE '2020s' 
    END as decade,
    ROUND(AVG(player_height), 2) as avg_height,
    ROUND(AVG(player_weight), 2) as avg_weight,
    ROUND(AVG(pts), 2) as avg_pts
FROM nba_seasons
GROUP BY decade
ORDER BY decade;
"

# 2. Rookies vs Veterans
query_rookies_vets <- "
SELECT 
    CASE 
        WHEN CAST(draft_year AS INT) = CAST(SUBSTR(season, 1, 4) AS INT) THEN 'Rookie'
        ELSE 'Veteran' 
    END as status,
    ROUND(AVG(pts), 1) as avg_pts,
    ROUND(AVG(net_rating), 1) as avg_rating
FROM nba_seasons
WHERE draft_year IS NOT NULL
GROUP BY status;
"

# (Removed old query_dream_team from here to avoid duplicates)

# 4. Rank Season Leaders (Top 3 Scorers per Season)
query_season_leaders <- "
SELECT season, rank_num, player_name, pts, gp as games_played
FROM (
    SELECT season, player_name, pts, gp, 
           RANK() OVER (PARTITION BY season ORDER BY pts DESC) as rank_num
    FROM nba_seasons
    WHERE gp > 20
) as ranked_table
WHERE rank_num <= 3
ORDER BY season DESC, rank_num ASC;
"

# 5. Efficiency Stats (High Usage & High TS%)
query_efficiency <- "
SELECT season, player_name, pts, gp, 
       usg_pct as usage_rate, 
       ts_pct as shooting_efficiency
FROM nba_seasons
WHERE usg_pct > 0.30 AND ts_pct > 0.60 AND gp > 40
ORDER BY ts_pct DESC;
"
# 6. Dream Team (Unique Players Only - Best Season)
query_dream_team <- "
WITH PlayerBestSeasons AS (
    -- 1. Get every player's stats and calculate MVP score
    SELECT 
        player_name, season, pts, reb, ast, net_rating, ts_pct,
        (pts + reb + ast + net_rating) as mvp_score,
        CASE 
            WHEN player_height > 208 THEN 'Center'
            WHEN player_height > 201 THEN 'Forward'
            ELSE 'Guard' 
        END as position,
        -- 2. Rank each player's OWN seasons to find their peak
        ROW_NUMBER() OVER(PARTITION BY player_name ORDER BY (pts + reb + ast + net_rating) DESC) as player_peak_rank
    FROM nba_seasons
    WHERE gp > 40
),
UniquePlayers AS (
    -- 3. Keep only the BEST season for each player (Removes Duplicates)
    SELECT * FROM PlayerBestSeasons WHERE player_peak_rank = 1
),
FinalRoster AS (
    -- 4. Now rank the unique players by position
    SELECT *,
        ROW_NUMBER() OVER(PARTITION BY position ORDER BY mvp_score DESC) as pos_rank
    FROM UniquePlayers
)
SELECT *,
    CASE 
        WHEN position = 'Center' AND pos_rank = 1 THEN 'Starter'
        WHEN position = 'Forward' AND pos_rank <= 2 THEN 'Starter'
        WHEN position = 'Guard' AND pos_rank <= 2 THEN 'Starter'
        ELSE 'Bench'
    END as role
FROM FinalRoster 
WHERE 
    (position = 'Center' AND pos_rank <= 2) OR
    (position = 'Forward' AND pos_rank <= 4) OR
    (position = 'Guard' AND pos_rank <= 4)
ORDER BY role DESC, mvp_score DESC;
"

# 7. Team Trends
query_team_trends <- "
SELECT 
    season,
    team_abbreviation as team,
    ROUND(AVG(pts), 1) as avg_pts,
    ROUND(AVG(net_rating), 1) as avg_rating,
    ROUND(AVG(ts_pct) * 100, 1) as avg_ts
FROM nba_seasons
WHERE team_abbreviation IS NOT NULL
GROUP BY season, team_abbreviation
ORDER BY season;
"

# 8. Top Colleges
query_top_colleges <- "
SELECT 
    college, 
    COUNT(DISTINCT player_name) as player_count,
    ROUND(AVG(pts), 1) as avg_ppg
FROM nba_seasons
WHERE college IS NOT NULL AND college != 'None' AND college != ''
GROUP BY college
ORDER BY player_count DESC
LIMIT 15;
"

# 9. International Growth
query_international_trend <- "
SELECT 
    CASE 
        WHEN CAST(SUBSTR(season, 1, 4) AS INT) BETWEEN 1990 AND 1999 THEN '1990s'
        WHEN CAST(SUBSTR(season, 1, 4) AS INT) BETWEEN 2000 AND 2009 THEN '2000s'
        WHEN CAST(SUBSTR(season, 1, 4) AS INT) BETWEEN 2010 AND 2019 THEN '2010s'
        ELSE '2020s' 
    END as decade,
    SUM(CASE WHEN country = 'USA' THEN 1 ELSE 0 END) as usa_players,
    SUM(CASE WHEN country != 'USA' THEN 1 ELSE 0 END) as intl_players
FROM nba_seasons
WHERE country IS NOT NULL
GROUP BY decade
ORDER BY decade;
"

# 10. Country Distribution
query_country_map <- "
SELECT 
    country, 
    COUNT(DISTINCT player_name) as player_count
FROM nba_seasons
WHERE country IS NOT NULL AND country != 'USA'
GROUP BY country
ORDER BY player_count DESC;
"

# 11. All Players List
query_all_players <- "
SELECT DISTINCT player_name FROM nba_seasons ORDER BY player_name;
"

# 12. Player Career Stats
query_player_career <- "
SELECT 
    season, team_abbreviation as team, age, 
    player_height as height, player_weight as weight,
    gp, pts, reb, ast, net_rating, ts_pct
FROM nba_seasons
WHERE player_name = ?
ORDER BY season;
"

# 13. Top 10 Most Improved Chart (Visual)
query_top_improved_chart <- "
WITH LaggedStats AS (
    SELECT 
        player_name, season, pts, gp,
        LAG(pts) OVER (PARTITION BY player_name ORDER BY season) as prev_pts,
        LAG(gp) OVER (PARTITION BY player_name ORDER BY season) as prev_gp
    FROM nba_seasons
)
SELECT 
    player_name, season, pts as current_pts, prev_pts,
    ROUND(pts - prev_pts, 1) as ppg_increase
FROM LaggedStats
WHERE prev_pts IS NOT NULL AND prev_gp > 20 AND gp > 20
ORDER BY ppg_increase DESC
LIMIT 10;
"

# 14. Most Improved Table (Detailed Data)
# THIS WAS MISSING BEFORE - CAUSING THE ERROR
query_most_improved <- "
WITH LaggedStats AS (
    SELECT 
        player_name, season, team_abbreviation as team, pts, gp,
        LAG(pts) OVER (PARTITION BY player_name ORDER BY season) as prev_pts,
        LAG(gp) OVER (PARTITION BY player_name ORDER BY season) as prev_gp
    FROM nba_seasons
)
SELECT 
    player_name, team, season, 
    prev_pts as 'Pre_PPG', pts as 'Post_PPG',
    ROUND(pts - prev_pts, 1) as 'Diff'
FROM LaggedStats
WHERE prev_pts IS NOT NULL AND prev_gp > 20 AND gp > 20
ORDER BY Diff DESC
LIMIT 50;
"

# 15. Demographics KPIs 
query_demo_kpis <- "
SELECT 
    COUNT(DISTINCT player_name) as total_players,
    COUNT(DISTINCT country) as total_countries,
    (SELECT country FROM nba_seasons WHERE country != 'USA' GROUP BY country ORDER BY COUNT(*) DESC LIMIT 1) as top_intl_country
FROM nba_seasons;
"

# 16. Era KPIs (NEW - Headlines)
query_era_kpis <- "
SELECT 
    -- Season with highest average points
    (SELECT season FROM nba_seasons GROUP BY season ORDER BY AVG(pts) DESC LIMIT 1) as high_score_szn,
    (SELECT ROUND(AVG(pts),1) FROM nba_seasons GROUP BY season ORDER BY AVG(pts) DESC LIMIT 1) as max_pts,
    
    -- Season with highest average height
    (SELECT season FROM nba_seasons GROUP BY season ORDER BY AVG(player_height) DESC LIMIT 1) as tall_szn,
    (SELECT ROUND(AVG(player_height),1) FROM nba_seasons GROUP BY season ORDER BY AVG(player_height) DESC LIMIT 1) as max_ht,

    -- Season with highest efficiency (TS%)
    (SELECT season FROM nba_seasons GROUP BY season ORDER BY AVG(ts_pct) DESC LIMIT 1) as efficient_szn,
    (SELECT ROUND(AVG(ts_pct)*100,1) FROM nba_seasons GROUP BY season ORDER BY AVG(ts_pct) DESC LIMIT 1) as max_ts
;
"

# 17. The Strategic Revolution (Scoring vs Efficiency)
# Uses ts_pct (Efficiency) and pts (Volume) to show the modern offensive boom
query_scoring_efficiency <- "
SELECT 
    season,
    ROUND(AVG(pts), 1) as avg_pts,
    ROUND(AVG(ts_pct) * 100, 1) as avg_efficiency
FROM nba_seasons
GROUP BY season
ORDER BY season;
"