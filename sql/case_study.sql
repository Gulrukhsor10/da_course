-- Создание схемы
CREATE SCHEMA IF NOT EXISTS adv_works;

-- Блок 1. Создание схемы и таблиц
-- Создание таблицы Customers
CREATE TABLE adv_works.customers (
    customer_key INT PRIMARY KEY,
    geography_key INT,
    name TEXT,
    birth_date DATE,
    marital_status CHAR(1),
    gender CHAR(1),
    yearly_income NUMERIC,
    number_children_at_home INT,
    occupation TEXT,
    house_owner_flag INT,
    number_cars_owned INT,
    address_line1 TEXT,
    address_line2 TEXT,
    phone TEXT,
    date_first_purchase DATE
);

-- Создание таблицы Products
CREATE TABLE adv_works.products (
    product_key INT PRIMARY KEY,
    product_subcategory_key INT,
    product_name TEXT,
    standard_cost NUMERIC,
    color TEXT,
    safety_stock_level INT,
    list_price NUMERIC,
    size TEXT,
    size_range TEXT,
    weight NUMERIC,
    days_to_manufacture INT,
    product_line TEXT,
    dealer_price NUMERIC,
    class TEXT,
    model_name TEXT,
    description TEXT,
    start_date DATE,
    end_date DATE,
    status TEXT
);

-- Создание таблицы Territory
CREATE TABLE adv_works.territory (
    territory_key INT PRIMARY KEY,
    region TEXT,
    country TEXT,
    "group" TEXT
);

-- Создание таблицы Sales
CREATE TABLE adv_works.sales (
    product_key INT,
    order_date DATE,
    order_date_key INT,
    customer_key INT,
    sales_territory_key INT,
    sales_order_number TEXT,
    sales_order_line_number INT,
    order_quantity INT,
    unit_price NUMERIC,
    extended_amount NUMERIC,
    unit_price_discount_pct NUMERIC,
    discount_amount NUMERIC,
    product_standard_cost NUMERIC,
    total_product_cost NUMERIC,
    sales_amount NUMERIC,
    tax_amt NUMERIC,
    freight NUMERIC,
    region_month_id TEXT,
    FOREIGN KEY (product_key) REFERENCES adv_works.products(product_key),
    FOREIGN KEY (customer_key) REFERENCES adv_works.customers(customer_key),
    FOREIGN KEY (sales_territory_key) REFERENCES adv_works.territory(territory_key)
);

-- Создание таблицы ProductCategory
CREATE TABLE adv_works.product_category (
    product_category_key INT PRIMARY KEY,
    product_category_alternate_key INT,
    english_product_category_name TEXT,
    spanish_product_category_name TEXT,
    french_product_category_name TEXT
);

-- Создание таблицы ProductSubcategory
CREATE TABLE adv_works.product_subcategory (
    product_subcategory_key INT PRIMARY KEY,
    product_subcategory_alternate_key INT,
    english_product_subcategory_name TEXT,
    spanish_product_subcategory_name TEXT,
    french_product_subcategory_name TEXT,
    product_category_key INT,
    FOREIGN KEY (product_category_key) REFERENCES adv_works.product_category(product_category_key)
);

-- Блок 2. Аналитические задачи
-- Секция 1. Анализ клиентов
-- Сегментация по доходу
SELECT 
    c."Occupation" AS occupation,
    COUNT(*) AS number_of_customers,
    ROUND(AVG(c."YearlyIncome"), 2) AS avg_income
FROM adv_works."Customers" c
GROUP BY c."Occupation"
ORDER BY avg_income DESC;

-- Семейный профиль
WITH total_customers AS (
    SELECT COUNT(*) AS total FROM adv_works."Customers"
)
SELECT 
    c."NumberChildrenAtHome" > 0 AS has_children,
    ROUND(COUNT(*) * 100.0 / t.total, 2) AS pct_of_customer_base
FROM adv_works."Customers" c
JOIN total_customers t ON true
GROUP BY c."NumberChildrenAtHome" > 0;

-- Высокодоходные клиенты
SELECT 
    s."CustomerKey" AS customer_key,
    c."FirstName" || ' ' || c."LastName" AS customer_name,
    SUM(s."SalesAmount") AS total_purchase
