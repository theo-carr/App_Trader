WITH 
long_purchase_cost AS -- add apple base in
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
--MAIN QUERY--
SELECT *
FROM apple_profit_info
ORDER BY longterm_profit DESC;