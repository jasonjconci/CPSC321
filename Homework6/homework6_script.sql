#comment as placeholder

/*
Query #1 - find the total number of films, by category, ordered from most to least.
*/

SELECT c.name, COUNT(f.film_id)
FROM film_category f JOIN category c USING (category_id)
GROUP BY c.name
ORDER BY COUNT(f.film_id) DESC
LIMIT 10;


/*
Query #2 - find the number of films acted in by each actor, from high to low
*/
SELECT actor_id, COUNT(film_id)
FROM film_actor
GROUP BY actor_id
ORDER BY COUNT(film_id) DESC
LIMIT 10;


/*
#3: For each PG rated film that costs 2.99 to rent, find the number of times it has been rented.
First, we join rental, inventory, and film. From these 3 tables, we need: rental_id, film rating,
film rental rate, and inventory mostly just to join the two. We only include all rows wherein rating
is PG and cost is 2.99, group by the film's id, and return the film's title, as well as count of
rental_id's (which is the number of times the film has been rented).
*/
SELECT f.title, COUNT(r.rental_id)
FROM rental r JOIN inventory i USING (inventory_id) JOIN film f USING (film_id)
WHERE f.rating = "PG" AND f.rental_rate = 2.99
GROUP BY i.film_id
ORDER BY COUNT(r.rental_id) DESC
LIMIT 10;


/*
#4: Selecting first/last name, as well as rental count, of customers who've rented 6 or more R rated films
costing 0.99. Joining rental to get count, customer for first/last name, film for rating/rental_rate, and
inventory to join rental and inventory as a go-between.
*/
SELECT c.first_name, c.last_name, COUNT(r.rental_id)
FROM rental r JOIN inventory i USING(inventory_id)
JOIN film f using (film_id)
JOIN customer c USING (customer_id)
WHERE f.rating = "R" AND f.rental_rate = 0.99
GROUP BY c.customer_id
HAVING COUNT(r.rental_id) >= 6
ORDER BY COUNT(r.rental_id) DESC
LIMIT 10;


/*
#5: Returns the total amount of sales (sum of payments), for each of our defined categories.
*/
SELECT c.name, SUM(p.amount)
FROM payment p JOIN rental r USING (rental_id)
JOIN inventory i USING (inventory_id)
JOIN film_category fc USING (film_id)
JOIN category c USING (category_id)
GROUP BY (fc.category_id)
ORDER BY SUM(p.amount) DESC
LIMIT 10;


/*
#6: Returns the category (as defined in table category) with the highest number of
R rated films. Returns category name, along with number of R rated films.
*/
SELECT c.name, COUNT(f.film_id)
FROM film f JOIN film_category fc USING (film_id)
JOIN category c USING (category_id)
WHERE f.rating = "R"
GROUP BY c.name
HAVING COUNT(f.film_id) =
	(SELECT MAX(film_count) FROM (
SELECT COUNT(f.film_id) as film_count
FROM film_category fc JOIN film f USING (film_id)
WHERE f.rating = "R"
GROUP BY fc.category_id) AS SQ2);

/*
#7: Returns the 'G' rated film(s) that has been rented the highest number of times.
Returns the film id, title, and number of rentals.
*/

SELECT f.film_id, f.title, COUNT(r.rental_id) as "number times rented"
FROM film f JOIN inventory i USING (film_id) JOIN rental r USING (inventory_id)
WHERE f.rating = "G"
GROUP BY f.film_id
HAVING COUNT(r.rental_id) = (
SELECT MAX(rental_count) FROM (
SELECT COUNT(r.rental_id) AS rental_count
FROM film f JOIN inventory i USING (film_id) JOIN rental r USING (inventory_id)
WHERE f.rating = "G"
GROUP BY f.film_id) AS SQ2);


/*
#8: This query returns the store(s) with the highest number of rentals.
 */
SELECT s.store_id, COUNT(r.rental_id)
FROM rental r JOIN staff s USING (staff_id)
GROUP BY s.store_id
HAVING COUNT(r.rental_id) = (
SELECT MAX(rentals_total) FROM (
SELECT COUNT(r.rental_id) AS rentals_total
FROM rental r JOIN staff s USING (staff_id)
GROUP BY s.store_id) AS SQ2);


/*
#9: I genuinely hope grouping by 2 attributes isn't cheating, I couldn't think of a better way.

This query finds the number of movies rented by each staff member that cost 99cents to rent.
Each line in the query return is the last/first names of staff member, movie title, and how
many times that staff member rented out that particular movie.
*/
SELECT s.last_name, s.first_name, f.title, COUNT(r.rental_id)
FROM rental r JOIN staff s USING (staff_id)
JOIN inventory i USING (inventory_id)
JOIN film f USING (film_id)
WHERE f.rental_rate = 0.99
GROUP BY s.last_name, f.title
ORDER BY s.last_name, s.first_name, COUNT(r.rental_id) DESC
LIMIT 10;

/*
#10: Self-written query
Returns the number of rentals, per category, per each store.
Could be used if you want to see what kinds of movies are rented
at each store - eg, store 2 rents much more sports films than store 1
*/
SELECT st.store_id, c.name, COUNT(r.rental_id)
FROM rental r JOIN inventory i USING (inventory_id)
JOIN film_category fc USING (film_id)
JOIN category c USING (category_id)
JOIN staff sf USING (staff_id)
JOIN store st ON (sf.store_id = st.store_id)
GROUP BY st.store_id, fc.category_id
ORDER BY st.store_id, COUNT(r.rental_id) DESC
LIMIT 10;
