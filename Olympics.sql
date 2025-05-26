DROP TABLE IF EXISTS olympics_history;
CREATE TABLE IF NOT EXISTS olympics_history
(
    id INT,
    name VARCHAR,
    sex CHAR(1),
    age VARCHAR,
    height VARCHAR,  
    weight VARCHAR,  
    team VARCHAR,
    noc CHAR(3),
    games VARCHAR,
    year INT,
    season VARCHAR,
    city VARCHAR,
    sport VARCHAR,
    event VARCHAR,
    medal VARCHAR);


UPDATE olympics_history
SET age = NULL
WHERE age = 'NA';

UPDATE olympics_history
SET height = NULL
WHERE height = 'NA';

UPDATE olympics_history
SET weight = NULL
WHERE weight = 'NA';

UPDATE olympics_history
SET medal = NULL
WHERE medal = 'NA';

ALTER TABLE olympics_history
ALTER COLUMN age TYPE INTEGER USING age::INTEGER;

ALTER TABLE olympics_history
ALTER COLUMN height TYPE INTEGER USING height::INTEGER;

ALTER TABLE olympics_history
ALTER COLUMN weight TYPE NUMERIC USING weight::NUMERIC;

SELECT * FROM olympics_history
LIMIT 10;


DROP TABLE IF EXISTS olympics_history_noc_regions;
CREATE TABLE IF NOT EXISTS olympics_history_noc_regions (
    noc VARCHAR(3) PRIMARY KEY,
    region VARCHAR,
    notes VARCHAR
);


SELECT * FROM olympics_history_noc_regions
LIMIT 10;


-- 1. How many olympics games have been held?
SELECT COUNT(DISTINCT(games)) AS games_count
FROM olympics_history;

-- 2. List down all Olympics games held so far.
SELECT DISTINCT(games) AS game, city
FROM olympics_history;

-- 3. Mention the total no of nations who participated in each olympics game?
SELECT games, COUNT(DISTINCT(noc)) AS total_no_of_nations
FROM olympics_history
GROUP BY games;

-- 4. Which year saw the highest and lowest no of countries participating in olympics?
WITH all_countries AS (
    SELECT 
        oh.games, 
        nr.region
    FROM 
        olympics_history AS oh
        JOIN olympics_history_noc_regions AS nr 
            ON oh.noc = nr.noc
    GROUP BY 
        oh.games, 
        nr.region
),
tot_countries AS (
    SELECT 
        games, 
        COUNT(*) AS total_countries
    FROM 
        all_countries
    GROUP BY 
        games
)
SELECT DISTINCT
    CONCAT(
        FIRST_VALUE(games) OVER (ORDER BY total_countries), 
        ' - ', 
        FIRST_VALUE(total_countries) OVER (ORDER BY total_countries)
    ) AS lowest_countries,
    
    CONCAT(
        FIRST_VALUE(games) OVER (ORDER BY total_countries DESC), 
        ' - ', 
        FIRST_VALUE(total_countries) OVER (ORDER BY total_countries DESC)
    ) AS highest_countries
FROM 
    tot_countries
ORDER BY 
    1;


-- 5. Which nation has participated in all of the olympic games?
SELECT 
    ohr.region AS country,
    COUNT(DISTINCT oh.games) AS total_participated_games
FROM 
    olympics_history AS oh
JOIN 
    olympics_history_noc_regions AS ohr ON oh.noc = ohr.noc
GROUP BY 
    ohr.region
HAVING 
    COUNT(DISTINCT oh.games) = (
        SELECT COUNT(DISTINCT games) FROM olympics_history
    );

-- 6. Identify the sport which was played in all summer olympics.
SELECT 
    sport,
    COUNT(DISTINCT games) AS appearances,
    (SELECT COUNT(DISTINCT games) 
     FROM olympics_history 
     WHERE season = 'Summer') AS total_summer_olympics
FROM olympics_history
WHERE season = 'Summer'
GROUP BY sport
HAVING COUNT(DISTINCT games) = (
    SELECT COUNT(DISTINCT games) 
    FROM olympics_history 
    WHERE season = 'Summer'
);

-- 7. Which Sports were just played only once in the olympics?
SELECT 
    sport,
    COUNT(DISTINCT games) AS appearances,
	games
FROM olympics_history
GROUP BY sport, games
HAVING COUNT(DISTINCT games) = 1;


