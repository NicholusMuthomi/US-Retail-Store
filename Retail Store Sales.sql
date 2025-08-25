-- =====================================
-- RETAIL SALES DATASET ANALYSIS
-- =====================================
/*
-- BUSINESS OBJECTIVE

   Retail stores collect thousands of sales records every year. Each record holds information about who bought something, what they bought, when they bought it, how much it cost
   and how much profit was made. But having data is not enough. What matters is making sense of it.
   
   -- The goal of this project is to analyse retail sales data using SQL. By doing this, we answer questions such as:
   
     * Which products bring in the most revenue and profit?
	 * Who are the most valuable customers?
	 * What time of day, week, or year drives the most sales?
	 * How do customer demographics like age or gender affect spending patterns?
	 * Are there data problems, such as missing or invalid values, that need cleaning before analysis?
	 
   The purpose is to use data to understand customer behavior, improve marketing, manage inventory better and grow revenue. 
   This mirrors how big retailers like Walmart or Amazon rely on data to make decisions every day.

-- DATA COLLETION
   The data used in this project was shared through a Telegram Data Scentist Channel from a actual store in United State Store for transations between 2022 and 2023.
   The data is shared on my Github.
*/

-- CREATE TABLE STRUCTURE
-- This creates our main table to store all retail sales transaction data
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales (
    transactions_id INT PRIMARY KEY,     -- Unique transaction identifier
    sale_date DATE,                      -- Date of the transaction
    sale_time TIME,                      -- Time of the transaction
    customer_id INT,                     -- Unique customer identifier
    gender VARCHAR(10),                  -- Customer gender (Male/Female)
    age INT,                             -- Customer age
    category VARCHAR(50),                -- Product category (Clothing, Beauty, Electronics)
    quantity INT,                        -- Number of items purchased
    price_per_unit DECIMAL(10,2),        -- Price per individual item
    cogs DECIMAL(10,2),                  -- Cost of Goods Sold
    total_sale DECIMAL(10,2)             -- Total transaction amount
);

-- =====================================
-- STEP 1: DATA QUALITY CHECKS
-- =====================================

-- 1.1 CHECK FOR NULL VALUES
-- This helps us understand data completeness across all columns
SELECT 
    'DATA COMPLETENESS CHECK' AS analysis_type,
    COUNT(*) as total_records,
    COUNT(transactions_id) as transactions_id_count,
    COUNT(sale_date) as sale_date_count,
    COUNT(sale_time) as sale_time_count,
    COUNT(customer_id) as customer_id_count,
    COUNT(gender) as gender_count,
    COUNT(age) as age_count,
    COUNT(category) as category_count,
    COUNT(quantity) as quantity_count,
    COUNT(price_per_unit) as price_per_unit_count,
    COUNT(cogs) as cogs_count,
    COUNT(total_sale) as total_sale_count
FROM retail_sales;
/*
Obserrvations
There dataset contains 2,000 rows and 12 columns.All columns have 2,000 entries with no missing values, they all have a 100% fill rate.
*/
-- 1.2 CHECK FOR DUPLICATE RECORDS
-- Identifies if the same transaction appears multiple times
SELECT 
    'DUPLICATE ANALYSIS' AS check_type,
    transactions_id, 
    customer_id, 
    sale_date, 
    total_sale,
    COUNT(*) as duplicate_count
FROM retail_sales 
GROUP BY transactions_id, customer_id, sale_date, total_sale 
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
/*
Observations
There are no duplicate values.
*/
-- 1.3 CHECK FOR DATA QUALITY ISSUES
-- Identifies invalid or suspicious data values
SELECT 
    'DATA QUALITY ISSUES' AS analysis_section,
    issue_type,
    count AS problematic_records
FROM (
    SELECT 'Invalid Age (<=0 or >120)' as issue_type, COUNT(*) as count
    FROM retail_sales WHERE age <= 0 OR age > 120
    UNION ALL
    SELECT 'Invalid Quantity (<=0)' as issue_type, COUNT(*) as count
    FROM retail_sales WHERE quantity <= 0
    UNION ALL
    SELECT 'Invalid Price (<=0)' as issue_type, COUNT(*) as count
    FROM retail_sales WHERE price_per_unit <= 0
    UNION ALL
    SELECT 'Invalid Total Sale (<=0)' as issue_type, COUNT(*) as count
    FROM retail_sales WHERE total_sale <= 0
    UNION ALL
    SELECT 'COGS Higher Than Sale Price' as issue_type, COUNT(*) as count
    FROM retail_sales WHERE cogs > total_sale
    UNION ALL
    SELECT 'Calculation Mismatch' as issue_type, COUNT(*) as count
    FROM retail_sales WHERE ABS(quantity * price_per_unit - total_sale) > 0.01
) quality_check
ORDER BY count DESC;
/*
Observations
The most common data issue is COGS exceeding the sale price in 70 cases, which can affect profit analysis.
There are 9 transactions with invalid quantities, prices or total sales that require review or cleaning.
Age and calculation consistency are 100% valid, supporting accurate demographic and financial analysis.
*/
-- Let fix COGS Higher Than Sale Price (70 Records)
UPDATE retail_sales 
SET cogs = total_sale * 0.7  -- Setting COGS to 70% of sale price because COGS should never exceed sale price, this (indicates loss on every sale)
WHERE cogs > total_sale;

-- Let remove Invalid Quantities/Prices/Total Sales (3 Records Each)
DELETE FROM retail_sales 
WHERE quantity <= 0 OR price_per_unit <= 0 OR total_sale <= 0;

