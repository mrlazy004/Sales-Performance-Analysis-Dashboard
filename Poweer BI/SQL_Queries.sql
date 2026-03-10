-- ============================================================
--  SALES PERFORMANCE ANALYSIS — SQL QUERIES
--  Database: MySQL 8+ / PostgreSQL 14+
--  Table: sales_data
-- ============================================================

-- ── TABLE CREATION ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sales_data (
    Order_ID       VARCHAR(20)    PRIMARY KEY,
    Order_Date     DATE           NOT NULL,
    Product_Name   VARCHAR(100)   NOT NULL,
    Category       VARCHAR(50)    NOT NULL,
    Region         VARCHAR(30)    NOT NULL,
    Customer_ID    VARCHAR(20)    NOT NULL,
    Quantity       INT            NOT NULL,
    Sales          DECIMAL(10,2)  NOT NULL,
    Profit         DECIMAL(10,2)  NOT NULL
);

-- ── DATA IMPORT (PostgreSQL COPY / MySQL LOAD DATA) ──────────
-- PostgreSQL:
-- \COPY sales_data FROM 'cleaned_sales_data.csv' CSV HEADER;

-- MySQL:
-- LOAD DATA INFILE '/path/to/cleaned_sales_data.csv'
-- INTO TABLE sales_data
-- FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;


-- ============================================================
--  QUERY 1: TOP SELLING PRODUCTS (by Revenue)
-- ============================================================
SELECT
    Product_Name,
    Category,
    SUM(Quantity)              AS Total_Units_Sold,
    ROUND(SUM(Sales), 2)       AS Total_Revenue,
    ROUND(SUM(Profit), 2)      AS Total_Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 1) AS Profit_Margin_Pct,
    RANK() OVER (ORDER BY SUM(Sales) DESC)  AS Revenue_Rank
FROM sales_data
GROUP BY Product_Name, Category
ORDER BY Total_Revenue DESC
LIMIT 10;


-- ============================================================
--  QUERY 2: TOP SELLING PRODUCTS (by Volume)
-- ============================================================
SELECT
    Product_Name,
    Category,
    SUM(Quantity)         AS Total_Units_Sold,
    COUNT(Order_ID)       AS Number_of_Orders,
    ROUND(SUM(Sales), 2)  AS Total_Revenue
FROM sales_data
GROUP BY Product_Name, Category
ORDER BY Total_Units_Sold DESC
LIMIT 10;


-- ============================================================
--  QUERY 3: REGION-WISE REVENUE BREAKDOWN
-- ============================================================
SELECT
    Region,
    COUNT(DISTINCT Customer_ID)                             AS Unique_Customers,
    COUNT(Order_ID)                                         AS Total_Orders,
    ROUND(SUM(Sales), 2)                                    AS Total_Revenue,
    ROUND(SUM(Profit), 2)                                   AS Total_Profit,
    ROUND(AVG(Sales), 2)                                    AS Avg_Order_Value,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 1)    AS Profit_Margin_Pct,
    ROUND(SUM(Sales) * 100.0 / SUM(SUM(Sales)) OVER (), 1) AS Revenue_Share_Pct
FROM sales_data
GROUP BY Region
ORDER BY Total_Revenue DESC;


-- ============================================================
--  QUERY 4: REGION × CATEGORY CROSS ANALYSIS
-- ============================================================
SELECT
    Region,
    Category,
    ROUND(SUM(Sales), 2)   AS Revenue,
    ROUND(SUM(Profit), 2)  AS Profit,
    COUNT(Order_ID)         AS Orders
FROM sales_data
GROUP BY Region, Category
ORDER BY Region, Revenue DESC;


-- ============================================================
--  QUERY 5: MONTHLY SALES TREND
-- ============================================================
SELECT
    DATE_FORMAT(Order_Date, '%Y-%m')    AS Month,       -- MySQL
    -- TO_CHAR(Order_Date, 'YYYY-MM')   AS Month,       -- PostgreSQL
    COUNT(Order_ID)                      AS Orders,
    ROUND(SUM(Sales), 2)                 AS Monthly_Revenue,
    ROUND(SUM(Profit), 2)                AS Monthly_Profit,
    ROUND(AVG(Sales), 2)                 AS Avg_Order_Value,
    ROUND(
        (SUM(Sales) - LAG(SUM(Sales)) OVER (ORDER BY DATE_FORMAT(Order_Date, '%Y-%m')))
        / NULLIF(LAG(SUM(Sales)) OVER (ORDER BY DATE_FORMAT(Order_Date, '%Y-%m')), 0) * 100,
    1)                                   AS MoM_Growth_Pct
FROM sales_data
GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
ORDER BY Month;


-- ============================================================
--  QUERY 6: QUARTERLY SALES TREND
-- ============================================================
SELECT
    YEAR(Order_Date)                           AS Year,   -- MySQL
    QUARTER(Order_Date)                         AS Quarter,
    CONCAT('Q', QUARTER(Order_Date))            AS Quarter_Label,
    ROUND(SUM(Sales), 2)                        AS Revenue,
    ROUND(SUM(Profit), 2)                       AS Profit,
    COUNT(DISTINCT Customer_ID)                  AS Customers
FROM sales_data
GROUP BY YEAR(Order_Date), QUARTER(Order_Date)
ORDER BY Year, Quarter;


