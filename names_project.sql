--Save a script containing the query you used to answer each question and your answer (as a comment).

--1. How many rows are in the names table?
SELECT COUNT(*)
FROM names;
--1,957,046

--2. How many total registered people appear in the dataset?
SELECT SUM(num_registered)
FROM names;
--351,653,025

--3. Which name had the most appearances in a single year in the dataset?
SELECT name
FROM names
ORDER BY num_registered DESC
LIMIT 1;
--Linda

--4. What range of years are included?
SELECT 
	MIN(year), 
	MAX(year)
FROM names;
--1880 through 2018.

--5. What year has the largest number of registrations?
SELECT 
	year, 
	SUM(num_registered) AS total_registered
FROM names
GROUP BY year
ORDER BY total_registered DESC
LIMIT 1;
--1957

/* BF:
select (case when males > females then 'true' else 'false' end) as are_more_males_than_females_registered
from (select count(gender) from usa_names where gender = 'M') males,
     (select count(gender) from usa_names where gender = 'F') females; */

--6. How many different (distinct) names are contained in the dataset?
SELECT COUNT(DISTINCT name)
FROM names;
--98,400

--7. Are there more males or more females registered?
SELECT 
	gender, 
	SUM(num_registered)
FROM names
GROUP BY gender;
--Males

/* BF: select distinct name, gender, sum(num_registered) over (partition by name, gender) as total_registrations
from usa_names
order by total_registrations desc */

/* JRR: (SELECT gender, name, SUM(num_registered) AS name_total
FROM names
WHERE gender = 'F'
GROUP BY gender, name
ORDER BY name_total DESC
LIMIT 1)
UNION
(SELECT gender, name, SUM(num_registered) AS name_total
FROM names
WHERE gender = 'M'
GROUP BY gender, name
ORDER BY name_total DESC
LIMIT 1)
*/

--8. What are the most popular male and female names overall (i.e., the most total registrations)?
SELECT 
	name, 
	gender, 
	SUM(num_registered) AS sum_registered
FROM names
GROUP BY 
	name, 
	gender
ORDER BY sum_registered DESC;
--For males, James; for females, Mary.

/* BF: select distinct name, gender, sum(num_registered) over (partition by name, gender) as total_registrations
from usa_names
where year between 2000 and 2009
order by total_registrations desc */



--9. What are the most popular boy and girl names of the first decade of the 2000s (2000 - 2009)?
SELECT 
	name, 
	gender, 
	SUM(num_registered) AS sum_registered
FROM names
WHERE year BETWEEN 2000 AND 2009
GROUP BY 
	name, 
	gender
ORDER BY sum_registered DESC;
--For males, Jacob; for females, Emily.

--10. Which year had the most variety in names (i.e. had the most distinct names)?
SELECT 
	year, 
	COUNT(DISTINCT name) AS name_count
FROM names
GROUP BY year
ORDER BY name_count DESC
LIMIT 1;
--2008

--11. What is the most popular name for a girl that starts with the letter X?
SELECT 
	name, 
	SUM(num_registered) AS sum_registered
FROM names
WHERE gender = 'F'
AND name LIKE 'X%'
GROUP BY name
ORDER BY sum_registered DESC
LIMIT 1;
--Ximena

--12. How many distinct names appear that start with a 'Q', but whose second letter is not 'u'?
SELECT COUNT(DISTINCT name)
FROM names
WHERE name LIKE 'Q%'
AND name NOT LIKE '_u%';
--46

--13. Which is the more popular spelling between "Stephen" and "Steven"? Use a single query to answer this question.
SELECT 
	name, 
	SUM(num_registered) AS sum_registered
FROM names
WHERE name LIKE 'Ste%en'
GROUP BY name
ORDER BY sum_registered DESC
LIMIT 2;
--Steven

--14. What percentage of names are "unisex" - that is what percentage of names have been used both for boys and for girls?
SELECT 
	CAST(MIN(unisex_count) AS FLOAT) / 
	CAST(MAX(unisex_count) AS FLOAT) * 100
FROM
	(
		SELECT 
			COUNT(*) AS unisex_count
		FROM 
			(
				SELECT name
				FROM names
				GROUP BY name
				HAVING COUNT(DISTINCT gender) > 1
			) AS ut
		UNION
		SELECT COUNT(DISTINCT name) AS total_count
		FROM names AS n
	) AS union_table;
