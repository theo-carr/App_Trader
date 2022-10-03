SELECT *
FROM app_store_apps;

SELECT DISTINCT name
FROM play_store_apps
INNER JOIN app_store_apps USING (name);


--a) profits by genre, profits by size etc, sort avg rating by app

--b) determine fall/halloween apps, family vs horror

--I'm focusing on genres

SELECT DISTINCT primary_genre
FROM app_store_apps;
--23 distinct genres in the app store


SELECT DISTINCT genres
FROM play_store_apps;
--119 genres in the play store.
--The app store's genres are more condensed than the play store.


/* Gameplan for genres:
-highest avg rated genre
-review_counts for genre
-avg genre price and avg profits
*/



--highest avg rated genre

SELECT primary_genre,ROUND(AVG(rating),2)as avg_rating
FROM app_store_apps
WHERE rating>=4
GROUP BY primary_genre
ORDER BY avg_rating DESC
LIMIT 10;

/* App store, top 5 avg ratings of primary genres:

Medical				4.54
Book				4.53
Health & Fitness	4.50
Reference			4.44
Photo & Video		4.42
*/


--Play Store avg ratings by genre

SELECT genres,ROUND(AVG(rating),2) as avg_rating
FROM play_store_apps
Where rating >=4
GROUP BY genres
ORDER BY avg_rating DESC
LIMIT 10;

/*In the play store, top 5 avg ratings of genres:

Comics;Creativity				4.80
Board;Pretend Play				4.80
Books & Reference;Education		4.70
Health & Fitness;Education		4.70
Art & Design;Creativity			4.62

The common genres between the app and play store with the highest avg ratings is:
Books/Reference, Health/Fitness

Common genres in top 10 also include games
*/


--Most review counts per genre:

SELECT primary_genre,SUM(review_count::numeric) AS total_count
FROM app_store_apps
GROUP BY primary_genre
ORDER BY total_count DESC;

--Games are by far most reviewed with 52,878,491 reviews
--Social Networking(7,598,316), Photo/Video(5,008,946), Entertaiment(4,030,518), and Music(3,980,199)

SELECT genres,SUM(review_count::numeric) AS total_count
FROM play_store_apps
GROUP BY genres
ORDER BY total_count DESC;

--Communication apps have the most reviews with 815,462,260
--Social(621,241,422), Casual(412,078,863), Action(350,303,953), Arcade (336,990,433)



--app_store_apps profit

WITH 
long_purchase_cost AS
		(SELECT name,
		size_bytes,
		price,rating,
		(12 + ((rating/.25)*6))::integer AS longevity,
		CASE WHEN price = 0 THEN 25000
			 ELSE 10000 * price END AS purchase_cost
		FROM app_store_apps),
apple_profit_info AS 
		(SELECT 
		 	name, 
		 	size_bytes,
		 	price,
		 	rating,
		 	longevity,
		 	purchase_cost,
		 	((2500 * longevity) - ((1000 * longevity)+purchase_cost))::money AS longterm_profit
		 FROM long_purchase_cost)
SELECT * 
FROM apple_profit_info
ORDER BY longterm_profit DESC;



--play_store_apps profit

WITH 
long_purchase_cost AS 
	(SELECT 
		* , 
		(12 + (ROUND(rating/.25) * 6))::integer AS longevity,
		CASE WHEN type = 'Paid' THEN 10000 * RIGHT(price,LENGTH(price)-1)::numeric
			 ELSE 25000 END AS purchase_cost
	FROM play_store_apps),
play_profit_info AS
	(SELECT 
	 	*, 
		((2500 * longevity) - ((1000 * longevity)+purchase_cost))::money AS longterm_profit
	FROM long_purchase_cost)
SELECT * 
FROM play_profit_info
WHERE longterm_profit IS NOT NULL
ORDER BY longterm_profit DESC;



--app_store profits by genre

WITH 
long_purchase_cost AS
		(SELECT name, 
		 primary_genre,
		size_bytes,
		price,rating,
		(12 + ((rating/.25)*6))::integer AS longevity,
		CASE WHEN price = 0 THEN 25000
			 ELSE 10000 * price END AS purchase_cost
		FROM app_store_apps),
apple_profit_info AS 
		(SELECT 
		 	name, 
		 	primary_genre,
		 	size_bytes,
		 	price,
		 	rating,
		 	longevity,
		 	purchase_cost,
		 	((2500 * longevity) - ((1000 * longevity)+purchase_cost))::money AS longterm_profit
		 FROM long_purchase_cost)
