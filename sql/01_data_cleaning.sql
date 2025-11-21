-- Data Cleaning Script for Loan Data
-- This script prepares the raw loan data for analysis

-- ============================================
-- Step 1: Create a clean loan table
-- ============================================

DROP TABLE IF EXISTS loans_clean;

CREATE TABLE loans_clean AS
SELECT 
    loan_id,
    customer_id,
    loan_amount,
    interest_rate,
    loan_term,
    monthly_payment,
    loan_status,
    purpose,
    credit_score,
    annual_income,
    employment_length,
    debt_to_income,
    application_date,
    approval_date,
    disbursement_date
FROM loans_raw;

-- ============================================
-- Step 2: Remove duplicate records
-- ============================================

DELETE FROM loans_clean
WHERE loan_id NOT IN (
    SELECT MIN(loan_id)
    FROM loans_clean
    GROUP BY customer_id, loan_amount, application_date
);

-- ============================================
-- Step 3: Handle missing values
-- ============================================

-- Remove records with missing critical fields
DELETE FROM loans_clean
WHERE loan_id IS NULL 
   OR customer_id IS NULL
   OR loan_amount IS NULL
   OR loan_status IS NULL;

-- Fill missing credit scores with median value
UPDATE loans_clean
SET credit_score = (
    SELECT CAST(AVG(credit_score) AS INTEGER)
    FROM loans_clean
    WHERE credit_score IS NOT NULL
)
WHERE credit_score IS NULL;

-- Fill missing employment length with 0
UPDATE loans_clean
SET employment_length = 0
WHERE employment_length IS NULL;

-- ============================================
-- Step 4: Standardize data formats
-- ============================================

-- Standardize loan status values
UPDATE loans_clean
SET loan_status = CASE
    WHEN UPPER(loan_status) LIKE '%FULLY%PAID%' THEN 'Fully Paid'
    WHEN UPPER(loan_status) LIKE '%CURRENT%' THEN 'Current'
    WHEN UPPER(loan_status) LIKE '%CHARGED%OFF%' THEN 'Charged Off'
    WHEN UPPER(loan_status) LIKE '%LATE%31%120%' THEN 'Late (31-120 days)'
    WHEN UPPER(loan_status) LIKE '%LATE%16%30%' THEN 'Late (16-30 days)'
    ELSE loan_status
END;

-- Trim whitespace from text fields
UPDATE loans_clean
SET purpose = TRIM(purpose);

-- ============================================
-- Step 5: Validate data ranges
-- ============================================

-- Remove invalid loan amounts (negative or zero)
DELETE FROM loans_clean
WHERE loan_amount <= 0;

-- Remove invalid interest rates (negative or unreasonably high)
DELETE FROM loans_clean
WHERE interest_rate < 0 OR interest_rate > 50;

-- Remove invalid credit scores (outside typical range)
DELETE FROM loans_clean
WHERE credit_score < 300 OR credit_score > 850;

-- Remove invalid annual income (negative or zero)
DELETE FROM loans_clean
WHERE annual_income <= 0;

-- ============================================
-- Step 6: Add calculated fields
-- ============================================

-- Add a column for loan-to-income ratio
ALTER TABLE loans_clean ADD COLUMN loan_to_income DECIMAL(10,4);

UPDATE loans_clean
SET loan_to_income = ROUND(CAST(loan_amount AS DECIMAL) / CAST(annual_income AS DECIMAL), 4);

-- Add a column for total interest paid
ALTER TABLE loans_clean ADD COLUMN total_interest DECIMAL(10,2);

UPDATE loans_clean
SET total_interest = ROUND((monthly_payment * loan_term) - loan_amount, 2);

-- Add a column for loan category based on amount
ALTER TABLE loans_clean ADD COLUMN loan_category VARCHAR(20);

UPDATE loans_clean
SET loan_category = CASE
    WHEN loan_amount < 10000 THEN 'Small'
    WHEN loan_amount >= 10000 AND loan_amount < 25000 THEN 'Medium'
    WHEN loan_amount >= 25000 THEN 'Large'
END;

-- ============================================
-- Step 7: Create summary statistics table
-- ============================================

DROP TABLE IF EXISTS data_quality_report;

CREATE TABLE data_quality_report AS
SELECT 
    'Total Records' AS metric,
    CAST(COUNT(*) AS VARCHAR) AS value
FROM loans_clean
UNION ALL
SELECT 
    'Unique Customers',
    CAST(COUNT(DISTINCT customer_id) AS VARCHAR)
FROM loans_clean
UNION ALL
SELECT 
    'Date Range',
    MIN(application_date) || ' to ' || MAX(application_date)
FROM loans_clean
UNION ALL
SELECT 
    'Average Loan Amount',
    '$' || CAST(ROUND(AVG(loan_amount), 2) AS VARCHAR)
FROM loans_clean;

-- Display summary
SELECT * FROM data_quality_report;
