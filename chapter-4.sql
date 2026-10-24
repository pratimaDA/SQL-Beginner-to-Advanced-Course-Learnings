-- movie with highest IMDB rating
select * from movies 
WHERE imdb_rating = (select MAX(imdb_rating) from movies );

-- movies with min and max rating
select * from movies
WHERE imdb_rating IN ((select MIN(imdb_rating) from movies) , (select MAX(imdb_rating) from movies));

-- actors whose age is greater than 70 and greater than 85
select name , age
FROM
 (select
name, YEAR(current_date())-birth_year as age
 from actors ) as movie_actors
WHERE age>70 AND age<85;

-- Correlated subqueries - Find actors with the numbers of movies they acted in.
select actor_id , name , 
(select COUNT(*) from movie_actor ma WHERE ma.actor_id = actors.actor_id) as movie_count
FROM actors 
ORDER BY movie_count DESC;

-- same using JOIN and GROUP BY
Explain analyze
select a.actor_id , a.name, COUNT(movie_id) as movie_count
FROM movie_actor ma
JOIN actors a ON a.actor_id = ma.actor_id
GROUP BY ma.actor_id
ORDER BY movie_count DESC;

-- USE Explain analyze for query performance 
-- First number before .. tells time to retrieve one row and second value after .. tells the time taken to retrieve whole result ----
-- actual time=1.977..1.988

--   Exercise --------------------------------------

-- 1. Select all the movies with minimum and maximum release_year. Note that there
-- can be more than one movie in min and a max year hence output rows can be more than 2
select * from movies 
WHERE release_year IN ((select MIN(release_year) from movies) , (select MAX(release_year) from movies) );
    
-- 2. Select all the rows from the movies table whose imdb_rating is higher than the average rating
select * from movies 
HAVING imdb_rating > (select AVG(imdb_rating) from movies);

-- Exercise 
-- Select all Hollywood movies released after the year 2000 that made more than 
-- 500 million $ profit or more profit. Note that all Hollywood movies have millions 
-- as a unit hence you don't need to do the unit conversion. 
-- Also, you can write this query without CTE as well but you should try to write this using CTE only.

With movie_profit as (
Select *, (revenue-budget) as profit
from financials
)
Select m.title as movie_name, m.release_year,m.industry, mp.profit from movies as m
JOIN movie_profit as mp
ON (m.movie_id = mp.movie_id)
WHERE m.industry="Hollywood" AND m.release_year >2000 AND mp.profit>500;


