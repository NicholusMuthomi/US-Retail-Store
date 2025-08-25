# Retail Store Sales Analysis

## Project Overview

This SQL analysis project examines a dataset of 1,997 retail transactions from a US-based store spanning 2022-2023. The analysis focuses on customer behavior, sales patterns, product performance and seasonal trends to provide actionable insights for retail decision-making and strategy development.

## Dataset Information

The dataset was sourced from actual store transactions shared through a Telegram Data Scientist channel and contains retail sales data with the following structure:

- **transactions_id**: Unique transaction identifier
- **sale_date**: Date of transaction
- **sale_time**: Time of transaction  
- **customer_id**: Unique customer identifier
- **gender**: Customer gender (Male/Female)
- **age**: Customer age
- **category**: Product category (Clothing, Beauty, Electronics)
- **quantity**: Number of items purchased
- **price_per_unit**: Price per individual item
- **cogs**: Cost of Goods Sold
- **total_sale**: Total transaction amount

## Questions Addressed

1. Which products bring in the most revenue and profit?
2. Who are the most valuable customers?
3. What time of day, week, or year drives the most sales?
4. How do customer demographics like age or gender affect spending patterns?
5. Are there data problems that need cleaning before analysis?

## Analysis Structure

### 1. Data Quality Checks
- Verified data completeness (no null values)
- Identified and corrected data issues (70 records with COGS exceeding sale price)
- Removed invalid records (9 transactions with negative/zero values)
- Checked for duplicate records

### 2. Dataset Exploration
- Basic statistics about transactions, customers and products
- Category distribution (35% Clothing, 34% Electronics, 31% Beauty)
- Gender distribution (51% Female, 49% Male)
- Age group analysis (Gen Z to Seniors)

### 3. Time-Based Analysis
- Monthly sales trends (peak in December, lowest in February)
- Daily sales patterns (weekends perform best)
- Hourly sales patterns (evening 5PM-9PM is prime time)
- Seasonal trends (Fall generates 42% of yearly revenue)

### 4. Customer Behavior Analysis
- Customer purchase frequency and loyalty
- Spending segmentation (High, Medium, Low value customers)
- Customer Lifetime Value analysis
- RFM (Recency, Frequency, Monetary) segmentation
- Monthly cohort analysis for retention tracking

### 5. Category and Product Analysis
- Category performance by gender and age groups
- Profitability analysis by category
- Product mix and cross-selling opportunities
- Pricing and margin statistics

### 6. Transactions Analysis
- Outlier transactions identification
- Running totals and moving averages
- High-value transactions (>$1000)

## Findings

1. **Revenue Overview**: The business earned $911,720 across 1,997 transactions with an average transaction value of $456.54.

2. **Category Performance**: 
   - Electronics: $313,810 revenue (34.42% share)
   - Clothing: $311,070 revenue (34.12% share) 
   - Beauty: $286,840 revenue (31.46% share)
   - Beauty had the highest profit margin (80.09%) and average transaction value ($468.69)

3. **Customer Insights**:
   - 155 unique customers with ages ranging from 10-64 (average age: 41)
   - Gen Z customers (under 25) had the highest average spend per transaction ($502.76)
   - Top 20% of customers generated approximately 6x more revenue than bottom 20%

4. **Temporal Patterns**:
   - Peak seasons: Fall (41.96% of yearly transactions) and Winter (25.34%)
   - Best days: Weekends (Saturday and Sunday)
   - Prime hours: Evening (5PM-9PM) accounted for almost half of daily business

5. **Customer Retention**: Strong customer acquisition but weak retention - only 24.49% of January 2022 cohort returned after one month

## Business Implications

1. **Customer Focus**: Prioritise high-value customers with targeted rewards and personalised offers
2. **Seasonal Strategy**: Maximise Fall and Winter sales while using Spring/Summer for promotions and inventory clearance
3. **Marketing Targeting**: Focus on young high-spending shoppers while maintaining engagement with middle-aged high-volume buyers
4. **Operational Decisions**: Extend evening operations to capture prime shopping hours
5. **Inventory Management**: Stock higher-margin Beauty products during peak seasons

## Technical Implementation

The analysis was conducted using SQL with:
- Data quality checks and cleaning procedures
- Statistical analysis and aggregation functions  
- Window functions for ranking and comparison
- Conditional logic for customer segmentation
- Time series analysis for trend identification
- Cohort analysis for retention tracking

##### Sample Query
```sql
-- Dataset Overview
SELECT 
    'DATASET OVERVIEW' AS analysis_section,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT category) AS unique_categories,
    ROUND(MIN(total_sale), 2) AS smallest_transaction,
    ROUND(MAX(total_sale), 2) AS largest_transaction,
    ROUND(AVG(total_sale), 2) AS avg_transaction_value,
    ROUND(SUM(total_sale), 2) AS total_revenue
FROM retail_sales;
```

---

## Conclusion

Through this analysis retail transaction data is turned into practical insights for decision making. Studying customer behavior, sales trends and product outcomes helps retailers improve marketing, manage stock, streamline operations  and strengthen customer loyalty.

## Contributing

Contributions are welcome. If you have suggestions for improvements or find any issues, please open an issue or submit a pull request.

## Contact


For inquiries or feedback, please reach out through (muthominicholus@gmaill.com) or (https://nicholusmuthomi.website/)
