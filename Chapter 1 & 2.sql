/*-----------------------------------------Basic Text Queries------------------------------------------------*/
Select * from movies;

Select * from movies WHERE industry = "bollywood";

Select COUNT(*) from movies WHERE industry = "bollywood";

Select * from movies WHERE industry = "hollywood";

Select COUNT(*) from movies WHERE industry = "hollywood";   #Find count where industry is hollywood.

Select distinct industry from movies;  #Find unique isdustry.

Select * from movies Where title LIKE '%Thor%';  # Return all movies which has Thor in title.

/*-----------------------------------------Exercise 1-----------------------------------------------------------------------*/

#1. Print all movie titles and release year for all Marvel Studios movies.
Select title , release_year, studio FROm movies WHERE studio='Marvel Studios';
#2. Print all movies that have Avenger in their name.
select * from movies Where title LIKE '%avenger';
#3. Print the year when the movie "The Godfather" was released.
select release_year,title from movies WHERE title='The Godfather';
#4. Print all distinct movie studios in the Bollywood industry.
select studio from movies WHERE industry='bollywood';

/*-----------------------------------------Numeric Queries-------------------------------------------------------------------*/
Select * from movies WHERE imdb_rating>=9;

Select * from movies WHERE imdb_rating BETWEEN 6 AND 8;

SELECT * from movies WHERE release_year IN (2020,2021,2022);   # Use IN operator when there are multiple OR conditions

/*-----------------------------------------Exercise 2-----------------------------------------------------------------------*/

#1. Print all movies in the order of their release year (latest first)
select * from movies ORDER BY release_year DESC;
#2. All movies released in the year 2022
select * from movies WHERE release_year = 2022;
#3. Now all the movies released after 2020
select * from movies WHERE release_year >2020;
#4. All movies after the year 2020 that have more than 8 rating
select * from movies WHERE release_year >2020 AND imdb_rating>8;
#5. Select all movies that are by Marvel studios and Hombale Films
select * from movies WHERE studio IN ('Marvel studios','Hombale Films');

/*-----------------------------------------Aggregate Functions-----------------------------------------------------------------------*/

Select MIN(imdb_rating) AS min_rating ,
 MAX(imdb_rating) as max_rating ,
 AVG(imdb_rating) avg_rating
 FROM movies 
 WHERE studio='Marvel Studios';
 
 select industry , COUNT(*) as cnt
 FROM movies 
 GROUP BY industry;
 
 select studio , COUNT(studio) As cnt, ROUND(AVG(imdb_rating),1) AS avg_rating
 FROM movies
 GROUP BY studio
 ORDER BY avg_rating DESC;
 
--  Exercise - Summary analytics (MIN, MAX, AVG, GROUP BY)

-- 1. How many movies were released between 2015 and 2022
select count(*) cnt_of_movies from movies WHERE release_year BETWEEN 2015 AND 2022;
-- 2. Print the max and min movie release year
select MAX(release_year) max_release_year, MIN(release_year) as min_release_year FROM movies;
-- 3. Print each year along with the number of movies released in that year, starting from the most recent year
select release_year , COUNT(*) as no_of_movies_released FROM movies 
GROUP BY release_year 
ORDER BY release_year DESC;

/*-----------------------------------------Calculated Columns-----------------------------------------------------------------------*/
select *,YEAR(current_date())-birth_year AS age from actors;    #find age of actors

select *,revenue-budget AS profit from financials;    #calculate profit

select *, IF(currency='USD',revenue*77,revenue) AS reveue_inr from financials;      #convert USD revenue to INR revenue

select 
*,CASE 
    WHEN unit="Billions" THEN revenue*1000
    WHEN unit="Thousands" THEN revenue/1000
    ELSE revenue
END as revenue_millons
from financials; 

/*-------------------------------------------------------------Exercise-----------------------------------------------------------------------*/
-- 1. Print profit % for all the movies
select movie_id,revenue-budget AS profit , ((revenue-budget)/budget)*100 as profit_pct from financials;



