USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

-- using UNION clause, to get the counts in a single result
SELECT 'director_mapping' AS "table_name",
       Count(*)  AS "row_count"
FROM   director_mapping
UNION
SELECT 'genre'  AS "table_name",
       Count(*) AS "row_count"
FROM   genre
UNION
SELECT 'movie'  AS "table_name",
       Count(*) AS "row_count"
FROM   movie
UNION
SELECT 'names'  AS "table_name",
       Count(*) AS "row_count"
FROM   names
UNION
SELECT 'ratings' AS "table_name",
       Count(*)  AS "row_count"
FROM   ratings
UNION
SELECT 'role_mapping' AS "table_name",
       Count(*)       AS "row_count"
FROM   role_mapping;
/*                  
TABLE NAME      ROW COUNTS:
director_mapping  3867
genre        14662
movie        7997
names        25735
ratings        7997
role_mapping    15615
*/

-- Q2. Which columns in the movie table have null values?
-- Type your code below:
WITH null_columns
     AS (SELECT CASE
                  WHEN id IS NULL THEN 'id'
                  WHEN title IS NULL THEN 'title'
                  WHEN year IS NULL THEN 'year'
                  WHEN date_published IS NULL THEN 'date_published'
                  WHEN duration IS NULL THEN 'duration'
                  WHEN country IS NULL THEN 'country'
                  WHEN worlwide_gross_income IS NULL THEN
                  'worlwide_gross_income'
                  WHEN languages IS NULL THEN 'languages'
                  WHEN production_company IS NULL THEN 'production_company'
                END AS null_col
         FROM   movie
         GROUP  BY null_col)
SELECT null_col
FROM   null_columns
WHERE  null_col IS NOT NULL; 
-- filter used in where clause, since the columns which dont have null values, 
-- will return null as per the logic within "null_columns" CTE
-- (worlwide_gross_income,production_company,country,languages) have null values


-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Movies released each year
SELECT year,
       Count(DISTINCT title) AS number_of_movies
FROM   movie
GROUP  BY year; 

-- Monthwise trend of releases
SELECT Month(date_published) AS month_num,
       Count(DISTINCT title) AS number_of_movies
FROM   movie
GROUP  BY month_num; 

/* 
	1. 2017 had the most releases (3036)
	2. The months of March(823), September(807), October(801), and January (804) 
		have had more releases (>800).
	3. The count of releases during the period of April-July, show a downward trend,
		and December has had the least number of releases 
*/

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:
SELECT Count(DISTINCT title) AS productions
FROM   movie
WHERE  ( Upper(country) LIKE '%INDIA%'
          -- UPPER() to eliminate case related misses, in strings.
          OR Upper(country) LIKE '%USA%' )
       -- 'LIKE' used, since multiple country combinations are present.
       AND year = 2019; 

-- USA and India have had 1056 releases, in 2019.

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT genre
FROM genre
GROUP BY genre;

-- There are 13 genres in total.


/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:


WITH movie_genre_count
     AS (SELECT genre,
                Count(movie_id) AS movies_count,
                Dense_rank()
                  OVER(
                    ORDER BY Count(movie_id) DESC) AS genre_rank
         FROM   genre
         GROUP  BY genre)
SELECT genre,
       movies_count
FROM   movie_genre_count
WHERE  genre_rank = 1; 

-- Most movies produced, were under "Drama" genre (4285 movies).

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:
WITH movie_genre_count
     AS (SELECT movie_id,
                Count(genre) AS genre_count
         FROM   genre
         GROUP  BY movie_id
         HAVING genre_count = 1)
SELECT Count(movie_id) AS single_genre_movies
FROM   movie_genre_count; 

-- 3289 movies, are tagged to only one genre

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT genre,
       Avg(duration) AS avg_duration
FROM   movie
       INNER JOIN genre
               ON movie.id = genre.movie_id
GROUP  BY genre
ORDER  BY avg_duration DESC; 

