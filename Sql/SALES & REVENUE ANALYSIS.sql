
 --SALES & REVENUE ANALYSIS--
 
-- Monthly Revenue Trend
SELECT 
    DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
    SUM(p.payment_value) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 1;

-- CUSTOMER ANALYSIS--

-- Top 10 Customers by Spend
SELECT 
    c.customer_unique_id,
    SUM(p.payment_value) AS total_spent,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_payments p ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC
LIMIT 10;

-- Top 10 Cities by Revenue
SELECT
    c.customer_city,
    SUM(p.payment_value) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_payments p ON o.order_id = p.order_id
GROUP BY c.customer_city
ORDER BY total_revenue DESC
LIMIT 10;

---PRODUCT & CATEGORY PERFORMANCE---
-- Top 5 Categories by Units Sold
SELECT 
    t.product_category_name_english AS category,
    COUNT(oi.product_id) AS units_sold,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
JOIN product p ON oi.product_id = p.product_id
JOIN product_category_name_translation t 
    ON p.product_category_name = t.product_category_name
GROUP BY 1
ORDER BY units_sold DESC
LIMIT 5;

-- Missing Category Translations
SELECT DISTINCT 
    p.product_category_name AS portuguese_name
FROM product p
LEFT JOIN product_category_name_translation t 
    ON p.product_category_name = t.product_category_name
WHERE t.product_category_name_english IS NULL;

--LOGISTICS & DELIVERY PERFORMANCE
-- Delivery Delay by State
SELECT 
    c.customer_state,
    ROUND(
        AVG(EXTRACT(DAY FROM 
        (o.order_delivered_customer_date - o.order_estimated_delivery_date)
        )), 1
    ) AS avg_delay_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY 1
ORDER BY avg_delay_days DESC;


---CUSTOMER EXPERIENCE
 -- Review Score vs Delivery Status
SELECT 
    CASE 
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
        THEN 'On-Time or Early'
        ELSE 'Late'
    END AS delivery_status,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    COUNT(*) AS total_orders
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1;

--- CUSTOMER SEGMENTATION (RFM PREVIEW)
 
SELECT 
    c.customer_unique_id,
    MAX(o.order_purchase_timestamp) AS last_purchase,
    SUM(p.payment_value) AS total_spent,
    COUNT(o.order_id) AS total_orders,
    EXTRACT(DAY FROM 
        ('2018-09-03'::timestamp - MAX(o.order_purchase_timestamp))
    ) AS days_since_last_purchase
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_payments p ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
HAVING SUM(p.payment_value) > 500
   AND EXTRACT(DAY FROM 
        ('2018-09-03'::timestamp - MAX(o.order_purchase_timestamp))
   ) > 180;


--- SELLER PERFORMANCE

SELECT 
    s.seller_id,
    COUNT(oi.product_id) AS items_sold
FROM sellers s
JOIN order_items oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_id
ORDER BY items_sold DESC;