FROM adv_works."Sales" s
JOIN adv_works."Customers" c ON s."CustomerKey" = c."CustomerKey"
GROUP BY s."CustomerKey", c."FirstName", c."LastName"
ORDER BY total_purchase DESC
LIMIT 10;

-- Влияние семейного положения
SELECT 
    EXTRACT(YEAR FROM s."OrderDate") AS year,
    c."MaritalStatus" AS marital_status,
    ROUND(AVG(s."SalesAmount"), 2) AS avg_sales_amount
FROM adv_works."Sales" s
JOIN adv_works."Customers" c ON s."CustomerKey" = c."CustomerKey"
GROUP BY EXTRACT(YEAR FROM s."OrderDate"), c."MaritalStatus"
ORDER BY year, marital_status;

-- Секция 2. Анализ продаж
-- Ежемесячные продажи (2003, 2004)
SELECT 
    EXTRACT(YEAR FROM s.SalesDate) AS year,
    EXTRACT(MONTH FROM s.SalesDate) AS monthkey,
    TO_CHAR(s.SalesDate, 'Month') AS month_name,
    COUNT(s.SalesOrderID) AS sales_count,
    SUM(soh.TotalDue) AS sales_amount
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.SalesOrderDetail s ON soh.SalesOrderID = s.SalesOrderID
WHERE 
    EXTRACT(YEAR FROM s.SalesDate) IN (2003, 2004)
GROUP BY 
    EXTRACT(YEAR FROM s.SalesDate), 
    EXTRACT(MONTH FROM s.SalesDate),
    TO_CHAR(s.SalesDate, 'Month')
ORDER BY 
    year, monthkey;

-- Продажи по регионам
SELECT 
    a.Name AS region,
    COUNT(s.SalesOrderID) AS sales_count,
    SUM(soh.TotalDue) AS sales_amount
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.SalesOrderDetail s ON soh.SalesOrderID = s.SalesOrderID
JOIN 
    Person.CountryRegion a ON soh.BillToAddressCountryRegionCode = a.CountryRegionCode
GROUP BY 
    a.Name
ORDER BY 
    sales_amount DESC;

-- Секция 3. Анализ продуктов
-- Доля продаж
WITH TotalSales AS (
    SELECT 
        SUM(soh.TotalDue) AS total_sales
    FROM 
        Sales.SalesOrderHeader soh
    JOIN 
        Sales.SalesOrderDetail s ON soh.SalesOrderID = s.SalesOrderID
),
CategorySales AS (
    SELECT 
        EXTRACT(YEAR FROM soh.OrderDate) AS year,
        p.ProductCategoryID AS product_category_key,
        pc.Name AS english_product_category_name,
        p.ProductID AS product_key,
        SUM(soh.TotalDue) AS sales_amount
    FROM 
        Sales.SalesOrderHeader soh
    JOIN 
        Sales.SalesOrderDetail s ON soh.SalesOrderID = s.SalesOrderID
    JOIN 
        Production.Product p ON s.ProductID = p.ProductID
    JOIN 
        Production.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
    GROUP BY 
        EXTRACT(YEAR FROM soh.OrderDate), 
        p.ProductCategoryID, 
        pc.Name, 
        p.ProductID
)
SELECT 
    cs.year,
    cs.product_key,
    cs.product_category_key,
    cs.english_product_category_name,
    cs.sales_amount,
    (cs.sales_amount / ts.total_sales) * 100 AS pct_of_total_sales
FROM 
    CategorySales cs
JOIN 
    TotalSales ts
ORDER BY 
    cs.year, cs.product_category_key, cs.product_key;

-- Самые продаваемые продукты
SELECT 
    p.ProductID AS product_key,
    p.Name AS product_name,
    pc.Name AS english_product_category_name,
    SUM(soh.TotalDue) AS sales_amount
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.SalesOrderDetail s ON soh.SalesOrderID = s.SalesOrderID
JOIN 
    Production.Product p ON s.ProductID = p.ProductID
JOIN 
    Production.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
GROUP BY 
    p.ProductID, p.Name, pc.Name
