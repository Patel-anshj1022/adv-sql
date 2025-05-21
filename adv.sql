-- Create database
CREATE DATABASE retail_store;
USE retail_store;

-- Customers table (simplified but with all needed fields)
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    address VARCHAR(200),
    registration_date DATE DEFAULT (CURRENT_DATE)
);

-- Products table
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0
);

-- Orders table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2),
    status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order items table
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Customer accounts table (for fund transfers)
CREATE TABLE customer_accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    balance DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

--sample data insertion
-- Add sample customers
INSERT INTO customers (first_name, last_name, email, phone, address) VALUES
('John', 'Doe', 'john@example.com', '555-0101', '123 Main St'),
('Jane', 'Smith', 'jane@example.com', '555-0202', '456 Oak Ave'),
('Mike', 'Johnson', 'mike@example.com', '555-0303', '789 Pine Rd'),
('Sarah', 'Williams', NULL, '555-0404', NULL);

-- Add sample products
INSERT INTO products (product_name, price, stock_quantity) VALUES
('Wireless Headphones', 59.99, 50),
('Smartphone Case', 19.99, 100),
('Bluetooth Speaker', 89.99, 30),
('USB Cable', 9.99, 200);

-- Add sample accounts
INSERT INTO customer_accounts (customer_id, balance) VALUES
(1, 500.00),
(2, 300.00),
(3, 750.00);

-- Add some orders (only for some customers)
INSERT INTO orders (customer_id, total_amount, status) VALUES
(1, 139.98, 'Completed'),
(1, 29.98, 'Pending'),
(2, 89.99, 'Completed');

-- Add order items
INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase) VALUES
(1, 1, 1, 59.99),  -- John bought headphones
(1, 2, 4, 19.99),   -- John bought 4 cases
(2, 4, 3, 9.99),    -- John bought 3 cables
(3, 3, 1, 89.99);   -- Jane bought a speaker

--Query 1: Retrieve customers who have not placed any orders.
SELECT c.customer_id, c.first_name, c.last_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
--Explanation:
--JOIN keeps all customers
--WHERE o.order_id IS NULL filters to only customers with no orders

-- Query 2: Calculate the total revenue generated from orders
SELECT SUM(total_amount) AS total_revenue
FROM orders
WHERE status = 'Completed';
--Explanation:
--SUM() adds up all values
--We only count 'Completed' orders (not pending/canceled ones)


-- Query 3: Find the top 5 products with the highest sales revenue.
SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.price_at_purchase) AS product_revenue
FROM 
    products p
JOIN 
    order_items oi ON p.product_id = oi.product_id
JOIN 
    orders o ON oi.order_id = o.order_id
WHERE 
    o.status = 'Completed'
GROUP BY 
    p.product_id, p.product_name
ORDER BY 
    product_revenue DESC
LIMIT 5;
--Explanation:
--JOIN combines product, order_items, and orders tables
--WHERE filters to only completed orders
--GROUP BY groups results by product
--ORDER BY sorts by revenue in descending order
--LIMIT restricts to top 5 products


-- Query 4: Update customer information (e.g., address) based on customerID.
UPDATE customers
SET address = '321 New Street'
WHERE customer_id = 3;
--Explanation:
--UPDATE modifies existing records
--SET specifies new values
--WHERE filters to only the customer with ID 3


--Query 5: Implement a transaction to handle the transfer of funds between two bank accounts.
-- Start a transaction
START TRANSACTION;

-- Set variables for the transfer
SET @from_account = 1;  -- John's account
SET @to_account = 2;    -- Jane's account
SET @amount = 100.00;

-- Check if sender has enough funds
SELECT balance INTO @current_balance 
FROM customer_accounts 
WHERE account_id = @from_account FOR UPDATE;

-- Only proceed if balance is sufficient
IF @current_balance >= @amount THEN
    -- Deduct from sender
    UPDATE customer_accounts 
    SET balance = balance - @amount 
    WHERE account_id = @from_account;
    
    -- Add to recipient
    UPDATE customer_accounts 
    SET balance = balance + @amount 
    WHERE account_id = @to_account;
    
    -- Record the transfer (would need a transactions table)
    -- INSERT INTO transfers (...) VALUES (...);
    
    COMMIT;
    SELECT 'Transfer successful' AS result;
ELSE
    ROLLBACK;
    SELECT 'Transfer failed: Insufficient funds' AS result;
END IF;
--Explanation:
--START TRANSACTION begins the secure operation
--FOR UPDATE locks the account during the check
--COMMIT makes changes permanent if successful
--ROLLBACK cancels everything if there's a problem

