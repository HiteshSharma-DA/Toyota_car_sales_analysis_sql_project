-- Toyota Car Sales Analysis: By Hitesh Sharma 
-- --------------------------------------------------------------------------------------------------------------------------
-- Caution = Synthetic educational data; not affiliated with Toyota Motor Corporation.
-- --------------------------------------------------------------------------------------------------------------------------
USE toyota_car_sales_analysis;
-- --------------------------------------------------------------------------------------------------------------------------
-- Net revenue formula used throughout:
-- quantity * unit_price_usd * (1 - discount_pct / 100)
-- ---------------------------------------------------------------------------------------------------------------------------
-- Below are queries i used to get insights from the dataset :

/*
====================================================================================================
QUERY 01: FULL SALES VIEW USING MULTIPLE JOINS
----------------------------------------------------------------------------------------------------
INSIGHT: Creates a readable transaction-level view across six tables.
====================================================================================================
*/
SELECT s.sale_id, s.sale_date, c.customer_name, c.customer_type,
       m.model_name, m.vehicle_type, d.dealership_name, r.region_name,
       e.employee_name, s.quantity,
       ROUND(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100), 2) AS net_revenue
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN models m ON s.model_id = m.model_id
JOIN dealerships d ON s.dealership_id = d.dealership_id
JOIN regions r ON d.region_id = r.region_id
JOIN employees e ON s.employee_id = e.employee_id
ORDER BY s.sale_date DESC, s.sale_id DESC
LIMIT 100;
--
-- RESULT 01: TOP 10 OF 100 ROWS
-- +---------+------------+---------------+---------------+------------+--------------+-------------------+---------------+---------------+----------+-------------+
-- | sale_id | sale_date  | customer_name | customer_type | model_name | vehicle_type | dealership_name   | region_name   | employee_name | quantity | net_revenue |
-- +---------+------------+---------------+---------------+------------+--------------+-------------------+---------------+---------------+----------+-------------+
-- | 39830   | 2025-12-31 | Ava Suzuki    | Government    | GR86       | Coupe        | Toyota Center 084 | Africa        | Maya Khan     | 3        | 104095.50   |
-- | 39551   | 2025-12-31 | Kenji Smith   | Government    | RAV4       | SUV          | Toyota Center 100 | Middle East   | Emma Smith    | 1        | 35886.69    |
-- | 38012   | 2025-12-31 | Olivia Patel  | Government    | Prius      | Hatchback    | Toyota Center 062 | Europe        | Liam Brown    | 1        | 29805.65    |
-- | 36778   | 2025-12-31 | Emma Garcia   | Individual    | Tacoma     | Pickup       | Toyota Center 076 | Middle East   | Liam Martin   | 1        | 41492.52    |
-- | 35917   | 2025-12-31 | Olivia Suzuki | Corporate     | Supra      | Coupe        | Toyota Center 088 | Middle East   | Ethan Sharma  | 1        | 52194.95    |
-- | 27971   | 2025-12-31 | Noah Tanaka   | Government    | Tacoma     | Pickup       | Toyota Center 069 | Asia-Pacific  | Lucas Martin  | 1        | 41760.38    |
-- | 27631   | 2025-12-31 | Noah Martin   | Government    | RAV4       | SUV          | Toyota Center 046 | Middle East   | Kenji Sharma  | 2        | 67704.29    |
-- | 26713   | 2025-12-31 | Noah Brown    | Individual    | Tundra     | Pickup       | Toyota Center 077 | Latin America | Lucas Brown   | 2        | 106743.24   |
-- | 26667   | 2025-12-31 | Noah Suzuki   | Corporate     | Camry      | Sedan        | Toyota Center 042 | Africa        | Liam Martin   | 3        | 96920.54    |
-- | 26604   | 2025-12-31 | Sophia Martin | Government    | Prius      | Hatchback    | Toyota Center 093 | Asia-Pacific  | Emma Tanaka   | 2        | 62496.98    |
-- +---------+------------+---------------+---------------+------------+--------------+-------------------+---------------+---------------+----------+-------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 02: MODEL PERFORMANCE WITH CONTRIBUTION PERCENTAGE
----------------------------------------------------------------------------------------------------
INSIGHT: Identifies models that contribute the largest share of revenue.
====================================================================================================
*/
WITH model_revenue AS (
    SELECT m.model_name,
           SUM(s.quantity) AS units_sold,
           SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)) AS revenue
    FROM sales s JOIN models m ON s.model_id = m.model_id
    GROUP BY m.model_id, m.model_name
)
SELECT model_name, units_sold, ROUND(revenue, 2) AS revenue,
       ROUND(100 * revenue / SUM(revenue) OVER (), 2) AS revenue_share_pct
FROM model_revenue
ORDER BY revenue DESC;
--
-- RESULT 02: TOP 10 OF 12 ROWS
-- +------------+------------+--------------+-------------------+
-- | model_name | units_sold | revenue      | revenue_share_pct |
-- +------------+------------+--------------+-------------------+
-- | Tundra     | 6973       | 385435626.73 | 12.12             |
-- | Supra      | 6826       | 364846885.69 | 11.47             |
-- | 4Runner    | 6702       | 330765337.43 | 10.40             |
-- | Sienna     | 6616       | 293866733.35 | 9.24              |
-- | Highlander | 6543       | 285037814.19 | 8.96              |
-- | bZ4X       | 6571       | 274579544.95 | 8.63              |
-- | Tacoma     | 6743       | 265368248.13 | 8.34              |
-- | RAV4       | 6555       | 224664066.09 | 7.06              |
-- | GR86       | 6690       | 207015931.61 | 6.51              |
-- | Prius      | 6514       | 198491197.60 | 6.24              |
-- +------------+------------+--------------+-------------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 03: TOP THREE MODELS IN EVERY REGION
----------------------------------------------------------------------------------------------------
INSIGHT: Shows regional product preferences.
====================================================================================================
*/
WITH regional_models AS (
    SELECT r.region_name, m.model_name, SUM(s.quantity) AS units_sold
    FROM sales s
    JOIN dealerships d ON s.dealership_id = d.dealership_id
    JOIN regions r ON d.region_id = r.region_id
    JOIN models m ON s.model_id = m.model_id
    GROUP BY r.region_name, m.model_name
), ranked AS (
    SELECT *, DENSE_RANK() OVER (PARTITION BY region_name ORDER BY units_sold DESC) AS model_rank
    FROM regional_models
)
SELECT * FROM ranked WHERE model_rank <= 3 ORDER BY region_name, model_rank;
--
-- RESULT 03: TOP 10 OF 18 ROWS
-- +---------------+------------+------------+------------+
-- | region_name   | model_name | units_sold | model_rank |
-- +---------------+------------+------------+------------+
-- | Africa        | Supra      | 1259       | 1          |
-- | Africa        | GR86       | 1212       | 2          |
-- | Africa        | Highlander | 1210       | 3          |
-- | Asia-Pacific  | Tundra     | 1221       | 1          |
-- | Asia-Pacific  | Camry      | 1181       | 2          |
-- | Asia-Pacific  | Tacoma     | 1157       | 3          |
-- | Europe        | GR86       | 1198       | 1          |
-- | Europe        | 4Runner    | 1183       | 2          |
-- | Europe        | Tundra     | 1172       | 3          |
-- | Latin America | Corolla    | 1225       | 1          |
-- +---------------+------------+------------+------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 04: DEALERSHIP RANKING INSIDE EACH REGION
----------------------------------------------------------------------------------------------------
INSIGHT: Benchmarks dealers against others operating in the same region.
====================================================================================================
*/
WITH dealer_revenue AS (
    SELECT r.region_name, d.dealership_name,
           SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)) AS revenue
    FROM sales s
    JOIN dealerships d ON s.dealership_id = d.dealership_id
    JOIN regions r ON d.region_id = r.region_id
    GROUP BY r.region_name, d.dealership_id, d.dealership_name
)
SELECT region_name, dealership_name, ROUND(revenue, 2) AS revenue,
       RANK() OVER (PARTITION BY region_name ORDER BY revenue DESC) AS regional_rank