-- 1.4 CHECK DATE RANGE AND VALIDITY
-- Ensures all dates are within reasonable range
SELECT 
    'DATE RANGE' AS analysis_section,
    MIN(sale_date) AS earliest_transaction,
    MAX(sale_date) AS latest_transaction,
    COUNT(DISTINCT sale_date) AS unique_dates,
    (MAX(sale_date), MIN(sale_date)) AS date_range_days
FROM retail_sales;
/*
Observations
There are transactions recorded from January 1, 2022 to December 31, 2023 covering a 2-year period.
The dataset includes 647 unique dates indicating sales occurred on about 88% of the days in that period. The missing date of around 83 days probably they are weekends and holidays.
*/
-- =============================
-- STEP 2: DATASET EXPLORATION
-- =============================

-- 2.1 DATASET OVERVIEW
-- Provides high-level statistics about our dataset
SELECT 
    'DATASET OVERVIEW' AS analysis_section,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT category) AS unique_categories,
    ROUND(MIN(total_sale), 2) AS smallest_transaction,
    ROUND(MAX(total_sale), 2) AS largest_transaction,
    ROUND(AVG(total_sale), 2) AS avg_transaction_value,
    ROUND(SUM(total_sale), 2) AS total_revenue,
    ROUND(MIN(age), 0) AS youngest_customer,
    ROUND(MAX(age), 0) AS oldest_customer,
    ROUND(AVG(age), 1) AS avg_customer_age
FROM retail_sales;
/*
Observations
There are 1,997 transactions with amounts ranging from 25.00 to 2,000.00.
There are 155 customers with ages ranging from 10 to 64 and an average age of 41.
There are 3 categories in the dataset.
The average transaction value is 456.54 and the total revenue is 911,720.00.
*/
-- 2.2 CATEGORY DISTRIBUTION
-- Shows what product categories are most popular
SELECT 
    'CATEGORY DISTRIBUTION' AS analysis_section,
    category,
    COUNT(*) AS transaction_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM retail_sales), 2) AS percentage_of_transactions,
    ROUND(SUM(total_sale), 2) AS category_revenue,
    ROUND(AVG(total_sale), 2) AS avg_transaction_value,
    ROUND(SUM(quantity), 0) AS total_items_sold
FROM retail_sales 
GROUP BY category 
ORDER BY transaction_count DESC;

/*
Observations
1. Clothing has 701 transactions (35.1%) generating 311,070.00 with an average spend of 443.75 and 1,785 items sold. It has high volume but lower average spend.
2. Electronics has 684 transactions (34.25%) generating 313,810.00 with an average spend of 458.79 and 1,698 items sold. It shows balanced performance.
3. Beauty has 612 transactions (30.65%) generating 286,840.00 with an average spend of 468.69 and 1,535 items sold. It has the highest average spend offering upsell potential.
*/
-- 2.3 GENDER DISTRIBUTION AND SPENDING PATTERNS
-- Shows gender-based shopping behavior
SELECT 
    'GENDER ANALYSIS' AS analysis_section,
    gender,
    COUNT(*) AS transaction_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM retail_sales), 2) AS percentage,
    ROUND(AVG(total_sale), 2) AS avg_spending_per_transaction,
    ROUND(SUM(total_sale), 2) AS total_spending,
    ROUND(AVG(age), 1) AS avg_age,
    ROUND(AVG(quantity), 1) AS avg_items_per_transaction
FROM retail_sales 
GROUP BY gender 
ORDER BY transaction_count DESC;
/*
Observations
* Females made 1,017 transactions (50.93%) with total spend of 465,400.00 and an average of 457.62 per transaction.
* Males made 980 transactions (49.07%) with total spend of 446,320.00 and an average of 455.43 per transaction.
* Both genders spend similarly per transaction at about 456, though females contribute slightly more total revenue.
* Average items per transaction is 2.5 for both genders.
* Average age for both genders is 41. 
*/
-- 2.4 AGE GROUP ANALYSIS
-- Segments customers by age groups and analyses spending patterns
SELECT 
    'AGE GROUP ANALYSIS' AS analysis_section,
    age_group,
    COUNT(*) AS transaction_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM retail_sales), 2) AS percentage,
    ROUND(AVG(total_sale), 2) AS avg_spending,
    ROUND(SUM(total_sale), 2) AS total_spending,
    ROUND(AVG(quantity), 1) AS avg_items_per_transaction
FROM (
    SELECT *,
        CASE 
            WHEN age < 25 THEN 'Gen Z (Under 25)'
            WHEN age >= 25 AND age < 35 THEN 'Millennials (25-34)'
            WHEN age >= 35 AND age < 45 THEN 'Gen X (35-44)'
            WHEN age >= 45 AND age < 55 THEN 'Boomers (45-54)'
            WHEN age >= 55 THEN 'Seniors (55+)'
        END AS age_group
    FROM retail_sales
) age_categorised
GROUP BY age_group 
ORDER BY avg_spending DESC;
/*
Observations
* Gen Z (under 25) accounts for 15% of sales with the highest average spend per transaction at 502.76 and total revenue of 152k.
* Millennials (25–34) account for 20% of sales with an average spend of 479.23 and total revenue of 194k.
* Gen X (35–44) accounts for 21% of sales with an average spend of 466.13 and total revenue of 194k.
* Boomers (45–54) account for 22% of sales with an average spend of 432.65 and total revenue of 193k.
* Seniors (55+) account for 21% of sales with an average spend of 417.82 and total revenue of 178k.
* Gen Z spends the most per transaction while Boomers and Gen X lead in transaction volume, contributing 43% combined.
* Revenue is similar across Millennials, Gen X and Boomers, while Seniors generate the lowest total revenue.
*/