--~10.95%
--::float to cast as float.

/* AZ: SELECT COUNT(unisex_counts)*100.00/COUNT(*)
FROM (SELECT CASE WHEN (COUNT( DISTINCT gender)>1) THEN 1 END AS unisex_counts
FROM names
GROUP BY name) AS unisex */

/* BF: select count(distinct name) / (select count(distinct name) from usa_names) as percent_unisex
from usa_names
where name in
      (select name from usa_names where gender = 'M')
  and name in
      (select name from usa_names where gender = 'F');
*/

/* CM: WITH male AS (SELECT
	 			DISTINCT(name) AS distinct_name
	  		FROM names
	  		WHERE gender = 'M'
),
	 
	 female AS (SELECT
				DISTINCT(name) AS distinct_name
			FROM names
			WHERE gender = 'F'
)

SELECT
	(COUNT(DISTINCT(f.distinct_name))::float / (SELECT COUNT(DISTINCT(name)) FROM names)) * 100
FROM female f
JOIN male m ON f.distinct_name = m.distinct_name; */


--15. How many names have made an appearance in every single year since 1880?
SELECT 
	COUNT(*)
FROM
	(
		SELECT name 
	 	FROM names
		GROUP BY name
		HAVING COUNT(DISTINCT year) = (
										SELECT MAX(year) + 1 - MIN(year) 
										FROM names)
										) AS yearly_names;
--921

--16. How many names have only appeared in one year?
SELECT COUNT(*)
FROM
	(
		SELECT name 
		FROM names
		GROUP BY name
		HAVING COUNT(DISTINCT year) = 1
	) AS one_year_names;
--21,123

--17. How many names only appeared in the 1950s?
SELECT COUNT(*)
FROM
	(
		SELECT name
		FROM names
		WHERE year BETWEEN 1950 AND 1959
		EXCEPT
		SELECT name
		FROM names
		WHERE year < 1950
		OR year > 1959
	) AS only_1950s;
--661
--MAX(year) and MIN(year) would have been better.
--18. How many names made their first appearance in the 2010s?
SELECT COUNT(*)
FROM
	(
		SELECT name
		FROM names
		WHERE year > 2009
		EXCEPT
		SELECT name
		FROM names
		WHERE year < 2010
	) AS only_2010s;
--11,270

--19. Find the names that have not been used in the longest.
SELECT 
	name, 
	2018 - MAX(year) AS longest_time_unused
FROM names
GROUP BY name
ORDER BY longest_time_unused DESC
LIMIT 10;
--Zilpah, Roll, Crete, Ng, Lelie, etc.

--20. Come up with a question that you would like to answer using this dataset. Then write a query to answer this question.
--Whether my name or my son's name has been more popular over the years.
SELECT 
	h.henry_year AS running_year, 
	h.henry_registrations, 
	c1.chris_registrations
FROM 
	(
		SELECT 
			year AS henry_year,
			SUM(num_registered) AS henry_registrations
		FROM names
		WHERE name = 'Henry'
		GROUP BY henry_year
		ORDER BY henry_year
	) AS h
		INNER JOIN
	(
		SELECT 
			year AS chris_year, 
			SUM(num_registered) AS chris_registrations
		FROM names
		WHERE name LIKE 'Chris%'
		GROUP BY chris_year
		ORDER BY chris_year) AS c1
		ON h.henry_year = c1.chris_year
		GROUP BY 
			running_year, 
			h.henry_registrations, 
			c1.chris_registrations;
--Turns out my name has been far more popular in recent years, though less popular in the early 20th century.

-----------------------------------------------------------------------------------------------------------------------

-- BONUS QUESTIONS

/* For this first set of questions, you might find it useful to refer to the PostgreSQL 
string functions (https://www.postgresql.org/docs/14/functions-string.html). */

-- 1. Find the longest name contained in this dataset. What do you notice about the long names?
SELECT name
FROM names
GROUP BY name
HAVING LENGTH(name) = (
						SELECT MAX(LENGTH(name))
					  	FROM names
						);
					  
--There are 36. It looks like bad data entry (smashed together first and last names).

--2. How many names are palindromes (i.e. read the same backwards and forwards, such as Bob and Elle)?
SELECT COUNT(DISTINCT name)
FROM names
WHERE LOWER(name) = REVERSE(LOWER(name));
--137

