drop database if exists  music_store;
create database music_store;
use music_store;
create table employee(
employee_id int primary key,
last_name text,
first_name text,
title text,
reports_to text,
levels text,
birthdate text,
hire_date text,
address text,
city text,
state text,
country text,
postal_code text,
phone text,
fax text,
email text
);
create table customer(
customer_id int primary key,
first_name text,
last_name text,
company text,
address text,
city text,
state text,
country text,
postal_code text,
phone text,
fax text,
email text,
support_rep_id int not null,
foreign key(support_rep_id) references employee(employee_id) on update cascade on delete cascade);
select * from customer;
select * from music_store.customer;



create table invoice(
invoive_id int primary key,
customer_id int,
invoice_date date,
billing_address text,
billing_city text,
billing_state text,
billing_country text,
billing_postalcode text,
 total float,
 foreign key(customer_id) references customer(customer_id) on update cascade on delete cascade);
 select * from invoice;
 
 
 create table playlist(
 playlist_id int primary key,
 name_ text);
 
 create table media_type(
 media_type_id int primary key,
 name_ text);
 
 create table genre(
 genre_id int primary key,
 name_ text);
 
 create table artist(
 artist_id int primary key,
 name_ text);
  
 create table album(
 album_id int primary key,
 title text,
 artist_id int,
 foreign key(artist_id) references artist(artist_id) on update cascade on delete cascade);
 
 

 
 
 
 create table track(
 track_id int primary key,
 name_ text,
 album_id int,
 media_type_id int,
 genre_id int,
 composer text,
 milliseconds int,
 bytes int,
 unit_price float,
 foreign key(media_type_id) references media_type(media_type_id),
 foreign key(genre_id) references genre(genre_id),
 foreign key(album_id) references album(album_id) on update cascade on delete cascade);
 
 
 create table invoice_line(
 invoice_line_id int primary key,
 invoice_id int,
 track_id int,
 unit_price float,
 quantity int,
 foreign key(invoice_id) references invoice(invoive_id),
 foreign key (track_id) references track(track_id) on update cascade on delete cascade);
 
 create table playlist_track(playlist_id int,track_id int,foreign key(playlist_id) references playlist(playlist_id),
 foreign key(track_id) references track(track_id) on update cascade on delete cascade);
 
 select * from music_store.track;
 
 
 	-- Question Set 1 - Easy

-- Who is the senior most employee based on job title?

select title,last_name,first_name from employee order by levels desc limit 1;                            

-- Which countries have the most Invoices?

SELECT COUNT(*) AS c, billing_country FROM invoice GROUP BY billing_country ORDER BY c DESC;

-- What are top 3 values of total invoice?

select total from invoice order by total desc limit 3 ;

/* Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.
 Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals*/

select billing_city,SUM(total) as InvoiceTotal from invoice group by billing_city order by invoicetotal desc limit 1;

/* Who is the best customer? The customer who has spent the most money will be declared the best customer.
 Write a query that returns the person who has spent the most money*/
SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spent
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;
							-- question set 2 Moderate
           
/*Write query to return the email, first name, last name, 
& Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A*/
SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name_ AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice_line.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name_ LIKE 'Rock'
ORDER BY email;
/*Let's invite the artists who have written the most rock music in our dataset. Write a query that 
returns the Artist name and total track count of the top 10 rock bands*/
SELECT artist.artist_id, artist.name_,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name_ LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;
/*Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. 
Order by the song length with the longest songs listed first*/
SELECT name_,milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC;

                   -- Question Set 3 – Advance

/*Find how much amount spent by each customer on artists? Write a query to
 return customer name, artist name and total spent*/
              
 WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name_ AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = il.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;
/*We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest
 amount of purchases. Write a query that returns each country along with the top Genre. */
 WITH RECURSIVE
	sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name_, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice_line.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;

