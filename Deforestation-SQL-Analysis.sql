/*Create a View called "forestation” by joining all three tables - forest_area, land_area and regions in the workspace.
The forest_area and land area tables join on both country code AND year.

The regions table joins these based on only country code.

In the ‘forestation’ View, include the following:

ALL of the columns of the origin tables
A new column that provides the percent of the land area that is designated as forest.
Keep in mind that the column forest_area_sqkm in the forest_area table and the land _area_sqmi in the land area table are in different units (square kilometers and square miles, respectively), so an adjustment will need to be made in the calculation you write (1 sqkm) */

DROP VIEW IF EXISTS forestation;
CREATE VIEW forestation AS
(SELECT forest_area.country_code,forest_area.country_name,forest_area.year,
forest_area.forest_area_sqkm,
land_area.total_area_sq _mi*2.59 AS total_land_area,
regions.region, regions.income_group,
forest_area.forest_area_sqkm/(land_area.total area_sq_mi*2.59)*18@ AS total_land_percentage
FROM forest_area
JOIN land_area
ON forest_area.country_code = land_area.country code AND forest_area.year = land_area.year
JOIN regions
ON forest_area.country_code = regions.country_code);

--1. GLOBAL SITUATION
--(a). What was the total forest area (in sq km) of the world in 1996?

SELECT forest_area_sqgkm, year, country_name
FROM forestation
WHERE year = 199@ AND country_name = 'World';

--(b). What was the total forest area (in sq km) of the world in 2016?

SELECT forest_area_sqkm,year,country_name
FROM forestation
WHERE year = 2016 AND country _name = 'World';

--BEST Way

WITH
area_2016 AS
(SELECT forest_area_sqkm AS a_2016,year, country_name
FROM forestation
WHERE year = 2016 AND country_name = 'World'),
area_1990 AS
(SELECT forest_area_sqkm AS a_1990,year, country_name
FROM forestation
WHERE year = 1990 AND country_name = 'World')
SELECT a_2016,a_1990
FROM area_1996,area_2016

--(c). What was the change (in sq km) in the forest area of the world from 19390 to 2016?

SELECT
(SELECT forest_area_sqkm
FROM forestation
WHERE year = 2016 AND country_name = 'World')
--
(SELECT forest_area_sqkm
FROM forestation
WHERE year = 1998 AND country_name = 'World') AS change;


--(d). What was the percent change in forest area of the world between 1990 and 2016?


WITH
areas_2016 AS
(SELECT forest_area_sqgkm AS a_2016,year, country_name
FROM forestation
WHERE year = 2016 AND country_name = 'World'),
areas_199@ AS
(SELECT forest_area_sqgkm AS a_1990@
FROM forestation
WHERE year = 1998 AND country_name = 'World'),
change AS
(SELECT a_1990,a_2016, a_2016 - a_199@ AS change, (a_2016-a_1990)/a_1990*10@ AS percentage_change
FROM areas_2016,areas_1990)
SELECT a_1990,a_2016, change, ROUND(percentage_change: :NUMERIC,2) AS percentage_change
FROM change;

--(e). If you compare the amount of forest area Lost between 1996 and 2016, to which country's total area in 2016 is it closest to?

SELECT DISTINCT country_name,total_land_area
FROM forestation
WHERE total _land_area BETWEEN 1270000 AND 1330000;

--2, REGIONAL OUTLOOK
--Create a table that shows the Regions and their percent forest area (sum of forest area divided by sum of land area) in 1999 and 2016.
--Based on the table you created, ....

--a. What was the percent forest of the entire world in 2016? Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?

SELECT region,ROUND((SUM(forest_area_sqkm)*180/SUM(total_land_area))::NUMERIC,2) AS percentage_2016
FROM forestation
WHERE year = 2016
GROUP BY region
ORDER BY percentage_2016 DESC;


--b. What was the percent forest of the entire world in 1990? Which region had the HIGHEST percent forest in 1996, and which had the LOWEST, to 2 decimal places?

SELECT region,ROUND((SUM(forest_area_sgkm)*100/SUM(total_land_area))::NUMERIC,2) AS percentage_1990
FROM forestation
WHERE year = 1990
GROUP BY region
ORDER BY percentage_1990 DESC;

--c. Based on the table you created, which regions of the world DECREASED in forest area from 1996 to 2016?

WITH
percentage 2016 AS
(SELECT region,ROUND((SUM(forest_area_sqkm)*1008/SUM(total_land_area))::NUMERIC,2) AS Forest_area_2016
FROM forestation
WHERE year = 2016
GROUP BY region
ORDER BY Forest_area_2016 DESC),
percentage_1990 AS
(SELECT region, ROUND((SUM(forest_area_sqkm)*108/SUM(total_land_area)): :NUMERIC,2) AS Forest_area_1990
FROM forestation
WHERE year = 1990
GROUP BY region
ORDER BY Forest_area_199@ DESC),
j_percent_1990_2016 AS
 (SELECT *
  FROM percentage_2016
  JOIN percentage_1990
  USING (region))

