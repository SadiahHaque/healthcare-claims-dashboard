# Healthcare Claims Analysis Dashboard

## Overview
This project involves cleaning and analyzing healthcare claims data to create an interactive Power BI dashboard. The dashboard visualizes key metrics, trends, and insights related to claims, payment status, and insurance type.

## Project Objectives
- Clean and preprocess raw healthcare claims data.
- Create KPIs and visualizations to analyze claims by insurance type.
- Build a **dynamic Power BI dashboard** to provide interactive insights for business decisions.

## Tools and Technologies
- **SQL**: For data cleaning and analysing trends.
- **Power BI**: For creating interactive dashboards and visualizations.
- **DAX**: For measure creation.

## Data Cleaning Process
1. **Removed NULL values** and filled missing `paid_amount` with `allowed_amount` where applicable.
2. **Standardized** inconsistent `insurance_type` and `claim_status` values.
3. **Handled Date Formatting**: Corrected `date_of_service` format issues.
4. **Removed duplicates** from the dataset.

## Key Insights from the Dashboard
- Claims are broken down by **insurance type** to understand trends and performance.
- Shows the ratio of **billed vs. paid amounts** for different insurance type.
- **Claim Denial Rates** for each insurance type.

## Files in This Repository:
- **Data**: Cleaned dataset (`healthcare_claims_clean.csv`)
            Raw dataset (`healthcare_claim_raw_data.csv`).
- **SQL**: SQL script for cleaning data (`data_cleaning_script.sql`).
- **Power-BI**: Power BI project file for the dashboard (`healthcare_claims_dashboard.pbix`).

## How to Use This Dashboard
1. Open the **Power BI** file (`healthcare_claims_dashboard.pbix`) in Power BI Desktop.
2. Explore interactive visuals with filters for insurance types and outcome.
3. Check out key KPIs and trends, such as claim denial rates and payment discrepancies.


