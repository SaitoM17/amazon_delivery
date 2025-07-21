# 📊 Amazon Delivery 
# Análisis de eficiencia en entregas de última milla

Este proyecto consiste en un dashboard interactivo y la generación de reportes ejecutivos. Ambas herramientas están diseñadas para analizar el rendimiento de la entrega de pedidos. Los datos utilizados provienen de un conjunto de datos real de entregas recopilado por [Sujal Suthar](https://www.kaggle.com/datasets/sujalsuthar/amazon-delivery-dataset/data), con información valiosa para entender y mejorar la eficiencia operativa.

---

## 📚 Tabla de Contenidos

- [🎯 Propósito](#-propósito)
- [📦 Conjunto de Datos](#-conjunto-de-datos)
- [🧪 Desarrollo del Proyecto](#-desarrollo-del-proyecto)
- [📌 Vista previa del Dashboard](#-vista-previa-del-dashboard)
- [💡 Insight clave](#-insight-clave)
- [🛠️ Tecnologías](#️-tecnologías)
- [📂 Archivos](#️-instalación)
- [👤 Autor](#-autor)
- [📝 Licencia](#-licencia)

---

## 🎯 Propósito

El propósito principal de este proyecto es optimizar la eficiencia en la entrega de pedidos. Para lograrlo, analizaremos datos en tiempo real con el fin de:

- Evaluar la eficiencia general de nuestras entregas.
- Identificar zonas geográficas y franjas horarias con mayores desafíos operativos.
- Reconocer el desempeño individual de los repartidores, destacando a los más eficientes y detectando áreas de mejora.
---

## 📦 Conjunto de Datos

El conjunto de datos utilizado contiene las siguientes columnas:

- `Order_ID`: Identificador único para cada pedido
- `Agent_age`: Edad del agente de entrega
- `Agent_Rating`: Calificación o puntuación de desempeño del agente de entrega
- `Store_Latitude`: Coordenadas geográficas (latitud) de la tienda donde se realizó el pedido
- `Store_Longitude`: Coordenadas geográficas (longitud) de la tienda donde se realizó el pedido
- `Drop_Latitude`: Coordenadas geográficas (latitud) del lugar de entrega
- `Drop_Longitude`: Coordenadas geográficas (longitud) del lugar de entrega
- `Order_Date`: Fecha en que se realizó el pedido
- `Order_Time`: Hora del pedido
- `Pickup_Time`: Hora en que se recogió el pedido para su entrega
- `Weather`: Condiciones climáticas durante la entrega (por ejemplo: sunny, rainy, snowy)
- `Traffic`: Condiciones del tráfico durante la entrega (por ejemplo: low, medium, jam)
- `Vehicle`: Tipo de vehiculo utilizado para la entrega (por ejemplo: van, motorcycle, bicycle, scooter)
- `Area`: Zona donde se realizó la entrega (Urban, Metropolitan)
- `Delivery_Time`: Tiempo que llevo completar la entrega
- `Category`: Categoría de producto del articulo pedido (por ejemplo: electronics, apparel, groceries)

Fuente: [Amazon Delivery Dataset](https://www.kaggle.com/datasets/sujalsuthar/amazon-delivery-dataset).

---

## 🧪 Desarrollo del Proyecto

### 1. **Creación y carga de la base de datos**

Este apartado describe los pasos para cargar, explorar y preparar inicialmente el conjunto de datos amazon_delivery.csv en una base de datos MySQL.

1. Origen de los Datos
El conjunto de datos utilizado para este análisis es amazon_delivery.csv, obtenido de Kaggle. Contiene información relacionada con entregas de Amazon.

2. Configuración de la Base de Datos
Para comenzar, necesitamos crear y seleccionar la base de datos donde se almacenarán nuestros datos.

```SQL
CREATE DATABASE amazon_delivery;
USE amazon_delivery; -- Asegúrate de seleccionar la base de datos correcta
```

3. Carga de Datos
Los datos se cargaron en la base de datos MySQL utilizando la interfaz gráfica de MySQL Workbench, específicamente el "Table Data Import Wizard".

Pasos para cargar los datos usando MySQL Workbench:
1. Crear la base de datos: Ejecuta la sentencia CREATE DATABASE amazon_delivery; o créala manualmente.
2. Seleccionar la base de datos: Haz doble clic en la base de datos amazon_delivery en el panel "Schemas" para seleccionarla, o usa la sentencia USE amazon_delivery;.
3. Iniciar el asistente de importación: Haz clic derecho en el apartado de "Tables" dentro de tu base de datos amazon_delivery.
4. Seleccionar "Table Data Import Wizard": Elige esta opción del menú contextual.
5. Seleccionar la ruta del archivo CSV: Navega y selecciona el archivo amazon_delivery.csv desde tu sistema de archivos.
6. Seleccionar "Create new table": Elige esta opción para crear una nueva tabla donde se importarán los datos.
7. Configurar los tipos de datos: Revisa y ajusta los tipos de datos sugeridos por el asistente para cada columna, asegurándote de que coincidan con el formato de tus datos (por ejemplo, VARCHAR para texto, INT o DECIMAL para números, DATE para fechas, etc.).

Finalizar la importación: Haz clic en "Next" y sigue las instrucciones finales para que el asistente comience a crear la tabla y cargar los datos.

4. Verificación y Exploración Inicial
Una vez que los datos se han cargado, puedes verificar que la tabla se haya creado correctamente y realizar una exploración inicial seleccionando todas las filas de la tabla:
```SQL
SELECT * FROM amazon_delivery;
```
Este comando te permitirá ver las primeras filas de los datos importados y confirmar que la carga fue exitosa.

***Archivo: [create_db.sql](sql/create_db.sql)***

### 2. **Exploración inicial de los datos**

Una vez que los datos han sido cargados en la base de datos amazon_delivery, se realiza una serie de consultas SQL para obtener una comprensión inicial de la estructura, el volumen y la calidad de los datos.

1. Verificación de los Datos Iniciales
Esta consulta permite visualizar las primeras 10 filas de la tabla amazon para tener una idea rápida de su contenido y formato.
```SQL
SELECT
    *
FROM
    amazon
LIMIT 10;
```

Esta consulta confirmar que los datos se han cargado correctamente y observar un extracto representativo de las filas.

2. Descripción de los Tipos de Datos
La sentencia DESCRIBE proporciona información sobre la estructura de la tabla, incluyendo los nombres de las columnas, sus tipos de datos, si aceptan valores nulos y si tienen claves.

```SQL
DESCRIBE amazon;
```

`DESCRIBRE` nos ayudo a entender los tipos de datos asignados a cada columna durante la importación, lo cual es crucial para planificar futuras transformaciones y limpieza.

3. Conteo de Registros
Esta consulta cuenta el número total de filas en la tabla, utilizando Order_ID como una columna no nula para el conteo.

```SQL
SELECT
    COUNT(Order_ID) AS cantidad_registros
FROM
    amazon;
```

El determinar el volumen total del conjunto de datos, nos ayuda a evaluar la escala del análisis.

4. Identificación de Valores Problemáticos (Cadenas Vacías, 'NaN', Espacios en Blanco)
Esta serie de consultas UNION ALL está diseñada para identificar registros que contienen valores "problemáticos" en columnas de texto o en columnas que, aunque deberían ser numéricas o de fecha, podrían haber sido importadas como texto y contener indicadores de valores faltantes o inválidos como cadenas vacías (''), la cadena 'NaN', o cadenas con solo espacios en blanco.

```SQL
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
SELECT
    'Order_Time' AS column_name, Order_Time FROM amazon WHERE TRIM(Order_Time) = '' OR TRIM(Order_Time) = 'NaN' OR TRIM(Order_Time) LIKE '%NaN%'
UNION ALL
SELECT
    'Pickup_Time' AS column_name, Pickup_Time FROM amazon WHERE TRIM(Pickup_Time) = '' OR TRIM(Pickup_Time) = 'NaN' OR TRIM(Pickup_Time) LIKE '%NaN%'
UNION ALL
SELECT
    'Order_Date' AS column_name, Order_Date FROM amazon WHERE TRIM(Order_Date) = '' OR TRIM(Order_Date) = 'NaN' OR TRIM(Order_Date) LIKE '%NaN%'
UNION ALL
SELECT
    'Agent_Age' AS column_name, Agent_Age FROM amazon WHERE Agent_Age IS NOT NULL AND (TRIM(Agent_Age) = '' OR TRIM(Agent_Age) = 'NaN' OR TRIM(Agent_Age) LIKE '%NaN%')
UNION ALL
SELECT
    'Agent_Rating' AS column_name, Agent_Rating FROM amazon WHERE Agent_Rating IS NOT NULL AND (TRIM(Agent_Rating) = '' OR TRIM(Agent_Rating) = 'NaN' OR TRIM(Agent_Rating) LIKE '%NaN%')
UNION ALL
SELECT
    'Store_Latitude' AS column_name, Store_Latitude FROM amazon WHERE Store_Latitude IS NOT NULL AND (TRIM(Store_Latitude) = '' OR TRIM(Store_Latitude) = 'NaN' OR TRIM(Store_Latitude) LIKE '%NaN%')
UNION ALL
SELECT
    'Store_Longitude' AS column_name, Store_Longitude FROM amazon WHERE Store_Longitude IS NOT NULL AND (TRIM(Store_Longitude) = '' OR TRIM(Store_Longitude) = 'NaN' OR TRIM(Store_Longitude) LIKE '%NaN%')
UNION ALL
SELECT
    'Drop_Latitude' AS column_name, Drop_Latitude FROM amazon WHERE Drop_Latitude IS NOT NULL AND (TRIM(Drop_Latitude) = '' OR TRIM(Drop_Latitude) = 'NaN' OR TRIM(Drop_Latitude) LIKE '%NaN%')
UNION ALL
SELECT
    'Drop_Longitude' AS column_name, Drop_Longitude FROM amazon WHERE Drop_Longitude IS NOT NULL AND (TRIM(Drop_Longitude) = '' OR TRIM(Drop_Longitude) = 'NaN' OR TRIM(Drop_Longitude) LIKE '%NaN%')
UNION ALL
SELECT
    'Delivery_Time' AS column_name, Delivery_Time FROM amazon WHERE Delivery_Time IS NOT NULL AND (TRIM(Delivery_Time) = '' OR TRIM(Delivery_Time) = 'NaN' OR TRIM(Delivery_Time) LIKE '%NaN%');
```

Lograr detectar valores inconsistentes o faltantes que no son NULL, pero que representan datos inválidos (como cadenas vacías o textos como "NaN"), es un paso clave durante la fase de limpieza de datos.

### 3. **Limpieza y preprocesamiento**
Las primeras etapas del proceso de limpieza y transformación de los datos en la tabla amazon, enfocándose en la estandarización de valores, la corrección de tipos de datos y la identificación de inconsistencias.

1. Reemplazo de Valores Problemáticos por NULL
Antes de realizar cualquier conversión de tipo de dato, es crucial estandarizar los valores que representan datos faltantes o inválidos. Esta consulta UPDATE reemplaza cadenas vacías (''), la cadena 'NaN' o subcadenas que contengan 'NaN' por NULL en las columnas Order_Time, Weather y Traffic.

```SQL
UPDATE amazon
SET
    -- Para columnas de tiempo/fecha:
    Order_Time = CASE WHEN TRIM(Order_Time) = '' OR TRIM(Order_Time) LIKE '%NaN%' THEN NULL ELSE Order_Time END,
    -- Para otras columnas TEXT:
    Weather = CASE WHEN TRIM(Weather) = '' OR TRIM(Weather) LIKE '%NaN%' THEN NULL ELSE Weather END,
    Traffic = CASE WHEN TRIM(Traffic) = '' OR TRIM(Traffic) LIKE '%NaN%' THEN NULL ELSE Traffic END;
```
Realizar este paso nos ayuda a preparar los datos para conversiones de tipo más precisas, asegurando que los valores ausentes sean representados uniformemente como NULL.

2. Identificación de Valores Nulos
Después de la primera fase de reemplazo, se realiza una verificación exhaustiva para contar la cantidad de valores NULL en cada columna. Esto proporciona una visión clara de la completitud de los datos, lo cual es fundamental para decidir las estrategias de imputación o eliminación.

```SQL
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
```

3. Transformación de Columnas de Tiempo (Order_Time, Pickup_Time)
Este paso se encarga de convertir las columnas de tiempo, que originalmente podrían haber sido importadas como TEXT, a un tipo de dato TIME adecuado para análisis de tiempo. Se utilizan columnas temporales para asegurar la integridad de los datos durante la transformación.

    1. Añadir columnas temporales:
    ```SQL
    ALTER TABLE amazon
    ADD COLUMN temp_order_time TIME,
    ADD COLUMN temp_pickup_time TIME;
    ```

    2. Convertir y poblar:
    ```SQL
    UPDATE amazon
    SET
        temp_order_time = STR_TO_DATE(Order_Time, '%H:%i:%s'),
        temp_pickup_time = STR_TO_DATE(Pickup_Time, '%H:%i:%s');
    ```

    3. Verificar la conversión:
    ```SQL
    SELECT
        Order_Time,
        temp_order_time,
        Pickup_Time,
        temp_pickup_time
    FROM
        amazon
    LIMIT 10;
    ```

    4. Eliminar columnas originales:
    ```SQL
    ALTER TABLE amazon
    DROP COLUMN Order_Time,
    DROP COLUMN Pickup_Time;
    ```

    5. Renombrar columnas temporales:
    ```SQL
    ALTER TABLE amazon
    CHANGE COLUMN temp_order_time Order_Time TIME,
    CHANGE COLUMN temp_pickup_time Pickup_Time TIME;
    ```

4. Transformación de la Columna de Fecha (Order_Date)
Similar al proceso de las columnas de tiempo, esta sección se dedica a convertir Order_Date a un tipo de dato DATE.

1. Añadir columna temporal:
```SQL
ALTER TABLE amazon
ADD COLUMN temp_order_date DATE;
```

2. Convertir y poblar:
```SQL
UPDATE amazon
SET temp_order_date = DATE(Order_Date);
```

3. Verificar la conversión (opcional):
```SQL
SELECT
    Order_Date, temp_order_date
FROM
    amazon
LIMIT
    10;
```

4. Eliminar columna original:
```SQL
ALTER TABLE amazon
DROP COLUMN Order_Date;
```

5. Renombrar columna temporal:

```SQL
ALTER TABLE amazon
CHANGE COLUMN temp_order_date Order_Date DATE;
```

5. Limpieza de Cadenas de Texto (Eliminar Espacios Extra)
Esta operación UPDATE utiliza la función TRIM() para eliminar espacios en blanco al inicio y al final de las cadenas en varias columnas de texto.

```SQL
UPDATE amazon
SET
    Weather = TRIM(Weather),
    Traffic = TRIM(Traffic),
    Vehicle = TRIM(Vehicle),
    Area = TRIM(Area),
    Category = TRIM(Category);
```

6. Re-evaluación de Valores Nulos
Se realiza una segunda verificación de valores nulos después de las transformaciones de tipo y la limpieza de cadenas.

```SQL
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
```

7. Búsqueda de Valores Negativos o Fuera de Rango
Esta consulta identifica registros donde las columnas numéricas (Agent_Age, Agent_Rating, coordenadas de latitud/longitud, Delivery_Time) contienen valores negativos o valores de latitud/longitud que están fuera de los rangos geográficos válidos.

```SQL
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
```

8. Identificación de Registros Completamente Duplicados
Se verifica la existencia de filas que son idénticas en todas sus columnas.

```SQL
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
```

9. Verificación de la Estructura y Datos Finales (Parte 1)
Finalmente, se revisa la estructura de la tabla y se visualizan las primeras filas para confirmar que todas las transformaciones de esta primera parte se hayan aplicado correctamente.

```SQL
DESCRIBE amazon;
```

```SQL
SELECT
    *
FROM
    amazon
LIMIT
    10;
```

4. **Análisis exploratorio de datos (EDA)**:
   - [Ej. Distribución, correlaciones, agrupaciones, etc.]

5. **Visualización de datos**:
   - Uso de gráficos de barras, líneas, cajas, dispersión y mapas de calor.

6. **Modelado o reportes (opcional)**:
   - [Si aplica: modelos de ML, clustering, predicciones, etc.]

7. **Conclusiones y recomendaciones**:
   - Síntesis de hallazgos clave y propuestas de acción.

---

## 📌 Vista previa del Dashboard

![Vsita Dashboard Amazon Delivery](dashboard/Dashboard_Amazon_Delivery.png)

Link: [Dashboard Amazon Delivery](https://public.tableau.com/app/profile/said.mariano/viz/Dashboard_Amazon_Delivery/Dashboard_Amazon_Delivery)

---

## 💡 Insight clave

- [Insight 1]
- [Insight 2]
- [Recomendación práctica o estratégica basada en los datos]

---

## 🛠️ Tecnologías

- **Python** - Limpeieza de datos y análisis de datos
   - Pandas
   - Numpy
   - Matplotlib
   - Seaborn
   - Jupyter Notebook
- **Kaggle** - Fuente de datos 
- **Tableau** - Visualización de datos y creación de Dashboard
- **GitHub** - Repositorio

---

## 📂 Archivos
- [amazon_delivery.csv](data/raw/amazon_delivery.csv): Conjunto de datos originales obtenido de Kaggle(sin procesar).
- [amazon_delivery.csv](data/processed/amazon_delivery_limpios.csv): Conjunto de datos limpios.
- [datos_entrega_procesados.csv](data/processed/datos_entrega_procesados.csv): Conjunto de datos granular y primario del análisis (Contiene cada registro de entrega individual, enriquecido con columnas calculadas y derivadas).
- [desafios_por_area_y_hora.csv](data/processed/desafios_por_area_y_hora.csv): Resume las métricas clave de desempeño (tiempo promedio de entrega, número total de entregas, número de entregas desafiantes y su porcentaje) por cada combinación única de Area (zona geográfica general) y Delivery_Time_Slot (franja horaria).
- [desafios_por_zona_geografica.csv](data/processed/desafios_por_zona_geografica.csv): Contiene métricas resumidas (tiempo promedio de entrega, número total de entregas, número de entregas desafiantes y su porcentaje) por Lat_Bin y Lon_Bin (coordenadas geográficas binned/agrupadas en celdas de cuadrícula).

---

## 👤 Autor

**Said Mariano Sánchez** – [📧](smariano170@gmail.com)
Analista de Datos Jr. | Visualización | Power BI | Python | SQL
🌎 México
Este proyecto forma parte de mi portafolio como analista de datos Jr.

---

## 📝 Licencia

Este proyecto está licenciado bajo la **Licencia MIT**. Puedes usarlo, modificarlo y distribuirlo libremente, siempre que menciones al autor original.

---