-- 2.5 PRICING AND PROFITABILITY ANALYSIS
-- Statistical summary of pricing and profit margins
SELECT 
    'PRICING STATISTICS' AS analysis_section,
    metric_name,
    ROUND(min_value, 2) AS minimum,
    ROUND(max_value, 2) AS maximum,
    ROUND(avg_value, 2) AS average,
    ROUND(std_deviation, 2) AS standard_deviation
FROM (
    SELECT 'Price Per Unit' AS metric_name, MIN(price_per_unit) AS min_value, MAX(price_per_unit) AS max_value, AVG(price_per_unit) AS avg_value, STDDEV(price_per_unit) AS std_deviation FROM retail_sales
    UNION ALL
    SELECT 'Total Sale', MIN(total_sale), MAX(total_sale), AVG(total_sale), STDDEV(total_sale) FROM retail_sales
    UNION ALL
    SELECT 'Cost of Goods Sold', MIN(cogs), MAX(cogs), AVG(cogs), STDDEV(cogs) FROM retail_sales
    UNION ALL
    SELECT 'Profit Margin', MIN(total_sale - cogs), MAX(total_sale - cogs), AVG(total_sale - cogs), STDDEV(total_sale - cogs) FROM retail_sales
    UNION ALL
    SELECT 'Quantity', MIN(quantity), MAX(quantity), AVG(quantity), STDDEV(quantity) FROM retail_sales
) pricing_stats
ORDER BY metric_name;
/*
Observation
* Price per unit ranges from 25.00 to 500.00, averaging 180.12 with variability of ±189.69. The high variability indicating potential for strategic price adjustments.
* Profit margin ranges from 0.00 to 1,875.00 per transaction, averaging 364.32.
* Average quantity per transaction is 2.51 items with a maximum of 4, this suggesting potential to increase basket size.

*/
-- =====================================
-- STEP 3: TIME-BASED ANALYSIS
-- =====================================

-- 3.1 MONTHLY SALES TRENDS
-- Shows revenue patterns across different months
SELECT 
    'MONTHLY SALES TRENDS' AS analysis_section,
    EXTRACT(MONTH FROM sale_date) AS month_number,
    TO_CHAR(sale_date, 'Month') AS month_name,
    COUNT(*) AS transaction_count,
    ROUND(SUM(total_sale), 2) AS monthly_revenue,
    ROUND(AVG(total_sale), 2) AS avg_transaction_value,
    ROUND(SUM(quantity), 0) AS total_items_sold
FROM retail_sales 
GROUP BY EXTRACT(MONTH FROM sale_date), TO_CHAR(sale_date, 'Month')
ORDER BY month_number;
/*
Observation
* September to December generate over 50% of annual revenue.
* December records the highest revenue at 142k and the second-highest transaction count.
* February has the fewest transactions at 91 and the lowest revenue at 41k.
*/

-- 3.2 DAILY SALES PATTERNS
-- Shows which days of the week perform best
SELECT 
    'DAILY SALES PATTERNS' AS analysis_section,
    TO_CHAR(sale_date, 'Day') AS day_of_week,
    EXTRACT(DOW FROM sale_date) AS day_number,
    COUNT(*) AS transaction_count,
    ROUND(SUM(total_sale), 2) AS daily_revenue,
    ROUND(AVG(total_sale), 2) AS avg_transaction_value
FROM retail_sales 
GROUP BY TO_CHAR(sale_date, 'Day'), EXTRACT(DOW FROM sale_date)
ORDER BY day_number;
/*
Observation
* Sunday and Saturday lead in both transaction volume and revenue.
* Monday has the highest average spend per transaction at 529.37 despite fewer transactions.
* Tuesday records the lowest transactions at 246 and the lowest revenue at 103k.
*/
-- 3.3 HOURLY SALES PATTERNS
-- Shows peak shopping hours
SELECT 
    'HOURLY SALES PATTERNS' AS analysis_section,
    EXTRACT(HOUR FROM sale_time) AS hour_of_day,
    COUNT(*) AS transaction_count,
    ROUND(SUM(total_sale), 2) AS hourly_revenue,
    ROUND(AVG(total_sale), 2) AS avg_transaction_value,
    CASE 
        WHEN EXTRACT(HOUR FROM sale_time) >= 6 AND EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning (6AM-12PM)'
        WHEN EXTRACT(HOUR FROM sale_time) >= 12 AND EXTRACT(HOUR FROM sale_time) < 17 THEN 'Afternoon (12PM-5PM)'
        WHEN EXTRACT(HOUR FROM sale_time) >= 17 AND EXTRACT(HOUR FROM sale_time) < 21 THEN 'Evening (5PM-9PM)'
        ELSE 'Night (9PM-6AM)'
    END AS time_period
FROM retail_sales 
GROUP BY EXTRACT(HOUR FROM sale_time)
ORDER BY hour_of_day;
/*
Observation
* The 5 PM to 9 PM period records over 860 transactions and $388k in revenue, accounting for almost half of daily business.
* The 7 AM to 11 AM period maintains a steady flow with an average ticket value of about $470.
* After 10 PM, transactions drop sharply, with only 6 recorded at 11 PM.
*/

-- 3.4 SEASONAL TRENDS AND PATTERNS
-- Identifies seasonal buying patterns
SELECT 
    'SEASONAL BUYING PATTERNS' AS analysis_section,
    season,
    COUNT(*) AS transaction_count,
    ROUND(SUM(total_sale), 2) AS seasonal_revenue,
    ROUND(AVG(total_sale), 2) AS avg_transaction_value,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM retail_sales), 2) AS percentage_of_year
