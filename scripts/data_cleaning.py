"""
Data Cleaning Script for Loan Data
This script prepares the raw loan data for analysis using Python and pandas
"""

import pandas as pd
import numpy as np
from datetime import datetime
import os

# Configuration
DATA_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'data')
INPUT_FILE = os.path.join(DATA_DIR, 'loan_data.csv')
OUTPUT_FILE = os.path.join(DATA_DIR, 'loan_data_cleaned.csv')

def load_data(filepath):
    """Load the raw loan data from CSV"""
    print(f"Loading data from {filepath}...")
    df = pd.read_csv(filepath)
    print(f"Loaded {len(df)} records with {len(df.columns)} columns")
    return df

def check_data_quality(df):
    """Generate data quality report"""
    print("\n=== Data Quality Report ===")
    print(f"Total Records: {len(df)}")
    print(f"Total Columns: {len(df.columns)}")
    print(f"\nMissing Values:")
    print(df.isnull().sum())
    print(f"\nDuplicate Records: {df.duplicated().sum()}")
    print(f"\nData Types:")
    print(df.dtypes)
    
def remove_duplicates(df):
    """Remove duplicate records"""
    initial_count = len(df)
    df = df.drop_duplicates(subset=['customer_id', 'loan_amount', 'application_date'])
    removed = initial_count - len(df)
    print(f"\nRemoved {removed} duplicate records")
    return df

def handle_missing_values(df):
    """Handle missing values in the dataset"""
    print("\n=== Handling Missing Values ===")
    
    # Remove records with missing critical fields
    critical_fields = ['loan_id', 'customer_id', 'loan_amount', 'loan_status']
    initial_count = len(df)
    df = df.dropna(subset=critical_fields)
    print(f"Removed {initial_count - len(df)} records with missing critical fields")
    
    # Fill missing credit scores with median
    if df['credit_score'].isnull().any():
        median_score = df['credit_score'].median()
        df['credit_score'].fillna(median_score, inplace=True)
        print(f"Filled missing credit scores with median: {median_score}")
    
    # Fill missing employment length with 0
    if df['employment_length'].isnull().any():
        df['employment_length'].fillna(0, inplace=True)
        print("Filled missing employment length with 0")
    
    return df

def standardize_formats(df):
    """Standardize data formats"""
    print("\n=== Standardizing Data Formats ===")
    
    # Standardize loan status
    status_mapping = {
        'fully paid': 'Fully Paid',
        'current': 'Current',
        'charged off': 'Charged Off',
        'late (31-120 days)': 'Late (31-120 days)',
        'late (16-30 days)': 'Late (16-30 days)'
    }
    df['loan_status'] = df['loan_status'].str.lower().map(lambda x: status_mapping.get(x, x.title()))
    
    # Trim whitespace from text fields
    text_columns = ['loan_status', 'purpose']
    for col in text_columns:
        df[col] = df[col].str.strip()
    
    # Convert date columns to datetime
    date_columns = ['application_date', 'approval_date', 'disbursement_date']
    for col in date_columns:
        df[col] = pd.to_datetime(df[col], errors='coerce')
    
    print("Data formats standardized")
    return df

def validate_data_ranges(df):
    """Validate data ranges and remove invalid records"""
    print("\n=== Validating Data Ranges ===")
    initial_count = len(df)
    
    # Remove invalid loan amounts
    df = df[df['loan_amount'] > 0]
    
    # Remove invalid interest rates
    df = df[(df['interest_rate'] >= 0) & (df['interest_rate'] <= 50)]
    
    # Remove invalid credit scores
    df = df[(df['credit_score'] >= 300) & (df['credit_score'] <= 850)]
    
    # Remove invalid annual income
    df = df[df['annual_income'] > 0]
    
    removed = initial_count - len(df)
    print(f"Removed {removed} records with invalid data ranges")
    return df

def add_calculated_fields(df):
    """Add calculated fields for analysis"""
    print("\n=== Adding Calculated Fields ===")
    
    # Loan-to-income ratio
    df['loan_to_income'] = (df['loan_amount'] / df['annual_income']).round(4)
    
    # Total interest paid
    df['total_interest'] = ((df['monthly_payment'] * df['loan_term']) - df['loan_amount']).round(2)
    
    # Loan category
    df['loan_category'] = pd.cut(
        df['loan_amount'], 
        bins=[0, 10000, 25000, float('inf')],
        labels=['Small', 'Medium', 'Large']
    )
    
    # Credit score band
    df['credit_band'] = pd.cut(
        df['credit_score'],
        bins=[0, 600, 650, 700, 750, 850],
        labels=['Very Poor', 'Poor', 'Fair', 'Good', 'Excellent']
    )
    
    print(f"Added {4} calculated fields")
    return df

def generate_summary_statistics(df):
    """Generate summary statistics"""
    print("\n=== Summary Statistics ===")
    print(f"Total Records: {len(df)}")
    print(f"Unique Customers: {df['customer_id'].nunique()}")
    print(f"Date Range: {df['application_date'].min()} to {df['application_date'].max()}")
    print(f"Average Loan Amount: ${df['loan_amount'].mean():.2f}")
    print(f"Median Loan Amount: ${df['loan_amount'].median():.2f}")
    print(f"Average Interest Rate: {df['interest_rate'].mean():.2f}%")
    print(f"Average Credit Score: {df['credit_score'].mean():.0f}")
    
    print("\nLoan Status Distribution:")
    print(df['loan_status'].value_counts())
    
    print("\nLoan Purpose Distribution:")
    print(df['purpose'].value_counts())

def save_cleaned_data(df, filepath):
    """Save the cleaned data to CSV"""
    df.to_csv(filepath, index=False)
    print(f"\nCleaned data saved to {filepath}")

def main():
    """Main execution function"""
    print("=" * 60)
    print("LOAN DATA CLEANING SCRIPT")
    print("=" * 60)
    
    # Load data
    df = load_data(INPUT_FILE)
    
    # Check initial data quality
    check_data_quality(df)
    
    # Clean data
    df = remove_duplicates(df)
    df = handle_missing_values(df)
    df = standardize_formats(df)
    df = validate_data_ranges(df)
    df = add_calculated_fields(df)
    
    # Generate summary
    generate_summary_statistics(df)
    
    # Save cleaned data
    save_cleaned_data(df, OUTPUT_FILE)
    
    print("\n" + "=" * 60)
    print("DATA CLEANING COMPLETED SUCCESSFULLY")
    print("=" * 60)

if __name__ == "__main__":
    main()
