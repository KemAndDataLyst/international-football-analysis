# Does Scoring First Win International Matches?

## Question
How often does the team that scores first go on to win an international football match?

## Data
- International results and goalscorers tables (MySQL 8.0)
- Matches after 1997-03-31 only. Earlier matches have missing goal minutes, so the first goal can't be identified.
- 10,303 matches with a known first goal

## Method
1. Ranked goals within each match by minute (`ROW_NUMBER`, partitioned by date, home team, away team)
2. Kept the first goal of each match
3. LEFT JOINed to results (0 unmatched), worked out the winner from the scores
4. Classified each match: first goal won / drew / lost

## Findings
In international matches since 1997, the team that scored first won 75.69%, drew 15.32%, and lost 9.00%.

## Caveats
- Date range is a data limit, not a choice
- Draws are reported separately
- Stronger teams tend to score first and win, so this mixes "scoring first helps" with "good teams do both"
- All tournament types are pooled (friendlies, qualifiers, World Cups)
- Three matches (out of 10,303) have two goals from different teams recorded in the same minute, two of them at minute 45 or 90, where stoppage-time goals     are logged under the same minute. The true first scorer can't be determined in these cases. This is too few to affect the results.
## Next steps
Join FIFA rankings to split matches into "favorite scored first" and "underdog scored first" and compare outcomes. Possible further work: whether underdogs' conversion rate links to factors like youth development (needs other data).
Repeat the analysis on club data (larger sample, more matches) to see whether the first-goal win rate is similar, and check how stoppage-time minutes are recorded, since same-minute ties may be more common there.
