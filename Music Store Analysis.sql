use Music_Database;

select * from album;
select * from album2;
select * from artist;
select * from customer;
select * from employee;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media_type;
select * from playlist;
select * from playlist_track;
select * from track;

--1. Who is the senior most employee based on job title?
select top 1 * from employee
order by levels desc;

--2. Which countries have the most Invoices?
select count(*) as invoice_count,billing_country
from invoice
group by billing_country
order by invoice_count desc;

--3. What are top 3 values of total invoice?
select top 3 total from invoice
order by total desc;

/*4. Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. Write a query that returns one city that
has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals*/
select SUM(total) as invoice_total,billing_city
from invoice
group by billing_city
order  by invoice_total desc;

/*5.Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent the
most money*/
select top 1 c.customer_id,c.first_name,c.last_name,SUM(i.total) as Total
from customer as c
join invoice as i
on c.customer_id = i.customer_id
group by c.customer_id,c.first_name, c.last_name
order by Total desc;

/*6.Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A*/
select distinct email,first_name,last_name
from customer as c
join invoice as i on c.customer_id= i.customer_id
join invoice_line as il on i.invoice_id=il.invoice_id
where track_id in(
	select track_id from track
	join genre on track.genre_id=genre.genre_id
	where genre.name like 'Rock'
	)
order by email;

/*7. Let's invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands*/
SELECT top 10 artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id,artist.name
ORDER BY number_of_songs DESC;

/*8. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
SELECT t.name, t.milliseconds
FROM track AS t
WHERE t.milliseconds > (
    SELECT AVG(t2.milliseconds) AS avg_track_length
    FROM track AS t2
)
ORDER BY t.milliseconds DESC;


/*9. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
WITH best_selling_artist AS (
    SELECT TOP 1 
        artist.artist_id AS artist_id, 
        artist.name AS artist_name, 
        SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM invoice_line
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN album ON album.album_id = track.album_id
    JOIN artist ON artist.artist_id = album.artist_id
    GROUP BY artist.artist_id, artist.name
    ORDER BY total_sales DESC
)
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    bsa.artist_name, 
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;

/*10.we want find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */
WITH popular_genre AS 
(
    SELECT 
        COUNT(invoice_line.quantity) AS purchases, 
        customer.country, 
        genre.name, 
        genre.genre_id, 
        ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY customer.country, genre.name, genre.genre_id
)
SELECT *
FROM popular_genre
WHERE RowNo = 1;


/*11 Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
WITH Customer_with_country AS (
    SELECT 
        customer.customer_id, 
        customer.first_name, 
        customer.last_name, 
        invoice.billing_country, 
        SUM(invoice.total) AS total_spending,
        ROW_NUMBER() OVER (PARTITION BY invoice.billing_country ORDER BY SUM(invoice.total) DESC) AS RowNo
    FROM invoice
    JOIN customer ON customer.customer_id = invoice.customer_id
    GROUP BY customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country
)
SELECT *
FROM Customer_with_country
WHERE RowNo = 1;








