-- Genre "Action" has the highest avg. duration of 112.88 mins.

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

WITH movie_count_table
     AS (SELECT genre,
                Count(title) AS movie_count
         FROM   movie
                INNER JOIN genre
                        ON genre.movie_id = movie.id
         GROUP  BY genre)
SELECT *
FROM   (SELECT *,													
               Rank()												
                 OVER (
                   ORDER BY movie_count DESC ) AS genre_rank
        FROM   movie_count_table) rs								-- Used subquery, to rank across all genres
WHERE  genre = 'thriller'; 											-- And then filter

-- Thriller has a movie count of 1484, which places it in #3 among genres, ranked in terms of no.of movies.


/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

SELECT Min(avg_rating)    AS min_avg_rating,
       Max(avg_rating)    AS max_avg_rating,
       Min(total_votes)   AS min_total_votes,
       Max(total_votes)   AS max_total_votes,
       Min(median_rating) AS min_median_rating,
       Max(median_rating) AS max_median_rating
FROM   ratings; 




    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

SELECT     title ,
           avg_rating ,
           Dense_rank() over ( ORDER BY avg_rating DESC ) AS movie_rank
FROM       movie
INNER JOIN ratings
ON         movie.id = ratings.movie_id
LIMIT      10;

-- The top movies based on avg_rating are Kirker and Love in Kilnerry
-- Both with avg_rating of 10.

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT median_rating,
       Count(title) AS movie_count
FROM   movie
       INNER JOIN ratings
               ON movie.id = ratings.movie_id
GROUP  BY median_rating
ORDER  BY movie_count DESC;				-- DESC, to quickly find the median rating, with most no.of movies.


/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

WITH aggregated_movie
     AS (SELECT production_company,
                Count(title)                     AS movie_count,
                Rank()
                  OVER (
                    ORDER BY Count(title) DESC ) AS prod_company_rank
         FROM   movie
                INNER JOIN ratings
                        ON movie.id = ratings.movie_id
         WHERE  avg_rating > 8
                AND production_company IS NOT NULL
         GROUP  BY production_company)
SELECT *
FROM   aggregated_movie
WHERE  prod_company_rank = 1; 						-- Used 'rank' in the CTE and 'where' as filter,
													-- instead of 'limit', as a best practice

-- Dream Warrior Picture and National Theatre Live, both have same hit movies count (3).

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH voted_movies
AS
  (
             SELECT     id ,
                        title
             FROM       movie
             INNER JOIN ratings
             ON         movie.id = ratings.movie_id
             WHERE      total_votes > 1000
             AND        year = 2017
             AND        month(date_published) = 3
             AND        Upper(country) LIKE '%USA%' )        -- Used Upper(), to eliminate case related differences.
  SELECT     genre ,
             count(title) AS movie_count
  FROM       voted_movies
  INNER JOIN genre
  WHERE      voted_movies.id = genre.movie_id
  GROUP BY   genre
  ORDER BY   movie_count DESC;

-- Drama, with 24 movies, has had the most movies in 2017 in the USA, with more than 1000 votes.

-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

SELECT title,
       avg_rating,
       genre
FROM   movie
       INNER JOIN ratings
               ON movie.id = ratings.movie_id
       INNER JOIN genre
               ON movie.id = genre.movie_id
WHERE  Upper(title) LIKE 'THE%'          			-- Used Upper(), to eliminate case related differences.     
       AND avg_rating > 8
ORDER  BY avg_rating DESC; 



-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:
SELECT Count(movie_id)
FROM   ratings
WHERE  median_rating = 8
       AND movie_id IN (SELECT id
                        FROM   movie
                        WHERE  date_published BETWEEN
                               '2018-04-01' AND '2019-04-01'
                        GROUP  BY id); 