/* 3. Find all names that contain no vowels (for this question, we'll count a,e,i,o,u, and y as vowels). 
(Hint: you might find this page helpful: https://www.postgresql.org/docs/8.3/functions-matching.html) */
SELECT COUNT(DISTINCT name)
FROM names
WHERE name !~* '[aeiouy]+';
--43

/* 4. How many double-letter names show up in the dataset? 
Double-letter means the same letter repeated back-to-back, like Matthew or Aaron. 
Are there any triple-letter names? */

SELECT COUNT(DISTINCT name)
FROM names
WHERE name ~* '(.)\1{1}';
--22,537

SELECT COUNT(DISTINCT name)
FROM names
WHERE name ~* '(.)\1{2}';
--12

/* BF: select distinct names_examined.name
from (select name, regexp_replace(lower(name), E'[aeiouy]', '', 'g') as modified_name from usa_names) as names_examined
where length(names_examined.name) = length(names_examined.modified_name); */


-----------------------------------------------------------------------------------------------------------------------


/* For the next few questions, you'll likely need to make use of subqueries. 
A subquery is a SQL query nested inside another query. 
You'll learn more about subqueries over the next few DataCamp assignments. */

/* 5. On question 17 of the first part of the exercise, you found names that only appeared in the 1950s. 
Now, find all names that did not appear in the 1950s but were used both before and after the 1950s. 
We'll answer this question in two steps. */

-- a. First, write a query that returns all names that appeared during the 1950s.

/* b. Now, make use of this query along with the IN keyword in order the find all names 
that did not appear in the 1950s but which were used both before and after the 1950s. 
See the example "A subquery with the IN operator." on this page: https://www.dofactory.com/sql/subquery. */

SELECT COUNT(DISTINCT name)
FROM names
WHERE name NOT IN 
	(
		SELECT name
		FROM names
		GROUP BY name
		HAVING MIN(year) >= 1950
		AND MAX(year) <= 1959
	)
AND name IN
	(
		SELECT name
		FROM names
		GROUP BY name
		HAVING MIN(year) < 1950
		AND MAX(year) > 1959
	);
--14,548.

/* 6. In question 16, you found how many names appeared in only one year. 
Which year had the highest number of names that only appeared once? */

SELECT COUNT(DISTINCT name) AS name_count
FROM names
WHERE name IN
	(
		SELECT name 
	 	FROM names
		GROUP BY name
		HAVING COUNT(DISTINCT year) = 1
	)
GROUP BY year
ORDER BY name_count DESC
LIMIT 1;
--1,055

/* 7. Which year had the most new names (names that hadn't appeared in any years before that year)? 
For this question, you might find it useful to write a subquery and then select from this subquery. 
See this page about using subqueries in the from clause: https://www.geeksforgeeks.org/sql-sub-queries-clause/ */

WITH sq AS (
	SELECT name, MIN(year) AS start_year
	FROM names
	GROUP BY name
)

SELECT start_year, COUNT(*)
FROM sq
GROUP BY start_year
ORDER BY count DESC
LIMIT 1;
--2007 AT 2,027 new names.

/* 8. Is there more variety (more distinct names) for females or for males? 
Is this true for all years or are their any years where this is reversed? 
Hint: you may need to make use of multiple subqueries and JOIN them in order to answer this question. */

WITH sq AS (
	SELECT 
		year, 
		m.male_count, 
		f.female_count
	FROM
		(
			SELECT
				year,
				COUNT(DISTINCT name) AS male_count
			FROM names
			WHERE gender = 'M'
			GROUP BY year
		) AS m
		INNER JOIN
		(
			SELECT
				year,
				COUNT(DISTINCT name) AS female_count
			FROM names
			WHERE gender = 'F'
			GROUP BY year
		) AS f
	USING (year)
)

SELECT 
	SUM(male_count) AS male_total,
	SUM(female_count) AS female_total
FROM sq;
--Women have more name variety overall.

SELECT
	SUM(CASE WHEN male_count > female_count THEN 1
	   WHEN female_count <= male_count THEN 0 END) AS years_of_male_variety
FROM sq;
--There are 3 years when the men have more name variety.
	
/* 9. Which names are closest to being evenly split between male and female usage? 
For this question, consider only names that have been used at least 10000 times in total. */ 

