-- =========================================
-- MINI PROJECT: ONLINE FOOD ORDER SYSTEM
-- =========================================

-- 1. CREATE DATABASE
CREATE DATABASE food_order_system;
USE food_order_system;

-- =========================================
-- 2. TABLES
-- =========================================

-- Customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15)
);

-- Restaurants
CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    location VARCHAR(100)
);

-- Menu
CREATE TABLE menu (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_id INT,
    item_name VARCHAR(100),
    price DECIMAL(10,2),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

-- Orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order Items
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    item_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (item_id) REFERENCES menu(item_id)
);

-- Payments
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    amount DECIMAL(10,2),
    payment_status VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- =========================================
-- 3. SAMPLE DATA
-- =========================================

INSERT INTO customers (name, email, phone) VALUES
('Rishi', 'rishi@gmail.com', '9999999999'),
('Amit', 'amit@gmail.com', '8888888888');

INSERT INTO restaurants (name, location) VALUES
('Veg Delight', 'Delhi'),
('Green Bowl', 'Mumbai');

INSERT INTO menu (restaurant_id, item_name, price) VALUES
(1, 'Paneer Butter Masala', 250),
(1, 'Veg Biryani', 180),
(2, 'Salad Bowl', 150);

-- =========================================
-- 4. INSERT ORDERS
-- =========================================

INSERT INTO orders (customer_id, status) VALUES
(1, 'Placed'),
(2, 'Placed');

INSERT INTO order_items (order_id, item_id, quantity) VALUES
(1, 1, 2),
(1, 2, 1),
(2, 3, 3);

INSERT INTO payments (order_id, amount, payment_status) VALUES
(1, 680, 'Paid'),
(2, 450, 'Pending');

-- =========================================
-- 5. QUERIES
-- =========================================

-- All Orders with Customer Name
SELECT o.order_id, c.name, o.order_date, o.status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;

-- Total Amount per Order
SELECT oi.order_id, SUM(m.price * oi.quantity) AS total_amount
FROM order_items oi
JOIN menu m ON oi.item_id = m.item_id
GROUP BY oi.order_id;

-- Top Selling Items
SELECT m.item_name, SUM(oi.quantity) AS total_sold
FROM order_items oi
JOIN menu m ON oi.item_id = m.item_id
GROUP BY m.item_name
ORDER BY total_sold DESC;

-- Orders with Payment Status
SELECT o.order_id, p.amount, p.payment_status
FROM orders o
JOIN payments p ON o.order_id = p.order_id;

-- =========================================
-- 6. STORED PROCEDURE
-- =========================================

DELIMITER //

CREATE PROCEDURE place_order(
    IN cust_id INT,
    IN item INT,
    IN qty INT
)
BEGIN
    DECLARE new_order_id INT;

    INSERT INTO orders(customer_id, status)
    VALUES (cust_id, 'Placed');

    SET new_order_id = LAST_INSERT_ID();

    INSERT INTO order_items(order_id, item_id, quantity)
    VALUES (new_order_id, item, qty);
END //

DELIMITER ;

-- Example Call
CALL place_order(1, 2, 2);

-- =========================================
-- 7. TRIGGER
-- =========================================

DELIMITER //

CREATE TRIGGER after_order_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO payments(order_id, amount, payment_status)
    VALUES (NEW.order_id, 0, 'Pending');
END //

DELIMITER ;

-- =========================================
-- END OF PROJECT
-- =========================================