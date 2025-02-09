-- Consultas SQL Iniciales
-- Crear esquema BBDD
CREATE TABLE actores (
    actor_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50)
);

CREATE TABLE peliculas (
    film_id INT PRIMARY KEY,
    title VARCHAR(100),
    language_id INT,
    original_language_id INT,
    rating VARCHAR(10),
    length INT,
    replacement_cost DECIMAL(10, 2)
);

CREATE TABLE alquileres (
    rental_id INT PRIMARY KEY,
    rental_date DATE,
    film_id INT,
    customer_id INT,
    amount DECIMAL(10, 2)
);


-- 1. Muestra los nombres de todas las películas con una clasificación por edades de 'R'.
select "title"
from public.film
where "rating" = 'R';

-- 2. Encuentra los nombres de los actores con actor_id entre 30 y 40.
select "first_name", last_name
from public.actor
where "actor_id" between 30 and 40;

-- 3. Obtén las películas cuyo idioma coincide con el idioma original.
select "title"
from public.film
where "language_id" = "original_language_id";

-- 4. Ordena las películas por duración de forma ascendente.
select "title", "length"
from public.film
order by "length" asc;

-- 5. Encuentra el nombre y apellido de los actores con 'Allen' en su apellido.
select "first_name", "last_name"
from public.actor
where "last_name" like '%Allen%';

-- 6. Encuentra la cantidad total de películas en cada clasificación de la tabla film y muestra la clasificación junto con el recuento.
select "rating", count (*)
from public.film
group by "rating";

-- 7. Encuentra el título de todas las películas que son 'PG13' o tienen una duración mayor a 3 horas.
select "title"
from public.film
where "rating" = 'PG-13' or "length" > 180;

-- 8. Encuentra la variabilidad de lo que costaría reemplazar las películas.
select STDDEV("replacement_cost"), variance("replacement_cost") 
from public.film;

-- 9. Encuentra la mayor y menor duración de una película en la base de datos.
select max("length"), min("length") 
from public.film;

-- 10. Encuentra lo que costó el antepenúltimo alquiler ordenado por día.
select "amount"
from public.payment
order by "payment_date" desc
limit 1
offset 2;

-- 11. Encuentra el título de las películas que no sean ni 'NC-17' ni 'G' en cuanto a clasificación.
select "title"
from public.film
where "rating" not in ('NC-17','G');

-- 12. Encuentra el promedio de duración de las películas para cada clasificación y muestra la clasificación junto con el promedio.
select "rating", avg("length")
from public.film
group by 1;

-- 13. Encuentra el título de todas las películas con una duración mayor a 180 minutos.
select "title"
from public.film
where "length" > 180;

-- 14. ¿Cuánto dinero ha generado en total la empresa?
select sum("amount")
from public.payment;

-- 15. Muestra los 10 clientes con mayor valor de ID.
select "customer_id"
from public.customer
order by 1 desc
limit 10;

-- 16. Encuentra el nombre y apellido de los actores que aparecen en la película con título 'Egg Igby'.
select "first_name", "last_name"
from public.actor a
join public.film_actor fa on a."actor_id" = fa. "actor_id"
join public.film f on fa."film_id" = f."film_id"
where f."title" = 'Egg Igby';

-- Consultas Intermedias

-- 1. Selecciona todos los nombres únicos de películas.
select distinct "title"
from public.film;

-- 2. Encuentra las películas que son comedias y tienen una duración mayor a 180 minutos.
select "title"
from public.film f
join public.film_category fc on f."film_id" = fc."film_id"
join public.category c on fc."category_id" = c."category_id"
where c."name" = 'Comedy' and "length" > 180;

-- 3. Encuentra las categorías de películas con un promedio de duración superior a 110 minutos y muestra el nombre de la categoría junto con el promedio.
select c."name", avg("length")
from public.category c
join public.film_category fc on fc."category_id" = c."category_id"
join public.film f on f."film_id" = fc."film_id"
group by 1
having avg("length") > 110;

-- 4. ¿Cuál es la media de duración del alquiler de las películas?
select avg("return_date" - "rental_date")
from public.rental;

-- 5. Crea una columna con el nombre completo (nombre y apellidos) de los actores y actrices.
select concat("first_name",' ', "last_name") as nombre_completo
from public.actor;