SELECT primary_genre,AVG(longterm_profit::numeric)::money AS avg_profit
FROM apple_profit_info
GROUP BY primary_genre
ORDER BY avg_profit DESC
LIMIT 10;

/*Top 5 app store apps with the highest avg profit are:
  "Photo & Video"		"$128,135.24"
  "Games"	        	"$121,720.74"
  "Health & Fitness"	"$121,480.00"
  "Weather"				"$120,681.94"
  "Shopping"			"$120,517.21"
*/ 




--play store apps with the highest avg profit

WITH 
long_purchase_cost AS 
	(SELECT 
		* , 
		(12 + (ROUND(rating/.25) * 6))::integer AS longevity,
		CASE WHEN type = 'Paid' THEN 10000 * RIGHT(price,LENGTH(price)-1)::numeric
			 ELSE 25000 END AS purchase_cost
	FROM play_store_apps),
play_profit_info AS
	(SELECT 
	 	*, 
		((2500 * longevity) - ((1000 * longevity)+purchase_cost))::money AS longterm_profit
	FROM long_purchase_cost)
SELECT genres, AVG(longterm_profit::numeric)::money as avg_profit
FROM play_profit_info
WHERE longterm_profit IS NOT NULL
GROUP BY genres
ORDER BY avg_profit DESC
LIMIT 5;
 
/* Top 5 genres with the highest avg_profit in the play store:
	"Board;Pretend Play"			"$179,100.00"
	"Health & Fitness;Education"	"$164,000.00"
	"Comics;Creativity"				"$164,000.00"
	"Music;Music & Video"			"$156,700.00"
	"Puzzle;Education"				"$155,000.00"
*/


--Common genres in play/app store with highest avg profit:
--Games, Health/Fitness, Photo/Video

						  						  


--TOP 10 APPS WE'RE CHOOSING

WITH 
long_purchase_cost AS -- add apple base in
		(SELECT 
		 *,
		(12 + ((rating/.25)*6))::integer AS longevity,
		CASE WHEN price = 0 THEN 25000
			 ELSE 10000 * price END AS purchase_cost
		FROM app_store_apps),
apple_profit_info AS 
		(SELECT 
		 *,
		 	((2500 * longevity) - ((1000 * longevity)+purchase_cost))::money AS longterm_profit
		 FROM long_purchase_cost), --app store base added in
long_purchase_cost_play AS 
	(SELECT 
		* , 
		(12 + (FLOOR(rating/.25) * 6))::integer AS longevity,
		CASE WHEN type = 'Paid' THEN 10000 * RIGHT(price,LENGTH(price)-1)::numeric
			 ELSE 25000 END AS purchase_cost
	FROM play_store_apps),
play_profit_info AS
	(SELECT 
		*, 
		((2500 * longevity) - ((1000 * longevity)+purchase_cost))::money AS longterm_profit
	FROM long_purchase_cost_play),-- play store base added in 

common_apps AS 
	(SELECT --FINDS HIGHEST RATING AND LIST OF COMMON APPS BETWEEN THE TWO STORES
		DISTINCT name,
	(2500 * apple_profit_info.longevity + (2500 * play_profit_info.longevity)) - ((1000)),
		CASE WHEN play_profit_info.rating >= apple_profit_info.rating THEN play_profit_info.rating
			 ELSE apple_profit_info.rating END AS highest_rating
	FROM apple_profit_info INNER JOIN play_profit_info USING(name))

--MAIN QUERY--
SELECT 
	DISTINCT name,
	genres AS playstore_genre,
	primary_genre AS appstore_genre,
	((2500 * apple_profit_info.longevity + (2500 * play_profit_info.longevity)) - 
		((1000*FLOOR((highest_rating/.25 * 6))) + (apple_profit_info.purchase_cost) + (play_profit_info.purchase_cost)))::money AS combined_profit
FROM common_apps
	INNER JOIN apple_profit_info USING(name) INNER JOIN play_profit_info USING(name)
WHERE 	((2500 * apple_profit_info.longevity + (2500 * play_profit_info.longevity)) - 
		((1000*ROUND((highest_rating/.25 * 6),2)) + (apple_profit_info.purchase_cost) + (play_profit_info.purchase_cost)))::money 
		>
		(SELECT MAX(longterm_profit) FROM apple_profit_info)
ORDER BY combined_profit DESC
LIMIT 10;
