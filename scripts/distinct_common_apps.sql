SELECT DISTINCT app_store_apps.name
FROM app_store_apps INNER JOIN play_store_apps USING(name)
ORDER BY name;