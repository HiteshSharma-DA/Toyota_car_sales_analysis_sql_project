-- Toyota Car Sales Analysis
-- Beginner-friendly SQL portfolio queries
-- Author: Hitesh Sharma
-- Data: Synthetic educational dataset
--
-- Net revenue formula:
-- quantity * unit_price_usd * (1 - discount_pct / 100)

USE toyota_car_sales_analysis;

-- 01. Overall business KPIs
SELECT COUNT(*) AS total_transactions,
       SUM(quantity) AS total_units_sold,
       ROUND(SUM(quantity * unit_price_usd * (1 - discount_pct / 100)), 2) AS net_revenue,
       ROUND(AVG(discount_pct), 2) AS avg_discount_pct
FROM sales;

-- 02. Model performance
SELECT m.model_name,
       SUM(s.quantity) AS units_sold,
       ROUND(SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)), 2) AS net_revenue
FROM sales s
JOIN models m ON s.model_id = m.model_id
GROUP BY m.model_name
ORDER BY net_revenue DESC;

-- 03. Yearly sales trend
SELECT YEAR(sale_date) AS sales_year,
       SUM(quantity) AS units_sold,
       ROUND(SUM(quantity * unit_price_usd * (1 - discount_pct / 100)), 2) AS net_revenue
FROM sales
GROUP BY YEAR(sale_date)
ORDER BY sales_year;

-- 04. Monthly revenue trend
SELECT DATE_FORMAT(sale_date, '%Y-%m') AS sales_month,
       ROUND(SUM(quantity * unit_price_usd * (1 - discount_pct / 100)), 2) AS net_revenue
FROM sales
GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
ORDER BY sales_month;

-- 05. Regional performance
SELECT r.region_name,
       SUM(s.quantity) AS units_sold,
       ROUND(SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)), 2) AS net_revenue
FROM sales s
JOIN dealerships d ON s.dealership_id = d.dealership_id
JOIN regions r ON d.region_id = r.region_id
GROUP BY r.region_name
ORDER BY net_revenue DESC;

-- 06. Top cities by revenue
SELECT d.city,
       SUM(s.quantity) AS units_sold,
       ROUND(SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)), 2) AS net_revenue
FROM sales s
JOIN dealerships d ON s.dealership_id = d.dealership_id
GROUP BY d.city
ORDER BY net_revenue DESC
LIMIT 10;

-- 07. Fuel-type performance
SELECT m.fuel_type,
       SUM(s.quantity) AS units_sold,
       ROUND(SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)), 2) AS net_revenue
FROM sales s
JOIN models m ON s.model_id = m.model_id
GROUP BY m.fuel_type
ORDER BY net_revenue DESC;

-- 08. Payment-method performance
SELECT payment_method,
       COUNT(*) AS transactions,
       SUM(quantity) AS units_sold,
       ROUND(SUM(quantity * unit_price_usd * (1 - discount_pct / 100)), 2) AS net_revenue
FROM sales
GROUP BY payment_method
ORDER BY net_revenue DESC;

-- 09. Customer-type performance
SELECT c.customer_type,
       COUNT(*) AS transactions,
       SUM(s.quantity) AS units_sold,
       ROUND(SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)), 2) AS net_revenue
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY c.customer_type
ORDER BY net_revenue DESC;

-- 10. Average discount by model
SELECT m.model_name,
       ROUND(AVG(s.discount_pct), 2) AS avg_discount_pct
FROM sales s
JOIN models m ON s.model_id = m.model_id
GROUP BY m.model_name
ORDER BY avg_discount_pct DESC;

-- 11. Top 10 dealerships
SELECT d.dealership_name,
       d.city,
       ROUND(SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)), 2) AS net_revenue
FROM sales s
JOIN dealerships d ON s.dealership_id = d.dealership_id
GROUP BY d.dealership_id, d.dealership_name, d.city
ORDER BY net_revenue DESC
LIMIT 10;

-- 12. Top 10 sales employees
SELECT e.employee_name,
       d.dealership_name,
       SUM(s.quantity) AS units_sold,
       ROUND(SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)), 2) AS net_revenue
FROM sales s
JOIN employees e ON s.employee_id = e.employee_id
JOIN dealerships d ON e.dealership_id = d.dealership_id
GROUP BY e.employee_id, e.employee_name, d.dealership_name
ORDER BY net_revenue DESC
LIMIT 10;

-- 13. Repeat customers
SELECT c.customer_id,
       c.customer_name,
       COUNT(s.sale_id) AS purchase_count,
       ROUND(SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)), 2) AS total_spend
FROM customers c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(s.sale_id) > 1
ORDER BY total_spend DESC
LIMIT 20;

-- 14. Current inventory by model
SELECT m.model_name,
       SUM(i.units_available) AS units_available
FROM inventory i
JOIN models m ON i.model_id = m.model_id
GROUP BY m.model_name
ORDER BY units_available DESC;

-- 15. Service satisfaction by model
SELECT m.model_name,
       COUNT(sr.service_id) AS service_visits,
       ROUND(AVG(sr.satisfaction_score), 2) AS avg_satisfaction_score
FROM service_records sr
JOIN sales s ON sr.sale_id = s.sale_id
JOIN models m ON s.model_id = m.model_id
GROUP BY m.model_name
ORDER BY avg_satisfaction_score DESC;

-- 16. Revenue by discount band
SELECT CASE
           WHEN discount_pct = 0 THEN 'No Discount'
           WHEN discount_pct <= 5 THEN 'Low (0-5%)'
           WHEN discount_pct <= 10 THEN 'Medium (5-10%)'
           ELSE 'High (>10%)'
       END AS discount_band,
       COUNT(*) AS transactions,
       ROUND(SUM(quantity * unit_price_usd * (1 - discount_pct / 100)), 2) AS net_revenue
FROM sales
GROUP BY discount_band
ORDER BY net_revenue DESC;

-- 17. Selling price versus catalogue base price
SELECT m.model_name,
       ROUND(AVG(m.base_price_usd), 2) AS base_price_usd,
       ROUND(AVG(s.unit_price_usd), 2) AS avg_selling_price_usd,
       ROUND(AVG(s.unit_price_usd - m.base_price_usd), 2) AS avg_price_difference
FROM sales s
JOIN models m ON s.model_id = m.model_id
GROUP BY m.model_name
ORDER BY avg_price_difference DESC;

-- 18. Basic data-quality checks
SELECT SUM(CASE WHEN quantity <= 0 THEN 1 ELSE 0 END) AS invalid_quantity_rows,
       SUM(CASE WHEN unit_price_usd <= 0 THEN 1 ELSE 0 END) AS invalid_price_rows,
       SUM(CASE WHEN discount_pct < 0 OR discount_pct > 100 THEN 1 ELSE 0 END) AS invalid_discount_rows
FROM sales;
