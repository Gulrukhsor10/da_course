with sales_per_month as (
    select 
        customer_id
        , full_name
        , extract(year from sale_date) as year
        , extract(month from sale_date) as monthkey
        , sum(amount) as total
    from store.sales
    group by customer_id, full_name, year, monthkey
),
sales_totals as (
    select 
        year
        , monthkey
        , sum(total) as total_sales_month
    from sales_per_month
    group by year, monthkey
)
select 
    s.customer_id
    , s.full_name
    , s.year
    , s.monthkey
    , s.total,
    (s.total / t.total_sales_month) * 100 as percentage_of_total
    , sum(s.total) over (partition by s.customer_id, s.year order by s.year, s.monthkey) as cumulative_total
    , avg(s.total) over (partition by s.customer_id order by s.year, s.monthkey rows between 2 precending and current row) as moving_avg_3_months
    , s.total - coalesce(lag(s.total) over (partition by s.customer_id order by s.year, s.monthkey), 0) as month_diff
from sales_per_month s
join sales_totals t
    on s.year = t.year and s.monthkey = t.monthkey
order by s.customer_id, s.year, s.monthkey
;

with sales_per_album as (
    select 
        a.album_name
        , a.artist_name
        , extract(year from s.sale_date) as year
        , sum(s.tracks_sold) as total_tracks_sold
    from sales s
    join albums a on s.album_id = a.album_id
    group by a.album_name, a.artist_name, year
)
, ranked_sales as (
    select 
        album_name
        , artist_name
        , year
        , total_tracks_sold
        , row_number() over (partition by year order by total_tracks_sold desc) as rank
    from sales_per_album
)
select 
    year
    , album_name
    , artist_name
    , total_tracks_sold
from ranked_sales
where rank <= 3
order by year
, rank
;

with sales_per_album as (
    select 
        a.album_name
        , a.artist_name
        , extract (year from s.sale_date) as year
        , sum(s.tracks_sold) as total_tracks_sold
    from sales s
    join albums a on s.album_id = a.album_id
    group by a.album_name, a.artist_name, year
)
, ranked_sales as (
    select 
        album_name
        , artist_name
        , year
        , total_tracks_sold
        , row_number() over (partition by year ORDER BY total_tracks_sold desc) as rank
    from sales_per_album
)
select 
    year
    , album_name
    , artist_name
    , total_tracks_sold
from ranked_sales
where rank <= 3
order BY year, rank
;

with employee_clients as (
    select 
        e.employee_id
        , e.full_name
        , count(c.customer_id) as client_count
    from employees e
    lefy join customers c on e.employee_id = c.employee_id
    group by e.employee_id, e.full_name
)
, total_clients as (
    select count(distinct customer_id) as total_client_count
    from customers
)
select 
    ec.employee_id
    , ec.full_name
    , ec.client_count
    , (ec.client_count * 100.0 / tc.total_client_count) AS client_percentage
from employee_clients ec
join total_clients tc on 1=1
order by ec.client_count desc
;

with customer_purchases as (
    select 
        customer_id,
        min(sale_date) as first_purchase_date,
        max(sale_date) as last_purchase_date
    from store.sales
    group by customer_id
)
select 
    customer_id
    , first_purchase_date
    , last_purchase_date
    , extract(year from age(last_purchase_date, first_purchase_date)) as years_between
from customer_purchases
;