FROM dealer_revenue
ORDER BY region_name, regional_rank;
--
-- RESULT 04: TOP 10 OF 120 ROWS
-- +-------------+-------------------+-------------+---------------+
-- | region_name | dealership_name   | revenue     | regional_rank |
-- +-------------+-------------------+-------------+---------------+
-- | Africa      | Toyota Center 024 | 29494307.06 | 1             |
-- | Africa      | Toyota Center 072 | 29201840.01 | 2             |
-- | Africa      | Toyota Center 108 | 27929710.64 | 3             |
-- | Africa      | Toyota Center 090 | 27694460.40 | 4             |
-- | Africa      | Toyota Center 054 | 27653177.75 | 5             |
-- | Africa      | Toyota Center 006 | 27646801.87 | 6             |
-- | Africa      | Toyota Center 096 | 27631356.18 | 7             |
-- | Africa      | Toyota Center 060 | 27527130.73 | 8             |
-- | Africa      | Toyota Center 012 | 27124052.20 | 9             |
-- | Africa      | Toyota Center 048 | 27057212.51 | 10            |
-- +-------------+-------------------+-------------+---------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 05: YEAR-OVER-YEAR REVENUE GROWTH
----------------------------------------------------------------------------------------------------
INSIGHT: Measures annual growth or decline.
====================================================================================================
*/
WITH yearly AS (
    SELECT YEAR(sale_date) AS sales_year,
           SUM(quantity * unit_price_usd * (1 - discount_pct / 100)) AS revenue
    FROM sales GROUP BY YEAR(sale_date)
), compared AS (
    SELECT *, LAG(revenue) OVER (ORDER BY sales_year) AS prior_year_revenue
    FROM yearly
)
SELECT sales_year, ROUND(revenue, 2) AS revenue,
       ROUND(100 * (revenue - prior_year_revenue) / NULLIF(prior_year_revenue, 0), 2) AS yoy_growth_pct
FROM compared ORDER BY sales_year;
--
-- RESULT 05: TOP 5 OF 5 ROWS
-- +------------+--------------+----------------+
-- | sales_year | revenue      | yoy_growth_pct |
-- +------------+--------------+----------------+
-- | 2021       | 634871399.98 | NULL           |
-- | 2022       | 630518545.58 | -0.69          |
-- | 2023       | 635459255.84 | 0.78           |
-- | 2024       | 642708677.34 | 1.14           |
-- | 2025       | 637689797.97 | -0.78          |
-- +------------+--------------+----------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 06: MONTH-OVER-MONTH REVENUE GROWTH
----------------------------------------------------------------------------------------------------
INSIGHT: Detects short-term acceleration and slowdown.
====================================================================================================
*/
WITH monthly AS (
    SELECT DATE_FORMAT(sale_date, '%Y-%m') AS sales_month,
           SUM(quantity * unit_price_usd * (1 - discount_pct / 100)) AS revenue
    FROM sales GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
), compared AS (
    SELECT *, LAG(revenue) OVER (ORDER BY sales_month) AS prior_month_revenue
    FROM monthly
)
SELECT sales_month, ROUND(revenue, 2) AS revenue,
       ROUND(100 * (revenue - prior_month_revenue) / NULLIF(prior_month_revenue, 0), 2) AS mom_growth_pct
FROM compared ORDER BY sales_month;
--
-- RESULT 06: TOP 10 OF 60 ROWS
-- +-------------+-------------+----------------+
-- | sales_month | revenue     | mom_growth_pct |
-- +-------------+-------------+----------------+
-- | 2021-01     | 50473867.78 | NULL           |
-- | 2021-02     | 47271601.40 | -6.34          |
-- | 2021-03     | 53866350.15 | 13.95          |
-- | 2021-04     | 57385416.19 | 6.53           |
-- | 2021-05     | 56221976.54 | -2.03          |
-- | 2021-06     | 52618448.44 | -6.41          |
-- | 2021-07     | 54408751.71 | 3.40           |
-- | 2021-08     | 51957781.85 | -4.50          |
-- | 2021-09     | 49580729.25 | -4.57          |
-- | 2021-10     | 50944350.09 | 2.75           |
-- +-------------+-------------+----------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 07: THREE-MONTH ROLLING REVENUE AVERAGE
----------------------------------------------------------------------------------------------------
INSIGHT: Smooths monthly volatility to reveal the underlying trend.
====================================================================================================
*/
WITH monthly AS (
    SELECT DATE_FORMAT(sale_date, '%Y-%m') AS sales_month,
           SUM(quantity * unit_price_usd * (1 - discount_pct / 100)) AS revenue
    FROM sales GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
)
SELECT sales_month, ROUND(revenue, 2) AS revenue,
       ROUND(AVG(revenue) OVER (ORDER BY sales_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_avg_3m
FROM monthly ORDER BY sales_month;
--
-- RESULT 07: TOP 10 OF 60 ROWS
-- +-------------+-------------+----------------+
-- | sales_month | revenue     | rolling_avg_3m |
-- +-------------+-------------+----------------+
-- | 2021-01     | 50473867.78 | 50473867.78    |
-- | 2021-02     | 47271601.40 | 48872734.59    |
-- | 2021-03     | 53866350.15 | 50537273.11    |
-- | 2021-04     | 57385416.19 | 52841122.58    |
-- | 2021-05     | 56221976.54 | 55824580.96    |
-- | 2021-06     | 52618448.44 | 55408613.73    |
-- | 2021-07     | 54408751.71 | 54416392.23    |
-- | 2021-08     | 51957781.85 | 52994994.00    |
-- | 2021-09     | 49580729.25 | 51982420.93    |
-- | 2021-10     | 50944350.09 | 50827620.40    |
-- +-------------+-------------+----------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 08: RUNNING REVENUE TOTAL BY YEAR
----------------------------------------------------------------------------------------------------
INSIGHT: Shows how quickly revenue accumulates through each year.
====================================================================================================
*/
WITH monthly AS (
    SELECT YEAR(sale_date) AS sales_year, MONTH(sale_date) AS month_no,
           SUM(quantity * unit_price_usd * (1 - discount_pct / 100)) AS revenue
    FROM sales GROUP BY YEAR(sale_date), MONTH(sale_date)
)
SELECT sales_year, month_no, ROUND(revenue, 2) AS monthly_revenue,
       ROUND(SUM(revenue) OVER (PARTITION BY sales_year ORDER BY month_no), 2) AS yearly_running_revenue
FROM monthly ORDER BY sales_year, month_no;
--
-- RESULT 08: TOP 10 OF 60 ROWS
-- +------------+----------+-----------------+------------------------+
-- | sales_year | month_no | monthly_revenue | yearly_running_revenue |
-- +------------+----------+-----------------+------------------------+
-- | 2021       | 1        | 50473867.78     | 50473867.78            |
-- | 2021       | 2        | 47271601.40     | 97745469.18            |
-- | 2021       | 3        | 53866350.15     | 151611819.33           |
-- | 2021       | 4        | 57385416.19     | 208997235.52           |
-- | 2021       | 5        | 56221976.54     | 265219212.06           |
-- | 2021       | 6        | 52618448.44     | 317837660.50           |
-- | 2021       | 7        | 54408751.71     | 372246412.21           |
-- | 2021       | 8        | 51957781.85     | 424204194.06           |
-- | 2021       | 9        | 49580729.25     | 473784923.30           |
-- | 2021       | 10       | 50944350.09     | 524729273.40           |
-- +------------+----------+-----------------+------------------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 09: BEST SALES EMPLOYEE AT EVERY DEALERSHIP
----------------------------------------------------------------------------------------------------
INSIGHT: Finds each dealer's leading salesperson.
====================================================================================================
*/
WITH employee_sales AS (
    SELECT d.dealership_name, e.employee_name,
           SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)) AS revenue
    FROM employees e
    JOIN dealerships d ON e.dealership_id = d.dealership_id
    LEFT JOIN sales s ON e.employee_id = s.employee_id
    GROUP BY d.dealership_id, d.dealership_name, e.employee_id, e.employee_name
), ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY dealership_name ORDER BY revenue DESC) AS rn
    FROM employee_sales
)
SELECT dealership_name, employee_name, ROUND(revenue, 2) AS revenue
FROM ranked WHERE rn = 1 ORDER BY revenue DESC;
--
-- RESULT 09: TOP 10 OF 120 ROWS
-- +-------------------+---------------+------------+
-- | dealership_name   | employee_name | revenue    |
-- +-------------------+---------------+------------+
-- | Toyota Center 108 | Noah Martin   | 7240410.31 |
-- | Toyota Center 006 | Aarav Miller  | 7157650.64 |
-- | Toyota Center 062 | Liam Garcia   | 7144897.85 |
-- | Toyota Center 073 | Kenji Suzuki  | 7038738.79 |
-- | Toyota Center 110 | Lucas Brown   | 7021452.78 |
-- | Toyota Center 096 | Ethan Martin  | 6924953.98 |
-- | Toyota Center 115 | Kenji Tanaka  | 6896713.77 |
-- | Toyota Center 101 | Kenji Brown   | 6886215.76 |
-- | Toyota Center 078 | Ava Smith     | 6842290.13 |
-- | Toyota Center 021 | Emma Garcia   | 6823591.86 |
-- +-------------------+---------------+------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 10: EMPLOYEES PERFORMING ABOVE THEIR DEALERSHIP AVERAGE
----------------------------------------------------------------------------------------------------
INSIGHT: Identifies locally strong performers without favoring large dealerships.
====================================================================================================
*/
WITH employee_sales AS (
    SELECT e.employee_id, e.employee_name, e.dealership_id,
           SUM(s.quantity) AS units_sold
    FROM employees e LEFT JOIN sales s ON e.employee_id = s.employee_id
    GROUP BY e.employee_id, e.employee_name, e.dealership_id
), benchmarked AS (
    SELECT *, AVG(units_sold) OVER (PARTITION BY dealership_id) AS dealership_avg_units
    FROM employee_sales
)
SELECT employee_name, dealership_id, units_sold, ROUND(dealership_avg_units, 2) AS dealership_avg_units
FROM benchmarked WHERE units_sold > dealership_avg_units
ORDER BY dealership_id, units_sold DESC;
--
-- RESULT 10: TOP 10 OF 305 ROWS
-- +---------------+---------------+------------+----------------------+
-- | employee_name | dealership_id | units_sold | dealership_avg_units |
-- +---------------+---------------+------------+----------------------+
-- | Emma Martin   | 1             | 143        | 126.40               |
-- | Emma Tanaka   | 1             | 136        | 126.40               |
-- | Olivia Brown  | 2             | 149        | 120.00               |
-- | Yuki Patel    | 2             | 133        | 120.00               |
-- | Lucas Tanaka  | 2             | 124        | 120.00               |
-- | Ava Khan      | 3             | 166        | 133.00               |
-- | Aarav Khan    | 4             | 140        | 127.60               |
-- | Aarav Martin  | 4             | 128        | 127.60               |
-- | Aarav Tanaka  | 5             | 150        | 136.60               |
-- | Olivia Patel  | 5             | 146        | 136.60               |
-- +---------------+---------------+------------+----------------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 11: HIGH-VALUE CUSTOMERS USING A SUBQUERY BENCHMARK
----------------------------------------------------------------------------------------------------
INSIGHT: Finds customers whose spending exceeds average customer spending.
====================================================================================================
*/
WITH customer_spend AS (
    SELECT c.customer_id, c.customer_name,
           SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)) AS spend
    FROM customers c JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, ROUND(spend, 2) AS spend
