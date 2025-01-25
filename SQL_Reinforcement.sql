use imdb;
select * from movie;
select * from genre;
select * from director_mapping;
select * from role_mapping;
select * from names;
select * from ratings;

-- 1.Count the total number of records in each table of the database.
select count(*) as movie_records from movie;
select count(*) as genre_records from genre;
select count(*) as director_mapping_records from director_mapping;
select count(*) as role_mapping_records from role_mapping;
select count(*) as names_records from names;
select count(*) as records from ratings;

-- 2. Identify which columns in the movie table contain null values.
select COUNT(*) - COUNT(title) AS null_count_title ,
 COUNT(*) - COUNT(year) AS null_count_year,
 COUNT(*) - COUNT(date_published) AS null_count_published,
 COUNT(*) - COUNT(duration) AS null_count_duration,
 COUNT(*) - COUNT(country) AS null_count_country,
 COUNT(*) - COUNT(worlwide_gross_income) AS null_count_income,
 COUNT(*) - COUNT(languages) AS null_count_lang,
 COUNT(*) - COUNT(production_company) AS null_count_company 
from movie;

-- 3. Determine the total number of movies released each year, and analyze how the trend changes month-wise.
select 
    year(date_published) AS movie_year,
    month(date_published) AS release_month,
    count(*) AS total_movies
from movie
where date_published IS NOT NULL
group by movie_year, release_month
order by movie_year, release_month ;


-- 4. How many movies were produced in either the USA or India in the year 2019?
select country, count(*) as movie_produced
from movie
where year = 2019 and (country = 'USA' or country = 'India')
group by country;

-- 5. List the unique genres in the dataset, and count how many movies belong exclusively to one genre.
select 
    genre as genres,
    COUNT(*) as movie_count
from genre
group by genres;

-- 6. Which genre has the highest total number of movies produced?
select genre, count(genre) as highest_total
from genre
group by genre
order by highest_total desc limit 1;

-- 7. Calculate the average movie duration for each genre.
select g.genre, avg(m.duration) as average_movie_duration
from movie m
join genre g
on m.id = g.movie_id
group by g.genre;

-- 8. Identify actors or actresses who have appeared in more than three movies with an average rating below 5.
select n.name, rm.category
from names n
join role_mapping rm on n.id = rm.name_id
join ratings r on rm.movie_id = r.movie_id
where r.avg_rating < 5
group by n.name, rm.category
having count(distinct r.movie_id) > 3;

select * from ratings;
select * from names;
select * from role_mapping;

-- 9. Find the minimum and maximum values for each column in the ratings table, excluding the movie_id column.
select 
    min(avg_rating) as min_avg_rating,
    max(avg_rating) as max_avg_rating,
    min(total_votes) as min_total_votes,
    max(total_votes) as max_total_votes,
    min(median_rating) as min_median_rating,
    max(median_rating) as max_median_rating
from ratings;


-- 10. Which are the top 10 movies based on their average rating?
select m.title as movie_name, r.avg_rating
from movie m
join ratings r
on m.id = r.movie_id
order by avg_rating desc
limit 10;

-- 11. Summarize the ratings table by grouping movies based on their median ratings.
 
select median_rating, COUNT(movie_id) AS movie_count
from ratings 
group by median_rating
order by median_rating;

-- 12. How many movies, released in March 2017 in the USA within a specific genre, had more than 1,000 votes?
select g.genre , count(m.id) as movie_count
from movie m
join genre g on m.id = g.movie_id
where m.year = 2017 and month(m.date_published)= 03 and country = 'USA'
	and m.id in(
    select r.movie_id
    from ratings r
    where r.total_votes > 1000)
group by g.genre
order by movie_count;

-- 13. Find movies from each genre that begin with the word “The” and have an average rating greater than 8.
select g.genre , m.title as movie_name
from genre g
join movie m on g.movie_id = m.id
join ratings r on m.id = r.movie_id
where r.avg_rating > 8 and m.title like 'The%'
order by g.genre;
    
-- 14. Of the movies released between April 1, 2018, and April 1, 2019, how many received a median rating of 8?
select count(m.id) as movie_count
from movie m
join ratings r on m.id = r.movie_id
where date_published between '2018-04-01' and '2019-04-01'
		and r.median_rating =8;
        
-- 15. Do German movies receive more votes on average than Italian movies?
select m.country, avg(r.total_votes) AS average_votes
from movie m
join ratings r on m.id = r.movie_id
where m.country in ('Germany', 'Italy')
group by m.country;

-- 16. Identify the columns in the names table that contain null values.
select COUNT(*) - COUNT(id) AS null_id ,
 COUNT(*) - COUNT(name) AS null_in_name,
 COUNT(*) - COUNT(height) AS null_in_height,
 COUNT(*) - COUNT(date_of_birth) AS null_in_dob,
 COUNT(*) - COUNT(known_for_movies) AS null_in_known_movie
from names;

-- 17. Who are the top two actors whose movies have a median rating of 8 or higher?
select n.name as Top_actors, r.median_rating
from role_mapping rm
join names n on rm.name_id = n.id
join ratings r on rm.movie_id = r.movie_id 
where r.median_rating >= 8
order by r.median_rating desc
limit 2;


-- 18. Which are the top three production companies based on the total number of votes their movies received?
select m.production_company, r.total_votes
from movie m
join ratings r on m.id = r.movie_id
order by r.total_votes desc limit 3; 

-- 19. How many directors have worked on more than three movies?
select count(*) as director_count
from (
select name_id from director_mapping
group by name_id
having count(movie_id)>3)as director;

-- 20. Calculate the average height of actors and actresses separately.
select r.category, avg(n.height) as height_average
from names n
join role_mapping r
on n.id = r.name_id
group  by r.category;

-- 21. List the 10 oldest movies in the dataset along with their title, country, and director.
select m.title, m.country, n.name as director, m.date_published
from movie m
join director_mapping d on m.id = d.movie_id
join names n on d.name_id = n.id
order by m.date_published asc limit 10;

-- 22. List the top 5 movies with the highest total votes, along with their genres.
select m.title, r.total_votes, g.genre
from movie m
join ratings r on m.id = r.movie_id
join genre g on g.movie_id = m.id
order by r.total_votes desc limit 5;

-- 23. Identify the movie with the longest duration, along with its genre and production company.
select m.title, g.genre, m.production_company, m.duration
from movie m
join genre g 
on m.id = g.movie_id
order by m.duration desc limit 1;

-- 24. Determine the total number of votes for each movie released in 2018.
select m.title, sum(r.total_votes) as total_votes
from movie m
join ratings r
on m.id = r.movie_id
where m.year = "2018"
group by m.title
order by total_votes desc;

-- 25. What is the most common language in which movies were produced?
select languages, count(languages) as count_lang
from movie
group by languages
order by count_lang desc limit 1;