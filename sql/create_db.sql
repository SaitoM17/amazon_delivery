CREATE DATABASE amazon_delivery;
USE amazon_delivery; -- Asegúrate de seleccionar la base de datos correcta

-- Los datos se cargaron por medio de la interfaz de MySQL Workbench
-- Pasos para cargar los datos
/**
1.-Crear la base de datos 
2.-Seleccionar la base de datos
3.- Dar click derecho en el apartado de tables
3.-Seleccionar "Table Data Import Wizard"
4.-Seleccionar la ruta donde esta el archivo CSV
5.-Seleccionar "Create new table"
6.-Configurar los tipos de datos 
7.-Darle click en Next y se empezara a crear la tabla con los datos
**/

-- Verificamos que se haya creado correctamente
SELECT * FROM amazon_delivery;