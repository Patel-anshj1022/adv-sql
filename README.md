# Retail Store Database Management System

![MySQL](https://img.shields.io/badge/mysql-%2300f.svg?style=for-the-badge&logo=mysql&logoColor=white)
![Database](https://img.shields.io/badge/Database-SQL-blue)

A complete database solution for retail stores with customer, product, and order management.

## Table of Contents
- [Features](#features)
- [Database Schema](#database-schema)
- [SQL Queries](#sql-queries)
- [Setup Guide](#setup-guide)
- [Usage Examples](#usage-examples)
- [License](#license)

## Features
- Customer information tracking
- Product inventory management
- Order processing system
- Financial transaction handling
- Sales analytics and reporting

## Database Schema

### Tables Overview

| Table | Description | Primary Key |
|-------|-------------|-------------|
| customers | Stores customer details | customer_id |
| products | Product catalog | product_id |
| orders | Customer orders | order_id |
| order_items | Order line items | order_item_id |
| customer_accounts | Customer balances | account_id |

## SQL Queries

### Key Queries

1. **Find inactive customers**
```sql
SELECT c.customer_id, c.first_name, c.last_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

2. **Calculate total revenue**
SELECT SUM(total_amount) AS total_revenue
FROM orders
WHERE status = 'Completed';

3. **Top selling products**
SELECT p.product_name, SUM(oi.quantity) AS total_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_sold DESC
LIMIT 5;