-- 8. Fetch the total no of sports played in each olympic games.
SELECT 
	games,
	COUNT(DISTINCT(sport)) AS number_of_sports
FROM olympics_history
GROUP BY games;

-- 9. Fetch details of the oldest athletes to win a gold medal.
WITH temp AS (
    SELECT 
        name,
        sex,
        CAST(CASE 
                WHEN age IS NULL THEN '0' 
                ELSE age 
             END AS INT) AS age,
        team,
        games,
        city,
        sport,
        event,
        medal
    FROM olympics_history
),
ranking AS (
    SELECT 
        *,
        RANK() OVER (ORDER BY age DESC) AS rnk
    FROM temp
    WHERE medal = 'Gold'
)
SELECT *
FROM ranking
WHERE rnk = 1;

-- 10. Find the Ratio of male and female athletes participated in all olympic games.
WITH sex_counts AS (
    SELECT 
        sex, 
        COUNT(*) AS cnt
    FROM olympics_history
    GROUP BY sex
),
min_max AS (
    SELECT 
        MIN(cnt) AS min_cnt,
        MAX(cnt) AS max_cnt
    FROM sex_counts
)
SELECT 
    CONCAT('1 : ', ROUND(max_cnt::DECIMAL / min_cnt, 2)) AS ratio
FROM min_max;



-- 11. Fetch the top 5 athletes who have won the most gold medals.
WITH gold_medals_per_athlete AS (
    SELECT 
        name, 
        team, 
        COUNT(*) AS total_gold_medals
    FROM olympics_history
    WHERE medal = 'Gold'
    GROUP BY name, team
),
ranked_athletes AS (
    SELECT 
        *, 
        DENSE_RANK() OVER (ORDER BY total_gold_medals DESC) AS rnk
    FROM gold_medals_per_athlete
)
SELECT 
    name, 
    team, 
    total_gold_medals
FROM ranked_athletes
WHERE rnk <= 5;


-- 12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
WITH medals_per_athlete AS (
    SELECT 
        name, 
        team, 
        COUNT(*) AS total_medals
    FROM olympics_history
	WHERE medal IN ('Gold', 'Silver', 'Bronze')
    GROUP BY name, team
),
ranked_athletes AS (
    SELECT 
        *, 
        DENSE_RANK() OVER (ORDER BY total_medals DESC) AS rnk
    FROM medals_per_athlete
)
SELECT 
    name, 
    team, 
    total_medals
FROM ranked_athletes
WHERE rnk <= 5;


-- 13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
WITH medals_per_country AS (
    SELECT 
        noc, 
        COUNT(*) AS total_medals
    FROM olympics_history
	WHERE medal IN ('Gold', 'Silver', 'Bronze')
    GROUP BY noc
),
ranked_countries AS (
    SELECT 
        *, 
        DENSE_RANK() OVER (ORDER BY total_medals DESC) AS rnk
    FROM medals_per_country
)
SELECT 
    ohr.region, 
    total_medals
FROM ranked_countries AS rc
JOIN olympics_history_noc_regions AS ohr
ON rc.noc = ohr.noc
WHERE rnk <= 5;

-- 14. List down total gold, silver and bronze medals won by each country.
WITH gold_medals AS (
    SELECT 
        noc,
        COUNT(*) AS gold_medals
    FROM olympics_history
    WHERE medal = 'Gold'
    GROUP BY noc
),
silver_medals AS (
    SELECT 
        noc,
        COUNT(*) AS silver_medals
    FROM olympics_history
    WHERE medal = 'Silver'
    GROUP BY noc
),
bronze_medals AS (
    SELECT 
        noc,
        COUNT(*) AS bronze_medals
    FROM olympics_history
    WHERE medal = 'Bronze'
    GROUP BY noc
)
SELECT 
    COALESCE(g.noc, s.noc, b.noc) AS noc,
    COALESCE(g.gold_medals, 0) AS gold_medals,
    COALESCE(s.silver_medals, 0) AS silver_medals,
    COALESCE(b.bronze_medals, 0) AS bronze_medals
FROM gold_medals g
FULL OUTER JOIN silver_medals s ON g.noc = s.noc
FULL OUTER JOIN bronze_medals b ON COALESCE(g.noc, s.noc) = b.noc
ORDER BY gold_medals DESC;



