/*
Imputación de datos en las columnas Order_Time, Weather y Traffic
*/

-- Conocer la cantidad de registros
SELECT
	COUNT(*) AS cant_registro
FROM
	amazon;

-- Cantidad de registros: 43685

-- Identificar que registros tiene valores nulos en Order_Time, Weather y Traffic
SELECT 
	*
FROM
	amazon
WHERE
	Order_Time IS NULL
OR
	Weather IS NULL
OR
	Traffic IS NULL;
    
-- Conocer la cantidad de registros con valores nulos
SELECT
	SUM(CASE WHEN Order_Time IS NULL THEN 1 ELSE 0 END) AS nulos_Order_Time,
    SUM(CASE WHEN Weather IS NULL THEN 1 ELSE 0 END) AS nulos_Weather,
    SUM(CASE WHEN Traffic IS NULL THEN 1 ELSE 0 END) AS nulos_Traffic
FROM
	amazon;
    
-- Imputar los datos en Order_Time
-- Paso 1: Obtener el promedio de la diferencia de tiempo en segundos
-- entre Pickup_Time y Order_Time para los registros no nulos.
SET @promedio_delta_segundos = (
    SELECT AVG(TIME_TO_SEC(TIMEDIFF(Pickup_Time, Order_Time)))
    FROM amazon
    WHERE Order_Time IS NOT NULL
      AND Order_Time <= Pickup_Time -- Filtra solo los casos lógicamente válidos
);

-- Puedes verificar el valor calculado del promedio
SELECT @promedio_delta_segundos;

-- Paso 2: Actualizar los registros con Order_Time nulo
-- Restamos el promedio_delta_segundos a Pickup_Time para estimar Order_Time.
UPDATE amazon
SET Order_Time = DATE_SUB(Pickup_Time, INTERVAL @promedio_delta_segundos SECOND)
WHERE Order_Time IS NULL;

-- Verificar la cantidad de valores nulos en Order_Time
SELECT
	SUM(CASE WHEN Order_Time IS NULL THEN 1 ELSE 0 END) AS nulos_Order_Time
FROM
	amazon;

-- Revisamos los datos
SELECT 
	*
FROM
	amazon
WHERE
	Weather IS NULL
OR
	Traffic IS NULL;

-- Paso 3: Revisar si hay valores negativos
SELECT 
	COUNT(*) 
FROM 
	amazon
WHERE 
	Order_Time < '00:00:00';
    
-- Identificar los registros con los valores negativos
SELECT 
	* 
FROM 
	amazon
WHERE 
	Order_Time < '00:00:00';    
    
-- Paso 4: Corregir los valores negativos
UPDATE amazon
SET Order_Time = '00:00:00'
WHERE Order_Time < '00:00:00' -- Identifica valores negativos en Order_Time
  AND Pickup_Time = '00:00:00'; -- Y Pickup_Time es medianoche
  
-- Revisar si aun hay valores negativos
SELECT 
	COUNT(*) 
FROM 
	amazon
WHERE 
	Order_Time < '00:00:00';

-- *** IMPUTACIÓN PARA 'Weather' ***

-- Definir la precisión para el redondeo de las coordenadas (cuantos decimales).
-- Ajustar estos valores (1, 2 o 3 son buenos puntos de partida).
SET @lat_precision = 2; -- Ej: Redondear a 2 decimales (aprox. 1.1 km de 'vecindario')
SET @lon_precision = 2; -- Ej: Redondear a 2 decimales

-- PASO 1: Crear una tabla temporal con la cuenta de cada Weather por zona y fecha
CREATE TEMPORARY TABLE IF NOT EXISTS temp_weather_counts AS
SELECT
    ROUND(Drop_Latitude, @lat_precision) AS rounded_lat,
    ROUND(Drop_Longitude, @lon_precision) AS rounded_lon,
    Order_Date, -- Asegúrate de que esta columna exista y tenga el tipo de dato DATE
    Weather,
    COUNT(*) AS cnt
FROM
    amazon
WHERE
    Weather IS NOT NULL
GROUP BY
    rounded_lat,
    rounded_lon,
    Order_Date,
    Weather;

-- PASO 2: Encontrar el COUNT máximo para cada grupo (lat_redondeada, lon_redondeada, fecha)
CREATE TEMPORARY TABLE IF NOT EXISTS temp_max_counts AS
SELECT
    rounded_lat,
    rounded_lon,
    Order_Date,
    MAX(cnt) AS max_cnt
FROM
    temp_weather_counts -- Aquí se espera que temp_weather_counts exista
GROUP BY
    rounded_lat,
    rounded_lon,
    Order_Date;

-- PASO 3: Unir las cuentas originales con los máximos para obtener la moda
CREATE TEMPORARY TABLE IF NOT EXISTS final_weather_modes AS
SELECT
    twc.rounded_lat,
    twc.rounded_lon,
    twc.Order_Date,
    twc.Weather
