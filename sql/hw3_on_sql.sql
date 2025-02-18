drop schema if exists store cascade
;

create schema store
;

set search_path to store
;

drop table if exists customers
;

create table customers (
    customer_id serial primary key
    , customer_name varchar(50) not null
    , email varchar(260),
    address text
)
;

select * 
from information_schema.tables 
where table_name = 'customer'
;

select table_schema
, table_name
from information_schema.tables
where table_name = 'customer'
;

set search_path to store
;

select table_name
from information_schema.tables
where table_schema = 'store'
;

insert into store.customers (customer_name, email, address)
select
    first_name || ' ' || last_name as customer_name
    , email
    , country || ' ' || state || ' ' || city || ' ' || address as address
from public.customer
;

create table products (
    product_id serial primary key
    , product_name varchar(100)
    , price decimal(10, 2) not null
)
;

insert into products (product_name, price)
values
    ('Ноутбук Lenovo Thinkpad', 12000)
    , ('Мышь для компьютера, беспроводная', 90)
    , ('Подставка для ноутбука', 300)
    , ('Шнур электрический для ПК', 160)
;

create table sales (
    sale_id serial primary key
    , sale_timestamp timestamp default current_timestamp
    , customer_id int references customers(customer_id) on delete cascade
    , product_id int references products(product_id) on delete cascade
    , quantity int default 1
)
;


insert into sales (customer_id, product_id, quantity)
values
    (3, 4, 1),
    (56, 2, 3),
    (11, 2, 1),
    (31, 2, 1),
    (24, 2, 3),
    (27, 2, 1),
    (37, 3, 2),
    (35, 1, 2),
    (21, 1, 2),
    (31, 2, 2),
    (15, 1, 1),
    (29, 2, 1),
    (12, 2, 1)
;

alter table sales
add column discount decimal(3, 2)
;

update sales
set discount = 0.2
where product_id = 1
;

alter table sales
add column discount decimal(3, 2)
;

select column_name
from information_schema.columns
where table_schema = 'store' and table_name = 'sales'
;

update sales
set discount = 0.2
where product_id = 1
;

create view v_usa_customers as
select * 
from customers
where address like '%USA%'
;




