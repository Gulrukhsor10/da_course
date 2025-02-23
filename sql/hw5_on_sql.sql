with employee_customers as (
    select 
        e.employee_id as id
        , e.first_name || ' ' || e.last_name as full_name
        , count (c.customer_id) AS customer_count
    from employee e
    left join customer c on e.employee_id = c.support_rep_id
    group by e.employee_id, full_name
),
total_customers as (
    select count (*) as total from customer
)
select 
    ec.id
    , ec.full_name
    , ec.customer_count
    , round((ec.customer_count * 100.0 / tc.total), 2) as percentage_of_total
from employee_customers ec, total_customers tc
;

select distinct a.title as album_name, ar.name as artist_name
from album a
join artist ar on a.artist_id = ar.artist_id
where a.album_id not in (
    select distinct t.album_id
    from track t
    join invoice_line il on t.track_id = il.track_id
)
;

select
	e.employee_id, e.first_name || ' ' || e.last_name as full_name
from employee e
where e.employee_id not in (select distinct reports_to from employee where reports_to is not null)
;

select
	distinct t.track_id, t.name as track_name
from track t
join invoice_line il on t.track_id = il.track_id
join invoice i on il.invoice_id = i.invoice_id
where i.billing_country = 'USA'
intersect 
select 
	distinct t.track_id, t.name as track_name
from track t
join invoice_line il on t.track_id = il.track_id
join invoice i on il.invoice_id = i.invoice_id
where i.billing_country = 'Canada'
;

select 
distinct t.track_id, t.name as track_name
from track t
join invoice_line il on t.track_id = il.track_id
join invoice i on il.invoice_id = i.invoice_id
where i.billing_country = 'Canada'
except
select 
distinct t.track_id, t.name as track_name
from track t
join invoice_line il on t.track_id = il.track_id
join invoice i on il.invoice_id = i.invoice_id
where i.billing_country = 'USA'
;

select 
distinct t.track_id, t.name as track_name
from track t
join invoice_line il on t.track_id = il.track_id
join invoice i on il.invoice_id = i.invoice_id
where i.billing_country = 'Canada'
except
select distinct t.track_id, t.name as track_name
from track t
join invoice_line il on t.track_id = il.track_id
join invoice i on il.invoice_id = i.invoice_id
where i.billing_country = 'USA'
;