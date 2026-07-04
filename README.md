P# 🎬 Netflix Movies & TV Shows Data Analysis using PostgreSQL

![Netflix Banner](https://github.com/arnavkhandelwal001/Netflix_sql_analysis_P2/blob/main/Netflix_logo.png)

## 📖 Overview

This project presents a comprehensive SQL analysis of the Netflix Movies & TV Shows dataset using **PostgreSQL**. The objective is to solve real-world business problems by leveraging SQL for data cleaning, transformation, and analysis.

The dataset contains information about Netflix titles, including movies and TV shows, along with their directors, cast members, countries, release years, ratings, genres, durations, and descriptions.

Throughout this project, several PostgreSQL-specific functions such as `UNNEST()`, `STRING_TO_ARRAY()`, `RANK()`, `TO_DATE()`, `EXTRACT()`, and `CASE` have been used to derive meaningful business insights.

---

## 📑 Table of Contents

- Overview
- Objectives
- Dataset
- Database Schema
- Business Problems & Solutions
- PostgreSQL Concepts Used
- Project Structure
- Key Learnings
- Skills Demonstrated
- Author

# 🎯 Objectives

- Analyze the distribution of Movies and TV Shows.
- Identify the most common ratings.
- Analyze Netflix content by country and year.
- Perform data transformation using PostgreSQL functions.
- Solve 15 real-world business problems using SQL.

---

# 📂 Dataset

- **Source:** Netflix Movies & TV Shows Dataset (Kaggle)
- **Total Records:** 8,807
- **Database:** PostgreSQL

---

# 🗂 Database Schema

```sql
DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix(
    show_id VARCHAR(10),
    type VARCHAR(10),
    title VARCHAR(150),
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
```

---

# 📊 Business Problems & Solutions

## 1. Count the Number of Movies vs TV Shows

```sql
SELECT
    type,
    COUNT(*) AS total_content
FROM netflix
GROUP BY type;
```

**Objective:** Determine the distribution of Movies and TV Shows available on Netflix.

---

## 2. Find the Most Common Rating for Movies and TV Shows

```sql
SELECT
    type,
    rating,
    ranking
FROM
(
SELECT
    type,
    rating,
    COUNT(*),
    RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
FROM netflix
GROUP BY 1,2
) AS t1
WHERE ranking = 1;
```

**Objective:** Identify the most frequently assigned rating for Movies and TV Shows.

---

## 3. List All Movies Released in 2020

```sql
SELECT
    type,
    title,
    release_year
FROM netflix
WHERE type='Movie'
AND release_year=2020;
```

**Objective:** Retrieve all movies released during 2020.

---

## 4. Find the Top 5 Countries with the Most Content

```sql
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(country,','))) AS country,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

**Objective:** Identify the countries contributing the highest amount of Netflix content.

---

## 5. Identify the Longest Movie

```sql
SELECT
    type,
    title,
    duration,
    REPLACE(duration,' mins','')::INT AS duration_mins
FROM netflix
WHERE type='Movie'
ORDER BY duration_mins DESC
LIMIT 1;
```

**Objective:** Find the longest movie available on Netflix.

---

## 6. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix
WHERE TO_DATE(date_added,'Month DD, YYYY')
>= CURRENT_DATE - INTERVAL '5 years';
```

**Objective:** Retrieve titles added during the last five years.

---

## 7. Find All Movies/TV Shows Directed by Rajiv Chilaka

```sql
SELECT *
FROM
(
SELECT *,
TRIM(UNNEST(STRING_TO_ARRAY(director,','))) AS each_director
FROM netflix
) t
WHERE each_director='Rajiv Chilaka';
```

**Objective:** List all content directed by Rajiv Chilaka.

---

## 8. List TV Shows with More Than 5 Seasons

```sql
SELECT
    type,
    title,
    LEFT(duration,2)::INT AS seasons
FROM netflix
WHERE type='TV Show'
AND LEFT(duration,2)::INT >5
ORDER BY seasons DESC;
```

**Objective:** Identify TV Shows having more than five seasons.

---

## 9. Count Content Items in Each Genre

```sql
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(listed_in,','))) AS genre,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;
```

**Objective:** Determine the distribution of Netflix titles across genres.

---

## 10A. Find Number of Indian Content Releases Each Year

```sql
SELECT
    EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD, YYYY')) AS year,
    each_country,
    COUNT(*) AS no_of_content
FROM
(
SELECT *,
TRIM(UNNEST(STRING_TO_ARRAY(country,','))) AS each_country
FROM netflix
) t
WHERE each_country='India'
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5;
```

**Objective:** Find the years with the highest number of Indian Netflix releases.

---

## 10B. Find the Average Number of Indian Content Releases Per Year

```sql
SELECT
ROUND(AVG(no_of_content),2) AS avg_content_released
FROM
(
SELECT
EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD, YYYY')) AS year,
COUNT(*) AS no_of_content
FROM
(
SELECT *,
TRIM(UNNEST(STRING_TO_ARRAY(country,','))) AS each_country
FROM netflix
)t
WHERE each_country='India'
GROUP BY 1
)t2;
```

**Objective:** Calculate the average yearly content released by India on Netflix.

---

## 11. List All Documentary Movies

```sql
SELECT *
FROM netflix
WHERE type='Movie'
AND listed_in ILIKE '%Documentaries%';
```

**Objective:** Retrieve all Documentary movies available on Netflix.

---

## 12. Find Content Without a Director

```sql
SELECT *
FROM netflix
WHERE director IS NULL;
```

**Objective:** Identify titles that do not have director information.

---

## 13. Count Movies Featuring Salman Khan in the Last 10 Years

```sql
SELECT COUNT(*) AS total_movies
FROM netflix
WHERE type='Movie'
AND casts LIKE '%Salman Khan%'
AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE)-10;
```

**Objective:** Count Salman Khan movies released during the last decade.

---

## 14. Top 10 Actors Appearing in the Highest Number of Indian Movies

```sql
SELECT
TRIM(UNNEST(STRING_TO_ARRAY(casts,','))) AS actor,
COUNT(*) AS total_movies
FROM netflix
WHERE type='Movie'
AND country LIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```

**Objective:** Identify actors with the highest number of appearances in Indian-produced Netflix movies.

---

## 15. Categorize Content Based on Keywords

```sql
SELECT
CASE
WHEN description ILIKE '%kill%'
OR description ILIKE '%violence%'
THEN 'Bad Content'
ELSE 'Good Content'
END AS category,
COUNT(*) AS total_content
FROM netflix
GROUP BY 1;
```

**Objective:** Categorize Netflix titles as **Bad Content** or **Good Content** depending on whether the description contains the keywords **kill** or **violence**.

---

# 🛠 PostgreSQL Concepts Used

- Aggregate Functions
- Window Functions (`RANK()`)
- CASE Statements
- Subqueries
- Data Cleaning
- String Manipulation
- `STRING_TO_ARRAY()`
- `UNNEST()`
- `TRIM()`
- `REPLACE()`
- `LEFT()`
- `TO_DATE()`
- `EXTRACT()`
- Type Casting
- Pattern Matching (`LIKE`, `ILIKE`)
- Date Arithmetic
- GROUP BY
- ORDER BY

---

# 📁 Project Structure

```
Netflix SQL Project
│
├── netflix_titles.csv
├── netflix_data_analysis.sql
└── README.md
```

---

# 📌 Key Learnings

- Learned how to clean and transform messy data using PostgreSQL.
- Worked extensively with comma-separated columns using `UNNEST()` and `STRING_TO_ARRAY()`.
- Applied window functions to solve ranking problems.
- Used date manipulation functions for temporal analysis.
- Built business-oriented SQL solutions rather than simple queries.
- Improved analytical thinking by solving practical SQL interview questions.

---

# 🚀 Skills Demonstrated

- PostgreSQL
- SQL Query Writing
- Data Cleaning
- Data Analysis
- Business Problem Solving
- Exploratory Data Analysis (EDA)
- Window Functions
- Data Transformation

---

# 👨‍💻 Author

**Arnav Khandelwal**

B.E. Mechanical Engineering, BITS Pilani

Interested in Data Analytics, Product Management, Consulting and Business Strategy.

If you found this project helpful, feel free to ⭐ this repository and connect with me!