FROM customer_spend
WHERE spend > (SELECT AVG(spend) FROM customer_spend)
ORDER BY spend DESC;
--
-- RESULT 11: TOP 10 OF 3622 ROWS
-- +-------------+---------------+------------+
-- | customer_id | customer_name | spend      |
-- +-------------+---------------+------------+
-- | 1285        | Noah Garcia   | 1393115.67 |
-- | 5955        | Liam Smith    | 1200757.63 |
-- | 4072        | Yuki Brown    | 1183840.87 |
-- | 2274        | Maya Khan     | 1166435.30 |
-- | 5261        | Liam Sharma   | 1151700.64 |
-- | 79          | Noah Sharma   | 1139977.41 |
-- | 5498        | Emma Khan     | 1137722.69 |
-- | 6478        | Sophia Suzuki | 1133754.82 |
-- | 155         | Sophia Suzuki | 1111647.43 |
-- | 2025        | Aarav Sharma  | 1101955.91 |
-- +-------------+---------------+------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 12: TOP 10% OF CUSTOMERS BY SPENDING
----------------------------------------------------------------------------------------------------
INSIGHT: Defines a premium customer segment for retention activity.
====================================================================================================
*/
WITH customer_spend AS (
    SELECT c.customer_id, c.customer_name,
           SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)) AS spend
    FROM customers c JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY c.customer_id, c.customer_name
), segmented AS (
    SELECT *, NTILE(10) OVER (ORDER BY spend DESC) AS spending_decile
    FROM customer_spend
)
SELECT customer_id, customer_name, ROUND(spend, 2) AS spend
FROM segmented WHERE spending_decile = 1 ORDER BY spend DESC;
--
-- RESULT 12: TOP 10 OF 795 ROWS
-- +-------------+---------------+------------+
-- | customer_id | customer_name | spend      |
-- +-------------+---------------+------------+
-- | 1285        | Noah Garcia   | 1393115.67 |
-- | 5955        | Liam Smith    | 1200757.63 |
-- | 4072        | Yuki Brown    | 1183840.87 |
-- | 2274        | Maya Khan     | 1166435.30 |
-- | 5261        | Liam Sharma   | 1151700.64 |
-- | 79          | Noah Sharma   | 1139977.41 |
-- | 5498        | Emma Khan     | 1137722.69 |
-- | 6478        | Sophia Suzuki | 1133754.82 |
-- | 155         | Sophia Suzuki | 1111647.43 |
-- | 2025        | Aarav Sharma  | 1101955.91 |
-- +-------------+---------------+------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 13: CUSTOMER RECENCY, FREQUENCY AND MONETARY VALUE
----------------------------------------------------------------------------------------------------
INSIGHT: Produces inputs for RFM customer segmentation.
====================================================================================================
*/
SELECT c.customer_id, c.customer_name,
       DATEDIFF((SELECT MAX(sale_date) FROM sales), MAX(s.sale_date)) AS recency_days,
       COUNT(DISTINCT s.sale_id) AS frequency,
       ROUND(SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)), 2) AS monetary_value
FROM customers c JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY monetary_value DESC;
--
-- RESULT 13: TOP 10 OF 7943 ROWS
-- +-------------+---------------+--------------+-----------+----------------+
-- | customer_id | customer_name | recency_days | frequency | monetary_value |
-- +-------------+---------------+--------------+-----------+----------------+
-- | 1285        | Noah Garcia   | 36           | 18        | 1393115.67     |
-- | 5955        | Liam Smith    | 223          | 11        | 1200757.63     |
-- | 4072        | Yuki Brown    | 72           | 11        | 1183840.87     |
-- | 2274        | Maya Khan     | 182          | 13        | 1166435.30     |
-- | 5261        | Liam Sharma   | 82           | 14        | 1151700.64     |
-- | 79          | Noah Sharma   | 230          | 15        | 1139977.41     |
-- | 5498        | Emma Khan     | 37           | 10        | 1137722.69     |
-- | 6478        | Sophia Suzuki | 93           | 11        | 1133754.82     |
-- | 155         | Sophia Suzuki | 24           | 11        | 1111647.43     |
-- | 2025        | Aarav Sharma  | 46           | 13        | 1101955.91     |
-- +-------------+---------------+--------------+-----------+----------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 14: REPEAT VERSUS ONE-TIME CUSTOMERS
----------------------------------------------------------------------------------------------------
INSIGHT: Measures the size of the repeat-customer base.
====================================================================================================
*/
WITH frequencies AS (
    SELECT customer_id, COUNT(*) AS purchase_count FROM sales GROUP BY customer_id
)
SELECT CASE WHEN purchase_count = 1 THEN 'One-time' ELSE 'Repeat' END AS customer_segment,
       COUNT(*) AS customers,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS customer_pct
FROM frequencies
GROUP BY CASE WHEN purchase_count = 1 THEN 'One-time' ELSE 'Repeat' END;
--
-- RESULT 14: TOP 2 OF 2 ROWS
-- +------------------+-----------+--------------+
-- | customer_segment | customers | customer_pct |
-- +------------------+-----------+--------------+
-- | Repeat           | 7677      | 96.65        |
-- | One-time         | 266       | 3.35         |
-- +------------------+-----------+--------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 15: CUSTOMERS WHO PURCHASED MULTIPLE VEHICLE MODELS
----------------------------------------------------------------------------------------------------
INSIGHT: Finds customers with broader product engagement.
====================================================================================================
*/
SELECT c.customer_id, c.customer_name, COUNT(DISTINCT s.model_id) AS distinct_models,
       GROUP_CONCAT(DISTINCT m.model_name ORDER BY m.model_name SEPARATOR ', ') AS models_purchased
