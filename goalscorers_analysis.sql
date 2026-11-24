SELECT COUNT(*),MAX(minute_scored), MIN(minute_scored) FROM goalscorers;

SELECT * FROM goalscorers WHERE minute_scored = 'NA';


# sets goals scored at minute 0 to NULL
SET SQL_SAFE_UPDATES = 0;
UPDATE goalscorers SET minute_scored = NULL WHERE minute_scored = 0;
SET SQL_SAFE_UPDATES = 1;

# counts null values in minute_scored per yr
use fifa_ranks;
SELECT year(match_date), COUNT(*) FROM goalscorers WHERE minute_scored is null
GROUP BY year(match_date)
ORDER BY year(match_date);

# finds the range of years with NULL minute_scored
SELECT MIN(match_date), MAX(match_date) FROM goalscorers 
WHERE minute_scored is NULL;

# get the 1st goal scored in each match, join with the results table and get the match outcome
WITH
first_goals AS (SELECT s.match_date, CONCAT(s.home_team, ' vs ', s.away_team) as match_game,
				s.team_scored, s.scorer, r.home_score, r.away_score,
				(CASE WHEN (r.home_score > r.away_score) THEN r.home_team
					WHEN (r.away_score > r.home_score) THEN r.away_team
                    ELSE 'Draw'
				END ) AS winner
FROM (SELECT *, 
	  ROW_NUMBER() OVER (partition by match_date, home_team, away_team ORDER BY minute_scored) as goals_ordered
	  FROM goalscorers) s LEFT JOIN results r
ON (s.match_date = r.match_date) AND (s.home_team = r.home_team) AND (s.away_team = r.away_team)
WHERE (s.match_date > '1997-03-31') and (s.goals_ordered = 1)),

first_goals_results AS (SELECT match_date, match_game, team_scored, scorer, winner,
								(CASE WHEN team_scored = winner THEN '1st goal won'
									  WHEN winner = 'Draw' THEN 'Draw' 
									  ELSE '1st goal lost'END)  AS first_goal_winner
FROM first_goals)

# find pct of matches won
SELECT first_goal_winner, COUNT(*) AS num_outcome, 
		ROUND(((COUNT(*) / SUM(COUNT(*)) OVER()) * 100.0), 2) AS pct_of_matches
FROM first_goals_results
GROUP BY first_goal_winner;



# match row counts for original table
# to compare with the rows on the joined tables to see if there was any errors when joined
SELECT COUNT(DISTINCT match_date, home_team, away_team) FROM goalscorers
WHERE match_date > '1997-03-31';


# get column names
DESCRIBE goalscorers;
SELECT * FROM results;



# check how many matches had a goal scored in the same minute by a different team
# for each match
WITH
first_goals AS (SELECT s.match_date, CONCAT(s.home_team, ' vs ', s.away_team) as match_game,
						s.team_scored, s.scorer, s.minute_scored, r.home_score, r.away_score,
						(CASE WHEN (r.home_score > r.away_score) THEN r.home_team
							  WHEN (r.away_score > r.home_score) THEN r.away_team
							  ELSE 'Draw'
							END ) AS winner,
                            s.goals_ordered, s.next_goal, s.next_minute
				FROM (SELECT *, 
							  ROW_NUMBER() OVER (partition by match_date, home_team, away_team ORDER BY minute_scored) as goals_ordered,
                              LEAD(minute_scored) OVER(partition by match_date, home_team, away_team ORDER BY minute_scored) as next_minute,
                              LEAD(team_scored) OVER(partition by match_date, home_team, away_team ORDER BY minute_scored) as next_goal
					   FROM goalscorers) s LEFT JOIN results r
						ON (s.match_date = r.match_date) AND (s.home_team = r.home_team) AND (s.away_team = r.away_team)
						WHERE (s.match_date > '1997-03-31') AND (s.goals_ordered <= 2))

SELECT match_date, match_game, team_scored, minute_scored, next_goal, next_minute, goals_ordered
FROM first_goals
WHERE minute_scored = next_minute AND goals_ordered = 1 AND team_scored != next_goal
ORDER BY match_date;