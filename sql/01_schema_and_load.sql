-- E-Commerce Revenue & Returns Reporting
-- PostgreSQL 14+

CREATE SCHEMA IF NOT EXISTS retail_reporting;
SET search_path TO retail_reporting;

DROP TABLE IF EXISTS retail_transactions;

CREATE TABLE retail_transactions (
    transaction_id BIGSERIAL PRIMARY KEY,
    invoice_no      VARCHAR(20),
    stock_code      VARCHAR(30),
    description     TEXT,
    quantity        INTEGER,
    invoice_date    TIMESTAMP,
    unit_price      NUMERIC(14, 4),
    customer_id     VARCHAR(20),
    country         VARCHAR(100),
    source_year     VARCHAR(30)
);

-- Export both UCI workbook sheets as CSV files, then load each file.
-- Update the paths before running these commands in psql.
--
-- \copy retail_transactions(invoice_no, stock_code, description, quantity,
--     invoice_date, unit_price, customer_id, country)
-- FROM 'online_retail_2009_2010.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
--
-- \copy retail_transactions(invoice_no, stock_code, description, quantity,
--     invoice_date, unit_price, customer_id, country)
-- FROM 'online_retail_2010_2011.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');

CREATE INDEX idx_retail_invoice_date ON retail_transactions (invoice_date);
CREATE INDEX idx_retail_invoice_no ON retail_transactions (invoice_no);
CREATE INDEX idx_retail_stock_code ON retail_transactions (stock_code);
CREATE INDEX idx_retail_customer_id ON retail_transactions (customer_id);
CREATE INDEX idx_retail_country ON retail_transactions (country);