-- 6. Muestra los números de alquileres por día, ordenados de forma descendente.
select "rental_date", count("rental_id")
from public.rental
group by 1
order by 2 desc;

-- 7. Encuentra las películas con una duración superior al promedio.
select "title"
from public.film
where "length" > (select avg("length") from public.film);

-- 8. Averigua el número de alquileres registrados por mes.
select extract (month from "rental_date"), count("rental_id")
from public.rental
group by 1
order by 2 desc;

-- 9. Encuentra el promedio, la desviación estándar y la varianza del total pagado.
select avg("amount"), stddev("amount"), variance("amount")
from payment p;

-- 10. ¿Qué películas se alquilan por encima del precio medio?
select f."title"
from public.film f
join public.inventory i on f."film_id" = i."film_id"
join public.rental r on i."inventory_id" = r."inventory_id"
join public.payment p on r."rental_id" = p."rental_id"
group by 1
having  sum("amount") / count("payment_id") > (select avg("amount") from public.payment);

-- 11. Muestra el ID de los actores que hayan participado en más de 40 películas.
select a."actor_id"
from public.actor a
join public.film_actor fa on a."actor_id" = fa."actor_id"
join public.film f on fa."film_id" = f.film_id
group by 1
having count(f.film_id) > 40;

-- 12. Obtén todas las películas y, si están disponibles en el inventario, muestra la cantidad disponible.
select "title", count(i."film_id")
from public.film f
join public.inventory i on f."film_id" = i."film_id"
group by 1
order by 2 desc;

-- 13. Obtén los actores y el número de películas en las que han actuado.
select concat("first_name",' ', "last_name") as nombre_actor, count(f."film_id")
from public.actor a
join public.film_actor fa on a."actor_id" = fa."actor_id"
join public.film f on fa."film_id" = f."film_id"
group by 1
order by 2 desc;

-- 14. Obtén todas las películas con sus actores asociados, incluso si algunas no tienen actores.
select f."title", concat("first_name",' ', "last_name") as nombre_actor
from public.film f
full join public.film_actor fa on f."film_id" = fa."film_id"
full join public.actor a on fa."actor_id" = a."actor_id"
group by 1, 2
order by 1;

-- 15. Encuentra los 5 clientes que más dinero han gastado.
select concat("first_name",' ', "last_name") as cliente, sum("amount")
from public.customer c
join public.payment p on c."customer_id" = p."customer_id"
group by 1
order by 2 desc
limit 5;


-- Consultas Avanzadas

-- 1. Encuentra el ID del actor más bajo y más alto.
select max("actor_id"), min("actor_id")
from public.actor;

-- 2. Cuenta cuántos actores hay en la tabla actor.
select count("actor_id")
from public.actor;

-- 3. Selecciona todos los actores y ordénalos por apellido en orden ascendente.
select *
from public.actor
order by last_name asc;

-- 4. Selecciona las primeras 5 películas de la tabla film.
select "title"
from public.film
limit 5;

-- 5. Agrupa los actores por nombre y cuenta cuántos tienen el mismo nombre.
select "first_name", count("actor_id") 
from public.actor
group by 1
order by 2 desc;

-- 6. Encuentra todos los alquileres y los nombres de los clientes que los realizaron.
select 
"rental_id", concat("first_name",' ', "last_name") as cliente
from public.customer c
join public.rental r on c."customer_id" = r."customer_id";


-- 7. Muestra todos los clientes y sus alquileres, incluyendo los que no tienen.
select 
concat("first_name",' ', "last_name") as cliente, count ("rental_id")
from public.customer c
full join public.rental r on c."customer_id" = r."customer_id"
group by 1
order by 2;

-- 8. Realiza un CROSS JOIN entre las tablas film y category. Analiza su valor.
select *
from public.film
cross join public.category;
-- se añaden 3 columnas (category_id, name y last update) pero genera muchos duplicados incorrectos

-- 9. Encuentra los actores que han participado en películas de la categoría 'Action'.
select concat("first_name",' ', "last_name") as actor
from public.actor a
join public.film_actor fa on a."actor_id" = fa."actor_id"
join public.film_category fc on fa."film_id" = fc."film_id"
join public.category c on fc."category_id" = c."category_id" 
where "name" = 'Action';

