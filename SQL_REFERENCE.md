# SQL Query Reference

This document provides a comprehensive reference for all SQL queries in the project.

## Table of Contents
1. [Portfolio Overview](#portfolio-overview)
2. [Loan Status Analysis](#loan-status-analysis)
3. [Credit Score Analysis](#credit-score-analysis)
4. [Loan Purpose Performance](#loan-purpose-performance)
5. [Risk Assessment](#risk-assessment)
6. [Profitability Analysis](#profitability-analysis)

---

## Portfolio Overview

### Query: Total Portfolio Metrics
```sql
SELECT 
    COUNT(DISTINCT loan_id) AS total_loans,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(loan_amount), 2) AS total_loan_volume,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate,
    ROUND(AVG(credit_score), 0) AS avg_credit_score
FROM loans_clean;
```

**Use Case**: Get a high-level overview of the entire loan portfolio

**Key Metrics**:
- Total number of loans
- Total loan volume (sum of all loans)
- Average loan amount
- Average interest rate
- Average borrower credit score

---

## Loan Status Analysis

### Query: Distribution by Status
```sql
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
```

**Use Case**: Understand the distribution of loans across different statuses

**Insights**:
- Percentage of loans in each status
- Financial exposure by status
- Interest rate patterns by status

---

## Credit Score Analysis

### Query: Default Rate by Credit Bands
```sql
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
    SUM(CASE WHEN loan_status IN ('Charged Off', 'Late (31-120 days)') 
        THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(SUM(CASE WHEN loan_status IN ('Charged Off', 'Late (31-120 days)') 
        THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS default_rate,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount
FROM credit_bands
GROUP BY credit_band
ORDER BY default_rate DESC;
```

**Use Case**: Assess risk levels across different credit score bands

**Insights**:
- Default rates by credit score range
- Correlation between credit score and loan performance
- Risk-adjusted pricing opportunities

---

## Loan Purpose Performance

### Query: Performance by Purpose
```sql
SELECT 
    purpose,
    COUNT(*) AS total_loans,
    ROUND(SUM(loan_amount), 2) AS total_volume,
    ROUND(AVG(loan_amount), 2) AS avg_loan_size,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate,
    ROUND(AVG(credit_score), 0) AS avg_credit_score,
    SUM(CASE WHEN loan_status = 'Fully Paid' THEN 1 ELSE 0 END) AS fully_paid_count,
    ROUND(SUM(CASE WHEN loan_status = 'Fully Paid' THEN 1 ELSE 0 END) 
        * 100.0 / COUNT(*), 2) AS repayment_rate
FROM loans_clean
GROUP BY purpose
ORDER BY total_volume DESC;
```

**Use Case**: Evaluate loan performance across different purposes

**Insights**:
- Most popular loan purposes
- Repayment rates by purpose
- Risk profiles for different loan types

---

## Risk Assessment

### Query: High-Risk Loan Identification
```sql
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
```

**Use Case**: Identify loans with elevated risk profiles

**Risk Factors**:
- Credit score below 650
- Debt-to-income ratio above 50%
- Interest rate above 8%

---

## Profitability Analysis

### Query: Profitability by Category and Status
```sql
SELECT 
    loan_category,
    loan_status,
    COUNT(*) AS loan_count,
    ROUND(SUM(loan_amount), 2) AS principal_amount,
    ROUND(SUM(total_interest), 2) AS total_interest_revenue,
    ROUND(SUM(CASE 
        WHEN loan_status = 'Charged Off' THEN loan_amount * 0.8
        WHEN loan_status LIKE 'Late%' THEN loan_amount * 0.2
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
```

**Use Case**: Evaluate profitability across loan categories

**Metrics**:
- Interest revenue generated
- Estimated losses from defaults and late payments
- Net revenue by category and status

---

## Monthly Trends

### Query: Loan Origination Trends
```sql
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
```

**Use Case**: Track loan origination patterns over time

**Insights**:
- Seasonal trends in loan applications
- Changes in average loan size
- Customer acquisition trends

---

## Customer Segmentation

### Query: Segments by Income and Loan Size
```sql
WITH customer_segments AS (
    SELECT 
        loan_id,
        customer_id,
        loan_amount,
        annual_income,
        loan_to_income,
        CASE 
            WHEN annual_income >= 80000 AND loan_amount >= 25000 
                THEN 'High Income - Large Loan'
            WHEN annual_income >= 80000 AND loan_amount < 25000 
                THEN 'High Income - Small Loan'
            WHEN annual_income < 80000 AND loan_amount >= 25000 
                THEN 'Low Income - Large Loan'
            WHEN annual_income < 80000 AND loan_amount < 25000 
                THEN 'Low Income - Small Loan'
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
```

**Use Case**: Understand customer segments and their borrowing patterns

**Segments**:
- High Income / Large Loan
- High Income / Small Loan
- Low Income / Large Loan
- Low Income / Small Loan

---

## Tips for Using These Queries

1. **Modify WHERE clauses**: Add filters for specific time periods or customer groups
2. **Adjust thresholds**: Change credit score bands or risk thresholds based on your criteria
3. **Combine queries**: Use CTEs to combine multiple analyses
4. **Add indexes**: For large datasets, add indexes on frequently queried columns
5. **Export results**: Use `.output filename.csv` in SQLite to export query results

## Database Compatibility

These queries are written for SQLite but can be adapted for:
- **PostgreSQL**: Replace `STRFTIME` with `TO_CHAR`
- **MySQL**: Replace `STRFTIME` with `DATE_FORMAT`
- **SQL Server**: Replace `STRFTIME` with `FORMAT`
