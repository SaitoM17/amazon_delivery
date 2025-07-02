USE amazon_delivery;

/*
Lmpieza y transformación de datos
*/

-- Verificamos los datos iniciales
SELECT
	*
FROM
	amazon
LIMIT 10;

-- Descripción de los tipos de datos iniciales
DESCRIBE amazon;

-- Contar la cantidad de registros
SELECT
	COUNT(Order_ID) AS cantidad_registros
FROM
	amazon;

-- Identificar valores problemáticos en TODAS las columnas TEXT
-- Busca cadenas vacías, 'NaN', o solo espacios en blanco.
SELECT
    'Order_ID' AS column_name, Order_ID AS problematic_value FROM amazon WHERE TRIM(Order_ID) = '' OR TRIM(Order_ID) = 'NaN' OR TRIM(Order_ID) LIKE '%NaN%'
UNION ALL
SELECT
    'Weather' AS column_name, Weather FROM amazon WHERE TRIM(Weather) = '' OR TRIM(Weather) = 'NaN' OR TRIM(Weather) LIKE '%NaN%'
UNION ALL
SELECT
    'Traffic' AS column_name, Traffic FROM amazon WHERE TRIM(Traffic) = '' OR TRIM(Traffic) = 'NaN' OR TRIM(Traffic) LIKE '%NaN%'
UNION ALL
SELECT
    'Vehicle' AS column_name, Vehicle FROM amazon WHERE TRIM(Vehicle) = '' OR TRIM(Vehicle) = 'NaN' OR TRIM(Vehicle) LIKE '%NaN%'
UNION ALL
SELECT
    'Area' AS column_name, Area FROM amazon WHERE TRIM(Area) = '' OR TRIM(Area) = 'NaN' OR TRIM(Area) LIKE '%NaN%'
UNION ALL
SELECT
    'Category' AS column_name, Category FROM amazon WHERE TRIM(Category) = '' OR TRIM(Category) = 'NaN' OR TRIM(Category) LIKE '%NaN%'
UNION ALL
-- Para las columnas de tiempo/fecha que se importaron como TEXT/DATETIME
SELECT
    'Order_Time' AS column_name, Order_Time FROM amazon WHERE TRIM(Order_Time) = '' OR TRIM(Order_Time) = 'NaN' OR TRIM(Order_Time) LIKE '%NaN%'
UNION ALL
SELECT
    'Pickup_Time' AS column_name, Pickup_Time FROM amazon WHERE TRIM(Pickup_Time) = '' OR TRIM(Pickup_Time) = 'NaN' OR TRIM(Pickup_Time) LIKE '%NaN%'
UNION ALL
SELECT
    'Order_Date' AS column_name, Order_Date FROM amazon WHERE TRIM(Order_Date) = '' OR TRIM(Order_Date) = 'NaN' OR TRIM(Order_Date) LIKE '%NaN%'
UNION ALL
-- Para columnas numéricas que pudieran contener 'NaN' o cadenas vacías si fueron importadas como texto (aunque ya sean INT/DOUBLE)
-- O si sus valores convertidos a texto son problematicos.
-- NOTA: Si una columna ya es INT/DOUBLE, MySQL tratará de convertir estas cadenas.
-- Si la importación ya falló o las dejó NULL, esta parte no será tan relevante para tipos ya numéricos.
-- Sin embargo, si fueron importadas como TEXT y luego se quieren convertir, esta verificación es clave.
SELECT
    'Agent_Age' AS column_name, Agent_Age FROM amazon WHERE Agent_Age IS NOT NULL AND TRIM(Agent_Age) = '' OR TRIM(Agent_Age) = 'NaN' OR TRIM(Agent_Age) LIKE '%NaN%'
UNION ALL
SELECT
    'Agent_Rating' AS column_name, Agent_Rating FROM amazon WHERE Agent_Rating IS NOT NULL AND TRIM(Agent_Rating) = '' OR TRIM(Agent_Rating) = 'NaN' OR TRIM(Agent_Rating) LIKE '%NaN%'
