WITH 
long_purchase_cost_play AS 
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
	FROM long_purchase_cost_play)
--MAIN QUERY--
SELECT *
FROM play_profit_info
ORDER BY longterm_profit DESC NULLS LAST;