-- 361 movies have released between 1 April 2018 and 1 April 2019, with median rating=8.

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:
SELECT CASE
         WHEN Sum(CASE
                    WHEN Upper(movie.languages) LIKE '%GERMAN%' THEN
                    ratings.total_votes
                    ELSE 0
                  end) > Sum(CASE
                               WHEN Upper(movie.languages) LIKE '%ITALIAN%' THEN
                               ratings.total_votes
                               ELSE 0
                             end) THEN 'yes'
         ELSE 'no'
       end AS German_movie_is_popular
FROM   movie
       INNER JOIN ratings
               ON movie.id = ratings.movie_id
WHERE Upper(movie.languages) LIKE '%GERMAN%'
        OR Upper(movie.languages) LIKE '%ITALIAN%' ; 

-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
SELECT Sum(CASE
             WHEN name IS NULL THEN 1
             ELSE 0
           end) AS name_nulls,
       Sum(CASE
             WHEN height IS NULL THEN 1
             ELSE 0
           end) AS height_nulls,
       Sum(CASE
             WHEN date_of_birth IS NULL THEN 1
             ELSE 0
           end) AS date_of_birth_nulls,
       Sum(CASE
             WHEN known_for_movies IS NULL THEN 1
             ELSE 0
           end) AS known_for_movies_nulls
FROM   names; 


/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
WITH top_genres
AS
  (
             SELECT     genre,
                        count(movie.id)  AS movie_count,
                        rank() over(ORDER BY count(movie.id) DESC) AS genre_rank
             FROM       movie
             INNER JOIN genre
             ON         genre.movie_id = movie.id
             INNER JOIN ratings
             ON         ratings.movie_id = movie.id
             WHERE      avg_rating > 8
             GROUP BY   genre
             )
  SELECT     names.name AS director_name ,
             count(director_mapping.movie_id) AS movie_count
  FROM       director_mapping
  INNER JOIN genre
  USING     (movie_id)
  INNER JOIN names
  ON         names.id = director_mapping.name_id
  INNER JOIN top_genres
  USING     (genre)
  INNER JOIN ratings
  USING      (movie_id)
  WHERE      avg_rating > 8
  AND genre_rank<=3											-- Using Window func in CTE, and "Where", instead of "limit"
  GROUP BY   name
  ORDER BY   movie_count DESC
  LIMIT      3 ;

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT name         AS actor_name,
       Count(title) AS movie_count
FROM   movie
       INNER JOIN role_mapping
               ON movie.id = role_mapping.movie_id
       INNER JOIN ratings
               ON movie.id = ratings.movie_id
       INNER JOIN names
               ON role_mapping.name_id = names.id
WHERE  median_rating >= 8
GROUP  BY name
ORDER  BY movie_count DESC
LIMIT  2; 

-- Mamootty as the most movies, with a median rating>=8, followed by Mohanlal.

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT     production_company,
           Sum(ratings.total_votes) AS vote_count,
           Dense_rank() over(ORDER BY sum(ratings.total_votes)DESC) AS prod_comp_rank
FROM       movie
INNER JOIN ratings
ON         movie.id=ratings.movie_id
GROUP BY   production_company
LIMIT      3;

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
CREATE VIEW indian_movies
AS
  SELECT *
  FROM   movie
  WHERE  country LIKE '%india%';

WITH actor_ratings
     AS (SELECT NAME,
                Sum(total_votes)                                 AS total_votes,
                Count(title)                                     AS movie_count,
                Sum(avg_rating * total_votes) / Sum(total_votes) AS
                actor_avg_rating
         FROM   role_mapping
                INNER JOIN indian_movies
                        ON role_mapping.movie_id = indian_movies.id
                INNER JOIN names
                        ON role_mapping.name_id = names.id
                INNER JOIN ratings
                        ON indian_movies.id = ratings.movie_id
         WHERE  category = 'actor'
         GROUP  BY NAME
         HAVING movie_count >= 5
         ORDER  BY actor_avg_rating DESC)
SELECT *,
       Dense_rank()
         OVER (
           ORDER BY actor_avg_rating DESC, total_votes DESC ) AS actor_rank
