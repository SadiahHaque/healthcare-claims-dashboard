# Healthcare Claims Analysis Dashboard

## Overview
This project involves cleaning and analyzing healthcare claims data to create an interactive Power BI dashboard. The dashboard visualizes key metrics, trends, and insights related to claims, payment status, and provider performance.

## Project Objectives
- Clean and preprocess raw healthcare claims data.
- Create KPIs and visualizations to analyze claims by provider, insurance type, and status.
- Build a **dynamic Power BI dashboard** to provide interactive insights for business decisions.

## Tools and Technologies
- **SQL**: For data cleaning and preprocessing.
- **Power BI**: For creating interactive dashboards and visualizations.
- **DAX**: For dynamic measure creation.

## Data Cleaning Process
1. **Removed NULL values** and filled missing `paid_amount` with `allowed_amount` where applicable.
2. **Standardized** inconsistent `insurance_type` and `claim_status` values.
3. **Handled Date Formatting**: Corrected `date_of_service` format issues.
4. **Removed duplicates** from the dataset.

## Key Insights from the Dashboard
- Claims are broken down by **insurance type** and **provider** to understand trends and performance.
- Payment analysis shows the ratio of **billed vs. paid amounts**.
- **Claim Denial Rates** for each insurance type and provider.

## Files in This Repository:
- **Data**: Cleaned dataset (`healthcare_claims_clean.csv`).
- **SQL**: SQL script for cleaning data (`data_cleaning_script.sql`).
- **Power-BI**: Power BI project file for the dashboard (`Healthcare_Claims_Dashboard.pbix`).

## How to Use This Dashboard
1. Open the **Power BI** file (`Healthcare_Claims_Dashboard.pbix`) in Power BI Desktop.
2. Explore interactive visuals with filters for insurance types, providers, and claim outcomes.
3. Check out key KPIs and trends, such as claim denial rates and payment discrepancies.


