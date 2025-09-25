# Retail Store Sales Analysis

## Project Overview

The project analyses a retail store dataset from the United States covering transactions between 2022 and 2023. The dataset includes detailed information on sales, customers, products and transaction values.

The objective is to extract better understanding of customer behavior, product performance, sales trends and profitability. The analysis was conducted using PostgreSQL on **pgAdmin4**.

## Business Objective

* Identify top-selling products and categories.
* Forecast demand and detect seasonal sales trends.
* Measure the impact of customer demographics on spending.
* Segment customers based on purchase frequency, value, and loyalty.
* Support data-driven decisions on pricing, inventory, and promotions.

## Dataset

* Source: Shared via Telegram Data Scientist Channel, published on my GitHub.
* Records: 2,000 transactions.
* Columns include:

  * Transaction ID, Sale Date, Sale Time
  * Customer ID, Gender, Age
  * Product Category
  * Quantity, Price Per Unit, COGS, Total Sale

## Environment and Tools

* **Database**: PostgreSQL
* **Interface**: pgAdmin4
* **SQL Script**: `Retail Store Sales.sql`

## Setup and Usage

1. Install PostgreSQL and pgAdmin4.
2. Create a new database (`retail_db`).
3. Open `Retail Store Sales.sql` in pgAdmin4.
4. Execute the script to:

   * Create the `retail_sales` table.
   * Load and clean the dataset.
   * Run queries for analysis.

##Analysis Steps

1. **Data Quality Checks**

   * Validated missing values, duplicates, invalid ages, quantities and prices.
   * Fixed COGS inconsistencies and removed invalid transactions.

2. **Dataset Exploration**

   * Overview of transactions, revenue, customer age distribution.
   * Category performance across Clothing, Electronics and Beauty.

3. **Time-based Analysis**

   * Monthly, daily, and hourly sales patterns.
   * Seasonal buying behavior across Winter, Spring, Summer, Fall.

4. **Customer Behavior**

   * Purchase frequency and loyalty analysis.
   * Customer lifetime value and segmentation (VIP, High Value, At Risk).
   * RFM (Recency, Frequency, Monetary) segmentation.
   * Monthly cohort analysis for retention.

5. **Category and Product Insights**

   * Profitability by category.
   * Gender and age group preferences.
   * Product mix and cross-selling opportunities.

6. **Transaction Analysis**

   * Outlier transactions and high-value sales.
   * Running totals and moving averages.
   * Bulk purchase patterns.

## Findings

* **Balanced product mix**: Clothing, Electronics and Beauty each contribute about one-third of revenue.
* **Seasonality drives sales**: Fall and Winter account for two-thirds of yearly revenue.
* **Customer segmentation**: A small group of VIPs drives most revenue, while many others contribute little.
* **High-value transactions**: Electronics dominates, but Beauty achieves the highest profit margins.
* **Demographic patterns**: Gen Z has the highest average spend per transaction while Boomers and Gen X dominate volume.
* **Loyalty impact**: Repeat customers and frequent shoppers are the backbone of revenue growth.

## Files

* `Retail Store Sales.sql` – SQL queries and analysis workflow for PostgreSQL (pgAdmin4).