FROM
    temp_weather_counts twc
JOIN
    temp_max_counts tmc ON
    twc.rounded_lat = tmc.rounded_lat AND
    twc.rounded_lon = tmc.rounded_lon AND
    twc.Order_Date = tmc.Order_Date AND
    twc.cnt = tmc.max_cnt;


-- PASO 4: Actualizar la tabla original 'amazon' para imputar 'Weather'
UPDATE amazon a
JOIN final_weather_modes fwm ON
    ROUND(a.Drop_Latitude, @lat_precision) = fwm.rounded_lat AND
    ROUND(a.Drop_Longitude, @lon_precision) = fwm.rounded_lon AND
    a.Order_Date = fwm.Order_Date
SET
    a.Weather = fwm.Weather
WHERE
    a.Weather IS NULL;

-- Limpiar tablas temporales al final
DROP TEMPORARY TABLE IF EXISTS temp_weather_counts;
DROP TEMPORARY TABLE IF EXISTS temp_max_counts;
DROP TEMPORARY TABLE IF EXISTS final_weather_modes;


-- Verificar la cantidad de valores nulos
SELECT
    SUM(CASE WHEN Weather IS NULL THEN 1 ELSE 0 END) AS nulos_Weather
FROM
	amazon;
 
-- *** IMPUTACIÓN PARA 'Traffic' ***
 
-- PASO 1: Crear una tabla temporal con la cuenta de cada Weather por zona y fecha
CREATE TEMPORARY TABLE IF NOT EXISTS temp_traffic_counts AS
SELECT
    ROUND(Drop_Latitude, @lat_precision) AS rounded_lat,
    ROUND(Drop_Longitude, @lon_precision) AS rounded_lon,
    Order_Date, -- Asegúrate de que esta columna exista y tenga el tipo de dato DATE
    Traffic,
    COUNT(*) AS cnt
FROM
    amazon
WHERE
    Traffic IS NOT NULL
GROUP BY
    rounded_lat,
    rounded_lon,
    Order_Date,
    Traffic;

-- PASO 2: Encontrar el COUNT máximo para cada grupo (lat_redondeada, lon_redondeada, fecha)
CREATE TEMPORARY TABLE IF NOT EXISTS temp_max_counts AS
SELECT
    rounded_lat,
    rounded_lon,
    Order_Date,
    MAX(cnt) AS max_cnt
FROM
    temp_traffic_counts -- Aquí se espera que temp_weather_counts exista
GROUP BY
    rounded_lat,
    rounded_lon,
    Order_Date;

-- PASO 3: Unir las cuentas originales con los máximos para obtener la moda
CREATE TEMPORARY TABLE IF NOT EXISTS final_traffic_modes AS
SELECT
    twc.rounded_lat,
    twc.rounded_lon,
    twc.Order_Date,
    twc.Traffic
FROM
    temp_traffic_counts twc
JOIN
    temp_max_counts tmc ON
    twc.rounded_lat = tmc.rounded_lat AND
    twc.rounded_lon = tmc.rounded_lon AND
    twc.Order_Date = tmc.Order_Date AND
    twc.cnt = tmc.max_cnt;


-- PASO 4: Actualizar la tabla original 'amazon' para imputar 'Weather'
UPDATE amazon a
JOIN final_traffic_modes fwm ON
    ROUND(a.Drop_Latitude, @lat_precision) = fwm.rounded_lat AND
    ROUND(a.Drop_Longitude, @lon_precision) = fwm.rounded_lon AND
    a.Order_Date = fwm.Order_Date
SET
    a.Traffic = fwm.Traffic
WHERE
    a.Traffic IS NULL;

-- Limpiar tablas temporales al final
DROP TEMPORARY TABLE IF EXISTS temp_traffic_counts;
DROP TEMPORARY TABLE IF EXISTS temp_max_counts;
DROP TEMPORARY TABLE IF EXISTS final_traffic_modes;

-- Verificar la cantidad de valores nulos
SELECT
    COUNT(*) AS nulos_Traffic
FROM
	amazon
WHERE 
	Traffic IS NULL;
    
-- Revisar los registros con valores nulos
SELECT * FROM amazon WHERE Weather IS NULL;
SELECT * FROM amazon WHERE Traffic IS NULL;


-- Eliminar los valores nulos que no se pueden inputar
-- Para Weather
DELETE FROM amazon
WHERE Weather IS NULL;

-- Para Traffic
DELETE FROM amazon
WHERE Traffic IS NULL;

-- Revisar la cantidad de registros despues de eliminar
SELECT
	COUNT(*) AS cant_registro
FROM
	amazon;
    
-- Cantidad de registros antes de eliminar: 43685
-- Cantidad de registros después de eliminar: 43644