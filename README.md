# rcm-revenue-intelligence-system
SQL-based system to detect revenue leakage, drift, and billing anomalies in healthcare RCM


## Project Overview

This project simulates a healthcare Revenue Cycle Management (RCM) system focused on Urology and Nephrology departments.
Mostly what I have learned (not the whole of it) in these years of working in the healthcare data systems. 

The objective is to analyze:
- revenue leakage
- billing drift
- missed claim recovery
- payment inconsistencies
- workflow anomalies

using advanced SQL and business-oriented analytical logic.


## Business Problems Solved

1. Revenue Drift Detection
2. Department Revenue Efficiency
3. Missed Revenue Identification
4. Recovery Effectiveness Analysis
5. Claim Conflict & Integrity Detection

## SQL Concepts Used

- Window Functions
- CTEs
- Aggregations
- Temporal/Event Logic
- NOT EXISTS
- Data Integrity Validation
- Multi-level Grain Control
- Financial KPI Analysis

## Project Structure

data/
- schema.sql
- insert_data.sql

sql/
- analytical business queries

assets/
- future dashboard screenshots and diagrams


## Key Insights

This project focuses on realistic healthcare billing workflows where:
- procedures may be added after claims are submitted
- claims can be revised multiple times
- payments may not match billed amounts
- operational inconsistencies can create revenue leakage

The SQL solutions were designed with production-style analytical thinking and data integrity validation.


## Future Improvements

- Build Power BI dashboard
- Add workflow automation logic
- Simulate API-driven claim updates
- Expand dataset scale
- Add provider-level KPI tracking

  ## Requests
- I would appreciate your feedback and comments.
- This project took around one and a half day to be completed. Your encouragement would help me grow more. 
