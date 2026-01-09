CREATE DATABASE restaurant_Analysis;
USE restaurant_Analysis;
-- creating table consumers
CREATE TABLE consumers (
    consumer_id VARCHAR(10) PRIMARY KEY,
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    smoker VARCHAR(10),
    drink_level VARCHAR(20),
    transportation_method VARCHAR(30),
    marital_status VARCHAR(20),
    children VARCHAR(20),
    age INT,
    occupation VARCHAR(50),
    budget VARCHAR(20)
);
SELECT * FROM consumers;

-- creating table consumer_preferences
CREATE TABLE consumer_preferences (
    consumer_id VARCHAR(10),
    preferred_cuisine VARCHAR(50),
    PRIMARY KEY (consumer_id, preferred_cuisine),
    FOREIGN KEY (consumer_id) REFERENCES consumers(consumer_id)
);

SELECT * FROM consumer_preferences;

-- creating table restaurants
CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    zip_code VARCHAR(10),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    alcohol_service VARCHAR(20),
    smoking_allowed VARCHAR(20),
    price VARCHAR(20),
    franchise VARCHAR(10),
    area VARCHAR(30),
    parking VARCHAR(30)
);

SELECT * FROM restaurants;

-- creating table restaurant_cuisines

CREATE TABLE restaurant_cuisines (
    restaurant_id INT,
    cuisine VARCHAR(50),
    PRIMARY KEY (restaurant_id, cuisine),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

SELECT * FROM restaurant_cuisines;

-- creating table ratings
CREATE TABLE ratings (
    consumer_id VARCHAR(10),
    restaurant_id INT,
    overall_rating INT,
    food_rating INT,
    service_rating INT,
    PRIMARY KEY (consumer_id, restaurant_id),
    FOREIGN KEY (consumer_id) REFERENCES consumers(consumer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

SELECT * FROM ratings;
SELECT * FROM consumers;
SELECT * FROM restaurant_cuisines;
SELECT * FROM restaurants;
SELECT * FROM consumer_preferences;

/* Using the WHERE clause to filter data based on specific criteria.*/

-- 1.List all details of consumers who live in the city of 'Cuernavaca'.
SELECT * FROM consumers 
WHERE city = 'Cuernavaca';

-- 2.Find the Consumer_ID, Age, and Occupation of all consumers who are 'Students' AND are 'Smokers'.
SELECT Consumer_ID, Age, Occupation  
FROM consumers 
WHERE Occupation='Students' AND Smoker = 'Yes';

-- 3.List the Name, City, Alcohol_Service, and Price of all restaurants that serve 'Wine & Beer' and have a 'Medium' price level.
SELECT name, city, alcohol_service, price
FROM restaurants
WHERE alcohol_service = 'Wine & Beer'
  AND price = 'Medium';

-- 4.Find the names and cities of all restaurants that are part of a 'Franchise'.
SELECT name, city
FROM restaurants
WHERE franchise = 'Yes';

-- 5.Show the Consumer_ID, Restaurant_ID, and Overall_Rating for all ratings where the Overall_Rating was 'Highly Satisfactory' (which corresponds to a value of 2, according to the data dictionary).
SELECT consumer_id, restaurant_id, overall_rating
FROM ratings
WHERE overall_rating = 2;

-- Questions JOINs with Subqueries

-- 1.List the names and cities of all restaurants that have an Overall_Rating of 2 (Highly Satisfactory) from at least one consumer.
SELECT DISTINCT r.name, r.city
FROM restaurants r
JOIN ratings rt
ON r.restaurant_id = rt.restaurant_id
WHERE rt.overall_rating = 2;

-- 2.Find the Consumer_ID and Age of consumers who have rated restaurants located in 'San Luis Potosi'.
SELECT DISTINCT c.consumer_id, c.age
FROM consumers c
JOIN ratings rt ON c.consumer_id = rt.consumer_id
JOIN restaurants r ON rt.restaurant_id = r.restaurant_id
WHERE r.city = 'San Luis Potosi';

-- 3.List the names of restaurants that serve 'Mexican' cuisine and have been rated by consumer 'U1001'.
SELECT DISTINCT r.name
FROM restaurants r
JOIN restaurant_cuisines rc ON r.restaurant_id = rc.restaurant_id
JOIN ratings rt ON r.restaurant_id = rt.restaurant_id
WHERE rc.cuisine = 'Mexican' AND rt.consumer_id = 'U1001';

-- 4.Find all details of consumers who prefer 'American' cuisine AND have a 'Medium' budget.
SELECT DISTINCT c.*
FROM consumers c
JOIN consumer_preferences cp
ON c.consumer_id = cp.consumer_id
WHERE cp.preferred_cuisine = 'American' AND c.budget = 'Medium';

-- 5.List restaurants (Name, City) that have received a Food_Rating lower than the average Food_Rating across all rated restaurants.
SELECT DISTINCT r.name, r.city
FROM restaurants r
JOIN ratings rt ON r.restaurant_id = rt.restaurant_id
WHERE rt.food_rating <
      (SELECT AVG(food_rating) FROM ratings);

-- 6.Find consumers (Consumer_ID, Age, Occupation) who have rated at least one restaurant but have NOT rated any restaurant that serves 'Italian' cuisine.
SELECT DISTINCT c.consumer_id, c.age, c.occupation
FROM consumers c
JOIN ratings rt ON c.consumer_id = rt.consumer_id
WHERE c.consumer_id NOT IN (
    SELECT rt2.consumer_id
    FROM ratings rt2
    JOIN restaurant_cuisines rc
    ON rt2.restaurant_id = rc.restaurant_id
    WHERE rc.cuisine = 'Italian'
);

-- 7.List restaurants (Name) that have received ratings from consumers older than 30.
SELECT DISTINCT r.name
FROM restaurants r
JOIN ratings rt ON r.restaurant_id = rt.restaurant_id
JOIN consumers c ON rt.consumer_id = c.consumer_id
WHERE c.age > 30;


-- 8.Find the Consumer_ID and Occupation of consumers whose preferred cuisine is 'Mexican' and who have given an Overall_Rating of 0 to at least one restaurant (any restaurant).
SELECT DISTINCT c.consumer_id, c.occupation
FROM consumers c
JOIN consumer_preferences cp ON c.consumer_id = cp.consumer_id
JOIN ratings rt ON c.consumer_id = rt.consumer_id
WHERE cp.preferred_cuisine = 'Mexican'
  AND rt.overall_rating = 0;


-- 9.List the names and cities of restaurants that serve 'Pizzeria' cuisine and are located in a city where at least one 'Student' consumer lives.
SELECT DISTINCT r.name, r.city
FROM restaurants r
JOIN restaurant_cuisines rc ON r.restaurant_id = rc.restaurant_id
WHERE rc.cuisine = 'Pizzeria'
  AND r.city IN (
      SELECT city
      FROM consumers
      WHERE occupation = 'Student'
  );

-- 10.Find consumers (Consumer_ID, Age) who are 'Social Drinkers' and have rated a restaurant that has 'No' parking.
SELECT DISTINCT c.consumer_id, c.age
FROM consumers c
JOIN ratings rt ON c.consumer_id = rt.consumer_id
JOIN restaurants r ON rt.restaurant_id = r.restaurant_id
WHERE c.drink_level = 'Social Drinker' AND r.parking = 'No';

-- Questions Emphasizing WHERE Clause and Order of Execution

/* 1.List Consumer_IDs and the count of restaurants they've rated, but only for consumers who are 'Students'. 
Show only students who have rated more than 2 restaurants.*/
SELECT c.consumer_id, COUNT(rt.restaurant_id) AS rating_count
FROM consumers c
JOIN ratings rt ON c.consumer_id = rt.consumer_id
WHERE c.occupation = 'Student'
GROUP BY c.consumer_id
HAVING COUNT(rt.restaurant_id) > 2;


/* 2.We want to categorize consumers by an 'Engagement_Score' which is their Age divided by 10 (integer division). 
List the Consumer_ID, Age, and this calculated Engagement_Score, but only for consumers whose Engagement_Score would be exactly 2 and who use 'Public' transportation.*/
SELECT consumer_id, age, age DIV 10 AS engagement_score
FROM consumers
WHERE age DIV 10 = 2
  AND transportation_method = 'Public';


/* 3.For each restaurant, calculate its average Overall_Rating. Then, list the restaurant Name, City, and its calculated average Overall_Rating, 
but only for restaurants located in 'Cuernavaca' AND whose calculated average Overall_Rating is greater than 1.0.*/
SELECT r.name, r.city, AVG(rt.overall_rating) AS avg_rating
FROM restaurants r
JOIN ratings rt ON r.restaurant_id = rt.restaurant_id
WHERE r.city = 'Cuernavaca'
GROUP BY r.restaurant_id, r.name, r.city
HAVING AVG(rt.overall_rating) > 1.0;


/* 4.Find consumers (Consumer_ID, Age) who are 'Married' and whose Food_Rating for any restaurant is equal to their Service_Rating for that same restaurant, 
but only consider ratings where the Overall_Rating was 2.*/
SELECT DISTINCT c.consumer_id, c.age
FROM consumers c
JOIN ratings rt ON c.consumer_id = rt.consumer_id
WHERE c.marital_status = 'Married'AND rt.food_rating = rt.service_rating
AND rt.overall_rating = 2;


/* 5.List Consumer_ID, Age, and the Name of any restaurant they rated, but only for consumers who are 'Employed' 
and have given a Food_Rating of 0 to at least one restaurant located in 'Ciudad Victoria'.*/
SELECT DISTINCT c.consumer_id, c.age, r.name
FROM consumers c
JOIN ratings rt ON c.consumer_id = rt.consumer_id
JOIN restaurants r ON rt.restaurant_id = r.restaurant_id
WHERE c.occupation = 'Employed' AND rt.food_rating = 0
AND r.city = 'Ciudad Victoria';


-- Advanced SQL Concepts: Derived Tables, CTEs, Window Functions, Views, Stored Procedures

/* 1.Using a CTE, find all consumers who live in 'San Luis Potosi'. Then, list their Consumer_ID, Age, and the Name of any Mexican
 restaurant they have rated with an Overall_Rating of 2.*/
WITH slp_consumers AS (
    SELECT consumer_id, age
    FROM consumers
    WHERE city = 'San Luis Potosi'
)
SELECT sc.consumer_id,
       sc.age,
       r.name AS restaurant_name
FROM slp_consumers sc
INNER JOIN ratings rt
    ON sc.consumer_id = rt.consumer_id
INNER JOIN restaurant_cuisines rc
    ON rt.restaurant_id = rc.restaurant_id
INNER JOIN restaurants r
    ON rc.restaurant_id = r.restaurant_id
WHERE rc.cuisine = 'Mexican'
  AND rt.overall_rating = 2;



/* 2.For each Occupation, find the average age of consumers. Only consider consumers who have made at least one rating. 
(Use a derived table to get consumers who have rated).*/
SELECT c.occupation,
       AVG(c.age) AS avg_age
FROM consumers c
INNER JOIN (
    SELECT DISTINCT consumer_id
    FROM ratings
) rated_consumers
    ON c.consumer_id = rated_consumers.consumer_id
GROUP BY c.occupation;



/* 3.Using a CTE to get all ratings for restaurants in 'Cuernavaca', rank these ratings within each restaurant based on
 Overall_Rating (highest first). Display Restaurant_ID, Consumer_ID, Overall_Rating, and the RatingRank.*/
WITH cuernavaca_ratings AS (
    SELECT rt.restaurant_id,
           rt.consumer_id,
           rt.overall_rating
    FROM ratings rt
    INNER JOIN restaurants r
        ON rt.restaurant_id = r.restaurant_id
    WHERE r.city = 'Cuernavaca'
)
SELECT restaurant_id,
       consumer_id,
       overall_rating,
       RANK() OVER (
           PARTITION BY restaurant_id
           ORDER BY overall_rating DESC
       ) AS RatingRank
FROM cuernavaca_ratings;


/*4.For each rating, show the Consumer_ID, Restaurant_ID, Overall_Rating, and also display the average Overall_Rating 
given by that specific consumer across all their ratings.*/
SELECT rt.consumer_id,
       rt.restaurant_id,
       rt.overall_rating,
       AVG(rt.overall_rating) OVER (
           PARTITION BY rt.consumer_id
       ) AS consumer_avg_rating
FROM ratings rt;


/* 5.Using a CTE, identify students who have a 'Low' budget. Then, for each of these students, 
list their top 3 most preferred cuisines based on the order they appear in the Consumer_Preferences table 
(assuming no explicit preference order, use Consumer_ID, Preferred_Cuisine to define order for ROW_NUMBER).*/
WITH low_budget_students AS (
    SELECT consumer_id
    FROM consumers
    WHERE occupation = 'Student'
      AND budget = 'Low'
)
SELECT consumer_id,
       preferred_cuisine
FROM (
    SELECT cp.consumer_id,
           cp.preferred_cuisine,
           ROW_NUMBER() OVER (
               PARTITION BY cp.consumer_id
               ORDER BY cp.consumer_id, cp.preferred_cuisine
           ) AS rn
    FROM consumer_preferences cp
    INNER JOIN low_budget_students lbs
        ON cp.consumer_id = lbs.consumer_id
) ranked
WHERE rn <= 3;


/* 6.Consider all ratings made by 'Consumer_ID' = 'U1008'. For each rating, show the Restaurant_ID, Overall_Rating, and the Overall_Rating 
of the next restaurant they rated (if any), ordered by Restaurant_ID (as a proxy for time if rating time isn't available). 
Use a derived table to filter for the consumer's ratings first.*/
SELECT restaurant_id,
       overall_rating,
       LEAD(overall_rating) OVER (
           ORDER BY restaurant_id
       ) AS next_overall_rating
FROM (
    SELECT restaurant_id, overall_rating
    FROM ratings
    WHERE consumer_id = 'U1008'
) t;



/* 7.Create a VIEW named HighlyRatedMexicanRestaurants that shows the Restaurant_ID, Name, and 
City of all Mexican restaurants that have an average Overall_Rating greater than 1.5.*/
CREATE VIEW HighlyRatedMexicanRestaurants AS
SELECT r.restaurant_id,
       r.name,
       r.city
FROM restaurants r
INNER JOIN restaurant_cuisines rc
    ON r.restaurant_id = rc.restaurant_id
INNER JOIN ratings rt
    ON r.restaurant_id = rt.restaurant_id
WHERE rc.cuisine = 'Mexican'
GROUP BY r.restaurant_id, r.name, r.city
HAVING AVG(rt.overall_rating) > 1.5;

SELECT * FROM HighlyRatedMexicanRestaurants;


/* 8.First, ensure the HighlyRatedMexicanRestaurants view from Q7 exists. Then, using a CTE to find consumers who prefer 'Mexican' cuisine,
 list those consumers (Consumer_ID) who have not rated any restaurant listed in the HighlyRatedMexicanRestaurants view. */
WITH mexican_lovers AS (
    SELECT DISTINCT consumer_id
    FROM consumer_preferences
    WHERE preferred_cuisine = 'Mexican'
)
SELECT ml.consumer_id
FROM mexican_lovers ml
LEFT JOIN ratings rt
    ON ml.consumer_id = rt.consumer_id
LEFT JOIN HighlyRatedMexicanRestaurants h
    ON rt.restaurant_id = h.restaurant_id
WHERE h.restaurant_id IS NULL;


/* 9.Create a stored procedure GetRestaurantRatingsAboveThreshold that accepts a Restaurant_ID and a minimum Overall_Rating as input.
 It should return the Consumer_ID, Overall_Rating, Food_Rating, and Service_Rating for that restaurant where the Overall_Rating meets or exceeds the threshold.*/
CALL GetRestaurantRatingsAboveThreshold(132560, 1);

SELECT DISTINCT restaurant_id
FROM ratings;

SELECT DISTINCT restaurant_id
FROM restaurants;

SELECT *
FROM ratings
WHERE restaurant_id = 132568;

CALL GetRestaurantRatingsAboveThreshold(132564, 0);

CALL GetRestaurantRatingsAboveThreshold(132572, 0);


/* 10.Identify the top 2 highest-rated (by Overall_Rating) restaurants for each cuisine type. If there are ties in rating, 
include all tied restaurants. Display Cuisine, Restaurant_Name, City, and Overall_Rating.*/
WITH RankedRestaurants AS (
    SELECT 
        rc.cuisine,
        r.name AS restaurant_name,
        r.city,
        rt.overall_rating,
        DENSE_RANK() OVER (
            PARTITION BY rc.cuisine 
            ORDER BY rt.overall_rating DESC
        ) AS rating_rank
    FROM restaurant_cuisines rc
    INNER JOIN restaurants r 
        ON rc.restaurant_id = r.restaurant_id
    INNER JOIN ratings rt 
        ON r.restaurant_id = rt.restaurant_id
)
SELECT cuisine, restaurant_name, city, overall_rating
FROM RankedRestaurants
WHERE rating_rank <= 2;


/* 11.First, create a VIEW named ConsumerAverageRatings that lists Consumer_ID and their average Overall_Rating. 
Then, using this view and a CTE, find the top 5 consumers by their average overall rating. For these top 5 consumers, list their Consumer_ID, 
their average rating, and the number of 'Mexican' restaurants they have rated. */

CREATE VIEW ConsumerAverageRatings AS
SELECT 
    consumer_id,
    AVG(overall_rating) AS avg_overall_rating
FROM ratings
GROUP BY consumer_id;

WITH TopConsumers AS (
    SELECT *
    FROM ConsumerAverageRatings
    ORDER BY avg_overall_rating DESC
    LIMIT 5
)
SELECT 
    tc.consumer_id,
    tc.avg_overall_rating,
    COUNT(rc.cuisine) AS mexican_restaurants_rated
FROM TopConsumers tc
INNER JOIN ratings r 
    ON tc.consumer_id = r.consumer_id
LEFT JOIN restaurant_cuisines rc
    ON r.restaurant_id = rc.restaurant_id
    AND rc.cuisine = 'Mexican'
GROUP BY tc.consumer_id, tc.avg_overall_rating;


/* 12.Create a stored procedure named GetConsumerSegmentAndRestaurantPerformance that accepts a Consumer_ID as input.

-- >The procedure should:
Determine the consumer's "Spending Segment" based on their Budget:
'Low' -> 'Budget Conscious'
'Medium' -> 'Moderate Spender'
'High' -> 'Premium Spender'
NULL or other -> 'Unknown Budget'

--> For all restaurants rated by this consumer:
List the Restaurant_Name.
The Overall_Rating given by this consumer.
The average Overall_Rating this restaurant has received from all consumers (not just the input consumer).
A "Performance_Flag" indicating if the input consumer's rating for that restaurant is 'Above Average', 'At Average', or 'Below Average' compared to the restaurant's overall average rating.
Rank these restaurants for the input consumer based on the Overall_Rating they gave (highest rating = rank 1). */

CALL GetConsumerSegmentAndRestaurantPerformance('U1001');

CALL GetConsumerSegmentAndRestaurantPerformance('U1033');