UNION ALL
SELECT
    'Store_Latitude' AS column_name, Store_Latitude FROM amazon WHERE Store_Latitude IS NOT NULL AND TRIM(Store_Latitude) = '' OR TRIM(Store_Latitude) = 'NaN' OR TRIM(Store_Latitude) LIKE '%NaN%'
UNION ALL
SELECT
    'Store_Longitude' AS column_name, Store_Longitude FROM amazon WHERE Store_Longitude IS NOT NULL AND TRIM(Store_Longitude) = '' OR TRIM(Store_Longitude) = 'NaN' OR TRIM(Store_Longitude) LIKE '%NaN%'
UNION ALL
SELECT
    'Drop_Latitude' AS column_name, Drop_Latitude FROM amazon WHERE Drop_Latitude IS NOT NULL AND TRIM(Drop_Latitude) = '' OR TRIM(Drop_Latitude) = 'NaN' OR TRIM(Drop_Latitude) LIKE '%NaN%'
UNION ALL
SELECT
    'Drop_Longitude' AS column_name, Drop_Longitude FROM amazon WHERE Drop_Longitude IS NOT NULL AND TRIM(Drop_Longitude) = '' OR TRIM(Drop_Longitude) = 'NaN' OR TRIM(Drop_Longitude) LIKE '%NaN%'
UNION ALL
SELECT
    'Delivery_Time' AS column_name, Delivery_Time FROM amazon WHERE Delivery_Time IS NOT NULL AND TRIM(Delivery_Time) = '' OR TRIM(Delivery_Time) = 'NaN' OR TRIM(Delivery_Time) LIKE '%NaN%';
-- Si Order_ID, Agent_Age, etc., ya son INT/DOUBLE directamente importados y no TEXT,
-- las condiciones TRIM(...) = '' o 'NaN' no aplicarán directamente a esos tipos numéricos
-- y podrían generar errores si se usan así (ej. TRIM(123) no tiene sentido).
-- La parte de los tipos numéricos es más útil si los importaste como TEXT y luego los vas a convertir.

-- Reemplazar valores problemáticos (cadenas vacías, 'NaN' exactos o 'NaN' en subcadenas) por NULL
-- Esto es fundamental antes de cualquier conversión de tipo.
UPDATE amazon
SET
    -- Para columnas de tiempo/fecha:
    Order_Time = CASE WHEN TRIM(Order_Time) = '' OR TRIM(Order_Time) LIKE '%NaN%' THEN NULL ELSE Order_Time END, --
    
    -- Para otras columnas TEXT:
    Weather = CASE WHEN TRIM(Weather) = '' OR TRIM(Weather) LIKE '%NaN%' THEN NULL ELSE Weather END, -- 
    Traffic = CASE WHEN TRIM(Traffic) = '' OR TRIM(Traffic) LIKE '%NaN%' THEN NULL ELSE Traffic END; --

