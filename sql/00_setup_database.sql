-- Database Setup Script
-- This script creates the initial database schema and loads the raw data

-- ============================================
-- Create loans_raw table
-- ============================================

DROP TABLE IF EXISTS loans_raw;

CREATE TABLE loans_raw (
    loan_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10) NOT NULL,
    loan_amount DECIMAL(10,2) NOT NULL,
    interest_rate DECIMAL(5,2) NOT NULL,
    loan_term INTEGER NOT NULL,
    monthly_payment DECIMAL(10,2) NOT NULL,
    loan_status VARCHAR(50) NOT NULL,
    purpose VARCHAR(100) NOT NULL,
    credit_score INTEGER,
    annual_income DECIMAL(10,2),
    employment_length INTEGER,
    debt_to_income DECIMAL(5,4),
    application_date DATE,
    approval_date DATE,
    disbursement_date DATE
);

-- ============================================
-- Note: Data Import
-- ============================================
-- To import data from CSV file, use SQLite command:
-- .mode csv
-- .import data/loan_data.csv loans_raw
-- 
-- Or for PostgreSQL:
-- COPY loans_raw FROM '/path/to/loan_data.csv' DELIMITER ',' CSV HEADER;
--
-- Or for MySQL:
-- LOAD DATA INFILE '/path/to/loan_data.csv'
-- INTO TABLE loans_raw
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;

-- ============================================
-- Verify data import
-- ============================================

SELECT COUNT(*) AS total_records FROM loans_raw;
SELECT * FROM loans_raw LIMIT 5;
