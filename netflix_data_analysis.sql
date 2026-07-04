-- Netflix Project 

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix(
	show_id VARCHAR(10),
	type VARCHAR(10),
	title VARCHAR(150), -- We can use the Excel fomrula =MAX(Len(Select column)) this will give us the maximum no. of characters in that column
	director VARCHAR(208),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);

SELECT * from netflix;

SELECT type, COUNT(*) as total_content from netflix
GROUP BY type;

-- 15 Business Problems

--1. Count the number of Movies vs TV Shows
--2. Find the most common rating for movies and TV shows
--3. List all movies released in a specific year (e.g•, 2020)
--4. Find the top 5 countries with the most content on Netflix
--5. Identify the longest movie?
--6. Find content added in the last 5 years
--7. Find all the movies/TV shows by director 'Rajiv Chilaka'
--8. List all TV shows with more than 5 seasons
--9. Count the number of content items in each genre
--10(A). Find numbers of content released each year by India on netflix, Return top 5 year with highest content release.
--10(B). Find Average number of content released on netflix India
--11. List all movies that are documentaries
--12. Find all content without a director
--13. Find how many movies actor 'Salman Khan' appeared in last 10 years.
--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
--15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.


--1. Count the number of Movies vs TV Shows

SELECT type, COUNT(*) as total_content from netflix
GROUP BY type;

--2. Find the most common rating for movies and TV shows

SELECT type, -- This is the main query that gives the final answer with exactly two rows extracted from the below query
	rating,
	ranking
FROM 
( 
SELECT type, -- We can't use the MAX function here as the ratings are characters and not numbers
	rating,
	Count(*),
	RANK() OVER (PARTITION BY type ORDER BY Count(*) DESC) as ranking  -- Here we give ranking to the ratings partitioned by there type
From netflix
GROUP BY 1,2) AS t1 -- To save the whole query as a table "t1", which we can refer to in the main query
WHERE ranking = 1; -- Now we can use the column ranking for putting conditions as it is there in the t1 table

--3. List all movies released in a specific year (e.g•, 2020)

SELECT type, title, release_year from netflix
WHERE type = 'Movie' AND release_year = 2020;

--4. Find the top 5 countries with the most content on Netflix

SELECT -- Here we directly just can't group by and arrange by frequency as there are some titles with multiple countries in 1 row
	UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country, -- Here we break the string into an array for the country column and new array input as soon as we get a ','; And use UNNEST to give every country in a new row so no. of rows increase
	Count(show_id) AS total_content
	From netflix
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 5; 

--5. Identify the longest movie?
DELETE from netflix
WHERE duration is NULL; -- Deleting the rows which had Null as duration coz then they would be at the top of descending order


SELECT type, -- Here we will convert the duration column with data type string to Integer 
	title,
	duration,
	REPLACE (duration, ' min', ' '):: INT AS duration_mins-- Here we actually give new column in output by replacing mins to nth and changing the data type to integer
From netflix
	WHERE type = 'Movie'
	ORDER BY duration_mins DESC -- Ordering by the integer data type does it correctly
	LIMIT 1
;

--6. Find content added in the last 5 years

SELECT type, title,date_added, RIGHT(date_added,4):: INT AS Addition_Year -- Create the date_added column from character to integer and then arranged in desc order
from netflix
WHERE RIGHT(date_added,4):: INT between 2017 AND 2021 -- Since the latest year was 2021 so 5 years back from 2021
ORDER BY addition_year DESC;

-- Now the problem with this is it is not from the exact current date, It's from the year; For that we can convert date_added to date format

SELECT *,
	To_DATE(date_added, 'Month DD, YYYY') AS Date_Format -- Changed the format from characters to date 
from netflix
WHERE 
	To_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

SELECT CURRENT_DATE - INTERVAL '5 years'; -- This give me the actual last timestap we looking for

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'.
SELECT *
FROM 
(
SELECT *, -- We could have directlky used WHERE director = 'Rajiv Chilaka' but we have certain rows with multiple director names 
	UNNEST(STRING_TO_ARRAY(director, ',')) As Each_Director -- Here we made new rows with each director name
from netflix
) AS t
WHERE Each_Director = 'Rajiv Chilaka'; 

--8. List all TV shows with more than 5 seasons

SELECT type,
	title,
	LEFT(duration, 2):: INT AS No_of_seasons
From netflix
WHERE type = 'TV Show' AND LEFT(duration, 2):: INT > 5
ORDER BY No_of_seasons DESC;

--9. Count the number of content items in each genre (Here also same thing multiple listed in, so use UNNEST)

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) As Genre,
	COUNT(show_id)
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;

--10(A). Find numbers of content released each year by India on netflix, Return top 5 year with highest content release.

SELECT 
	EXTRACT(Year from TO_DATE(date_added, 'Month DD, YYYY')) AS year,
	Each_Country,
	COUNT(*) AS No_of_Content
FROM (
	SELECT *,
		UNNEST(STRING_TO_ARRAY(country, ',')) As Each_Country
	FROM netflix) as t4
WHERE Each_Country = 'India'
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5;

--10(B). Find Average number of content released on netflix India

SELECT
    ROUND(AVG(no_of_content), 2) AS avg_content_released
FROM
(
    SELECT
        EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
		each_country,
        COUNT(*) AS no_of_content
    FROM
    (
        SELECT *,
               (UNNEST(STRING_TO_ARRAY(country, ','))) AS each_country
        FROM netflix
    ) AS t4
    WHERE each_country = 'India'
    GROUP BY 1,2
) AS t5;

--11. List all movies that are documentaries

SELECT * FROM netflix
WHERE listed_in ILIKE '%documentaries%'; -- ILIKE operator used to avoid case sensitivity of documentary vs Documentary

--12. Find all content without a director

SELECT * from netflix
WHERE director is NULL;

--13. Find in how many movies actor 'Salman Khan' appeared in last 10 years.

 SELECT * from netflix
 WHERE casts LIKE '%Salman Khan%' AND release_year >= EXTRACT(Year FROM CURRENT_DATE) - 10 ; -- Basically the films we have 10 years ago from current year

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) As Actors, --Always use trim with unnest otherwise spacing issue for the 2nd and 3nd word
	Count(*) AS total_content
FROM netflix
WHERE country LIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

--15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.

WITH new_table
AS 
( -- This query will execute first and the ouput will be stored in a temporary table "new_table"
SELECT *,
	CASE WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad Content'
	ELSE 'Good Content' END category
from netflix
)
SELECT 
	category,
	COUNT(*) as total_content
	FROM new_table
	GROUP BY 1;
