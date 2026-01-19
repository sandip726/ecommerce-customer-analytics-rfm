-- DATABASE SCHEMA (TABLE CREATION)

-- Customers Table
CREATE TABLE customers (
    customer_id VARCHAR PRIMARY KEY,
    customer_unique_id VARCHAR,
    customer_zip_code_prefix INT,
    customer_city VARCHAR,
    customer_state VARCHAR
);

-- Orders Table
CREATE TABLE orders (
    order_id VARCHAR PRIMARY KEY,
    customer_id VARCHAR,
    order_status VARCHAR,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- Order Items Table
CREATE TABLE order_items (
    order_id VARCHAR,
    order_item_id INT,
    product_id VARCHAR,
    seller_id VARCHAR,
    shipping_limit_date TIMESTAMP,
    price DECIMAL,
    freight_value DECIMAL
);

-- Products Table
CREATE TABLE product (
    product_id VARCHAR PRIMARY KEY,
    product_category_name VARCHAR,
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- Order Payments Table
CREATE TABLE order_payments (
    order_id VARCHAR,
    payment_sequential INT,
    payment_type VARCHAR,
    payment_installments INT,
    payment_value DECIMAL
);

-- Order Reviews Table
CREATE TABLE order_reviews (
    review_id VARCHAR,
    order_id VARCHAR,
    review_score INT,
    review_comment_title VARCHAR,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

-- Sellers Table
CREATE TABLE sellers (
    seller_id VARCHAR PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR,
    seller_state VARCHAR
);

-- Geolocation Table
CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat DECIMAL,
    geolocation_lng DECIMAL,
    geolocation_city VARCHAR,
    geolocation_state VARCHAR
);

-- Product Category Translation Table
CREATE TABLE product_category_name_translation (
    product_category_name VARCHAR,
    product_category_name_english VARCHAR
);
