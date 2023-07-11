-- Q1: Who is the senior most employee based on the job title?

select * from employee
order by levels desc
limit 1;


-- Q2: Which countries have the most invoices?

select billing_country, count(*) as billing_number from invoice
group by billing_country 
order by billing_number desc


-- Q3: What are top 3 values of total invoice?

select total from invoice
order by total desc
limit 3;


-- Q4: Which city has the best customer? WE would like to throw a promotional Music Festival
-- in the city we made the most money. Write a query that returns one city that has the highest 
-- sum of the invoice totals. Return both the city name and sum of all invoice totals.

select sum(total)as invoice_total, billing_city 
from invoice
group by billing_city
order by invoice_total desc


-- Q5: Who is the best customer? The customer who spent the most money will be declared the best
-- customer. Write a query that returns the person who has spent the most money.

select customer.customer_id,first_name,last_name, sum(invoice.total)as total_spent from customer
inner join invoice
on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total_spent desc
limit 1;


-- Q6: Write query to return the email, first name, last name and genre of all Rock Music listners.
-- Return your list ordered alphabetically by emial starting with A.

select distinct email,first_name, last_name
from customer
inner join invoice on customer.customer_id = invoice.customer_id
inner join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in (
	select track_id from track
	inner join genre on track.genre_id = genre.genre_id
	where genre.name = 'Rock'
)
order by email asc;


-- Q7: Let's invite the artist who have written the most rock music in our dataset. Write a
-- query that returns the Artist name and total track count of the top 10 rock band.

select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track
inner join album on album.album_id = track.album_id
inner join artist on artist.artist_id = album.artist_id
inner join genre on genre.genre_id = track.genre_id
where genre.name = 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;



-- Q8: Return all the track names that have a song length longer htan the average song length. 
-- Return the name and milliseconds for each track. Order by hte song length with the longest 
-- song listed first.

select name, milliseconds
from track
where milliseconds > (
	select avg(milliseconds) as avg_track_length
	from track)
	order by milliseconds desc;


-- Q9: Find how much amount spent by each customer on artist? Write query to return customer 
-- name, artist name and total spent.

with best_selling_artist as (
	select artist.artist_id as artist_id, artist.name as artist_name, 
	sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
	from invoice_line
	inner join track on track.track_id = invoice_line.track_id
	inner join album on album.album_id = track.album_id
	inner join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price * il.quantity) as amount_spent
from invoice i
inner join customer c on c.customer_id = i.customer_id
inner join invoice_line il on il.invoice_id = i.invoice_id
inner join track t on t.track_id =il.track_id
inner join album alb on alb.album_id = t.album_id
inner join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;



-- Q10: We want to find out the most popular music genre for each country. We determine the 
-- most popular genre as the genre with the highest amount of purchases. Write a query that
-- returns each country along with the top genre. For countries where the maximum number of
-- purchases is shared return all genres.

with popular_genre as
(
	select count(invoice_line.quantity)as purchases, customer.country, genre.name, genre.genre_id,
	row_number() over(partition by customer.country order by count(invoice_line.quantity) desc)
	as rowNo from invoice_line
	inner join invoice on invoice.invoice_id = invoice_line.invoice_id
	inner join customer on customer.customer_id = invoice.customer_id
	inner join track on track.track_id = invoice_line.track_id
	inner join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select  * from popular_genre 
where rowNo <=1;


-- Q11: Write a query that determine the customer that has spent the most on music for each
-- country. Write a query that returns the country along with the top customer and how much 
-- they spent. For countries where the top amount spent is shared , provide all customers who
-- spent this amount.

with customer_with_country as (
	select customer.customer_id, first_name, last_name, billing_country, sum(total)as total_spending,
	row_number() over(partition by billing_country order by sum(total)desc) as rowNo
	from invoice
	inner join customer on customer.customer_id = invoice.customer_id
	group by 1,2,3,4
order by 4 asc, 5 desc
)
select * from customer_with_country
where rowNo <=1;