-- 10. Encuentra todos los actores que no han participado en películas.
select concat("first_name",' ', "last_name") as actor
from public.actor a
full join public.film_actor fa on a."actor_id" = fa."actor_id"
where "film_id" = null;

-- 11. Crea una vista llamada actor_num_peliculas que muestre los nombres de los actores y el número de películas en las que han actuado.
create view actor_num_peliculas as
select concat("first_name",' ', "last_name") as actor, count (f."film_id")
from public.actor a
join public.film_actor fa on a."actor_id" = fa."actor_id"
join public.film f on fa."film_id" = f."film_id"
group by 1
order by 2 desc;

-- Consultas con Tablas Temporales

-- 1. Calcula el número total de alquileres realizados por cada cliente.
with cte_1 as (
select "customer_id" as n_alquileres
from public.rental)
select 
concat("first_name",' ', "last_name") as cliente, count(n_alquileres)
from public.customer c
join cte_1 on c."customer_id" = cte_1."n_alquileres"
group by 1
order by 2 desc;

-- 2. Calcula la duración total de las películas en la categoría Action.
with cte_2 as (
select sum("length") as duracion, "film_id"
from public.film f
group by 2
)
select "name", sum(duracion)
from public.category c
join public.film_category fc on c."category_id" = fc."category_id"
join cte_2 on fc."film_id" = cte_2."film_id"
where "name" = 'Action'
group by 1;


-- 3. Encuentra los clientes que alquilaron al menos 7 películas distintas.
with cte_3 as (
select distinct "customer_id" as numero_alquileres, i."film_id"
from public.rental r
join public.inventory i on r."inventory_id" = i."inventory_id")
select 
concat("first_name",' ', "last_name") as cliente, count("numero_alquileres")
from public.customer c
join cte_3 on c."customer_id" = cte_3."numero_alquileres"
group by 1
having count(cte_3."numero_alquileres") > 7
order by 2 desc;

-- 4. Encuentra la cantidad total de películas alquiladas por categoría.
with cte_4 as (
select i."film_id", COUNT(r."rental_id") AS total_alquileres
from public.rental r
join public.inventory i ON r."inventory_id" = i."inventory_id"
group by i."film_id")
select "name", sum(cte_4.total_alquileres)
from public.category c
join public.film_category fc on c."category_id" = fc."category_id"
join cte_4 on fc."film_id" = cte_4."film_id"
group by 1
order by 2 desc;
-- 5. Renombra las columnas first_name como Nombre y last_name como Apellido.
select "first_name" as Nombre, "last_name" as Apellido
from public.actor

-- 6. Crea una tabla temporal llamada cliente_rentas_temporal para almacenar el total de alquileres por cliente.
with cliente_rentas_temporal as(
select concat("first_name",' ', "last_name") as cliente, count ("rental_id")
from public.customer c
join public.rental r on c."customer_id" = r."customer_id"
group by 1);

-- 7. Crea otra tabla temporal llamada peliculas_alquiladas para almacenar películas alquiladas al menos 10 veces.
with peliculas_alquiladas as(
select "title", count("rental_id")
from public.film f
join public.inventory i on f."film_id" = i."film_id"
join public.rental r on i."inventory_id" = r."inventory_id"
group by 1
having count("rental_id") > 10
order by 2 desc);

-- 8. Encuentra los nombres de los clientes que más gastaron y sus películas asociadas.
with cte as (
select concat("first_name",' ', "last_name") as cliente, sum("amount") as gastado, c."customer_id"
from public.customer c
join public.payment p on c."customer_id" = p."customer_id"
group by 1, 3
order by 2 desc)
select "title", cliente, gastado
from public.film f
join public.inventory i on f.film_id = i.film_id 
join public.rental r on i.inventory_id = r.inventory_id 
join cte c on r.customer_id = c.customer_id;

-- 9. Encuentra los actores que actuaron en películas de la categoría Sci-Fi.
with cte2 as (select "name", "category_id"
from public.category)
select concat("first_name",' ', "last_name") as actor
from public.actor a
join public.film_actor fa on a."actor_id" = fa."actor_id"
join public.film_category fc on fa."film_id" = fc."film_id"
join cte2 on fc."category_id" = cte2."category_id" 
where "name" = 'Sci-Fi';