FROM (
    SELECT *,
        CASE 
            WHEN EXTRACT(MONTH FROM sale_date) IN (12, 1, 2) THEN 'Winter'
            WHEN EXTRACT(MONTH FROM sale_date) IN (3, 4, 5) THEN 'Spring'
            WHEN EXTRACT(MONTH FROM sale_date) IN (6, 7, 8) THEN 'Summer'
            WHEN EXTRACT(MONTH FROM sale_date) IN (9, 10, 11) THEN 'Fall'
        END AS season
    FROM retail_sales
) seasonal_data
GROUP BY season 
ORDER BY seasonal_revenue DESC;

/*
Observations
There is a strong seasonal trend in sales.
* Fall is the busiest season with 41.96% of yearly transactions and $381,495 in revenue. Major shopping events drive this surge.
* Winter ranks second with 25.34% of sales, boosted by December holidays. Customers spend more per order despite fewer transactions.
* Spring and Summer are slower, together making up only 32.7% of sales. Spring has fewer buyers but the highest average order value at \$465.79.
Business focus should be on maximizing Fall and Winter while using Spring and Summer for targeted promotions and inventory clearance.
*/

-- =====================================
-- STEP 4: CUSTOMER BEHAVIOR ANALYSIS
-- =====================================

-- 4.1 CUSTOMER PURCHASE FREQUENCY
-- Identifies most loyal customers
SELECT 
    'CUSTOMER LOYALTY ANALYSIS' AS analysis_section,
    customer_id,
    COUNT(*) AS total_purchases,
    ROUND(SUM(total_sale), 2) AS total_spent,
    ROUND(AVG(total_sale), 2) AS avg_purchase_value,
    ROUND(SUM(quantity), 0) AS total_items_purchased,
    MIN(sale_date) AS first_purchase,
    MAX(sale_date) AS last_purchase,
    (MAX(sale_date) - MIN(sale_date)) AS customer_lifespan_days
FROM retail_sales 
GROUP BY customer_id 
HAVING COUNT(*) > 1  -- Only repeat customers
ORDER BY total_spent DESC 
LIMIT 20;
/*
Observation
* Customer #3 generates the highest revenue, matching Customer #1 in visits but spending 7.7k+ more.
* Customers #67, #55 and #71 spend between $650 and $930 per visit despite fewer trips.
* The top 5 customers have shopped for 1.5 to 2 years indicating strong retention.
*/

-- 4.2 CUSTOMER SEGMENTATION BY SPENDING
-- Segments customers into spending tiers
WITH customer_spending AS (
    SELECT 
        customer_id,
        SUM(total_sale) AS total_spent,
        COUNT(*) AS transaction_count,
        AVG(total_sale) AS avg_transaction
    FROM retail_sales 
    GROUP BY customer_id
),
spending_quartiles AS (
    SELECT 
        customer_id,
        total_spent,
        transaction_count,
        avg_transaction,
        NTILE(4) OVER (ORDER BY total_spent) AS spending_quartile
    FROM customer_spending
)
SELECT 
    'CUSTOMER SPENDING SEGMENTS' AS analysis_section,
    CASE 
        WHEN spending_quartile = 4 THEN 'High Value Customers (Top 25%)'
        WHEN spending_quartile = 3 THEN 'Medium-High Value (75th percentile)'
        WHEN spending_quartile = 2 THEN 'Medium Value (50th percentile)'
        ELSE 'Low Value Customers (Bottom 25%)'
    END AS customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spent), 2) AS avg_total_spent,
    ROUND(AVG(transaction_count), 1) AS avg_transactions,
    ROUND(AVG(avg_transaction), 2) AS avg_transaction_value
FROM spending_quartiles
GROUP BY spending_quartile
ORDER BY spending_quartile DESC;

/*
Observation
* The top 38 customers generate about ~6x more revenue than the bottom 39.
* High-value shoppers spend 80% more per transaction than low-value shoppers.
* Trip frequency doubles with each higher segment showing that loyalty increases lifetime value.
*/

-- 4.3 CUSTOMER LIFETIME VALUE ANALYSIS
-- Calculates CLV and customer segments
WITH customer_metrics AS (
    SELECT 
        customer_id,
        gender,
        ROUND(AVG(age), 0) AS age,
        COUNT(*) AS total_transactions,
        ROUND(SUM(total_sale), 2) AS total_revenue,
        ROUND(AVG(total_sale), 2) AS avg_order_value,
        (MAX(sale_date) - MIN(sale_date)) + 1 AS customer_lifespan_days,
        MIN(sale_date) AS first_purchase,
        MAX(sale_date) AS last_purchase
    FROM retail_sales 
    GROUP BY customer_id, gender
)
SELECT 
    'CUSTOMER LIFETIME VALUE ANALYSIS' AS analysis_section,
    customer_id,
    gender,
    age,
    total_transactions,
    total_revenue,
    avg_order_value,
    customer_lifespan_days,
    ROUND(total_revenue / NULLIF(customer_lifespan_days, 0), 2) AS daily_value,
    CASE 
        WHEN total_revenue >= 2000 THEN 'VIP Customer'
        WHEN total_revenue >= 1000 THEN 'High Value Customer'
        WHEN total_revenue >= 500 THEN 'Medium Value Customer'
        ELSE 'Low Value Customer'
    END AS customer_segment,
    first_purchase,
    last_purchase,
    ROUND(total_revenue / NULLIF(total_transactions, 0), 2) AS revenue_per_transaction,
    CASE 
        WHEN customer_lifespan_days > 180 THEN 'Established (>6 months)'
        WHEN customer_lifespan_days > 30 THEN 'Developing (1-6 months)'
        ELSE 'New (<1 month)'
    END AS customer_tenure
