-- Advanced SQL Queries for Loan Insights
-- This script contains complex queries to extract key metrics and insights

-- ============================================
-- Query 1: Loan Portfolio Overview
-- ============================================

SELECT 
    COUNT(DISTINCT loan_id) AS total_loans,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(loan_amount), 2) AS total_loan_volume,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate,
    ROUND(AVG(credit_score), 0) AS avg_credit_score,
    ROUND(SUM(CASE WHEN loan_status = 'Fully Paid' THEN loan_amount ELSE 0 END), 2) AS fully_paid_volume,
    ROUND(SUM(CASE WHEN loan_status = 'Charged Off' THEN loan_amount ELSE 0 END), 2) AS charged_off_volume
FROM loans_clean;

-- ============================================
-- Query 2: Loan Status Distribution
-- ============================================

SELECT 
    loan_status,
    COUNT(*) AS loan_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage,
    ROUND(SUM(loan_amount), 2) AS total_amount,
    ROUND(AVG(loan_amount), 2) AS avg_amount,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate
FROM loans_clean
GROUP BY loan_status
ORDER BY loan_count DESC;

-- ============================================
-- Query 3: Default Rate Analysis by Credit Score Bands
-- ============================================

WITH credit_bands AS (
    SELECT 
        loan_id,
        loan_amount,
        loan_status,
        CASE 
            WHEN credit_score >= 750 THEN 'Excellent (750+)'
            WHEN credit_score >= 700 THEN 'Good (700-749)'
            WHEN credit_score >= 650 THEN 'Fair (650-699)'
            WHEN credit_score >= 600 THEN 'Poor (600-649)'
            ELSE 'Very Poor (<600)'
        END AS credit_band
    FROM loans_clean
)
SELECT 
    credit_band,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status IN ('Charged Off', 'Late (31-120 days)') THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(SUM(CASE WHEN loan_status IN ('Charged Off', 'Late (31-120 days)') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS default_rate,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount
FROM credit_bands
GROUP BY credit_band
ORDER BY default_rate DESC;

-- ============================================
-- Query 4: Loan Purpose Performance Analysis
-- ============================================

SELECT 
    purpose,
    COUNT(*) AS total_loans,
    ROUND(SUM(loan_amount), 2) AS total_volume,
    ROUND(AVG(loan_amount), 2) AS avg_loan_size,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate,
    ROUND(AVG(credit_score), 0) AS avg_credit_score,
    SUM(CASE WHEN loan_status = 'Fully Paid' THEN 1 ELSE 0 END) AS fully_paid_count,
    ROUND(SUM(CASE WHEN loan_status = 'Fully Paid' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS repayment_rate
FROM loans_clean
GROUP BY purpose
ORDER BY total_volume DESC;

-- ============================================
-- Query 5: Monthly Loan Origination Trends
-- ============================================

SELECT 
    STRFTIME('%Y-%m', application_date) AS month,
    COUNT(*) AS loans_originated,
    ROUND(SUM(loan_amount), 2) AS total_volume,
    ROUND(AVG(loan_amount), 2) AS avg_loan_size,
    ROUND(AVG(interest_rate), 2) AS avg_rate,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM loans_clean
GROUP BY STRFTIME('%Y-%m', application_date)
ORDER BY month;

-- ============================================
-- Query 6: High-Risk Loan Identification
-- ============================================

SELECT 
    loan_id,
    customer_id,
    loan_amount,
    interest_rate,
    credit_score,
    debt_to_income,
    loan_status,
    purpose,
    CASE 
        WHEN credit_score < 650 THEN 'Low Credit Score'
        WHEN debt_to_income > 0.50 THEN 'High DTI'
        WHEN interest_rate > 8.0 THEN 'High Interest Rate'
        ELSE 'Other'
    END AS risk_factor
FROM loans_clean
WHERE credit_score < 650 
   OR debt_to_income > 0.50 
   OR interest_rate > 8.0
ORDER BY 
    CASE loan_status 
        WHEN 'Charged Off' THEN 1
        WHEN 'Late (31-120 days)' THEN 2
        WHEN 'Late (16-30 days)' THEN 3
        ELSE 4
    END,
    credit_score ASC;

-- ============================================
-- Query 7: Customer Segmentation by Income and Loan Size
-- ============================================

WITH customer_segments AS (
    SELECT 
        loan_id,
        customer_id,
        loan_amount,
        annual_income,
        loan_to_income,
        CASE 
            WHEN annual_income >= 80000 AND loan_amount >= 25000 THEN 'High Income - Large Loan'
            WHEN annual_income >= 80000 AND loan_amount < 25000 THEN 'High Income - Small Loan'
            WHEN annual_income < 80000 AND loan_amount >= 25000 THEN 'Low Income - Large Loan'
            WHEN annual_income < 80000 AND loan_amount < 25000 THEN 'Low Income - Small Loan'
        END AS segment
    FROM loans_clean
)
SELECT 
    segment,
    COUNT(*) AS loan_count,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
    ROUND(AVG(annual_income), 2) AS avg_annual_income,
    ROUND(AVG(loan_to_income), 4) AS avg_loan_to_income_ratio
FROM customer_segments
GROUP BY segment
ORDER BY loan_count DESC;

-- ============================================
-- Query 8: Profitability Analysis
-- ============================================

SELECT 
    loan_category,
    loan_status,
    COUNT(*) AS loan_count,
    ROUND(SUM(loan_amount), 2) AS principal_amount,
    ROUND(SUM(total_interest), 2) AS total_interest_revenue,
    ROUND(SUM(CASE 
        WHEN loan_status = 'Charged Off' THEN loan_amount * 0.8  -- Assume 80% loss on charged off
        WHEN loan_status LIKE 'Late%' THEN loan_amount * 0.2     -- Assume 20% loss on late payments
        ELSE 0 
    END), 2) AS estimated_losses,
    ROUND(SUM(total_interest) - SUM(CASE 
        WHEN loan_status = 'Charged Off' THEN loan_amount * 0.8
        WHEN loan_status LIKE 'Late%' THEN loan_amount * 0.2
        ELSE 0 
    END), 2) AS net_revenue
FROM loans_clean
GROUP BY loan_category, loan_status
ORDER BY loan_category, net_revenue DESC;

-- ============================================
-- Query 9: Loan Term Performance Comparison
-- ============================================

SELECT 
    loan_term,
    COUNT(*) AS loan_count,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
    ROUND(AVG(monthly_payment), 2) AS avg_monthly_payment,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate,
    ROUND(AVG(total_interest), 2) AS avg_total_interest,
    SUM(CASE WHEN loan_status = 'Fully Paid' THEN 1 ELSE 0 END) AS fully_paid_count,
    ROUND(SUM(CASE WHEN loan_status = 'Fully Paid' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS success_rate
FROM loans_clean
GROUP BY loan_term
ORDER BY loan_term;

-- ============================================
-- Query 10: Employment Length Impact Analysis
-- ============================================

WITH employment_groups AS (
    SELECT 
        loan_id,
        loan_status,
        loan_amount,
        interest_rate,
        CASE 
            WHEN employment_length = 0 THEN '0 years'
            WHEN employment_length BETWEEN 1 AND 2 THEN '1-2 years'
            WHEN employment_length BETWEEN 3 AND 5 THEN '3-5 years'
            WHEN employment_length BETWEEN 6 AND 10 THEN '6-10 years'
            WHEN employment_length > 10 THEN '10+ years'
        END AS employment_group
    FROM loans_clean
)
SELECT 
    employment_group,
    COUNT(*) AS loan_count,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate,
    SUM(CASE WHEN loan_status IN ('Charged Off', 'Late (31-120 days)') THEN 1 ELSE 0 END) AS at_risk_loans,
    ROUND(SUM(CASE WHEN loan_status IN ('Charged Off', 'Late (31-120 days)') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS risk_rate
FROM employment_groups
GROUP BY employment_group
ORDER BY 
    CASE employment_group
        WHEN '0 years' THEN 1
        WHEN '1-2 years' THEN 2
        WHEN '3-5 years' THEN 3
        WHEN '6-10 years' THEN 4
        WHEN '10+ years' THEN 5
    END;