-- ============================================================
--  QUERY 7: PROFIT vs LOSS PRODUCTS
-- ============================================================
SELECT
    Product_Name,
    Category,
    ROUND(SUM(Sales), 2)                AS Total_Revenue,
    ROUND(SUM(Profit), 2)               AS Total_Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales),0) * 100, 1) AS Margin_Pct,
    CASE
        WHEN SUM(Profit) > 0  THEN 'Profitable'
        WHEN SUM(Profit) = 0  THEN 'Break-Even'
        ELSE 'Loss-Making'
    END                                 AS Profit_Status,
    COUNT(Order_ID)                      AS Orders
FROM sales_data
GROUP BY Product_Name, Category
ORDER BY Total_Profit ASC;


-- ============================================================
--  QUERY 8: LOSS-MAKING PRODUCTS (Priority Alert)
-- ============================================================
SELECT
    Product_Name,
    Category,
    Region,
    ROUND(SUM(Sales), 2)   AS Revenue,
    ROUND(SUM(Profit), 2)  AS Loss_Amount,
    COUNT(Order_ID)         AS Orders_With_Loss
FROM sales_data
WHERE Profit < 0
GROUP BY Product_Name, Category, Region
ORDER BY Loss_Amount ASC
LIMIT 15;


-- ============================================================
--  QUERY 9: CUSTOMER SEGMENTATION (RFM-lite)
-- ============================================================
SELECT
    Customer_ID,
    COUNT(Order_ID)             AS Frequency,
    ROUND(SUM(Sales), 2)        AS Monetary_Value,
    ROUND(AVG(Sales), 2)        AS Avg_Order_Value,
    MAX(Order_Date)             AS Last_Purchase_Date,
    DATEDIFF(CURDATE(), MAX(Order_Date)) AS Recency_Days,  -- MySQL
    CASE
        WHEN SUM(Sales) > 5000  THEN 'VIP'
        WHEN SUM(Sales) > 2000  THEN 'High Value'
        WHEN SUM(Sales) > 500   THEN 'Mid Value'
        ELSE 'Low Value'
    END                          AS Customer_Segment
FROM sales_data
GROUP BY Customer_ID
ORDER BY Monetary_Value DESC
LIMIT 20;


-- ============================================================
--  QUERY 10: CATEGORY PERFORMANCE SCORECARD
-- ============================================================
SELECT
    Category,
    COUNT(DISTINCT Product_Name)                            AS Unique_Products,
    COUNT(DISTINCT Customer_ID)                             AS Unique_Customers,
    SUM(Quantity)                                           AS Units_Sold,
    ROUND(SUM(Sales), 2)                                    AS Total_Revenue,
    ROUND(SUM(Profit), 2)                                   AS Total_Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales), 0) * 100, 1)    AS Profit_Margin_Pct,
    ROUND(AVG(Sales), 2)                                    AS Avg_Order_Value,
    ROUND(SUM(Sales) * 100.0 / SUM(SUM(Sales)) OVER (), 1) AS Revenue_Share_Pct,
    RANK() OVER (ORDER BY SUM(Sales) DESC)                  AS Category_Rank
FROM sales_data
GROUP BY Category
ORDER BY Total_Revenue DESC;


-- ============================================================
--  QUERY 11: DAILY PEAK SALES ANALYSIS
-- ============================================================
SELECT
    DAYNAME(Order_Date)   AS Day_of_Week,
    DAYOFWEEK(Order_Date) AS Day_Num,
    COUNT(Order_ID)        AS Orders,
    ROUND(AVG(Sales), 2)  AS Avg_Daily_Revenue
FROM sales_data
GROUP BY DAYNAME(Order_Date), DAYOFWEEK(Order_Date)
ORDER BY Day_Num;


-- ============================================================
--  QUERY 12: YOY GROWTH COMPARISON
-- ============================================================
SELECT
    curr.Year,
    curr.Category,
    curr.Revenue                                       AS Current_Revenue,
    prev.Revenue                                       AS Prev_Revenue,
    ROUND((curr.Revenue - prev.Revenue)
          / NULLIF(prev.Revenue, 0) * 100, 1)         AS YoY_Growth_Pct
FROM (
    SELECT YEAR(Order_Date) AS Year, Category,
           ROUND(SUM(Sales), 2) AS Revenue
    FROM sales_data GROUP BY YEAR(Order_Date), Category
) curr
LEFT JOIN (
    SELECT YEAR(Order_Date) AS Year, Category,
           ROUND(SUM(Sales), 2) AS Revenue
    FROM sales_data GROUP BY YEAR(Order_Date), Category
) prev ON curr.Category = prev.Category AND curr.Year = prev.Year + 1
WHERE curr.Year = (SELECT MAX(YEAR(Order_Date)) FROM sales_data)
ORDER BY YoY_Growth_Pct DESC;


-- ============================================================
--  QUERY 13: EXECUTIVE SUMMARY VIEW
-- ============================================================
CREATE OR REPLACE VIEW executive_summary AS
SELECT
    'All Time'                                 AS Period,
    COUNT(DISTINCT Order_ID)                   AS Total_Orders,
    COUNT(DISTINCT Customer_ID)                AS Total_Customers,
    ROUND(SUM(Sales), 2)                       AS Total_Revenue,
    ROUND(SUM(Profit), 2)                      AS Total_Profit,
    ROUND(SUM(Profit)/NULLIF(SUM(Sales),0)*100,1) AS Overall_Margin_Pct,
    ROUND(AVG(Sales), 2)                       AS Avg_Order_Value,
    COUNT(DISTINCT Product_Name)               AS Products_Sold,
    COUNT(DISTINCT Region)                     AS Active_Regions
FROM sales_data;

SELECT * FROM executive_summary;