FROM customer_metrics
ORDER BY total_revenue DESC;
/*
Observations
There is a clear concentration of revenue among a small group of top customers. A few VIPs drive most of the business, while many others contribute little.
* The top 5 customers each spent over $13,000, with one contributing nearly $25,000. More than 50 customers spent under \$500 each.
* Two valuable customer types stand out: frequent loyal shoppers with steady spend and occasional buyers with very high order values.
* Some customers generate high daily value by spending heavily in a short time making them extremely profitable.
* Most high-value customers stay for long periods showing strong retention and loyalty.
* Top customers are balanced across genders and spread across ages 28–48 showing wide demographic appeal.
*/

-- 4.4 CUSTOMER RANKING AND PERCENTILES
-- Ranks customers by various metrics
WITH customer_rankings AS (
    SELECT 
        customer_id,
        gender,
        SUM(total_sale) AS total_spent,
        COUNT(*) AS transaction_count,
        AVG(total_sale) AS avg_transaction,
        RANK() OVER (ORDER BY SUM(total_sale) DESC) AS spending_rank,
        ROUND(PERCENT_RANK() OVER (ORDER BY SUM(total_sale))::numeric * 100, 1) AS spending_percentile,
        NTILE(10) OVER (ORDER BY SUM(total_sale)) AS spending_decile,
        MIN(sale_date) AS first_purchase_date,
        MAX(sale_date) AS last_purchase_date,
        (MAX(sale_date) - MIN(sale_date)) AS customer_tenure_days
    FROM retail_sales 
    GROUP BY customer_id, gender
)
SELECT 
    'CUSTOMER RANKINGS AND PERCENTILES' AS analysis_section,
    customer_id,
    gender,
    ROUND(total_spent::numeric, 2) AS total_spent,
    transaction_count,
    ROUND(avg_transaction::numeric, 2) AS avg_transaction,
    spending_rank,
    spending_percentile,
    spending_decile,
    CASE 
        WHEN spending_decile >= 9 THEN 'Top 20% (VIP)'
        WHEN spending_decile >= 7 THEN 'Top 40% (High Value)'
        WHEN spending_decile >= 4 THEN 'Middle 40% (Regular)'
        ELSE 'Bottom 40% (Occasional)'
    END AS customer_tier,
    first_purchase_date,
    last_purchase_date,
    customer_tenure_days,
    ROUND(total_spent / NULLIF(customer_tenure_days, 0)::numeric, 2) AS daily_spending_rate
FROM customer_rankings
ORDER BY spending_rank
LIMIT 25;
/*
Observations
There is a large gap between your top customers and the rest. A few individuals drive most of the revenue, while the majority contribute far less.
* The top customer spent $24,895, which is 38% more than the second-ranked customer and over 100 times more than a low-value customer. Retaining these top clients is critical.
* All ranked customers fall in the top 10% by spending. This allows segmentation into Ultra-VIPs (top 5%), high-value customers to nurture (next 5%) and high-potential customers (next 10%).
* Two VIP profiles appear: loyal frequent buyers with steady spend and occasional buyers with very large orders.
* Customers with high daily spending rates generate the fastest returns, making them especially efficient and profitable.
* Even customers ranked as low as #25 remain in the 92nd percentile, showing a steep drop in value outside the top tiers.
*/

-- 4.5 REPEAT CUSTOMERS 
-- Find customers who have made more than 1 purchase and their average spending
SELECT 
    'REPEAT CUSTOMERS ANALYSIS' AS query_type,
    customer_id,
    gender,
    ROUND(AVG(age), 0) AS age,
    COUNT(*) AS total_purchases,
    ROUND(SUM(total_sale), 2) AS total_spent,
    ROUND(AVG(total_sale), 2) AS avg_spending_per_visit,
    ROUND(SUM(quantity), 0) AS total_items_purchased,
    (MAX(sale_date) - MIN(sale_date)) AS days_between_first_last_purchase,
    ROUND((MAX(sale_date) - MIN(sale_date))::numeric / NULLIF(COUNT(*)-1, 0), 1) AS avg_days_between_purchases
FROM retail_sales 
GROUP BY customer_id, gender 
HAVING COUNT(*) > 1
ORDER BY total_spent DESC;

/*
Observations
There is strong evidence that our business depends on loyal repeat customers who generate most of the revenue. Distinct shopping patterns reveal clear opportunities to retain and grow value.
* The top 10 customers bring in about $150,000, with one customer alone spending $24,895 across 41 purchases. Losing even one would require dozens of replacements.
* Two main profiles exist: frequent shoppers who buy often with steady spend and event-driven shoppers who buy rarely but spend heavily each time.
* More purchases almost always mean higher total spend, showing frequency is the strongest driver of customer value.
* Short purchase cycles (10–15 days for top customers) can signal loyalty, while delays beyond normal cycles can flag at-risk customers.
* A long tail of occasional shoppers makes only a few purchases, but even small increases in their frequency would create large revenue gains.
*/

-- 4.6 CUSTOMER FREQUENCY SEGMENTATION
-- RFM-style analysis (Recency, Frequency, Monetary)
WITH customer_rfm AS (
    SELECT 
        customer_id,
        CURRENT_DATE - MAX(sale_date) AS recency_days,
        COUNT(*) AS frequency,
        SUM(total_sale) AS monetary_value,
        AVG(total_sale) AS avg_order_value
    FROM retail_sales 
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT 
        customer_id,
        recency_days,
        frequency,
        ROUND(monetary_value::numeric, 2) AS monetary_value,
        ROUND(avg_order_value::numeric, 2) AS avg_order_value,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary_value ASC) AS monetary_score
    FROM customer_rfm
)
SELECT 
    'RFM CUSTOMER SEGMENTATION' AS analysis_section,
    customer_id,
    recency_days,
    frequency,
    monetary_value,
    avg_order_value,
    recency_score,
    frequency_score,
    monetary_score,
    CASE 
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'Loyal Customers'
        WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'New Customers'
        WHEN recency_score <= 2 AND frequency_score >= 3 THEN 'At Risk'
        WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'Lost Customers'
        ELSE 'Potential Loyalists'
    END AS customer_segment
