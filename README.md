# Loan Insights Project 📊

A comprehensive loan data analysis project that leverages SQL, Python, and data visualization techniques to extract meaningful insights from loan portfolio data.

## 🎯 Project Overview

This repository focuses on analyzing loan data to uncover patterns, assess risk, and derive actionable insights. The project demonstrates end-to-end data analysis workflow including data cleaning, exploratory analysis, and advanced SQL queries.

## 📁 Project Structure

```
Loan_Insights-Project/
│
├── data/                          # Data directory
│   └── loan_data.csv             # Sample loan dataset
│
├── sql/                           # SQL scripts
│   ├── 00_setup_database.sql     # Database schema setup
│   ├── 01_data_cleaning.sql      # Data cleaning queries
│   └── 02_advanced_queries.sql   # Advanced analytical queries
│
├── scripts/                       # Python scripts
│   └── data_cleaning.py          # Data cleaning automation
│
├── notebooks/                     # Jupyter notebooks
│   ├── loan_eda.ipynb            # Exploratory Data Analysis
│   └── loan_visualization.ipynb  # Advanced visualizations
│
├── .gitignore                     # Git ignore file
└── README.md                      # This file
```

## 🔍 Features

### a) Data Cleaning
- **SQL-based cleaning**: Comprehensive SQL scripts to prepare raw data
  - Remove duplicates and handle missing values
  - Standardize data formats
  - Validate data ranges
  - Add calculated fields for analysis
  
- **Python automation**: Automated data cleaning pipeline
  - Quality checks and validation
  - Missing value imputation
  - Outlier detection and handling

### b) EDA & Visualization
- **Exploratory Data Analysis**:
  - Comprehensive statistical analysis
  - Distribution analysis for key metrics
  - Correlation analysis
  - Pattern detection
  
- **Interactive Visualizations**:
  - Loan status distribution
  - Credit score impact analysis
  - Risk segmentation dashboard
  - Time series analysis
  - Profitability metrics

### c) SQL Queries
- **Advanced Analytics**:
  - Portfolio overview and metrics
  - Default rate analysis by credit bands
  - Loan purpose performance evaluation
  - Monthly origination trends
  - High-risk loan identification
  - Customer segmentation
  - Profitability analysis
  - Employment length impact assessment

## 📊 Dataset Description

The sample dataset includes the following fields:

| Field | Description |
|-------|-------------|
| loan_id | Unique loan identifier |
| customer_id | Customer identifier |
| loan_amount | Principal loan amount |
| interest_rate | Annual interest rate (%) |
| loan_term | Loan term in months |
| monthly_payment | Monthly payment amount |
| loan_status | Current status of the loan |
| purpose | Purpose of the loan |
| credit_score | Borrower's credit score |
| annual_income | Borrower's annual income |
| employment_length | Years of employment |
| debt_to_income | Debt-to-income ratio |
| application_date | Date of application |
| approval_date | Date of approval |
| disbursement_date | Date of disbursement |

## 🚀 Getting Started

### Prerequisites
- **For SQL analysis**:
  - SQLite, PostgreSQL, or MySQL
  - SQL client (e.g., DBeaver, pgAdmin, MySQL Workbench)

- **For Python analysis**:
  ```bash
  pip install pandas numpy matplotlib seaborn jupyter
  ```

### Usage

#### 1. Database Setup and Data Loading

**SQLite Example:**
```bash
# Create database
sqlite3 loan_analysis.db

# In SQLite shell
.mode csv
.import data/loan_data.csv loans_raw
.read sql/00_setup_database.sql
```

**PostgreSQL/MySQL:**
```sql
-- Run the setup script first
source sql/00_setup_database.sql;

-- Then import the CSV data using COPY or LOAD DATA commands
```

#### 2. Data Cleaning

**Using SQL:**
```bash
# Execute the data cleaning script
sqlite3 loan_analysis.db < sql/01_data_cleaning.sql
```

**Using Python:**
```bash
cd scripts
python data_cleaning.py
```

#### 3. Run Analysis Queries

```bash
# Execute advanced queries
sqlite3 loan_analysis.db < sql/02_advanced_queries.sql
```

#### 4. Exploratory Data Analysis

```bash
# Launch Jupyter notebook
jupyter notebook notebooks/loan_eda.ipynb
```

#### 5. Generate Visualizations

```bash
# Open visualization notebook
jupyter notebook notebooks/loan_visualization.ipynb
```

## 📈 Key Insights

The analysis reveals several important insights:

1. **Portfolio Performance**: 
   - Overall portfolio health metrics
   - Loan distribution by status
   - Total loan volume trends

2. **Risk Assessment**:
   - Default rates by credit score bands
   - High-risk loan identification
   - Risk segmentation analysis

3. **Profitability**:
   - Interest revenue analysis
   - Loss estimation by loan status
   - Net profitability by loan category

4. **Customer Behavior**:
   - Loan purpose preferences
   - Income vs. loan amount patterns
   - Employment length impact

## 🛠️ SQL Query Examples

### Portfolio Overview
```sql
SELECT 
    COUNT(DISTINCT loan_id) AS total_loans,
    ROUND(SUM(loan_amount), 2) AS total_volume,
    ROUND(AVG(interest_rate), 2) AS avg_rate
FROM loans_clean;
```

### Default Rate by Credit Score
```sql
SELECT 
    credit_band,
    COUNT(*) AS total_loans,
    ROUND(SUM(CASE WHEN loan_status = 'Charged Off' 
              THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS default_rate
FROM loans_clean
GROUP BY credit_band
ORDER BY default_rate DESC;
```

## 📚 Documentation

Each component includes detailed documentation:
- SQL scripts have inline comments explaining each step
- Python scripts include docstrings and function documentation
- Notebooks include markdown explanations for each analysis

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is open source and available under the MIT License.

## 📧 Contact

For questions or feedback, please open an issue in this repository.

---

**Note**: This project uses sample data for demonstration purposes. In a production environment, ensure proper data privacy and security measures are in place.