FROM customers c
JOIN sales s ON c.customer_id = s.customer_id
JOIN models m ON s.model_id = m.model_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT s.model_id) >= 2
ORDER BY distinct_models DESC, c.customer_id;
--
-- RESULT 15: TOP 10 OF 7622 ROWS
-- +-------------+---------------+-----------------+-------------------------------------------------------------------------------------+
-- | customer_id | customer_name | distinct_models | models_purchased                                                                    |
-- +-------------+---------------+-----------------+-------------------------------------------------------------------------------------+
-- | 1976        | Maya Sharma   | 11              | 4Runner, bZ4X, Camry, Corolla, GR86, Highlander, Prius, RAV4, Sienna, Supra, Tacoma |
-- | 2           | Noah Suzuki   | 10              | 4Runner, bZ4X, Camry, Corolla, GR86, Highlander, Prius, RAV4, Tacoma, Tundra        |
-- | 1285        | Noah Garcia   | 10              | 4Runner, bZ4X, Corolla, GR86, Highlander, Prius, RAV4, Sienna, Supra, Tacoma        |
-- | 6742        | Noah Brown    | 10              | 4Runner, bZ4X, Camry, GR86, Highlander, Prius, Sienna, Supra, Tacoma, Tundra        |
-- | 79          | Noah Sharma   | 9               | 4Runner, bZ4X, Camry, GR86, Highlander, Prius, RAV4, Sienna, Tundra                 |
-- | 365         | Noah Brown    | 9               | 4Runner, bZ4X, GR86, Highlander, RAV4, Sienna, Supra, Tacoma, Tundra                |
-- | 417         | Ava Smith     | 9               | 4Runner, Corolla, GR86, Highlander, Prius, RAV4, Sienna, Tacoma, Tundra             |
-- | 492         | Liam Tanaka   | 9               | Camry, Corolla, GR86, Highlander, Prius, Sienna, Supra, Tacoma, Tundra              |
-- | 830         | Sophia Martin | 9               | 4Runner, bZ4X, Highlander, Prius, RAV4, Sienna, Supra, Tacoma, Tundra               |
-- | 891         | Lucas Smith   | 9               | 4Runner, bZ4X, Camry, GR86, Highlander, Prius, RAV4, Sienna, Tundra                 |
-- +-------------+---------------+-----------------+-------------------------------------------------------------------------------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 16: CUSTOMERS WITHOUT A PURCHASE USING NOT EXISTS
----------------------------------------------------------------------------------------------------
INSIGHT: Identifies registered customers who have not converted.
====================================================================================================
*/
SELECT c.customer_id, c.customer_name, c.customer_type
FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM sales s WHERE s.customer_id = c.customer_id)
ORDER BY c.customer_id;
--
-- RESULT 16: TOP 10 OF 57 ROWS
-- +-------------+---------------+---------------+
-- | customer_id | customer_name | customer_type |
-- +-------------+---------------+---------------+
-- | 72          | Aarav Patel   | Individual    |
-- | 286         | Emma Patel    | Government    |
-- | 416         | Ava Tanaka    | Corporate     |
-- | 562         | Aarav Smith   | Government    |
-- | 576         | Ethan Suzuki  | Corporate     |
-- | 785         | Emma Brown    | Individual    |
-- | 788         | Lucas Miller  | Corporate     |
-- | 851         | Maya Martin   | Individual    |
-- | 1012        | Ethan Martin  | Individual    |
-- | 1236        | Ava Sharma    | Individual    |
-- +-------------+---------------+---------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 17: DEALERSHIPS WITH REVENUE ABOVE THE OVERALL DEALERSHIP AVERAGE
----------------------------------------------------------------------------------------------------
INSIGHT: Separates above-average dealer locations.
====================================================================================================
*/
WITH dealer_revenue AS (
    SELECT d.dealership_id, d.dealership_name,
           SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)) AS revenue
    FROM dealerships d JOIN sales s ON d.dealership_id = s.dealership_id
    GROUP BY d.dealership_id, d.dealership_name
)
SELECT dealership_name, ROUND(revenue, 2) AS revenue
FROM dealer_revenue
WHERE revenue > (SELECT AVG(revenue) FROM dealer_revenue)
ORDER BY revenue DESC;
--
-- RESULT 17: TOP 10 OF 55 ROWS
-- +-------------------+-------------+
-- | dealership_name   | revenue     |
-- +-------------------+-------------+
-- | Toyota Center 070 | 31029661.50 |
-- | Toyota Center 024 | 29494307.06 |
-- | Toyota Center 013 | 29318315.40 |
-- | Toyota Center 067 | 29254908.76 |
-- | Toyota Center 072 | 29201840.01 |
-- | Toyota Center 074 | 29093860.40 |
-- | Toyota Center 092 | 28879575.41 |
-- | Toyota Center 087 | 28864585.71 |
-- | Toyota Center 004 | 28800091.14 |
-- | Toyota Center 041 | 28683247.21 |
-- +-------------------+-------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 18: MODEL PRICE VARIANCE FROM CATALOG BASE PRICE
----------------------------------------------------------------------------------------------------
INSIGHT: Shows which models sell above or below their reference base price.
====================================================================================================
*/
SELECT m.model_name, m.base_price_usd,
       ROUND(AVG(s.unit_price_usd), 2) AS avg_selling_price,
       ROUND(AVG(s.unit_price_usd - m.base_price_usd), 2) AS avg_price_variance,
       ROUND(100 * AVG(s.unit_price_usd - m.base_price_usd) / m.base_price_usd, 2) AS variance_pct
FROM models m JOIN sales s ON m.model_id = s.model_id
GROUP BY m.model_id, m.model_name, m.base_price_usd
ORDER BY variance_pct DESC;
--
-- RESULT 18: TOP 10 OF 12 ROWS
-- +------------+----------------+-------------------+--------------------+--------------+
-- | model_name | base_price_usd | avg_selling_price | avg_price_variance | variance_pct |
-- +------------+----------------+-------------------+--------------------+--------------+
-- | 4Runner    | 52500.00       | 52588.18          | 88.18              | 0.17         |
-- | bZ4X       | 44500.00       | 44556.27          | 56.27              | 0.13         |
-- | RAV4       | 36500.00       | 36545.28          | 45.28              | 0.12         |
-- | GR86       | 33000.00       | 33014.34          | 14.34              | 0.04         |
-- | Corolla    | 24500.00       | 24501.35          | 1.35               | 0.01         |
-- | Camry      | 31500.00       | 31492.89          | -7.11              | -0.02        |
-- | Prius      | 32500.00       | 32493.55          | -6.45              | -0.02        |
-- | Supra      | 57000.00       | 56974.62          | -25.38             | -0.04        |
-- | Tacoma     | 42000.00       | 41968.44          | -31.56             | -0.08        |
-- | Tundra     | 59000.00       | 58949.94          | -50.06             | -0.08        |
-- +------------+----------------+-------------------+--------------------+--------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 19: DISCOUNT BANDS AND THEIR REVENUE IMPACT
----------------------------------------------------------------------------------------------------
INSIGHT: Compares transaction volume and revenue across discount levels.
====================================================================================================
*/
SELECT CASE
           WHEN discount_pct < 3 THEN 'Low: under 3%'
           WHEN discount_pct < 7 THEN 'Medium: 3%-6.99%'
           WHEN discount_pct < 10 THEN 'High: 7%-9.99%'
           ELSE 'Very high: 10%+'
       END AS discount_band,
       COUNT(*) AS transactions, SUM(quantity) AS units,
       ROUND(AVG(discount_pct), 2) AS avg_discount,
       ROUND(SUM(quantity * unit_price_usd * (1 - discount_pct / 100)), 2) AS net_revenue