FROM rfm_scores
ORDER BY monetary_value DESC;
/*
Observations
There is a clear segmentation of customers based on recency, frequency and monetary value. 
This gives a sharper picture than spend alone and shows who is loyal, who is at risk and who could grow in value.
* Champions are your best customers. They buy often, spend a lot and purchased recently. Keep them loyal with rewards and exclusive offers.
* Loyal Customers spend well and shop often but have not purchased as recently. Simple nudges or rewards can bring them back.
* At Risk customers spent heavily before but have not purchased for a long time. They need urgent re-engagement with strong offers.
* Potential Loyalists buy recently and often but spend less. Upselling and product education can increase their value.
* New Customers bought recently but lack history. A strong welcome experience is needed to move them toward loyalty.
* Lost Customers score low in all areas. Focus should be on higher-value groups instead of re-acquiring low-value ones.
*/

-- 4.7 MONTHLY COHORT ANALYSIS
-- Tracks customer retention by their first purchase month
WITH first_purchase AS (
    SELECT 
        customer_id,
        MIN(sale_date) AS first_purchase_date,
        TO_CHAR(MIN(sale_date), 'YYYY-MM') AS cohort_month
    FROM retail_sales 
    GROUP BY customer_id
),
customer_activity AS (
    SELECT 
        r.customer_id,
        f.cohort_month,
        TO_CHAR(r.sale_date, 'YYYY-MM') AS activity_month,
        (EXTRACT(YEAR FROM r.sale_date) - EXTRACT(YEAR FROM f.first_purchase_date)) * 12 +
        (EXTRACT(MONTH FROM r.sale_date) - EXTRACT(MONTH FROM f.first_purchase_date)) AS period_number
    FROM retail_sales r
    JOIN first_purchase f ON r.customer_id = f.customer_id
)
SELECT 
    'MONTHLY COHORT ANALYSIS' AS analysis_section,
    cohort_month,
    COUNT(DISTINCT customer_id) AS cohort_size,
    COUNT(DISTINCT CASE WHEN period_number = 0 THEN customer_id END) AS month_0,
    COUNT(DISTINCT CASE WHEN period_number = 1 THEN customer_id END) AS month_1,
    COUNT(DISTINCT CASE WHEN period_number = 2 THEN customer_id END) AS month_2,
    COUNT(DISTINCT CASE WHEN period_number = 3 THEN customer_id END) AS month_3,
    ROUND(COUNT(DISTINCT CASE WHEN period_number = 1 THEN customer_id END) * 100.0 / 
          NULLIF(COUNT(DISTINCT CASE WHEN period_number = 0 THEN customer_id END), 0), 2) AS month_1_retention,
    ROUND(COUNT(DISTINCT CASE WHEN period_number = 2 THEN customer_id END) * 100.0 / 
          NULLIF(COUNT(DISTINCT CASE WHEN period_number = 0 THEN customer_id END), 0), 2) AS month_2_retention
FROM customer_activity
GROUP BY cohort_month
ORDER BY cohort_month;
/*
Observations
There is strong customer acquisition, but retention is weak and inconsistent. Many first-time buyers do not return after their initial purchase.
* The largest cohort (January 2022) brought in 49 new customers, but only 24.49% returned in Month 1 and 32.65% by Month 2. Retention is low despite high acquisition.
* Retention rates are unstable, ranging from 0% in some months to 75% or even 100% in others. This shows the lack of a consistent retention system.
* New customer acquisition slowed in late 2022, with some cohorts having only 1 customer, making growth harder.
* August 2022 is a positive outlier. All 4 new customers returned by Month 2, proving high retention is possible when conditions are right.
*/

-- =====================================
-- STEP 5: CATEGORY AND PRODUCT ANALYSIS
-- =====================================

-- 5.1 CATEGORY PERFORMANCE BY GENDER
-- Shows gender preferences across product categories
SELECT 
    'CATEGORY PREFERENCES BY GENDER' AS analysis_section,
    category,
    gender,
    COUNT(*) AS transaction_count,
    ROUND(SUM(total_sale), 2) AS revenue,
    ROUND(AVG(total_sale), 2) AS avg_transaction_value,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY category), 2) AS gender_percentage_within_category
FROM retail_sales 
GROUP BY category, gender 
ORDER BY category, transaction_count DESC;

/*
Observation
* In Beauty, 53.92% of buyers are female but men spend more per transaction at 487.13 compared to 452.94. Target men with premium Beauty products like grooming kits.
* In Clothing, the gender split is about equal but women spend 11.5% more per transaction at 468.18 compared to 419.80. Offer women’s exclusive styling bundles to increase this gap.
* In Electronics, the gender split is nearly equal with 50.29% male and 49.71% female, but men spend 3.3% more at 466.10 compared to 451.38. 
  Create gender-neutral tech bundles like smart home starter packs.
*/

-- 5.2 CATEGORY PERFORMANCE BY AGE GROUP
-- Shows age group preferences across product categories
SELECT 
    'CATEGORY PREFERENCES BY AGE GROUP' AS analysis_section,
    category,
    age_group,
    COUNT(*) AS transaction_count,
    ROUND(SUM(total_sale), 2) AS revenue,
    ROUND(AVG(total_sale), 2) AS avg_transaction_value
