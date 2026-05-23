-- =========================================================
-- 🚀 ZEPTO 360° BUSINESS ANALYTICS PROJECT
-- 📌 SQL Data Cleaning, Transformation & Analytical Views
-- 🛠 Tools Used: MySQL | SQL | Power BI
-- =========================================================


-- =========================================================
-- 📂 DATABASE SETUP
-- =========================================================

CREATE DATABASE zepto;
USE zepto;


-- =========================================================
-- 📌 TABLE RENAME
-- =========================================================

RENAME TABLE zepto_dataset TO customers;


-- =========================================================
-- 📊 DATA PREVIEW
-- =========================================================

SELECT * FROM customers;
SELECT * FROM delivery;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM rating;
SELECT * FROM transcation;


-- =========================================================
-- 🧹 DATA CLEANING
-- =========================================================


-- ---------------------------------------------------------
-- 👤 Customers Table Cleaning
-- ---------------------------------------------------------

-- Identify NULL city values
SELECT 
    customer_id,
    customer_name,
    city,
    state
FROM customers
WHERE city IS NULL;

-- Replace NULL city values
UPDATE customers
SET city = 'Unknown'
WHERE city IS NULL;


-- ---------------------------------------------------------
-- ⚙ Disable Safe Update Mode
-- ---------------------------------------------------------

SET SQL_SAFE_UPDATES = 0;


-- ---------------------------------------------------------
-- 📦 Products Table Cleaning
-- ---------------------------------------------------------

-- Remove extra spaces from product names
UPDATE products
SET product_name = TRIM(product_name);

-- Remove invalid product pricing
DELETE FROM products
WHERE price <= 0;


-- ---------------------------------------------------------
-- 🛒 Orders Table Cleaning
-- ---------------------------------------------------------

-- Remove orders with missing customer IDs
DELETE FROM orders
WHERE customer_id IS NULL;


-- ---------------------------------------------------------
-- 🚚 Delivery Table Cleaning
-- ---------------------------------------------------------

-- Remove invalid delivery records
DELETE FROM delivery
WHERE delivery_time_mins <= 0
   OR distance_km <= 0;


-- ---------------------------------------------------------
-- ⭐ Ratings Table Cleaning
-- ---------------------------------------------------------

-- Remove unnecessary spaces from reviews
UPDATE rating
SET review = TRIM(review);


-- ---------------------------------------------------------
-- 💳 Transaction Table Cleaning
-- ---------------------------------------------------------

-- Remove invalid transaction records
DELETE FROM transcation
WHERE quantity <= 0
   OR amount <= 0;


-- =========================================================
-- 🔄 FEATURE ENGINEERING
-- =========================================================


-- ---------------------------------------------------------
-- 👥 Customer Age Group Segmentation
-- ---------------------------------------------------------

ALTER TABLE customers
ADD age_group VARCHAR(20);

UPDATE customers
SET age_group = CASE
    WHEN age < 20 THEN 'Teen'
    WHEN age BETWEEN 20 AND 35 THEN 'Young Adult'
    WHEN age BETWEEN 36 AND 50 THEN 'Adult'
    ELSE 'Senior'
END;


-- ---------------------------------------------------------
-- 💰 Order Value Classification
-- ---------------------------------------------------------

ALTER TABLE transcation
ADD order_value_category VARCHAR(20);

UPDATE transcation
SET order_value_category = CASE
    WHEN amount > 1000 THEN 'High'
    WHEN amount BETWEEN 500 AND 1000 THEN 'Medium'
    ELSE 'Low'
END;


-- =========================================================
-- 📊 ANALYTICAL VIEWS
-- =========================================================


-- ---------------------------------------------------------
-- 📦 Order Details View
-- ---------------------------------------------------------

CREATE VIEW vw_order_details AS
SELECT
    o.order_id,
    c.customer_name,
    c.city,
    c.state,
    c.age_group,
    o.order_date,
    o.order_status,
    p.product_name,
    p.category,
    t.quantity,
    t.amount,
    t.payment_mode,
    d.delivery_time_mins,
    d.delivery_status,
    d.distance_km,
    r.rating
FROM orders o
INNER JOIN customers c
    USING(customer_id)
INNER JOIN transcation t
    USING(order_id)
INNER JOIN products p
    USING(product_id)
LEFT JOIN delivery d
    USING(order_id)
LEFT JOIN rating r
    USING(order_id);


-- ---------------------------------------------------------
-- 👤 Customer Summary View
-- ---------------------------------------------------------

CREATE VIEW vw_customer_summary AS
SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    COUNT(o.order_id) AS total_orders,
    SUM(t.amount) AS total_spent,
    AVG(r.rating) AS avg_rating
FROM customers c
LEFT JOIN orders o
    USING(customer_id)
LEFT JOIN transcation t
    USING(order_id)
LEFT JOIN rating r
    USING(order_id)
GROUP BY
    c.customer_id,
    c.customer_name,
    c.city;


-- ---------------------------------------------------------
-- 📈 Product Performance View
-- ---------------------------------------------------------

CREATE VIEW vw_product_performance AS
SELECT
    p.product_name,
    p.category,
    SUM(t.quantity) AS total_quantity_sold,
    SUM(t.amount) AS total_revenue,
    AVG(r.rating) AS avg_rating
FROM products p
INNER JOIN transcation t
    USING(product_id)
LEFT JOIN rating r
    USING(order_id)
GROUP BY
    p.product_name,
    p.category;


-- ---------------------------------------------------------
-- 🚚 Delivery Performance View
-- ---------------------------------------------------------

CREATE VIEW vw_delivery_performance AS
SELECT
    delivery_status,
    AVG(delivery_time_mins) AS avg_delivery_time,
    AVG(distance_km) AS avg_distance
FROM delivery
GROUP BY delivery_status;


-- ---------------------------------------------------------
-- 📅 Daily Sales View
-- ---------------------------------------------------------

CREATE VIEW vw_daily_sales AS
SELECT
    o.order_date,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(t.amount) AS total_sales
FROM orders o
INNER JOIN transcation t
    USING(order_id)
GROUP BY o.order_date;


-- =========================================================
-- 🚀 DELIVERY SPEED ANALYSIS
-- =========================================================

SELECT *,
    CASE
        WHEN delivery_time_mins < 20 THEN 'Fast'
        WHEN delivery_time_mins BETWEEN 20 AND 40 THEN 'Medium'
        ELSE 'Slow'
    END AS delivery_speed
FROM delivery;