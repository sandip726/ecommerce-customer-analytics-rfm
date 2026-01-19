-- DATA VALIDATION
  

SELECT
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM orders) AS total_orders,
    (SELECT COUNT(*) FROM order_items) AS total_order_items,
    (SELECT COUNT(*) FROM product) AS total_products,
    (SELECT COUNT(*) FROM order_payments) AS total_payments;
