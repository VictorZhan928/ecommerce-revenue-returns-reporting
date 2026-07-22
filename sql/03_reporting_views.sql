SET search_path TO retail_reporting;

CREATE OR REPLACE VIEW vw_monthly_performance AS
WITH sales AS (
    SELECT
        order_month,
        SUM(signed_value) AS completed_revenue,
        COUNT(DISTINCT invoice_no) AS completed_orders,
        SUM(quantity) AS units_sold,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM vw_completed_sales
    GROUP BY order_month
), cancellations AS (
    SELECT
        order_month,
        COUNT(DISTINCT invoice_no) AS cancelled_orders,
        SUM(cancellation_value) AS cancellation_value
    FROM vw_cancellations
    GROUP BY order_month
), combined AS (
    SELECT
        s.order_month,
        s.completed_revenue,
        s.completed_orders,
        s.units_sold,
        s.completed_revenue / NULLIF(s.completed_orders, 0) AS average_order_value,
        s.active_customers,
        COALESCE(c.cancelled_orders, 0) AS cancelled_orders,
        COALESCE(c.cancellation_value, 0) AS cancellation_value,
        COALESCE(c.cancelled_orders, 0)::numeric /
            NULLIF(s.completed_orders + COALESCE(c.cancelled_orders, 0), 0) AS cancellation_rate
    FROM sales s
    LEFT JOIN cancellations c USING (order_month)
)
SELECT
    *,
    (completed_revenue - LAG(completed_revenue) OVER (ORDER BY order_month)) /
        NULLIF(LAG(completed_revenue) OVER (ORDER BY order_month), 0) AS revenue_mom_change
FROM combined
ORDER BY order_month;

CREATE OR REPLACE VIEW vw_country_performance AS
WITH country_sales AS (
    SELECT
        country,
        SUM(signed_value) AS completed_revenue,
        COUNT(DISTINCT invoice_no) AS completed_orders,
        SUM(quantity) AS units_sold,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM vw_completed_sales
    GROUP BY country
)
SELECT
    *,
    completed_revenue / NULLIF(completed_orders, 0) AS average_order_value,
    completed_revenue / NULLIF(SUM(completed_revenue) OVER (), 0) AS revenue_share,
    DENSE_RANK() OVER (ORDER BY completed_revenue DESC) AS revenue_rank
FROM country_sales
ORDER BY completed_revenue DESC;

CREATE OR REPLACE VIEW vw_product_performance AS
WITH sales AS (
    SELECT
        stock_code,
        MAX(description) AS description,
        SUM(signed_value) AS completed_revenue,
        SUM(quantity) AS units_sold,
        COUNT(DISTINCT invoice_no) AS completed_orders
    FROM vw_completed_sales
    WHERE stock_code NOT IN
        ('M','POST','DOT','D','C2','BANK CHARGES','AMAZONFEE','CRUK','PADS','B','S')
      AND description IS NOT NULL
    GROUP BY stock_code
), cancellations AS (
    SELECT
        stock_code,
        ABS(SUM(quantity)) AS cancelled_units,
        SUM(cancellation_value) AS cancellation_value,
        COUNT(DISTINCT invoice_no) AS cancelled_orders
    FROM vw_cancellations
    GROUP BY stock_code
)
SELECT
    s.*,
    COALESCE(c.cancelled_units, 0) AS cancelled_units,
    COALESCE(c.cancellation_value, 0) AS cancellation_value,
    COALESCE(c.cancelled_orders, 0) AS cancelled_orders,
    COALESCE(c.cancelled_units, 0)::numeric /
        NULLIF(s.units_sold + COALESCE(c.cancelled_units, 0), 0) AS unit_cancellation_rate,
    DENSE_RANK() OVER (ORDER BY s.completed_revenue DESC) AS revenue_rank
FROM sales s
LEFT JOIN cancellations c USING (stock_code)
ORDER BY s.completed_revenue DESC;

CREATE OR REPLACE VIEW vw_customer_performance AS
SELECT
    customer_id,
    MAX(country) AS country,
    SUM(signed_value) AS completed_revenue,
    COUNT(DISTINCT invoice_no) AS completed_orders,
    SUM(quantity) AS units_sold,
    SUM(signed_value) / NULLIF(COUNT(DISTINCT invoice_no), 0) AS average_order_value,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DENSE_RANK() OVER (ORDER BY SUM(signed_value) DESC) AS revenue_rank
FROM vw_completed_sales
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY completed_revenue DESC;

CREATE OR REPLACE VIEW vw_time_performance AS
SELECT
    weekday_number,
    TO_CHAR(order_date, 'FMDay') AS weekday,
    order_hour,
    SUM(signed_value) AS completed_revenue,
    COUNT(DISTINCT invoice_no) AS completed_orders,
    SUM(quantity) AS units_sold
FROM vw_completed_sales
GROUP BY weekday_number, TO_CHAR(order_date, 'FMDay'), order_hour
ORDER BY weekday_number, order_hour;

