# Quick Start Guide

This guide helps you get started with the Loan Insights Project quickly.

## 🚀 Quick Setup

### Option 1: SQL Analysis with SQLite

```bash
# 1. Navigate to project directory
cd Loan_Insights-Project

# 2. Create database and setup schema
sqlite3 loan_analysis.db < sql/00_setup_database.sql

# 3. Import data (SQLite)
sqlite3 loan_analysis.db << EOF
.mode csv
.import --skip 1 data/loan_data.csv loans_raw
EOF

# 4. Run data cleaning
sqlite3 loan_analysis.db < sql/01_data_cleaning.sql

# 5. Execute analytical queries
sqlite3 loan_analysis.db < sql/02_advanced_queries.sql
```

### Option 2: Python Data Cleaning

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Run the cleaning script
python scripts/data_cleaning.py
```

### Option 3: Jupyter Notebooks

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Launch Jupyter
jupyter notebook

# 3. Open and run notebooks:
#    - notebooks/loan_eda.ipynb
#    - notebooks/loan_visualization.ipynb
```

## 📊 Sample Queries

### Portfolio Overview
```sql
sqlite3 -column -header loan_analysis.db << 'EOF'
SELECT 
    COUNT(*) AS total_loans,
    ROUND(SUM(loan_amount), 2) AS total_volume,
    ROUND(AVG(interest_rate), 2) AS avg_rate
FROM loans_clean;
EOF
```

### Loan Status Distribution
```sql
sqlite3 -column -header loan_analysis.db << 'EOF'
SELECT 
    loan_status,
    COUNT(*) AS count,
    ROUND(AVG(loan_amount), 2) AS avg_amount
FROM loans_clean
GROUP BY loan_status;
EOF
```

### High-Risk Loans
```sql
sqlite3 -column -header loan_analysis.db << 'EOF'
SELECT 
    loan_id,
    loan_amount,
    credit_score,
    debt_to_income,
    loan_status
FROM loans_clean
WHERE credit_score < 650 OR debt_to_income > 0.50
ORDER BY credit_score ASC
LIMIT 10;
EOF
```

## 🔍 What Each Component Does

### SQL Scripts
- **00_setup_database.sql**: Creates the initial database schema
- **01_data_cleaning.sql**: Cleans and prepares data for analysis
- **02_advanced_queries.sql**: Contains 10 advanced analytical queries

### Python Scripts
- **data_cleaning.py**: Automates data cleaning with pandas

### Notebooks
- **loan_eda.ipynb**: Comprehensive exploratory data analysis
- **loan_visualization.ipynb**: Advanced visualizations and dashboards

## 💡 Tips

1. **Start with SQL**: If you're new to data analysis, start with the SQL scripts
2. **Use notebooks**: For visual insights, use the Jupyter notebooks
3. **Modify queries**: Feel free to modify queries to answer your own questions
4. **Add your data**: Replace `loan_data.csv` with your own loan data (keep the same format)

## ⚠️ Common Issues

**Problem**: `ModuleNotFoundError` when running Python scripts
**Solution**: Install dependencies with `pip install -r requirements.txt`

**Problem**: SQL syntax errors
**Solution**: Make sure you're using SQLite. For other databases, adjust syntax accordingly.

**Problem**: Cannot import CSV
**Solution**: Ensure your CSV file has the correct format with headers

## 📚 Next Steps

1. Explore the advanced queries in `sql/02_advanced_queries.sql`
2. Run the Jupyter notebooks to see visualizations
3. Modify queries to explore different aspects of the data
4. Add your own data and insights

## 🤔 Need Help?

- Check the main README.md for detailed documentation
- Review the inline comments in SQL and Python files
- Open an issue on GitHub for questions