-- Identificar valores nulos en los registros
SELECT
    SUM(CASE WHEN Order_ID IS NULL THEN 1 ELSE 0 END) AS nulos_Order_ID,
    SUM(CASE WHEN Agent_age IS NULL THEN 1 ELSE 0 END) AS nulos_Agent_age,
    SUM(CASE WHEN Agent_Rating IS NULL THEN 1 ELSE 0 END) AS nulos_Agent_Rating,
    SUM(CASE WHEN Store_Latitude IS NULL THEN 1 ELSE 0 END) AS nulos_Store_Latitude,
    SUM(CASE WHEN Store_Longitude IS NULL THEN 1 ELSE 0 END) AS nulos_Store_Longitude,
    SUM(CASE WHEN Drop_Latitude IS NULL THEN 1 ELSE 0 END) AS nulos_Drop_Latitude,
    SUM(CASE WHEN Drop_Longitude IS NULL THEN 1 ELSE 0 END) AS nulos_Drop_Longitude,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS nulos_Order_Date,
    SUM(CASE WHEN Order_Time IS NULL THEN 1 ELSE 0 END) AS nulos_Order_Time,
    SUM(CASE WHEN Pickup_Time IS NULL THEN 1 ELSE 0 END) AS nulos_Pickup_Time,
    SUM(CASE WHEN Weather IS NULL THEN 1 ELSE 0 END) AS nulos_Weather,
    SUM(CASE WHEN Traffic IS NULL THEN 1 ELSE 0 END) AS nulos_Traffic,
    SUM(CASE WHEN Vehicle IS NULL THEN 1 ELSE 0 END) AS nulos_Vehicle,
    SUM(CASE WHEN Area IS NULL THEN 1 ELSE 0 END) AS nulos_Area,
    SUM(CASE WHEN Delivery_Time IS NULL THEN 1 ELSE 0 END) AS nulos_Delivery_Time,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS nulos_Category
FROM
    amazon;

-- Paso 1: Limpiar y transformar las columnas de tiempo (Order_Time, Pickup_Time)

-- 1.1 Añadir nuevas columnas temporales con el tipo de dato TIME
-- Esto nos permite trabajar con seguridad sin alterar las columnas originales hasta que estemos seguros.
ALTER TABLE amazon
ADD COLUMN temp_order_time TIME,
ADD COLUMN temp_pickup_time TIME;

-- 1.2 Convertir los datos de TEXT a TIME y poblar las nuevas columnas
UPDATE amazon
SET
    temp_order_time = STR_TO_DATE(Order_Time, '%H:%i:%s'),
    temp_pickup_time = STR_TO_DATE(Pickup_Time, '%H:%i:%s');

-- 1.3 Verificar la conversión de tiempo
SELECT
    Order_Time,
    temp_order_time,
    Pickup_Time,
    temp_pickup_time
FROM
    amazon
LIMIT 10;

-- 1.4 Eliminar las columnas originales de tipo TEXT para el tiempo
ALTER TABLE amazon
DROP COLUMN Order_Time,
DROP COLUMN Pickup_Time;

-- 1.5 Renombrar las nuevas columnas temporales a los nombres originales
ALTER TABLE amazon
CHANGE COLUMN temp_order_time Order_Time TIME,
CHANGE COLUMN temp_pickup_time Pickup_Time TIME;

-- Paso 2: Limpiar y transformar la columna de fecha (Order_Date)
-- 2.1 Añadir una nueva columna temporal con el tipo de dato DATE
ALTER TABLE amazon
ADD COLUMN temp_order_date DATE;

-- 2.2 Convertir los datos de DATETIME a DATE
UPDATE amazon
SET temp_order_date = DATE(Order_Date);

-- 2.3 (Opcional pero recomendado) Verificar la conversión de fecha
SELECT 
	Order_Date, temp_order_date 
FROM 
	amazon 
LIMIT 
	10;

-- 2.4 Eliminar la columna original 'Order_Date' de tipo DATETIME
ALTER TABLE amazon
DROP COLUMN Order_Date;

-- 2.5 Renombrar la nueva columna temporal a 'Order_Date'
ALTER TABLE amazon
CHANGE COLUMN temp_order_date Order_Date DATE;
    
-- Paso 3: Limpiar cadenas de texto (Trim extra spaces)
UPDATE amazon
SET
    Weather = TRIM(Weather),
    Traffic = TRIM(Traffic),
    Vehicle = TRIM(Vehicle),
    Area = TRIM(Area),
    Category = TRIM(Category);
    
