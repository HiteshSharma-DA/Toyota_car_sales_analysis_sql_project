# Toyota Car Sales Analytics — SQL

An end-to-end data analytics portfolio project built with **MySQL. The project uses a relational Toyota car sales database containing **60,000 synthetic records** to answer business questions about revenue, products, customers, dealerships, inventory, employees, and after-sales service.

> **Disclaimer:** This project uses synthetic educational data and is not affiliated with Toyota Motor Corporation.

## Project objectives

- Design and analyse a normalized relational sales database.
- Use SQL joins, CTEs, subqueries, window functions, and aggregations.
- Measure sales performance through business KPIs.
- Discover product, customer, dealership, and regional trends.
- Present clear, data-supported business recommendations.

## Executive summary

| KPI | Result |
|---|---:|
| Sales transactions | 40,000 |
| Units sold | 80,130 |
| Net revenue | $3.18 billion |
| Average discount | 6.24% |
| Analysis period | 2021–2025 |
| Highest-revenue model | Tundra |
| Tundra revenue | $385.44 million |
| Highest-revenue region | Africa |
| Africa revenue | $542.29 million |

Net revenue is calculated as:

```text
quantity × unit_price_usd × (1 − discount_pct / 100)
```

## Database design

The project uses eight related tables:

| Table | Purpose | Rows |
|---|---|---:|
| `regions` | Geographic sales regions | 6 |
| `models` | Toyota model catalogue and base prices | 12 |
| `dealerships` | Dealership locations linked to regions | 120 |
| `employees` | Sales employees linked to dealerships | 600 |
| `customers` | Individual, corporate, and government customers | 8,000 |
| `sales` | Vehicle sales transactions | 40,000 |
| `inventory` | Model stock held by dealerships | 4,262 |
| `service_records` | After-sales service activity | 7,000 |

### Main relationships

```text
regions ──< dealerships ──< employees
    │             │
    │             ├──< inventory >── models
    │             │
    └──< customers ──< sales >────── models
                         │
                         └──< service_records
```

## Tools and technologies

- **MySQL 8:** database storage and business analysis
- **MySQL Workbench:** query development and validation

The analysis file contains **39 business insight queries**, including:

- Full transaction view using six-table joins
- Model revenue and contribution percentage
- Top three models in every region
- Dealership ranking within each region
- Year-over-year and month-over-month growth
- Rolling averages and running revenue totals
- Employee and dealership performance
- High-value customers and customer RFM metrics
- Repeat versus one-time customers
- Discount-band and payment-method performance
- Inventory availability, value, and sell-through
- Service satisfaction and time to first service
- Quarterly revenue pivot
- Data-quality anomaly detection
- Executive annual KPI summary

### SQL techniques demonstrated

- Multi-table `INNER JOIN` and `LEFT JOIN`
- Common table expressions and recursive CTEs
- Correlated and non-correlated subqueries
- `RANK`, `DENSE_RANK`, `ROW_NUMBER`, `NTILE`, and `PERCENT_RANK`
- `LAG`, running totals, and rolling averages
- Conditional aggregation and `CASE`
- `NOT EXISTS` and relational division
- Date functions and growth calculations
- Data-quality validation

## Key findings

- The database records **80,130 units sold** across **40,000 transactions**.
- Total net revenue is approximately **$3.18 billion** during 2021–2025.
- **Tundra** is the highest-revenue model, generating approximately **$385.44 million**.
- **Africa** is the highest-revenue region, generating approximately **$542.29 million**.
- The average transaction discount is **6.24%**.
- Regional rankings reveal different model preferences and dealership performance levels.
- Customer segmentation identifies high-value, repeat, inactive, and multi-model customers.
- Inventory and service analysis connects sales with stock availability and after-sales satisfaction.

## Repository files

```text
Toyota-car-sales-project/
│
├── README.md
├── 01_create_schema.sql
├── 02_load_data.sql
└── 03_Toyota_car_sales_analytics.sql
```

| File | Description |
|---|---|
| `01_create_schema.sql` | Creates the database, tables, keys, and relationships |
| `02_load_data.sql` | Loads all 60,000 synthetic records |
| `03_Toyota_car_sales_analytics.sql` | Contains 39 documented business queries and sample results |

## How to run the project

### 1. Create the database

Run `01_create_schema.sql` in MySQL Workbench or SQLTools.

### 2. Load the data

After the schema finishes, run `02_load_data.sql`.

### 3. Validate the database

```sql
USE toyota_car_sales_analysis;

SHOW TABLES;

SELECT COUNT(*) AS sales_rows
FROM sales;
```

The final query should return `40000`.

### 4. Run the SQL analysis

Open `Toyota_car_sales_analytics.sql` and execute queries individually.


## Author

**Hitesh Sharma**  
Aspiring Data Analyst 