-- 15. List down total gold, silver and broze medals won by each country corresponding to each olympic games.
WITH gold_medals AS (
    SELECT
		games,
        noc,
        COUNT(*) AS gold_medals
    FROM olympics_history
    WHERE medal = 'Gold'
    GROUP BY games, noc
),
silver_medals AS (
    SELECT 
		games,
        noc,
        COUNT(*) AS silver_medals
    FROM olympics_history
    WHERE medal = 'Silver'
    GROUP BY games, noc
),
bronze_medals AS (
    SELECT 
		games,
        noc,
        COUNT(*) AS bronze_medals
    FROM olympics_history
    WHERE medal = 'Bronze'
    GROUP BY games, noc
)
SELECT 
    COALESCE(g.games, s.games, b.games) AS games,
    COALESCE(g.noc, s.noc, b.noc) AS noc,
    COALESCE(g.gold_medals, 0) AS gold_medals,
    COALESCE(s.silver_medals, 0) AS silver_medals,
    COALESCE(b.bronze_medals, 0) AS bronze_medals
FROM gold_medals g
FULL OUTER JOIN silver_medals s 
    ON g.games = s.games AND g.noc = s.noc
FULL OUTER JOIN bronze_medals b 
    ON COALESCE(g.games, s.games) = b.games AND COALESCE(g.noc, s.noc) = b.noc
ORDER BY games, noc;


-- 16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
WITH medal_counts AS (
  SELECT
    games,
    noc,
    medal,
    COUNT(*) AS medal_count
  FROM olympics_history
  WHERE medal IN ('Gold', 'Silver', 'Bronze')
  GROUP BY games, noc, medal
),
ranked AS (
  SELECT *,
         RANK() OVER (PARTITION BY games, medal ORDER BY medal_count DESC) AS rnk
  FROM medal_counts
)
SELECT *
FROM ranked
WHERE rnk = 1;


-- 17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
WITH medal_counts AS (
  SELECT
    games,
    noc,
    medal,
    COUNT(*) AS medal_count
  FROM olympics_history
  WHERE medal IN ('Gold', 'Silver', 'Bronze')
  GROUP BY games, noc, medal
),
total_medals AS (
  SELECT
    games,
    noc,
    COUNT(*) AS total_count
  FROM olympics_history
  WHERE medal IN ('Gold', 'Silver', 'Bronze')
  GROUP BY games, noc
),
ranked_individual AS (
  SELECT *,
         RANK() OVER (PARTITION BY games, medal ORDER BY medal_count DESC) AS rnk
  FROM medal_counts
),
ranked_total AS (
  SELECT *,
         RANK() OVER (PARTITION BY games ORDER BY total_count DESC) AS rnk
  FROM total_medals
)
SELECT 'Gold/Silver/Bronze' AS type, games, noc, medal AS medal_type, medal_count AS count
FROM ranked_individual
WHERE rnk = 1

UNION ALL

SELECT 'Total' AS type, games, noc, NULL, total_count
FROM ranked_total
WHERE rnk = 1
ORDER BY games, type;



-- 18. Which countries have never won gold medal but have won silver/bronze medals?
WITH gold_countries AS (
    SELECT DISTINCT noc
    FROM olympics_history
    WHERE medal = 'Gold'
),
silver_bronze_counts AS (
    SELECT
        noc,
        SUM(CASE WHEN medal = 'Silver' THEN 1 ELSE 0 END) AS silver_count,
        SUM(CASE WHEN medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze_count
    FROM olympics_history
    WHERE medal IN ('Silver', 'Bronze')
    GROUP BY noc
)
SELECT
    sb.noc,
    sb.silver_count,
    sb.bronze_count
FROM silver_bronze_counts sb
LEFT JOIN gold_countries g ON sb.noc = g.noc
WHERE g.noc IS NULL;



-- 19. In which Sport/event, India has won highest medals.
WITH ranked_medals AS (
    SELECT
        sport,
        event,
        COUNT(medal) AS medal_count,
        RANK() OVER (ORDER BY COUNT(medal) DESC) AS rnk
    FROM olympics_history
    WHERE noc = 'IND'
    GROUP BY sport, event
)
SELECT *
FROM ranked_medals
WHERE rnk = 1;



-- 20. Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.
WITH hockey_medals AS (
    SELECT 
        games,
        COUNT(medal) AS hockey_medal_count
    FROM olympics_history
    WHERE sport = 'Hockey' AND noc = 'IND'
    GROUP BY games
)
SELECT *
FROM hockey_medals
ORDER BY games;

