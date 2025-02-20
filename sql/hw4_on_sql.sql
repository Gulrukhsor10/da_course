select e.employee_id
	, e.first_name || ' ' || e.last_name as full_name
	, e.title
	, e.reports_to
	, 
     (select m.first_name || ' ' || m.last_name || ', ' || m.title 
        from employee m 
        where m.employee_id = e.reports_to) as manager_info
from employee e
;

with avg_invoice as (
    select avg(total) as avg_total 
    from invoice 
    where extract(year from invoice_date) = 2023
)
select invoice_id
	, invoice_date
	, extract (year from invoice_date) * 100 + extract (month from invoice_date) as monthkey
	, customer_id
	, total
from invoice
where total > (select avg_total from avg_invoice)
;

with avg_invoice as (
    select avg(total) as avg_total 
    from invoice 
    where extract (year from invoice_date) = 2023
)
select i.invoice_id
	, i.invoice_date
	, extract(year from i.invoice_date) * 100 + extract(month from i.invoice_date) as monthkey
	, i.customer_id
	, i.total
	, (select c.email 
        from customer c 
        where c.customer_id = i.customer_id) as email
from invoice i
where i.total > (select avg_total from avg_invoice)
;

with avg_invoice as (
    select avg(total) as avg_total 
    from invoice
    where extract(year from invoice_date) = 2023
)
select i.invoice_id
	, i.invoice_date
	, extract(year from i.invoice_date) * 100 + extract(month from i.invoice_date) as monthkey
	, i.customer_id
	, i.total
	, (select c.email from customer c where c.customer_id = i.customer_id) as email
from invoice i
where i.total > (select avg_total from avg_invoice)
and (select c.email from customer c where c.customer_id = i.customer_id) not like '%@gmail.com'
;

with total_revenue as (
    select sum(total) as total_2024 
    from invoice 
    where extract(year from invoice_date) = 2024
)
select i.invoice_id
	, i.total
	, round((i.total / (select total_2024 from total_revenue)) * 100, 2) as revenue_percentage
from invoice i
where extract (year from i.invoice_date) = 2024
;

with total_revenue as (
    select sum(total) as total_2024 
    from invoice 
    where extract(year from invoice_date) = 2024
)
select i.customer_id
	, sum(i.total) as customer_revenue
	, round((sum(i.total) / (select total_2024 from total_revenue)) * 100, 2) as revenue_percentage
from invoice i
where extract(year from i.invoice_date) = 2024
group by i.customer_id
;




