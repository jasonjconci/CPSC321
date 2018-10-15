/*
*
* Homework #5 Script: More Database Queries. Queries are presented in order
* they are asked in the homework PDF, along with a plain(ish) English
* description in a comment block, above each query.
*
*/



/*
This query will select all distinct provinces, along with corresponding
province area, for provinces containing a city with a population greater
than 1000.
*/
SELECT DISTINCT p.province_name, p.area
FROM province p JOIN city c ON (c.province_name = p.province_name)
WHERE c.population > 1000;


/*
This query will select a city's name, along with that city's country's
name, if that city, say c1, shares a name with another city, say c2, 
in a different country, and c1  has a larger population than c2.
*/
SELECT c1.city_name, c1.country_code
FROM city c1 JOIN city c2 USING (city_name)
WHERE c1.country_code <> c2.country_code
AND c1.population > c2.population;


/*
Selects the country code, gdp, inflation, and total population for
each country. Population is the sum of all cities within a country
present within our city table.
*/
SELECT co.country_code, co.gdp, co.inflation, SUM(ci.population)
FROM country co JOIN city ci USING (country_code)
GROUP BY co.country_code;


/*
Selects province name, province area, and sum of populations of
cities within a province. Only selects provinces where the sum of
city populations is greater than 1,000,000.
*/
SELECT p.province_name, p.area, SUM(c.population)
FROM province p JOIN city c USING (province_name)
GROUP BY p.province_name
HAVING SUM(c.population) > 1000000;


/*
Selects country code, and country population (computed via sum
of populations of cities within the country). Ordered by country
population, from highest to lowest.
*/
SELECT co.country_code, SUM(ci.population)
FROM country co JOIN city ci USING (country_code)
GROUP BY co.country_code
ORDER BY SUM(ci.population) DESC;


/*
Selects country code, and country area (computed via sum of
all areas of provinces within a country). Ordered by country
size, from highest to lowest.
*/
SELECT c.country_code, SUM(p.area)
FROM country c JOIN province p USING (country_code)
GROUP BY c.country_code
ORDER BY SUM(p.area) DESC;


/*
Selects distinct country names, wherein the country contains a
province containing 5 or more cities.
*/
SELECT DISTINCT p.country_code, COUNT(c.city_name)
FROM province p JOIN city c USING (province_name)
GROUP BY p.province_name
HAVING COUNT(c.city_name) >= 5;



# Deleting our assoc_borders view, if it already exists
DROP VIEW IF EXISTS assoc_borders;

/*
Creates an "associative" view of all borders in our border table.
That is, for each row containing c1-c2-len in the border table,
assoc_borders will contain this row, as well as c2-c1-len.
Using a union because it seems like the simplest way to do this.
*/
CREATE VIEW assoc_borders AS
(SELECT * FROM border)
UNION
(SELECT country2_code, country1_code, border_length
FROM border);


/*
Select the country_code, as well as avg gdp and inflation of countries
our country borders. Country in question is country_1, we join with
country c on a.country2_code. We group by a.country1, and average the
gdp and inflations in the group, which are always country1. Order by
gdp, then inflation, in ascending order.
*/
SELECT a.country1_code AS "country", AVG(c.gdp) AS "border avg gdp", AVG(c.inflation) as "border avg inflation"
FROM assoc_borders a JOIN country c ON (a.country2_code = c.country_code)
GROUP BY a.country1_code
ORDER BY AVG(c.gdp), AVG(c.inflation) ASC;