ORDER BY 
    sales_amount DESC
LIMIT 5;

-- Маржа от продаж
SELECT 
    EXTRACT(YEAR FROM soh.OrderDate) AS year,
    EXTRACT(MONTH FROM soh.OrderDate) AS monthkey,
    TO_CHAR(soh.OrderDate, 'Month') AS month_name,
    p.ProductID AS product_key,
    p.Name AS product_name,
    SUM(soh.TotalDue) AS sales_amount,
    SUM(sod.LineTotal) AS total_product_cost, 
    SUM(soh.TaxAmt) AS tax_amt,
    SUM(soh.Freight) AS freight,
    (SUM(soh.TotalDue) - SUM(sod.LineTotal) - SUM(soh.TaxAmt) - SUM(soh.Freight)) AS margin,
    ((SUM(soh.TotalDue) - SUM(sod.LineTotal) - SUM(soh.TaxAmt) - SUM(soh.Freight)) / SUM(soh.TotalDue)) * 100 AS margin_pct
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    Production.Product p ON sod.ProductID = p.ProductID
GROUP BY 
    EXTRACT(YEAR FROM soh.OrderDate),
    EXTRACT(MONTH FROM soh.OrderDate),
    TO_CHAR(soh.OrderDate, 'Month'),
    p.ProductID, 
    p.Name
ORDER BY 
    year, monthkey, margin DESC;

-- Секция 4. Анализ трендов
-- Квартальный рост
WITH CategorySales AS (
    SELECT 
        EXTRACT(YEAR FROM soh.OrderDate) AS year,
        EXTRACT(QUARTER FROM soh.OrderDate) AS quarter_id,
        p.ProductCategoryID AS product_category_key,
        pc.Name AS english_product_category_name,
        SUM(soh.TotalDue) AS quarter_sales_amount
    FROM 
        Sales.SalesOrderHeader soh
    JOIN 
        Sales.SalesOrderDetail s ON soh.SalesOrderID = s.SalesOrderID
    JOIN 
        Production.Product p ON s.ProductID = p.ProductID
    JOIN 
        Production.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
    GROUP BY 
        EXTRACT(YEAR FROM soh.OrderDate), 
        EXTRACT(QUARTER FROM soh.OrderDate),
        p.ProductCategoryID, 
        pc.Name
),
TopCategories AS (
    SELECT 
        product_category_key,
        SUM(quarter_sales_amount) AS total_sales
    FROM 
        CategorySales
    GROUP BY 
        product_category_key
    ORDER BY 
        total_sales DESC
    LIMIT 2
)
SELECT 
    cs.year,
    cs.quarter_id,
    cs.product_category_key,
    cs.english_product_category_name,
    cs.quarter_sales_amount,
    ((cs.quarter_sales_amount - LAG(cs.quarter_sales_amount) OVER (PARTITION BY cs.product_category_key ORDER BY cs.year, cs.quarter_id)) / 
     LAG(cs.quarter_sales_amount) OVER (PARTITION BY cs.product_category_key ORDER BY cs.year, cs.quarter_id)) * 100 AS quarter_over_quarter_growth_pct
FROM 
    CategorySales cs
JOIN 
    TopCategories tc ON cs.product_category_key = tc.product_category_key
ORDER BY 
    cs.product_category_key, cs.year, cs.quarter_id;

-- Сравнение будних и выходных (суббота, воскресенье) дней
SELECT 
    EXTRACT(YEAR FROM soh.OrderDate) AS year,
    TO_CHAR(soh.OrderDate, 'Day') AS day_name,
    CASE 
        WHEN EXTRACT(DOW FROM soh.OrderDate) IN (0, 6) THEN 1  -- 0 = Sunday, 6 = Saturday
        ELSE 0 
    END AS is_weekend,
    SUM(soh.TotalDue) AS sales_amount
FROM 
    Sales.SalesOrderHeader soh
GROUP BY 
    EXTRACT(YEAR FROM soh.OrderDate),
    TO_CHAR(soh.OrderDate, 'Day'),
    EXTRACT(DOW FROM soh.OrderDate)
ORDER BY 
    year, is_weekend DESC, sales_amount DESC;


