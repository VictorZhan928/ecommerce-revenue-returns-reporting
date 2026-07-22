SET search_path TO retail_reporting;

CREATE OR REPLACE VIEW vw_clean_transactions AS
SELECT
    transaction_id,
    NULLIF(BTRIM(invoice_no), '') AS invoice_no,
    NULLIF(BTRIM(stock_code), '') AS stock_code,
    NULLIF(BTRIM(description), '') AS description,
    quantity,
    invoice_date,
    invoice_date::date AS order_date,
    DATE_TRUNC('month', invoice_date)::date AS order_month,
    EXTRACT(ISODOW FROM invoice_date)::integer AS weekday_number,
    EXTRACT(HOUR FROM invoice_date)::integer AS order_hour,
    unit_price,
    NULLIF(BTRIM(customer_id), '') AS customer_id,
    NULLIF(BTRIM(country), '') AS country,
    quantity * unit_price AS signed_value,
    CASE
        WHEN UPPER(invoice_no) LIKE 'C%' OR quantity < 0 THEN 'Cancellation'
        WHEN quantity > 0 AND unit_price > 0 THEN 'Completed Sale'
        ELSE 'Excluded'
    END AS transaction_status
FROM retail_transactions;

CREATE OR REPLACE VIEW vw_completed_sales AS
SELECT *
FROM vw_clean_transactions
WHERE transaction_status = 'Completed Sale';

CREATE OR REPLACE VIEW vw_cancellations AS
SELECT
    *,
    ABS(signed_value) AS cancellation_value
FROM vw_clean_transactions
WHERE transaction_status = 'Cancellation';

-- A compact quality scorecard used by Excel and Power BI.
CREATE OR REPLACE VIEW vw_data_quality AS
WITH totals AS (
    SELECT COUNT(*)::numeric AS total_rows
    FROM retail_transactions
), checks AS (
    SELECT 'Missing customer ID' AS check_name, COUNT(*)::numeric AS affected_rows
    FROM retail_transactions
    WHERE customer_id IS NULL OR BTRIM(customer_id) = ''

    UNION ALL
    SELECT 'Missing description', COUNT(*)::numeric
    FROM retail_transactions
    WHERE description IS NULL OR BTRIM(description) = ''

    UNION ALL
    SELECT 'Zero or negative unit price', COUNT(*)::numeric
    FROM retail_transactions
    WHERE unit_price <= 0

    UNION ALL
    SELECT 'Zero quantity', COUNT(*)::numeric
    FROM retail_transactions
    WHERE quantity = 0

    UNION ALL
    SELECT 'Cancellation or negative quantity', COUNT(*)::numeric
    FROM retail_transactions
    WHERE UPPER(invoice_no) LIKE 'C%' OR quantity < 0

    UNION ALL
    SELECT 'Exact duplicate rows', COALESCE(SUM(duplicate_count - 1), 0)::numeric
    FROM (
        SELECT COUNT(*) AS duplicate_count
        FROM retail_transactions
        GROUP BY invoice_no, stock_code, description, quantity,
                 invoice_date, unit_price, customer_id, country
        HAVING COUNT(*) > 1
    ) duplicates
)
SELECT
    check_name,
    affected_rows::bigint,
    affected_rows / NULLIF(total_rows, 0) AS affected_rate
FROM checks
CROSS JOIN totals
ORDER BY affected_rows DESC;

