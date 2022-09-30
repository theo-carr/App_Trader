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
--LIMIT 10