WITH male_counts AS (
	SELECT 
		name, 
		SUM(num_registered) AS m_registered
	FROM names
	WHERE gender = 'M'
	GROUP BY name
	HAVING SUM(num_registered) > 10000
),
female_counts AS (
	SELECT 
		name, 
		SUM(num_registered) AS f_registered
	FROM names
	WHERE gender = 'F'
	GROUP BY name
	HAVING SUM(num_registered) > 10000
)

SELECT
	name,
	m_registered,
	f_registered
FROM male_counts
INNER JOIN female_counts
USING (name)
WHERE m_registered BETWEEN f_registered * 0.90 AND f_registered * 1.10
OR f_registered BETWEEN m_registered * 0.90 AND m_registered * 1.10;
--Kris, Elisha, Justice, Robbie, Kerry, Quinn and Blair.

-----------------------------------------------------------------------------------------------------------------------

/* For the last questions, you might find window functions useful 
(see https://www.postgresql.org/docs/9.1/sql-expressions.html#SYNTAX-WINDOW-FUNCTIONS and 
https://www.postgresql.org/docs/9.1/functions-window.html for a list of window function available in PostgreSQL). 
A window function is like an aggregate function in that it can be applied across a group, 
but a window function does not collapse each group down to a single summary statistic. 
The groupings for a window function are specified using the PARTITION BY keyword (and can include an ORDER BY when it is needed). 
The PARTITION BY and ORDER BY associated with a window function are CONTAINED in an OVER clause.
For example, to rank each row by the value of num_registered, we can use the query

```
SELECT name, year, num_registered, RANK() OVER(ORDER BY num_registered DESC)
FROM names;
```

If I want to rank within gender, I can add a PARTITION BY:  

```
SELECT name, year, num_registered, RANK() OVER(PARTITION BY gender ORDER BY num_registered DESC)
FROM names;*/
```

/* 10. Which names have been among the top 25 most popular names for their gender in every single year contained in the names table? 
Hint: you may have to combine a window function and a subquery to answer this question. */

WITH ranked_names AS (
	SELECT
		name,
		gender,
		year,
		registration_rank
	FROM 
		(
		SELECT
			name,
			gender,
			year,
			num_registered,
			RANK() OVER(PARTITION BY year, gender 
						ORDER BY num_registered DESC) as registration_rank
		FROM names
	) AS sq
	WHERE registration_rank BETWEEN 1 AND 25
)

SELECT name
FROM ranked_names
GROUP BY name
HAVING COUNT(DISTINCT year) = (SELECT MAX(year) + 1 - MIN(year) FROM names)
--James, Joseph and William.

--11. Find the name that had the biggest gap between years that it was used. 

WITH years_diff AS (
	SELECT 
		name, 
		year, 
		MAX(year) OVER(PARTITION BY name
					   ORDER BY year
					   ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS last_year
	FROM names
)

SELECT 
	name, 
	year - last_year AS difference
FROM years_diff
WHERE last_year IS NOT NULL
ORDER BY difference DESC
LIMIT 1;
--Franc, at 118 years.

/* 12. Have there been any names that were not used in the first year of the dataset (1880) 
but which made it to be the most-used name for its gender in some year? */

SELECT DISTINCT name
FROM 
	(
		SELECT
			name,
			year,
			gender,
			num_registered,
			RANK() OVER(PARTITION BY year, 
						gender ORDER BY num_registered DESC) AS year_rank
		FROM names
		WHERE name IN
			(
				SELECT name
				FROM names
				GROUP BY name
				HAVING MIN(year) != 1880
			)
	) AS sq
WHERE year_rank = 1;
--There are 38 such names.


/* Difficult follow-up: 
What is the shortest amount of time that a name has gone from not being used at all to being 
the number one used name for its gender in a year? */

SELECT 
	name, 
	gender, 
	MIN(year) AS first_number_one_year,
	MIN(year - first_year_period + 1) AS years_to_number_one
FROM 
	(
		SELECT 
			name, 
			gender,
			year, 
			RANK() OVER(PARTITION BY year, gender 
						ORDER BY num_registered DESC) AS year_rank,
			MIN(year) OVER() AS first_year_period
		FROM names
		WHERE name IN
					(
						SELECT name
						FROM names
						GROUP BY name
						HAVING MIN(year) != 1880
					) 
	) AS sq
WHERE year_rank = 1
GROUP BY name, gender
ORDER BY first_number_one_year;
-- 1 year for Newell (M), Adell (F), Celeste (F) and Brown (M).