FROM (
    SELECT *,
        CASE 
            WHEN age < 25 THEN 'Gen-Z'
            WHEN age >= 25 AND age < 35 THEN 'Millenials'
            WHEN age >= 35 AND age < 45 THEN 'Gen-X'
            WHEN age >= 45 AND age < 55 THEN 'Boomers'
            WHEN age >= 55 THEN 'Silent'
        END AS age_group
    FROM retail_sales
) categorised
GROUP BY category, age_group 
ORDER BY category, transaction_count DESC;

/*
Observation
* In Beauty, the 35–44 age group has the highest average spend at 577.45 followed by under 25 at 549.71. The 55+ group spends 42% less at 335.28. 
  Launch age-defying skincare kits for 35–44 and target Gen Z with trendy mini sets.
* In Clothing, Millennials (25–34) have the highest average spend at 573.72 and revenue at 83k. 
  Seniors (55+) have the lowest average spend at 391.38 despite high transaction volume. Offer workwear capsules for Millennials and comfort-focused lines for seniors.
* In Electronics, the 55+ group has the highest average spend at 518.39 while the 45–54 group has the lowest at 409.06. 
  Market easy-to-use tech bundles to seniors and upgrade deals to the 35–44 group.
*/

-- 5.3 PROFITABILITY ANALYSIS BY CATEGORY
-- Shows which categories are most profitable
SELECT 
    'CATEGORY PROFITABILITY ANALYSIS' AS analysis_section,
    category,
    COUNT(*) AS transaction_count,
    ROUND(SUM(total_sale), 2) AS total_revenue,
    ROUND(SUM(cogs), 2) AS total_costs,
    ROUND(SUM(total_sale - cogs), 2) AS total_profit,
    ROUND((SUM(total_sale - cogs) / SUM(total_sale)) * 100, 2) AS profit_margin_percent,
    ROUND(AVG(total_sale - cogs), 2) AS avg_profit_per_transaction
FROM retail_sales 
GROUP BY category 
ORDER BY total_profit DESC;

/*
Observation
* Beauty generates 286,840.00 in revenue with 229,736.00 profit, an 80.09% margin and the highest average profit per transaction at 375.39.
* Clothing generates 311,070.00 in revenue with 248,998.00 profit, an 80.05% margin supported by strong volume but slightly lower margins.
* Electronics generates 313,810.00 in revenue with 248,823.00 profit, a 79.29% margin with the lowest margin but strong high-ticket potential.
*/

-- 5.4 CATEGORY PERFORMANCE COMPARISON
-- Compares each category's performance against others
WITH category_metrics AS (
    SELECT 
        category,
        COUNT(*) AS transaction_count,
        SUM(total_sale) AS total_revenue,
        AVG(total_sale) AS avg_transaction,
        SUM(quantity) AS total_items
    FROM retail_sales 
    GROUP BY category
)
SELECT 
    'CATEGORY PERFORMANCE COMPARISON' AS analysis_section,
    category,
    transaction_count,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(avg_transaction, 2) AS avg_transaction,
    total_items,
    ROUND(total_revenue / SUM(total_revenue) OVER () * 100, 2) AS revenue_share_percent,
    ROUND(transaction_count / SUM(transaction_count) OVER () * 100, 2) AS transaction_share_percent,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    RANK() OVER (ORDER BY avg_transaction DESC) AS avg_transaction_rank
FROM category_metrics
ORDER BY total_revenue DESC;

/*
There is strong balance across the three product categories. Each contributes significantly to revenue, but they play different roles in driving growth.
* Electronics leads revenue at $313,810, but Clothing is close at $311,070 and Beauty follows at $286,840. The spread between top and bottom is only $27,000 showing no single-category dependency.
* Beauty delivers the highest average transaction value at $468.69, making it the most profitable per order.
* Clothing generates the most activity with 701 transactions and 1,785 items sold, though it has the lowest average spend per visit.
* Electronics balances all factors with the highest revenue, strong transaction counts and a solid average order value.
*/

-- 5.5 PRODUCT MIX ANALYSIS
-- Analyses produuct mix and cross-selling opportunities
SELECT 
    'PRODUCT MIX ANALYSIS' AS analysis_section,
    category,
    COUNT(*) AS transaction_count,
    ROUND(SUM(total_sale), 2) AS category_revenue,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM retail_sales), 2) AS transaction_share,
    ROUND(SUM(total_sale) * 100.0 / (SELECT SUM(total_sale) FROM retail_sales), 2) AS revenue_share,
    ROUND(AVG(quantity), 1) AS avg_items_per_transaction,
    ROUND(AVG(total_sale), 2) AS avg_transaction_value
FROM retail_sales 
GROUP BY category 
ORDER BY category_revenue DESC;

/*
Observations
The product mix is balanced and efficient. The standout finding is that all three categories share the same average basket size of 2.5 items.
* Revenue and transaction shares are nearly identical. Electronics contributes 34.42% of revenue with 34.25% of transactions, Clothing 34.12% revenue with 35.10% transactions
  and Beauty 31.46% revenue with 30.65% transactions. This balance reduces business risk.
* Each category averages 2.5 items per transaction. This shows consistent sales execution and customer behavior across all product types.
* Roles are defined. Beauty delivers the highest average transaction value at $468.69. Clothing drives traffic with 701 transactions. Electronics leads revenue with $313,810 
  and shows steady performance.
*/

-- =====================================
-- STEP 6: TRANSACTIONS ANALYSIS
-- =====================================

