-- Inner join 
select m.movie_id, title , budget , revenue , currency , unit
FROM movies m
INNER JOIN financials f
ON m.movie_id = f.movie_id;
-- LEFT JOIN
select m.movie_id, title , budget , revenue , currency , unit
FROM movies m
LEFT JOIN financials f
ON m.movie_id = f.movie_id;

-- RIGHT JOIN
select f.movie_id, title , budget , revenue , currency , unit
FROM movies m
RIGHT JOIN financials f
ON m.movie_id = f.movie_id;

-- FULL JOIN

select f.movie_id, title , budget , revenue , currency , unit
FROM movies m
LEFT JOIN financials f
ON m.movie_id = f.movie_id 
UNION
select f.movie_id, title , budget , revenue , currency , unit
FROM movies m
RIGHT JOIN financials f
ON m.movie_id = f.movie_id;

-- Exercise 

-- 1. Show all the movies with their language names
select m.title , l.name as Language
FROM movies m
LEFT JOIN languages l
USING(language_id);
-- 2. Show all Telugu movie names (assuming you don't know the language
-- id for Telugu)
select m.title , l.name as Language
FROM movies m
LEFT JOIN languages l
USING(language_id)
WHERE l.name = 'Telugu';
-- 3. Show the language and number of movies released in that language
select l.name as Language, COUNT(l.language_id) As movies_cnt
FROM movies m
LEFT JOIN languages l
USING(language_id)
GROUP BY l.language_id;

select m.movie_id,title,industry,budget,revenue,unit,currency
, CASE 
     WHEN unit='Thousands' THEN ROUND((revenue-budget)/1000,2)
     WHEN unit='Billions' THEN  ROUND((revenue-budget)*1000,2)
     ELSE ROUND((revenue-budget),2)
   END as profit_mln
from movies m
LEFT JOIN financials f
USING(movie_id)
WHERE industry="bollywood"
ORDER BY profit_mln DESC;

#List movie_name with actor names

select m.movie_id,title,group_concat(name separator " | ") as actors_name
from movies m
JOIN movie_actor ma ON(m.movie_id=ma.movie_id)
JOIN actors a ON(ma.actor_id=a.actor_id)
GROUP BY m.movie_id;

# Result - Actor and movies name She/he has acted in

select a.name ,group_concat(title separator " | ") as movies_names , count(m.movie_id) as no_of_movies
from actors a
JOIN movie_actor ma ON(a.actor_id=ma.actor_id)
JOIN movies m ON(m.movie_id=ma.movie_id)
GROUP BY a.actor_id
ORDER BY no_of_movies DESC;

-- Excercise - JOIN more than one tables
-- 1. Generate a report of all Hindi movies sorted by their revenue amount in millions.
-- Print movie name, revenue, currency, and unit
select m.title as movie_name ,
CASE 
WHEN unit='Billions' THEN ROUND(revenue*1000,2)
WHEN unit='Thousands' THEN ROUND(revenue/1000,2)
ELSE ROUND(revenue,2)
END as revenue_mln,
currency, unit
from movies m
JOIN languages l USING(language_id)
JOIN financials f ON(m.movie_id=f.movie_id)
WHERE l.language_id = 1
ORDER BY revenue_mln DESC;
