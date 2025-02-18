select 
    min(invoice_date) as first_purchase_date
    , max(invoice_date) as last_purchase_date
from invoice
;

select avg(total) as avg_receipt
from invoice
where billing_country = 'USA'
;

select city
from customer
group by city
having count(customer_id) > 1
;


select phone
from customer
where phone not like '%(%' and phone not like '%)%'
;

select initcap('lorem') || ' ' || lower('ipsum') as formatted_text
;

select name
from track
where lower(name) like '%run%'
;

select *
from customer
where email like '%@gmail.com';

select name
from track
order by length(name) desc
limit 1
;

select 
    extract(month from invoice_date) as month_id, 
    sum(total) as sales_sum
from invoice
where extract (year from invoice_date) = 2021
group by month_id
order by month_id
;

select 
    extract(month from invoice_date) as month_id, 
    to_char(invoice_date, 'Month') as month_name, 
    sum(total) as sales_sum
from invoice
where extract(year from invoice_date) = 2021
group by month_id, month_name
order by month_id
;

 select 
    first_name || ' ' || last_name as full_name, 
    birth_date,
    date_part('year', age(now(), birth_date)) as age_now
from employee
order by age_now desc
limit 3
;

select 
    avg(date_part('year', age(now() + interval '3 years 4 months', birth_date))) as avg_age_future
from employee
;

select 
    extract(year from invoice_date) as year, 
    billing_country, 
    sum(total) as sales_sum
from invoice
group by year, billing_country
having sum(total) > 20
order by year asc, sales_sum desc
;