SELECT Region,Forest_area_1990,Forest_area_2016, (Forest_area_2016-Forest_area_1999) AS Difference_in_Area
FROM j_percent_1990_2016;

--3. COUNTRY-LEVEL DFTAIL
--a. Which 5 countries saw the largest amount decrease in forest area from 1998 to 2016? What was the difference in forest area for each?

WITH
area_2016 AS
(SELECT region, country_name,ROUND(SUM(forest_area_sqkm): : NUMERIC,2) AS Forest_area_2016
FROM forestation
WHERE year = 2016 AND forest_area_sqkm IS NOT NULL
GROUP BY 1,2
ORDER BY Forest_area_2016 DESC),
area_1990 AS
(SELECT region, country_name,ROUND(SUM(forest_area_sqkm): :NUMERIC,2) AS Forest_area_199@
FROM forestation
WHERE year = 1990 AND forest_area_sqkm IS NOT NULL
GROUP BY 1,2
ORDER BY Forest_area_199@ DESC),
f_area_1990_2016 AS
(SELECT *
FROM area_2016
JOIN area_1996
USING (region,country name))
SELECT country_name, region,Forest_area_199@,Forest_area_2016, (Forest_area_2016-Forest_area_1998) AS Absolute_Forest_Area_Change
FROM f_area_199@_2016
WHERE country_name <> 'World'
ORDER BY Absolute_Forest_Area_Change
LIMIT 5;

/*NOTE:- with order by DESC we got country _name with highest figures of Absolute_forest_area_change which were CHINA & THE USA.*/

--b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?

WITH
area_2016 AS
(SELECT region, country_name,ROUND(SUM(forest_area_sqkm): :NUMERIC,2) AS Forest_area_2016
FROM forestation
WHERE year = 2016 AND forest_area_sqkm IS NOT NULL
GROUP BY 1,2
ORDER BY Forest_area_2016 DESC),
area_1990 AS
(SELECT region, country_name,ROUND(SUM(forest_area_sqkm): :NUMERIC,2) AS Forest_area_199@
FROM forestation
WHERE year = 1990 AND forest_area_sqkm IS NOT NULL
GROUP BY 1,2
ORDER BY Forest_area_199@ DESC),
f_area_1990_2016 AS
(SELECT *
FROM area_2016
JOIN area_1990
USING (region, country_name))
SELECT country_name, region,Forest_area_1999,Forest_area_2016,ROUND((Forest_area_2016-Forest_area_1990)*100/Forest_area_199@: :NUMERIC,2) AS Pct_Forest_Area_Change
FROM f_area_199@_2016
WHERE country_name <> "World"
ORDER BY Pct_Forest_Area_Change
LIMIT 5;

/*NOTE:- with order by DESC we got country_name with highest Percentage _forest_area_change which was ICELAND*/


--c. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?

WITH
c_group AS
(SELECT country_name,total_land_percentage,
CASE WHEN total_land_percentage >= 75 THEN '75%-100%'
WHEN total_land_percentage >= 50 THEN '50%-75%'
WHEN total_land_percentage >= 25 THEN '25%-50%'
ELSE '0%-25%' END AS Quartiles
FROM forestation
WHERE year = 2016 AND total land percentage IS NOT NULL AND country_name <> 'World')
SELECT Quartiles, COUNT(*) AS no_countries
FROM c_group
GROUP BY 1
ORDER BY Quartiles;


--d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016. (REGION/COUNTRIES/PERCENTAGE DESIGNATED AS FOREST)

WITH c_group AS
(SELECT region, country_name,total_land_percentage,
CASE WHEN total_land_percentage >= 75 THEN '75%-100%'
WHEN total_land_percentage >= 5@ THEN '50%-75%'
WHEN total_land_percentage >= 25 THEN '25%-50%'
ELSE "0%-25%" END AS Quartiles
FROM forestation
WHERE year = 2016 AND total_land_percentage IS NOT NULL AND country_name <> 'World')
SELECT country_name, region,ROUND(total_land_ percentage: :NUMERIC,2) AS Percentage_designated_forest
FROM c_group
WHERE total_land_percentage>=75
ORDER BY Quartiles;

--e. How many countries had a percent forestation higher than the United States in 2016?

SELECT COUNT (country_name)
FROM forestation
WHERE total_land_percentage >
(SELECT total_land_percentage
FROM forestation
WHERE country_code = 'USA' AND year = 2016)
AND year = 2016;

/*In Latin America & the Caribbean and Sub-Saharan Africa, where forest area is dropping the most, the world lost 3.2% of its total forest area between 1990 and 2016, an area larger than Peru. This reduction impacts the entire world since there is a high percentage
However, countries like China and the United States have seen significant growth in their forest acreage, while comparable nations Like Iceland have made significant efforts and seen success. Brazil exhibits a significant decline in forest acreage, while other cow
The Last quarter only includes 9 countries (more than 75). The regions of Latin America & the Caribbean and Sub-Saharan Africa in particular should receive special consideration due to the countries there that have experienced the biggest reduction in forest area*/