FROM   actor_ratings; 

-- Top actor is Vijay Sethupathi. He is followed by Fahaad Faasil.

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
CREATE view indian_hindi_movies AS
SELECT *
FROM   movie
WHERE  country LIKE '%india%'
AND    languages LIKE '%hindi%';

WITH actress_ratings
AS
  (
             SELECT     name ,
                        sum(total_votes)                                 AS total_votes ,
                        count(title)                                     AS movie_count ,
                        sum(avg_rating * total_votes) / sum(total_votes) AS actress_avg_rating
             FROM       role_mapping
             INNER JOIN indian_hindi_movies
             ON         role_mapping.movie_id = indian_hindi_movies.id
             INNER JOIN names
             ON         role_mapping.name_id = names.id
             INNER JOIN ratings
             ON         indian_hindi_movies.id = ratings.movie_id
             WHERE      category = 'actress'
             GROUP BY   name
             HAVING     count(title) >= 3
             ORDER BY   actress_avg_rating DESC )
  SELECT   * ,
           dense_rank() over ( ORDER BY actress_avg_rating DESC ,total_votes DESC ) AS actress_rank
  FROM     actress_ratings
  LIMIT    5;

/* Taapsee Pannu tops with average rating 7.74. Kriti Sanon is 2nd, with an avg.rating of 7.049.
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:
SELECT m.title AS movie_name,
       CASE
         WHEN avg_rating > 8 THEN 'Superhit movies'
         WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
         WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
         WHEN avg_rating < 5 THEN 'Flop movies'
       end     AS movie_category
FROM   (SELECT movie_id
        FROM   genre
        WHERE  Upper(genre) = 'THRILLER'
        GROUP  BY movie_id,
                  genre) g
       INNER JOIN (SELECT id,
                          title
                   FROM   movie
                   GROUP  BY id,
                             title) m
               ON m.id = g.movie_id
       INNER JOIN (SELECT movie_id,
                          avg_rating
                   FROM   ratings
                   GROUP  BY movie_id,
                             avg_rating) r
               ON r.movie_id = g.movie_id; 


/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
WITH genre_average
AS
  (
             SELECT     g.genre,
                        round(avg(m.duration),2) AS avg_duration
             FROM       (
                                 SELECT   id,
                                          duration
                                 FROM     movie
                                 GROUP BY id,
                                          duration ) m
             INNER JOIN genre g
             ON         g.movie_id=m.id
             GROUP BY   g.genre )
  SELECT   *,
           sum(round(avg(avg_duration),2)) over genres AS running_total_duration,
           round(avg(avg_duration) over genres,2)      AS moving_avg_duration
  FROM     genre_average
  GROUP BY genre window genres AS (ORDER BY genre rows unbounded preceding);

-- Romance movies have the highest average duration, of 109.53 mins.

-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies

CREATE view movie_transformed AS
SELECT * ,
       CASE
              WHEN worlwide_gross_income LIKE '$%' THEN Trim(Substring(worlwide_gross_income, 2))
              ELSE Trim(Substring(worlwide_gross_income, 4))
       end AS transformed_total
FROM   movie;

CREATE view top_three_genres_based_on_number AS
SELECT     genre
FROM       genre
INNER JOIN movie
ON         genre.movie_id = movie.id
GROUP BY   genre
ORDER BY   Count(title) DESC
LIMIT      3;

WITH filtered_movies
AS
  (
             SELECT     genre ,
                        year ,
                        title                             AS movie_name ,
                        CONVERT(transformed_total, FLOAT) AS transformed_total
             FROM       movie_transformed
             INNER JOIN genre
             ON         genre.movie_id = movie_transformed.id
             WHERE      genre IN
                        (
                               SELECT genre
                               FROM   top_three_genres_based_on_number ) )
  SELECT genre ,
         year ,
         movie_name ,
         transformed_total AS worldwide_gross_income ,
         movie_rank
  FROM   (
                  SELECT   * ,
                           dense_rank() over ( partition BY year ORDER BY transformed_total DESC ) AS movie_rank
                  FROM     filtered_movies ) AS rs
  WHERE  movie_rank <= 5;


-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

WITH actress_summary
AS
  (
             SELECT     name                      AS actress_name ,
                        sum(total_votes)          AS total_votes ,
                        count(title)              AS movie_count ,
                        round(avg(avg_rating), 2) AS actress_avg_rating
             FROM       movie
             INNER JOIN ratings
             ON         movie.id = ratings.movie_id
             INNER JOIN genre
             ON         movie.id = genre.movie_id
             INNER JOIN role_mapping
             ON         movie.id = role_mapping.movie_id
             INNER JOIN names
             ON         role_mapping.name_id = names.id
             WHERE      avg_rating > 8
             AND        genre LIKE '%drama%'
             AND        category = 'actress'
             GROUP BY   name )
  SELECT   * ,
           rank() over ( ORDER BY actress_avg_rating ) AS actress_rank
  FROM     actress_summary
  ORDER BY actress_rank ,
           total_votes DESC
  LIMIT    3;



-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH actress_summary
AS (
	SELECT NAME AS actress_name
		,sum(total_votes) AS total_votes
		,count(title) AS movie_count
		,ROUND(avg(avg_rating), 2) AS actress_avg_rating
	FROM movie
	INNER JOIN ratings ON movie.id = ratings.movie_id
	INNER JOIN genre ON movie.id = genre.movie_id
	INNER JOIN role_mapping ON movie.id = role_mapping.movie_id
	INNER JOIN names ON role_mapping.name_id = names.id
	WHERE avg_rating > 8
		AND genre LIKE '%drama%'
		AND category = 'actress'
	GROUP BY NAME
	)
SELECT *
	,RANK() OVER (
		ORDER BY actress_avg_rating
		) AS actress_rank
FROM actress_summary
ORDER BY actress_rank
	,total_votes DESC limit 3;






/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:
CREATE view director_movie_summary AS
            (
                       SELECT     n.id               AS director_id ,
                                  n.name             AS director_name ,
                                  Count(m.title)     AS number_of_movies ,
                                  Avg(r.avg_rating)  AS avg_rating ,
                                  Sum(r.total_votes) AS total_votes ,
                                  Min(r.avg_rating)  AS min_rating ,
                                  Max(r.avg_rating)  AS max_rating ,
                                  Sum(m.duration)    AS total_duration
                       FROM       movie              AS m
                       INNER JOIN ratings            AS r
                       ON         m.id = r.movie_id
                       INNER JOIN director_mapping AS dr
                       ON         dr.movie_id = m.id
                       INNER JOIN names AS n
                       ON         n.id = dr.name_id
                       GROUP BY   n.name ,
                                  n.id
                       ORDER BY   number_of_movies DESC
                       LIMIT      9
            );


WITH director_release_dates
AS
  (
             SELECT     name_id AS director_id ,
                        date_published ,
                        lead(date_published, 1) over ( partition BY name_id ORDER BY date_published ) AS next_release
             FROM       movie
             INNER JOIN director_mapping
             ON         movie.id = director_mapping.movie_id
             WHERE      director_mapping.name_id IN
                        (
                               SELECT director_id
                               FROM   director_movie_summary )
             ORDER BY   director_id ,
                        date_published )
  ,director_inter_movie_days
AS
  (
           SELECT   director_id ,
                    avg(datediff(next_release, date_published)) AS avg_inter_movie_days
           FROM     director_release_dates
           GROUP BY director_id )
  SELECT     d.director_id,
             director_name,
             number_of_movies,
             avg_inter_movie_days,
             avg_rating,
             total_votes,
             min_rating,
             max_rating,
             total_duration
  FROM       director_inter_movie_days AS d
  INNER JOIN director_movie_summary    AS s
  ON         d.director_id = s.director_id
  ORDER BY   number_of_movies DESC;