FROM sales
GROUP BY discount_band
ORDER BY MIN(discount_pct);
--
-- RESULT 19: TOP 4 OF 4 ROWS
-- +------------------+--------------+-------+--------------+---------------+
-- | discount_band    | transactions | units | avg_discount | net_revenue   |
-- +------------------+--------------+-------+--------------+---------------+
-- | Low: under 3%    | 9617         | 19111 | 1.50         | 799299572.56  |
-- | Medium: 3%-6.99% | 12819        | 25880 | 5.00         | 1042587841.74 |
-- | High: 7%-9.99%   | 9559         | 19080 | 8.50         | 736848441.97  |
-- | Very high: 10%+  | 8005         | 16059 | 11.25        | 602511820.43  |
-- +------------------+--------------+-------+--------------+---------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 20: MODELS WITH AN ABOVE-AVERAGE DISCOUNT
----------------------------------------------------------------------------------------------------
INSIGHT: Highlights models that may require heavier promotional support.
====================================================================================================
*/
SELECT m.model_name, ROUND(AVG(s.discount_pct), 2) AS avg_discount_pct
FROM models m JOIN sales s ON m.model_id = s.model_id
GROUP BY m.model_id, m.model_name
HAVING AVG(s.discount_pct) > (SELECT AVG(discount_pct) FROM sales)
ORDER BY avg_discount_pct DESC;
--
-- RESULT 20: TOP 4 OF 4 ROWS
-- +------------+------------------+
-- | model_name | avg_discount_pct |
-- +------------+------------------+
-- | Corolla    | 6.38             |
-- | Camry      | 6.31             |
-- | Sienna     | 6.31             |
-- | GR86       | 6.30             |
-- +------------+------------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 21: PAYMENT PREFERENCE BY CUSTOMER TYPE
----------------------------------------------------------------------------------------------------
INSIGHT: Connects financing behavior with customer segments.
====================================================================================================
*/
SELECT c.customer_type, s.payment_method, COUNT(*) AS transactions,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY c.customer_type), 2) AS segment_pct
FROM sales s JOIN customers c ON s.customer_id = c.customer_id
GROUP BY c.customer_type, s.payment_method
ORDER BY c.customer_type, segment_pct DESC;
--
-- RESULT 21: TOP 9 OF 9 ROWS
-- +---------------+----------------+--------------+-------------+
-- | customer_type | payment_method | transactions | segment_pct |
-- +---------------+----------------+--------------+-------------+
-- | Corporate     | Loan           | 4381         | 34.20       |
-- | Corporate     | Cash           | 4215         | 32.90       |
-- | Corporate     | Lease          | 4214         | 32.90       |
-- | Government    | Cash           | 4475         | 33.96       |
-- | Government    | Lease          | 4383         | 33.26       |
-- | Government    | Loan           | 4320         | 32.78       |
-- | Individual    | Cash           | 4777         | 34.09       |
-- | Individual    | Loan           | 4622         | 32.99       |
-- | Individual    | Lease          | 4613         | 32.92       |
-- +---------------+----------------+--------------+-------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 22: WILDCARD SEARCH FOR SUV-RELATED VEHICLE TYPES
----------------------------------------------------------------------------------------------------
INSIGHT: Demonstrates LIKE while summarizing the SUV portfolio.
====================================================================================================
*/
SELECT m.model_name, m.vehicle_type, SUM(s.quantity) AS units_sold,
       ROUND(SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)), 2) AS revenue
FROM models m JOIN sales s ON m.model_id = s.model_id
WHERE m.vehicle_type LIKE '%SUV%'
GROUP BY m.model_id, m.model_name, m.vehicle_type
ORDER BY revenue DESC;
--
-- RESULT 22: TOP 4 OF 4 ROWS
-- +------------+--------------+------------+--------------+
-- | model_name | vehicle_type | units_sold | revenue      |
-- +------------+--------------+------------+--------------+
-- | 4Runner    | SUV          | 6702       | 330765337.43 |
-- | Highlander | SUV          | 6543       | 285037814.19 |
-- | bZ4X       | Electric SUV | 6571       | 274579544.95 |
-- | RAV4       | SUV          | 6555       | 224664066.09 |
-- +------------+--------------+------------+--------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 23: WILDCARD SEARCH FOR MAINTENANCE-RELATED SERVICES
----------------------------------------------------------------------------------------------------
INSIGHT: Measures routine maintenance demand.
====================================================================================================
*/
SELECT sr.service_type, COUNT(*) AS service_visits,
       ROUND(AVG(sr.service_cost_usd), 2) AS avg_service_cost,
       ROUND(AVG(sr.satisfaction_score), 2) AS avg_satisfaction
FROM service_records sr
WHERE sr.service_type LIKE '%Maintenance%'
  AND sr.service_status NOT LIKE 'Cancel%'
GROUP BY sr.service_type;
--
-- RESULT 23: TOP 1 OF 1 ROWS
-- +-----------------------+----------------+------------------+------------------+
-- | service_type          | service_visits | avg_service_cost | avg_satisfaction |
-- +-----------------------+----------------+------------------+------------------+
-- | Scheduled Maintenance | 1374           | 788.62           | 5.43             |
-- +-----------------------+----------------+------------------+------------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 24: CURRENT IN-STOCK INVENTORY BY MODEL AND REGION
----------------------------------------------------------------------------------------------------
INSIGHT: Shows where available stock is concentrated.
====================================================================================================
*/
SELECT r.region_name, m.model_name, SUM(i.units_available) AS available_units,
       ROUND(SUM(i.units_available * i.cost_per_unit_usd), 2) AS inventory_cost
FROM inventory i
JOIN models m ON i.model_id = m.model_id
JOIN dealerships d ON i.dealership_id = d.dealership_id
JOIN regions r ON d.region_id = r.region_id
WHERE i.inventory_status = 'In Stock'
GROUP BY r.region_name, m.model_name
ORDER BY r.region_name, available_units DESC;
--
-- RESULT 24: TOP 10 OF 72 ROWS
-- +-------------+------------+-----------------+----------------+
-- | region_name | model_name | available_units | inventory_cost |
-- +-------------+------------+-----------------+----------------+
-- | Africa      | Highlander | 419             | 16652431.00    |
-- | Africa      | GR86       | 381             | 10787248.00    |
-- | Africa      | Tundra     | 375             | 18841179.00    |
-- | Africa      | Tacoma     | 356             | 12813810.00    |
-- | Africa      | bZ4X       | 349             | 13171270.00    |
-- | Africa      | Prius      | 305             | 8475162.00     |
-- | Africa      | Sienna     | 288             | 11740240.00    |
-- | Africa      | 4Runner    | 268             | 12051805.00    |
-- | Africa      | Corolla    | 265             | 5522588.00     |
-- | Africa      | Supra      | 245             | 11859025.00    |
-- +-------------+------------+-----------------+----------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 25: ESTIMATED MODEL SELL-THROUGH RATIO
----------------------------------------------------------------------------------------------------
INSIGHT: Compares sold units with sold plus currently available stock.
====================================================================================================
*/
WITH sold AS (
    SELECT model_id, SUM(quantity) AS sold_units FROM sales GROUP BY model_id
), stocked AS (
    SELECT model_id, SUM(units_available) AS stock_units
    FROM inventory WHERE inventory_status = 'In Stock' GROUP BY model_id
)
SELECT m.model_name, COALESCE(s.sold_units, 0) AS sold_units,
       COALESCE(i.stock_units, 0) AS stock_units,
       ROUND(100 * COALESCE(s.sold_units, 0) /
             NULLIF(COALESCE(s.sold_units, 0) + COALESCE(i.stock_units, 0), 0), 2) AS sell_through_pct
FROM models m
LEFT JOIN sold s ON m.model_id = s.model_id
LEFT JOIN stocked i ON m.model_id = i.model_id
ORDER BY sell_through_pct DESC;
--
-- RESULT 25: TOP 10 OF 12 ROWS
-- +------------+------------+-------------+------------------+
-- | model_name | sold_units | stock_units | sell_through_pct |
-- +------------+------------+-------------+------------------+
-- | Corolla    | 6720       | 1428        | 82.47            |
-- | Supra      | 6826       | 1570        | 81.30            |
-- | Sienna     | 6616       | 1524        | 81.28            |
-- | Prius      | 6514       | 1619        | 80.09            |
-- | RAV4       | 6555       | 1634        | 80.05            |
-- | GR86       | 6690       | 1667        | 80.05            |
-- | bZ4X       | 6571       | 1638        | 80.05            |
-- | Tacoma     | 6743       | 1758        | 79.32            |
-- | Tundra     | 6973       | 1844        | 79.09            |
-- | 4Runner    | 6702       | 1830        | 78.55            |
-- +------------+------------+-------------+------------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 26: INVENTORY VALUE RANKING WITHIN EACH REGION
----------------------------------------------------------------------------------------------------
INSIGHT: Highlights dealers carrying the most inventory investment locally.
====================================================================================================
*/
WITH dealer_inventory AS (
    SELECT r.region_name, d.dealership_name,
           SUM(i.units_available * i.cost_per_unit_usd) AS inventory_value
    FROM inventory i
    JOIN dealerships d ON i.dealership_id = d.dealership_id
    JOIN regions r ON d.region_id = r.region_id
    WHERE i.inventory_status = 'In Stock'
    GROUP BY r.region_name, d.dealership_name
)
SELECT region_name, dealership_name, ROUND(inventory_value, 2) AS inventory_value,
       DENSE_RANK() OVER (PARTITION BY region_name ORDER BY inventory_value DESC) AS inventory_rank