-- Paso 4: Manejar valores NULL 
-- Identificar valores nulos en los registros
SELECT
    SUM(CASE WHEN Order_ID IS NULL THEN 1 ELSE 0 END) AS nulos_Order_ID,
    SUM(CASE WHEN Agent_age IS NULL THEN 1 ELSE 0 END) AS nulos_Agent_age,
    SUM(CASE WHEN Agent_Rating IS NULL THEN 1 ELSE 0 END) AS nulos_Agent_Rating,
    SUM(CASE WHEN Store_Latitude IS NULL THEN 1 ELSE 0 END) AS nulos_Store_Latitude,
    SUM(CASE WHEN Store_Longitude IS NULL THEN 1 ELSE 0 END) AS nulos_Store_Longitude,
    SUM(CASE WHEN Drop_Latitude IS NULL THEN 1 ELSE 0 END) AS nulos_Drop_Latitude,
    SUM(CASE WHEN Drop_Longitude IS NULL THEN 1 ELSE 0 END) AS nulos_Drop_Longitude,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS nulos_Order_Date,
    SUM(CASE WHEN Order_Time IS NULL THEN 1 ELSE 0 END) AS nulos_Order_Time,
    SUM(CASE WHEN Pickup_Time IS NULL THEN 1 ELSE 0 END) AS nulos_Pickup_Time,
    SUM(CASE WHEN Weather IS NULL THEN 1 ELSE 0 END) AS nulos_Weather,
    SUM(CASE WHEN Traffic IS NULL THEN 1 ELSE 0 END) AS nulos_Traffic,
    SUM(CASE WHEN Vehicle IS NULL THEN 1 ELSE 0 END) AS nulos_Vehicle,
    SUM(CASE WHEN Area IS NULL THEN 1 ELSE 0 END) AS nulos_Area,
    SUM(CASE WHEN Delivery_Time IS NULL THEN 1 ELSE 0 END) AS nulos_Delivery_Time,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS nulos_Category
FROM
    amazon;
    
-- Tratar valores nulos (En caso de haya valores nulos)
-- Como si hay valores nulos (en las columnas Ordet_Time, Weather, Traffict), se tratara de conseguir los datos faltantes por medio de las coordenadas (se realiza posteriormente)

-- Paso 5: Buscar valores negativas
SELECT 
	Agent_Age, 
	Agent_Rating, 
	Store_Latitude,
    Store_Longitude,
    Drop_Latitude,
    Drop_Longitude,
    Delivery_Time
FROM 
	amazon 
WHERE 
    Agent_Age < 0 OR
    Agent_Rating < 0 OR
    Store_Latitude < -90 OR Store_Latitude > 90 OR -- Latitud fuera de rango
    Store_Longitude < -180 OR Store_Longitude > 180 OR -- Longitud fuera de rango
    Drop_Latitude < -90 OR Drop_Latitude > 90 OR
    Drop_Longitude < -180 OR Drop_Longitude > 180 OR
    Delivery_Time < 0;
    
-- Paso 6: Identificar registros completamente duplicados (todas las columnas iguales)
-- En caso de encontrar se eliminaran
SELECT
    Order_ID,
    Agent_age,
    Agent_Rating,
    Store_Latitude,
    Store_Longitude,
    Drop_Latitude,
    Drop_Longitude,
    Order_Date,
    Order_Time,
    Pickup_Time,
    Weather,
    Traffic,
    Vehicle,
    Area,
    Delivery_Time,
    Category,
    COUNT(*) AS cant_duplicados
FROM
    amazon
GROUP BY
    Order_ID,
    Agent_age,
    Agent_Rating,
    Store_Latitude,
    Store_Longitude,
    Drop_Latitude,
    Drop_Longitude,
    Order_Date,
    Order_Time,
    Pickup_Time,
    Weather,
    Traffic,
    Vehicle,
    Area,
    Delivery_Time,
    Category
HAVING
    COUNT(*) > 1;
 -- No se encontraron registros duplicados
 
 --  Verificar la estructura final de la tabla y los datos después de la limpieza
DESCRIBE amazon;

SELECT 
	* 
FROM 
	amazon 
LIMIT 
	10;