-- 6.1 OUTLIER TRANSACTIONS ANALYSIS
-- Identifies unusual transactions for further investigation
WITH transaction_stats AS (
    SELECT 
        AVG(total_sale) AS avg_sale,
        STDDEV(total_sale) AS std_sale
    FROM retail_sales
)
SELECT 
    'OUTLIER TRANSACTIONS ANALYSIS' AS analysis_section,
    r.transactions_id,
    r.customer_id,
    r.sale_date,
    r.category,
    r.total_sale,
    ROUND(t.avg_sale, 2) AS dataset_avg_sale,
    ROUND((r.total_sale - t.avg_sale) / t.std_sale, 2) AS z_score,
    CASE 
        WHEN ABS((r.total_sale - t.avg_sale) / t.std_sale) > 3 THEN 'Extreme Outlier'
        WHEN ABS((r.total_sale - t.avg_sale) / t.std_sale) > 2 THEN 'Moderate Outlier'
        ELSE 'Normal Transaction'
    END AS outlier_category
FROM retail_sales r
CROSS JOIN transaction_stats t
WHERE ABS((r.total_sale - t.avg_sale) / t.std_sale) > 2
ORDER BY ABS((r.total_sale - t.avg_sale) / t.std_sale) DESC;
/*
Observations
* Outliers were identified using the Z-score. All transactions on the list have a Z-score of 2.76, making them moderate outliers.
* The average transaction value is $456.54. Each outlier transaction is $2,000, which is more than four times the average and also the dataset’s maximum value.
* There are 100 such outlier transactions, showing a consistent pattern of high-value sales.
* Distribution by category: Electronics has about 43, Clothing about 30 and Beauty about 27. All categories contribute.
* These sales appear in every month across 2022 and 2023, showing they are not seasonal spikes.
* Many different customers make these purchases, not just a few. This indicates a broad base of high-value buyers.
*/
-- 6.2 RUNNING TOTALS AND MOVING AVERAGES
-- Shows cumulative sales and trends over time
SELECT 
    'RUNNING TOTALS AND TRENDS' AS analysis_section,
    sale_date,
    COUNT(*) AS daily_transactions,
    ROUND(SUM(total_sale), 2) AS daily_revenue,
    ROUND(SUM(SUM(total_sale)) OVER (ORDER BY sale_date ROWS UNBOUNDED PRECEDING), 2) AS running_total_revenue,
    ROUND(AVG(SUM(total_sale)) OVER (ORDER BY sale_date ROWS 6 PRECEDING), 2) AS seven_day_avg_revenue,
    ROUND(SUM(total_sale) - LAG(SUM(total_sale), 1) OVER (ORDER BY sale_date), 2) AS day_over_day_change
FROM retail_sales 
GROUP BY sale_date 
ORDER BY sale_date;

/*
Observations
The output shows daily sales performance and cumulative revenue for 2022–2023.
* Revenue grows from $2,150 on January 1, 2022 to $911,720 on December 31, 2023. The business expands steadily over two years.
* Daily revenue is unstable that is $7,900 on 2022-10-10 and $8,400 on 2023-11-23. Large sales or promotions cause these swings.
* Seasonal cycles are clear. Sales slow in early 2022 and 2023, averaging $200–400. Q4 peaks at $3,500–3,800 in both years.
* The 7-day average is a useful guide. Rising averages show momentum. Falling averages warn of slowdown.
* Sales are missing on some dates, showing the store does not operate every day.
*/

-- 6.3 HIGH VALUE TRANSACTIONS
---All transactions where the total sale is greater than 1000
SELECT 
    'HIGH VALUE TRANSACTIONS (>1000)' AS query_type,
    transactions_id,
    customer_id,
    sale_date,
    category,
    gender,
    age,
    quantity,
    price_per_unit,
    total_sale,
    (total_sale - cogs) AS profit
FROM retail_sales 
WHERE total_sale > 1000
ORDER BY total_sale DESC;

/*
Observations
* There are over 100 transactions exceeding 1,000.00, averaging between 1,500.00 and 2,000.00 per sale.
* Electronics account for 60% of these high-value transactions followed by Beauty at 25% and Clothing at 15%.
* Top spenders include males aged 45–60 in Electronics and females aged 30–45 in Beauty bundles.
* Profit margins are highest in Beauty at about 85% and lowest in Electronics at about 75%.
* Bulk purchases make up 80% of these transactions involving 3–4 items each.
* Seasonal spikes occur in Q4, accounting for 40% of high-value transactions.
*/

-- =====================================
-- CONCLUSION
-- =====================================
/*

The project analysis of the retail sales dataset has successfully transformed raw transactional data. It has helped a business to actually understand its data. 
Through the analysis of two years of retail transactions, we were able to see how customers shop, when sales peak and which products make the biggest impact.

OUTCOME:
* The business earned over $900,000 in revenue across 1,997 transactions with strong peaks in the last quarter of each year.
* Clothing, Electronics and Beauty performed almost equally in total revenue but each played a unique role. Clothing drove the most activity, Electronics generated the 
  largest revenue and Beauty delivered the highest profit margin.
* Customers aged 35–54 dominated sales volume while younger shoppers (Gen Z) showed the highest average spend per transaction.
* Weekends and evening hours proved to be the most valuable selling periods. Seasonal analysis confirmed Fall and Winter as peak revenue seasons.
* Customer analysis revealed a clear imbalance: a small group of VIP customers generated a large share of revenue while most shoppers contributed little. 
  Loyal repeat customers showed steady value, while many new buyers did not return, exposing weak retention.
* RFM segmentation and cohort analysis provided sharper views of customer loyalty, showing who to retain, who to re-engage and who to prioritise.

BUSINESS OPPORTINITIES:
1. Double down on loyal and high-value customers with targeted rewards and personalised offers.
2. Maximise Fall and Winter sales while using Spring and Summer for promotions and inventory clearance.
3. Focus marketing on young high-spending shoppers while maintaining engagement with middle-aged high-volume buyers.
4. Strengthen retention strategies, since acquiring new customers without keeping them long term leads to lost growth potential.

*/
-- =====================================
-- END OF THE ANALYSIS
-- =====================================