FROM dealer_inventory
ORDER BY region_name, inventory_rank;
--
-- RESULT 26: TOP 10 OF 120 ROWS
-- +-------------+-------------------+-----------------+----------------+
-- | region_name | dealership_name   | inventory_value | inventory_rank |
-- +-------------+-------------------+-----------------+----------------+
-- | Africa      | Toyota Center 030 | 11413502.00     | 1              |
-- | Africa      | Toyota Center 066 | 10211573.00     | 2              |
-- | Africa      | Toyota Center 042 | 9084236.00      | 3              |
-- | Africa      | Toyota Center 072 | 8939662.00      | 4              |
-- | Africa      | Toyota Center 006 | 8241951.00      | 5              |
-- | Africa      | Toyota Center 018 | 7092177.00      | 6              |
-- | Africa      | Toyota Center 090 | 7024064.00      | 7              |
-- | Africa      | Toyota Center 120 | 6873548.00      | 8              |
-- | Africa      | Toyota Center 084 | 6839458.00      | 9              |
-- | Africa      | Toyota Center 012 | 6625950.00      | 10             |
-- +-------------+-------------------+-----------------+----------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 27: AVERAGE TIME FROM SALE TO FIRST SERVICE
----------------------------------------------------------------------------------------------------
INSIGHT: Estimates how quickly customers return for after-sales service.
====================================================================================================
*/
WITH first_service AS (
    SELECT sale_id, MIN(service_date) AS first_service_date
    FROM service_records WHERE service_status = 'Completed' GROUP BY sale_id
)
SELECT m.model_name,
       ROUND(AVG(DATEDIFF(fs.first_service_date, s.sale_date)), 1) AS avg_days_to_first_service,
       COUNT(*) AS serviced_sales
FROM first_service fs
JOIN sales s ON fs.sale_id = s.sale_id
JOIN models m ON s.model_id = m.model_id
GROUP BY m.model_id, m.model_name
ORDER BY avg_days_to_first_service;
--
-- RESULT 27: TOP 10 OF 12 ROWS
-- +------------+---------------------------+----------------+
-- | model_name | avg_days_to_first_service | serviced_sales |
-- +------------+---------------------------+----------------+
-- | RAV4       | 429.4                     | 425            |
-- | 4Runner    | 438.2                     | 457            |
-- | Sienna     | 438.3                     | 444            |
-- | Prius      | 440.6                     | 379            |
-- | Corolla    | 443.2                     | 408            |
-- | Supra      | 445.5                     | 412            |
-- | bZ4X       | 447.6                     | 419            |
-- | Camry      | 450.4                     | 368            |
-- | GR86       | 451.2                     | 411            |
-- | Highlander | 451.6                     | 385            |
-- +------------+---------------------------+----------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 28: SERVICE SATISFACTION RANKING BY MODEL
----------------------------------------------------------------------------------------------------
INSIGHT: Compares after-sales experience across models.
====================================================================================================
*/
WITH satisfaction AS (
    SELECT m.model_name, COUNT(*) AS completed_services,
           AVG(sr.satisfaction_score) AS avg_score
    FROM service_records sr
    JOIN sales s ON sr.sale_id = s.sale_id
    JOIN models m ON s.model_id = m.model_id
    WHERE sr.service_status = 'Completed'
    GROUP BY m.model_id, m.model_name
)
SELECT model_name, completed_services, ROUND(avg_score, 2) AS avg_score,
       DENSE_RANK() OVER (ORDER BY avg_score DESC) AS satisfaction_rank
FROM satisfaction ORDER BY satisfaction_rank;
--
-- RESULT 28: TOP 10 OF 12 ROWS
-- +------------+--------------------+-----------+-------------------+
-- | model_name | completed_services | avg_score | satisfaction_rank |
-- +------------+--------------------+-----------+-------------------+
-- | RAV4       | 452                | 5.62      | 1                 |
-- | Corolla    | 431                | 5.61      | 2                 |
-- | Prius      | 416                | 5.61      | 3                 |
-- | Tacoma     | 411                | 5.58      | 4                 |
-- | Camry      | 391                | 5.52      | 5                 |
-- | Sienna     | 485                | 5.51      | 6                 |
-- | Highlander | 412                | 5.49      | 7                 |
-- | 4Runner    | 486                | 5.45      | 8                 |
-- | bZ4X       | 446                | 5.43      | 9                 |
-- | Tundra     | 466                | 5.39      | 10                |
-- +------------+--------------------+-----------+-------------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 29: DEALERSHIPS WITH BELOW-AVERAGE SATISFACTION BUT ABOVE-AVERAGE REVENUE
----------------------------------------------------------------------------------------------------
INSIGHT: Finds commercially strong locations with customer-experience risk.
====================================================================================================
*/
WITH dealer_metrics AS (
    SELECT d.dealership_id, d.dealership_name,
           SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)) AS revenue,
           AVG(sr.satisfaction_score) AS avg_satisfaction
    FROM dealerships d
    JOIN sales s ON d.dealership_id = s.dealership_id
    LEFT JOIN service_records sr ON s.sale_id = sr.sale_id AND sr.service_status = 'Completed'
    GROUP BY d.dealership_id, d.dealership_name
)
SELECT dealership_name, ROUND(revenue, 2) AS revenue,
       ROUND(avg_satisfaction, 2) AS avg_satisfaction
FROM dealer_metrics
WHERE revenue > (SELECT AVG(revenue) FROM dealer_metrics)
  AND avg_satisfaction < (SELECT AVG(avg_satisfaction) FROM dealer_metrics)
ORDER BY revenue DESC;
--
-- RESULT 29: TOP 10 OF 27 ROWS
-- +-------------------+-------------+------------------+
-- | dealership_name   | revenue     | avg_satisfaction |
-- +-------------------+-------------+------------------+
-- | Toyota Center 024 | 29754590.71 | 4.73             |
-- | Toyota Center 092 | 29581814.90 | 4.96             |
-- | Toyota Center 117 | 29362816.42 | 5.24             |
-- | Toyota Center 067 | 29254908.76 | 5.40             |
-- | Toyota Center 026 | 28896097.79 | 5.28             |
-- | Toyota Center 004 | 28831710.36 | 4.82             |
-- | Toyota Center 041 | 28806101.36 | 5.47             |
-- | Toyota Center 064 | 28560787.19 | 5.39             |
-- | Toyota Center 093 | 28440645.34 | 5.28             |
-- | Toyota Center 029 | 28256870.39 | 5.33             |
-- +-------------------+-------------+------------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 30: SERVICE COST AS A PERCENTAGE OF VEHICLE SALES REVENUE BY MODEL
----------------------------------------------------------------------------------------------------
INSIGHT: Compares after-sales service value with original sales value.
====================================================================================================
*/
WITH sales_value AS (
    SELECT model_id, SUM(quantity * unit_price_usd * (1 - discount_pct / 100)) AS revenue
    FROM sales GROUP BY model_id
), service_value AS (
    SELECT s.model_id, SUM(sr.service_cost_usd) AS service_cost
    FROM service_records sr JOIN sales s ON sr.sale_id = s.sale_id
    WHERE sr.service_status = 'Completed' GROUP BY s.model_id
)
SELECT m.model_name, ROUND(sv.revenue, 2) AS sales_revenue,
       ROUND(COALESCE(rv.service_cost, 0), 2) AS service_cost,
       ROUND(100 * COALESCE(rv.service_cost, 0) / NULLIF(sv.revenue, 0), 3) AS service_to_sales_pct
