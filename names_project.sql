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
SELECT MIN(year), MAX(year)
FROM names;
--1880 through 2018.

--5. What year has the largest number of registrations?
SELECT year
FROM names
ORDER BY num_registered DESC
LIMIT 1;
--1947

--6. How many different (distinct) names are contained in the dataset?
SELECT COUNT(DISTINCT name)
FROM names;
--98,400

--7. Are there more males or more females registered?
SELECT gender, SUM(num_registered)
FROM names
GROUP BY gender;
--Males

--8. What are the most popular male and female names overall (i.e., the most total registrations)?
SELECT name, gender, SUM(num_registered) AS sum_registered
FROM names
GROUP BY name, gender
ORDER BY sum_registered DESC;
--For males, James; for females, Mary.

--9. What are the most popular boy and girl names of the first decade of the 2000s (2000 - 2009)?
SELECT name, gender, SUM(num_registered) AS sum_registered
FROM names
WHERE year BETWEEN 2000 AND 2009
GROUP BY name, gender
ORDER BY sum_registered DESC;
--For males, Jacob; for females, Emily.

--10. Which year had the most variety in names (i.e. had the most distinct names)?
SELECT year, COUNT(DISTINCT name) AS name_count
FROM names
GROUP BY year
ORDER BY name_count DESC
LIMIT 1;
--2008

--11. What is the most popular name for a girl that starts with the letter X?
SELECT name, SUM(num_registered) AS sum_registered
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
AND name NOT LIKE '^u';
--537

--13. Which is the more popular spelling between "Stephen" and "Steven"? Use a single query to answer this question.
SELECT name, SUM(num_registered) AS sum_registered
FROM names
WHERE name LIKE 'Ste%en'
GROUP BY name
ORDER BY sum_registered DESC
LIMIT 2;
--Steven

--14. What percentage of names are "unisex" - that is what percentage of names have been used both for boys and for girls?
SELECT CAST(MIN(unisex_count) AS FLOAT) / CAST(MAX(unisex_count) AS FLOAT) * 100
FROM
(SELECT 
COUNT(*) AS unisex_count
FROM 
(SELECT name
FROM names
GROUP BY name
HAVING COUNT(DISTINCT gender) > 1) AS ut
UNION
SELECT 
COUNT(DISTINCT name) AS total_count
FROM names AS n) AS union_table;
--~10.95%

--15. How many names have made an appearance in every single year since 1880?
SELECT 
COUNT(*)
FROM
(SELECT name 
FROM names
GROUP BY name
HAVING COUNT(DISTINCT year) = (SELECT MAX(year) - MIN(year) FROM names)) AS yearly_names;
--120

--16. How many names have only appeared in one year?
SELECT 
COUNT(*)
FROM
(SELECT name 
FROM names
GROUP BY name
HAVING COUNT(DISTINCT year) = 1) AS one_year_names;
--21,123

--17. How many names only appeared in the 1950s?
SELECT COUNT(*)
FROM
(SELECT name
FROM names
WHERE year BETWEEN 1950 AND 1959
EXCEPT
SELECT name
FROM names
WHERE year < 1950
OR year > 1959) AS only_1950s;
--661

--18. How many names made their first appearance in the 2010s?
SELECT COUNT(*)
FROM
(SELECT name
FROM names
WHERE year > 2009
EXCEPT
SELECT name
FROM names
WHERE year < 2010) AS only_2010s;
--11,270

--19. Find the names that have not been used in the longest.
SELECT name, 2018 - MAX(year) AS longest_time_unused
FROM names
GROUP BY name
ORDER BY longest_time_unused DESC
LIMIT 10;
--Zilpah, Roll, Crete, Ng, Lelie, etc.

--20. Come up with a question that you would like to answer using this dataset. Then write a query to answer this question.
--Whether my name or my son's name has been more popular over the years.
SELECT h.henry_year AS running_year, h.henry_registrations, c1.chris_registrations
FROM (SELECT year AS henry_year, SUM(num_registered) AS henry_registrations
FROM names
WHERE name = 'Henry'
GROUP BY henry_year
ORDER BY henry_year) AS h
INNER JOIN
(SELECT year AS chris_year, SUM(num_registered) AS chris_registrations
FROM names
WHERE name LIKE 'Chris%'
GROUP BY chris_year
ORDER BY chris_year) AS c1
ON h.henry_year = c1.chris_year
GROUP BY running_year, h.henry_registrations, c1.chris_registrations;
--Turns out my name has been far more popular in recent years, though less popular in the early 20th century.