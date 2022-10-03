SELECT *
FROM play_store_apps;

--profit calculation = 5000 * longevity - ((marketing cost * longevity) + initial purchase cost)

--starting point ideas
-- a. profits by genre, profits by size etc, sort avg rating by app, compare global market with currency 
--b/c. determine 'fall/halloween apps', family vs. horror games, companies with uptick in sales in fall, determine countries that 
--celebrate halloween
--------------------------------------------------------------

--a. look at ratings (content or actual rating)

--ratings for app_store_apps where there are more than 1000 reviews and the ratings are higher than 4
--Top apps 1. Instagram 2. Clash of Clans 3.Temple Run 4. Pinterest 5. Bible 6. Candy Crush Saga
--         7. Spotify Music 8. Angry Birds 9. Subway Surfers 10. Fruit Ninja Classic 

--quick observations - 8/10 are either games or social network apps, most popular games have a low level content rating

--no install count, but can approx based on looking at playstore review count/install count 
SELECT *
FROM app_store_apps
WHERE review_count::numeric > '10000'
AND rating > '4'
ORDER BY review_count::numeric DESC, rating DESC;
 

--ratings for play_store_apps where there are more than 1000 reviews
--Top apps 1. Facebook 2. WhatsApp Messenger 3. Instagram 4. Clash of Clans 5. Clean Master-Space Cleaner and Antivirus
--         6. Subway Surfers 7. youtube 8. Security Master- Antivirus, vpn, applock, booster, 9. Clash Royale 10. Candy Crush Saga
SELECT *
FROM play_store_apps
WHERE review_count::numeric > '10000'
AND rating > '4'
ORDER BY review_count::numeric DESC, rating DESC;

--tried to find ratings with the top ratings but its not very informative
SELECT content_rating, AVG(rating)
FROM play_store_apps
WHERE review_count::numeric > '10000'
GROUP BY content_rating
ORDER BY AVG(rating);

--ratings for app_store_apps and play_store_apps inner joined where there are more than 1000 reviews
SELECT *
FROM app_store_apps
INNER JOIN play_store_apps
USING (name)
WHERE app_store_apps.review_count::numeric > '10000'
ORDER BY app_store_apps.review_count::numeric DESC, app_store_apps.rating DESC;



--Theo's purchase cost + longterm profit calculations
--app_store
WITH 
long_purchase_cost AS
		(SELECT *,
		(12 + ((rating/.25)*6))::integer AS longevity,
		CASE WHEN price = 0 THEN 25000
			 ELSE 10000 * price END AS purchase_cost
		FROM app_store_apps),
apple_profit_info AS 
		(SELECT 
		 	*,
		 	((2500 * longevity) - ((1000 * longevity)+purchase_cost))::money AS longterm_profit
		 FROM long_purchase_cost)
SELECT * 
FROM apple_profit_info
WHERE rating > '4'
ORDER BY longterm_profit DESC, review_count::numeric DESC;

-------
--play_store
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
AND rating > '4'
ORDER BY longterm_profit DESC, review_count DESC;

--Halloween stuff (count just run this search through the profit calc to pic a few)

--top halloween apps for kids and teens, seems like a good place to focus on for a halloween launch

WITH 
long_purchase_cost AS
		(SELECT *,
		(12 + ((rating/.25)*6))::integer AS longevity,
		CASE WHEN price = 0 THEN 25000
			 ELSE 10000 * price END AS purchase_cost
		FROM app_store_apps),
apple_profit_info AS 
		(SELECT 
		 	*,
		 	((2500 * longevity) - ((1000 * longevity)+purchase_cost))::money AS longterm_profit
		 FROM long_purchase_cost)
SELECT * 
FROM apple_profit_info
WHERE rating > '4'
AND name ILIKE '%haunted%'
ORDER BY longterm_profit DESC;


SELECT DISTINCT *
FROM app_store_apps
WHERE name ILIKE '%horror%';

SELECT DISTINCT *
FROM app_store_apps
WHERE name ILIKE '%pumpkin%';
---
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
AND rating > '4'
AND name ILIKE '%horror%'
ORDER BY longterm_profit DESC;



SELECT DISTINCT *
FROM play_store_apps
WHERE name ILIKE '%horror%';


---

SELECT DISTINCT content_rating
FROM app_store_apps

SELECT DISTINCT content_rating 
FROM play_store_apps

---combined 