FROM models m
JOIN sales_value sv ON m.model_id = sv.model_id
LEFT JOIN service_value rv ON m.model_id = rv.model_id
ORDER BY service_to_sales_pct DESC;
--
-- RESULT 30: TOP 10 OF 12 ROWS
-- +------------+---------------+--------------+----------------------+
-- | model_name | sales_revenue | service_cost | service_to_sales_pct |
-- +------------+---------------+--------------+----------------------+
-- | Corolla    | 154182913.27  | 339860.00    | 0.220                |
-- | Prius      | 198491197.60  | 337505.00    | 0.170                |
-- | GR86       | 207015931.61  | 350926.00    | 0.170                |
-- | RAV4       | 224664066.09  | 356529.00    | 0.159                |
-- | Camry      | 196993377.63  | 302532.00    | 0.154                |
-- | Sienna     | 293866733.35  | 394033.00    | 0.134                |
-- | Tacoma     | 265368248.13  | 339198.00    | 0.128                |
-- | bZ4X       | 274579544.95  | 340776.00    | 0.124                |
-- | Highlander | 285037814.19  | 328121.00    | 0.115                |
-- | 4Runner    | 330765337.43  | 369538.00    | 0.112                |
-- +------------+---------------+--------------+----------------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 31: QUARTERLY REVENUE PIVOT USING CONDITIONAL AGGREGATION
----------------------------------------------------------------------------------------------------
INSIGHT: Places quarterly results side by side for year-level comparison.
====================================================================================================
*/
SELECT YEAR(sale_date) AS sales_year,
       ROUND(SUM(CASE WHEN QUARTER(sale_date) = 1 THEN quantity * unit_price_usd * (1-discount_pct/100) ELSE 0 END), 2) AS q1_revenue,
       ROUND(SUM(CASE WHEN QUARTER(sale_date) = 2 THEN quantity * unit_price_usd * (1-discount_pct/100) ELSE 0 END), 2) AS q2_revenue,
       ROUND(SUM(CASE WHEN QUARTER(sale_date) = 3 THEN quantity * unit_price_usd * (1-discount_pct/100) ELSE 0 END), 2) AS q3_revenue,
       ROUND(SUM(CASE WHEN QUARTER(sale_date) = 4 THEN quantity * unit_price_usd * (1-discount_pct/100) ELSE 0 END), 2) AS q4_revenue
FROM sales GROUP BY YEAR(sale_date) ORDER BY sales_year;
--
-- RESULT 31: TOP 5 OF 5 ROWS
-- +------------+--------------+--------------+--------------+--------------+
-- | sales_year | q1_revenue   | q2_revenue   | q3_revenue   | q4_revenue   |
-- +------------+--------------+--------------+--------------+--------------+
-- | 2021       | 151611819.33 | 166225841.18 | 155947262.80 | 161086476.67 |
-- | 2022       | 156668334.80 | 152905593.30 | 158922387.91 | 162022229.56 |
-- | 2023       | 153387628.92 | 161035480.21 | 164440094.64 | 156596052.07 |
-- | 2024       | 157353679.81 | 162664057.78 | 160758579.73 | 161932360.02 |
-- | 2025       | 158662507.72 | 159414723.23 | 159332480.78 | 160280086.24 |
-- +------------+--------------+--------------+--------------+--------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 32: BEST MONTH IN EACH YEAR
----------------------------------------------------------------------------------------------------
INSIGHT: Identifies the peak sales month annually.
====================================================================================================
*/
WITH monthly AS (
    SELECT YEAR(sale_date) AS sales_year, MONTH(sale_date) AS month_no,
           MONTHNAME(sale_date) AS month_name,
           SUM(quantity * unit_price_usd * (1 - discount_pct / 100)) AS revenue
    FROM sales GROUP BY YEAR(sale_date), MONTH(sale_date), MONTHNAME(sale_date)
), ranked AS (
    SELECT *, RANK() OVER (PARTITION BY sales_year ORDER BY revenue DESC) AS month_rank
    FROM monthly
)
SELECT sales_year, month_no, month_name, ROUND(revenue, 2) AS revenue
FROM ranked WHERE month_rank = 1 ORDER BY sales_year;
--
-- RESULT 32: TOP 5 OF 5 ROWS
-- +------------+----------+------------+-------------+
-- | sales_year | month_no | month_name | revenue     |
-- +------------+----------+------------+-------------+
-- | 2021       | 4        | April      | 57385416.19 |
-- | 2022       | 10       | October    | 58918514.94 |
-- | 2023       | 8        | August     | 58442926.92 |
-- | 2024       | 12       | December   | 58001161.01 |
-- | 2025       | 3        | March      | 57294590.24 |
-- +------------+----------+------------+-------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 33: REVENUE PERCENTILE FOR EVERY DEALERSHIP
----------------------------------------------------------------------------------------------------
INSIGHT: Places dealerships into performance quartiles.
====================================================================================================
*/
WITH dealer_revenue AS (
    SELECT d.dealership_name,
           SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)) AS revenue
    FROM dealerships d JOIN sales s ON d.dealership_id = s.dealership_id
    GROUP BY d.dealership_id, d.dealership_name
)
SELECT dealership_name, ROUND(revenue, 2) AS revenue,
       ROUND(100 * PERCENT_RANK() OVER (ORDER BY revenue), 2) AS percentile_rank,
       NTILE(4) OVER (ORDER BY revenue DESC) AS performance_quartile
FROM dealer_revenue ORDER BY revenue DESC;
--
-- RESULT 33: TOP 10 OF 120 ROWS
-- +-------------------+-------------+-----------------+----------------------+
-- | dealership_name   | revenue     | percentile_rank | performance_quartile |
-- +-------------------+-------------+-----------------+----------------------+
-- | Toyota Center 070 | 31029661.50 | 100             | 1                    |
-- | Toyota Center 024 | 29494307.06 | 99.16           | 1                    |
-- | Toyota Center 013 | 29318315.40 | 98.32           | 1                    |
-- | Toyota Center 067 | 29254908.76 | 97.48           | 1                    |
-- | Toyota Center 072 | 29201840.01 | 96.64           | 1                    |
-- | Toyota Center 074 | 29093860.40 | 95.8            | 1                    |
-- | Toyota Center 092 | 28879575.41 | 94.96           | 1                    |
-- | Toyota Center 087 | 28864585.71 | 94.12           | 1                    |
-- | Toyota Center 004 | 28800091.14 | 93.28           | 1                    |
-- | Toyota Center 041 | 28683247.21 | 92.44           | 1                    |
-- +-------------------+-------------+-----------------+----------------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 34: REVENUE DIFFERENCE FROM REGIONAL LEADER
----------------------------------------------------------------------------------------------------
INSIGHT: Quantifies the gap each dealership must close to lead its region.
====================================================================================================
*/
WITH dealer_revenue AS (
    SELECT r.region_name, d.dealership_name,
           SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)) AS revenue
    FROM sales s
    JOIN dealerships d ON s.dealership_id = d.dealership_id
    JOIN regions r ON d.region_id = r.region_id
    GROUP BY r.region_name, d.dealership_name
)
SELECT region_name, dealership_name, ROUND(revenue, 2) AS revenue,
       ROUND(MAX(revenue) OVER (PARTITION BY region_name) - revenue, 2) AS gap_from_region_leader
