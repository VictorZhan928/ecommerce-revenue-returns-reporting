SET search_path TO retail_reporting;

-- Executive KPI reconciliation.
SELECT
    ROUND(SUM(signed_value), 2) AS completed_revenue,
    COUNT(DISTINCT invoice_no) AS completed_orders,
    ROUND(SUM(signed_value) / NULLIF(COUNT(DISTINCT invoice_no), 0), 2) AS average_order_value,
    SUM(quantity) AS units_sold,
    COUNT(DISTINCT customer_id) AS active_identified_customers
FROM vw_completed_sales;

-- Peak completed-revenue month. December 2011 is partial through December 9.
SELECT order_month, ROUND(completed_revenue, 2) AS completed_revenue
FROM vw_monthly_performance
ORDER BY completed_revenue DESC
LIMIT 1;

-- Largest international markets.
SELECT country, ROUND(completed_revenue, 2) AS completed_revenue,
       completed_orders, ROUND(average_order_value, 2) AS average_order_value
FROM vw_country_performance
WHERE country <> 'United Kingdom'
ORDER BY completed_revenue DESC
LIMIT 10;

-- Highest-revenue merchandise products.
SELECT stock_code, description, ROUND(completed_revenue, 2) AS completed_revenue,
       units_sold, ROUND(unit_cancellation_rate * 100, 2) AS cancellation_rate_pct
FROM vw_product_performance
ORDER BY completed_revenue DESC
LIMIT 10;

-- Monthly cancellations and their value.
SELECT order_month, cancelled_orders,
       ROUND(cancellation_value, 2) AS cancellation_value,
       ROUND(cancellation_rate * 100, 2) AS cancellation_rate_pct
FROM vw_monthly_performance
ORDER BY order_month;

-- Data-quality conditions that materially affect reporting coverage.
SELECT check_name, affected_rows,
       ROUND(affected_rate * 100, 2) AS affected_rate_pct
FROM vw_data_quality
ORDER BY affected_rows DESC;

-- Peak weekday and hour for completed revenue.
SELECT weekday, ROUND(SUM(completed_revenue), 2) AS completed_revenue
FROM vw_time_performance
GROUP BY weekday, weekday_number
ORDER BY completed_revenue DESC
LIMIT 1;

SELECT order_hour, ROUND(SUM(completed_revenue), 2) AS completed_revenue
FROM vw_time_performance
GROUP BY order_hour
ORDER BY completed_revenue DESC
LIMIT 1;