FROM dealer_revenue ORDER BY region_name, gap_from_region_leader;
--
-- RESULT 34: TOP 10 OF 120 ROWS
-- +-------------+-------------------+-------------+------------------------+
-- | region_name | dealership_name   | revenue     | gap_from_region_leader |
-- +-------------+-------------------+-------------+------------------------+
-- | Africa      | Toyota Center 024 | 29494307.06 | 0.00                   |
-- | Africa      | Toyota Center 072 | 29201840.01 | 292467.05              |
-- | Africa      | Toyota Center 108 | 27929710.64 | 1564596.42             |
-- | Africa      | Toyota Center 090 | 27694460.40 | 1799846.66             |
-- | Africa      | Toyota Center 054 | 27653177.75 | 1841129.31             |
-- | Africa      | Toyota Center 006 | 27646801.87 | 1847505.19             |
-- | Africa      | Toyota Center 096 | 27631356.18 | 1862950.88             |
-- | Africa      | Toyota Center 060 | 27527130.73 | 1967176.33             |
-- | Africa      | Toyota Center 012 | 27124052.20 | 2370254.86             |
-- | Africa      | Toyota Center 048 | 27057212.51 | 2437094.55             |
-- +-------------+-------------------+-------------+------------------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 35: MODELS PURCHASED IN EVERY REGION USING RELATIONAL DIVISION
----------------------------------------------------------------------------------------------------
INSIGHT: Finds models with truly broad geographic reach.
====================================================================================================
*/
SELECT m.model_name
FROM models m
WHERE NOT EXISTS (
    SELECT 1 FROM regions r
    WHERE NOT EXISTS (
        SELECT 1
        FROM sales s JOIN dealerships d ON s.dealership_id = d.dealership_id
        WHERE s.model_id = m.model_id AND d.region_id = r.region_id
    )
);
--
-- RESULT 35: TOP 10 OF 12 ROWS
-- +------------+
-- | model_name |
-- +------------+
-- | Corolla    |
-- | Camry      |
-- | Prius      |
-- | RAV4       |
-- | Highlander |
-- | 4Runner    |
-- | Tacoma     |
-- | Tundra     |
-- | Sienna     |
-- | GR86       |
-- +------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 36: RECURSIVE CTE CALENDAR WITH MONTHLY REVENUE, INCLUDING EMPTY MONTHS
----------------------------------------------------------------------------------------------------
INSIGHT: Prevents missing months from disappearing from trend reporting.
====================================================================================================
*/
WITH RECURSIVE calendar AS (
    SELECT
        DATE_FORMAT(MIN(sale_date), '%Y-%m-01') + INTERVAL 0 DAY
            AS month_start
    FROM sales

    UNION ALL

    SELECT month_start + INTERVAL 1 MONTH
    FROM calendar
    WHERE month_start + INTERVAL 1 MONTH <= (
        SELECT
            DATE_FORMAT(MAX(sale_date), '%Y-%m-01') + INTERVAL 0 DAY
        FROM sales
    )
),
monthly AS (
    SELECT
        DATE_FORMAT(sale_date, '%Y-%m-01') + INTERVAL 0 DAY
            AS month_start,
        SUM(
            quantity * unit_price_usd *
            (1 - discount_pct / 100)
        ) AS revenue
    FROM sales
    GROUP BY
        DATE_FORMAT(sale_date, '%Y-%m-01') + INTERVAL 0 DAY
)
SELECT
    DATE_FORMAT(c.month_start, '%Y-%m') AS sales_month,
    ROUND(COALESCE(m.revenue, 0), 2) AS revenue
FROM calendar AS c
LEFT JOIN monthly AS m
    ON c.month_start = m.month_start
ORDER BY c.month_start;
--
-- RESULT 36: TOP 10 OF 60 ROWS
-- +-------------+-------------+
-- | sales_month | revenue     |
-- +-------------+-------------+
-- | 2021-01     | 50473867.78 |
-- | 2021-02     | 47271601.40 |
-- | 2021-03     | 53866350.15 |
-- | 2021-04     | 57385416.19 |
-- | 2021-05     | 56221976.54 |
-- | 2021-06     | 52618448.44 |
-- | 2021-07     | 54408751.71 |
-- | 2021-08     | 51957781.85 |
-- | 2021-09     | 49580729.25 |
-- | 2021-10     | 50944350.09 |
-- +-------------+-------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 37: POTENTIAL DATA ANOMALIES USING CASE AND MULTIPLE CONDITIONS
----------------------------------------------------------------------------------------------------
INSIGHT: Flags records requiring data-quality review.
====================================================================================================
*/
SELECT sale_id, sale_date, quantity, unit_price_usd, discount_pct,
       CASE
           WHEN quantity <= 0 THEN 'Invalid quantity'
           WHEN unit_price_usd <= 0 THEN 'Invalid price'
           WHEN discount_pct NOT BETWEEN 0 AND 100 THEN 'Invalid discount'
           WHEN unit_price_usd > 1.5 * (SELECT base_price_usd FROM models WHERE model_id = sales.model_id) THEN 'Unusually high price'
           WHEN unit_price_usd < 0.7 * (SELECT base_price_usd FROM models WHERE model_id = sales.model_id) THEN 'Unusually low price'
           ELSE 'Review'
       END AS anomaly_reason
FROM sales
WHERE quantity <= 0 OR unit_price_usd <= 0 OR discount_pct NOT BETWEEN 0 AND 100
   OR unit_price_usd > 1.5 * (SELECT base_price_usd FROM models WHERE model_id = sales.model_id)
   OR unit_price_usd < 0.7 * (SELECT base_price_usd FROM models WHERE model_id = sales.model_id);
--
-- RESULT 37: TOP 0 OF 0 ROWS
-- (No rows returned)
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 39: REVENUE CONCENTRATION AMONG THE TOP FIVE MODELS
----------------------------------------------------------------------------------------------------
INSIGHT: Measures dependency on the best-selling product group.
====================================================================================================
*/
WITH model_revenue AS (
    SELECT m.model_name,
           SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)) AS revenue
    FROM sales s JOIN models m ON s.model_id = m.model_id
    GROUP BY m.model_id, m.model_name
), ranked AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY revenue DESC) AS rn FROM model_revenue
)
SELECT ROUND(SUM(CASE WHEN rn <= 5 THEN revenue ELSE 0 END), 2) AS top_5_revenue,
       ROUND(SUM(revenue), 2) AS total_revenue,
       ROUND(100 * SUM(CASE WHEN rn <= 5 THEN revenue ELSE 0 END) / SUM(revenue), 2) AS top_5_concentration_pct
FROM ranked;
--
-- RESULT 38: TOP 1 OF 1 ROWS
-- +---------------+---------------+-------------------------+
-- | top_5_revenue | total_revenue | top_5_concentration_pct |
-- +---------------+---------------+-------------------------+
-- | 1659952397.40 | 3181247676.69 | 52.18                   |
-- +---------------+---------------+-------------------------+
-- ----------------------------------------------------------------------------------------------------------------------------
/*
====================================================================================================
QUERY 39: EXECUTIVE KPI SUMMARY BY YEAR WITH GROWTH AND CUSTOMER REACH
----------------------------------------------------------------------------------------------------
INSIGHT: Combines the most important annual indicators into one report.
====================================================================================================
*/
WITH yearly AS (
    SELECT YEAR(s.sale_date) AS sales_year,
           COUNT(DISTINCT s.sale_id) AS transactions,
           SUM(s.quantity) AS units_sold,
           SUM(s.quantity * s.unit_price_usd * (1 - s.discount_pct / 100)) AS revenue,
           COUNT(DISTINCT s.customer_id) AS active_customers,
           COUNT(DISTINCT s.dealership_id) AS active_dealerships,
           AVG(s.discount_pct) AS avg_discount_pct
    FROM sales s GROUP BY YEAR(s.sale_date)
), final AS (
    SELECT *, LAG(revenue) OVER (ORDER BY sales_year) AS prior_revenue
    FROM yearly
)
SELECT sales_year, transactions, units_sold, ROUND(revenue, 2) AS revenue,
       ROUND(100 * (revenue - prior_revenue) / NULLIF(prior_revenue, 0), 2) AS yoy_growth_pct,
       active_customers, active_dealerships,
       ROUND(revenue / NULLIF(active_customers, 0), 2) AS revenue_per_customer,
       ROUND(avg_discount_pct, 2) AS avg_discount_pct
FROM final ORDER BY sales_year;
--
-- RESULT 39: TOP 5 OF 5 ROWS
-- +------------+--------------+------------+--------------+----------------+------------------+--------------------+----------------------+------------------+
-- | sales_year | transactions | units_sold | revenue      | yoy_growth_pct | active_customers | active_dealerships | revenue_per_customer | avg_discount_pct |
-- +------------+--------------+------------+--------------+----------------+------------------+--------------------+----------------------+------------------+
-- | 2021       | 8015         | 16052      | 634871399.98 | NULL           | 5116             | 120                | 124095.27            | 6.24             |
-- | 2022       | 7923         | 15879      | 630518545.58 | -0.69          | 5012             | 120                | 125801.78            | 6.29             |
-- | 2023       | 8002         | 16005      | 635459255.84 | 0.78           | 5042             | 120                | 126033.17            | 6.19             |
-- | 2024       | 8066         | 16124      | 642708677.34 | 1.14           | 5059             | 120                | 127042.63            | 6.28             |
-- | 2025       | 7994         | 16070      | 637689797.97 | -0.78          | 5053             | 120                | 126200.24            | 6.23             |
-- +------------+--------------+------------+--------------+----------------+------------------+--------------------+----------------------+------------------+
-- ----------------------------------------------------------------------------------------------------------------------------
