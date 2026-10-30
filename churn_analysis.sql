-- =====================================================================
-- Bank Customer Churn Analysis  |  MySQL 8
-- Author: Dattatrieya G H
-- Dataset: Kaggle "Bank Customer Churn" (Churn_Modelling.csv), 10,000 rows
-- Business question: Which customer segments is the bank losing,
--                    and where should retention efforts focus?
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. SETUP: create table, then import Churn_Modelling.csv using
--    MySQL Workbench > right-click table > Table Data Import Wizard
-- ---------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS bank_churn;
USE bank_churn;

CREATE TABLE IF NOT EXISTS customers (
    RowNumber        INT,
    CustomerId       INT PRIMARY KEY,
    Surname          VARCHAR(50),
    CreditScore      INT,
    Geography        VARCHAR(20),
    Gender           VARCHAR(10),
    Age              INT,
    Tenure           INT,
    Balance          DECIMAL(12,2),
    NumOfProducts    INT,
    HasCrCard        TINYINT,
    IsActiveMember   TINYINT,
    EstimatedSalary  DECIMAL(12,2),
    Exited           TINYINT          -- 1 = customer left the bank
);

-- ---------------------------------------------------------------------
-- 1. DATA QUALITY CHECKS
-- ---------------------------------------------------------------------
-- 1a. Row count (expected: 10,000)
SELECT COUNT(*) AS total_rows FROM customers;

-- 1b. Duplicate customers (expected: 0)
SELECT CustomerId, COUNT(*) AS cnt
FROM customers
GROUP BY CustomerId
HAVING COUNT(*) > 1;

-- 1c. Missing values in key columns (expected: 0)
SELECT
    SUM(CASE WHEN Geography IS NULL THEN 1 ELSE 0 END) AS null_geo,
    SUM(CASE WHEN Age       IS NULL THEN 1 ELSE 0 END) AS null_age,
    SUM(CASE WHEN Balance   IS NULL THEN 1 ELSE 0 END) AS null_balance,
    SUM(CASE WHEN Exited    IS NULL THEN 1 ELSE 0 END) AS null_exited
FROM customers;

-- 1d. Customers with zero balance (finding: 3,617)
SELECT COUNT(*) AS zero_balance_customers FROM customers WHERE Balance = 0;

-- ---------------------------------------------------------------------
-- 2. OVERALL KPIs
-- ---------------------------------------------------------------------
-- Finding: 2,037 of 10,000 customers churned = 20.4%
SELECT
    COUNT(*)                         AS total_customers,
    SUM(Exited)                      AS churned,
    ROUND(100 * AVG(Exited), 1)      AS churn_rate_pct
FROM customers;

-- Finding: $185.6M in balances left with churned customers = 24.3% of all deposits
SELECT
    ROUND(SUM(CASE WHEN Exited = 1 THEN Balance ELSE 0 END) / 1e6, 1) AS balance_lost_m,
    ROUND(100 * SUM(CASE WHEN Exited = 1 THEN Balance ELSE 0 END) / SUM(Balance), 1) AS pct_deposits_lost
FROM customers;

-- ---------------------------------------------------------------------
-- 3. SEGMENT ANALYSIS
-- ---------------------------------------------------------------------
-- 3a. Geography  -> Germany 32.4% vs France 16.2%, Spain 16.7% (2x)
SELECT Geography,
       COUNT(*) AS customers,
       SUM(Exited) AS churned,
       ROUND(100 * AVG(Exited), 1) AS churn_rate_pct,
       ROUND(SUM(CASE WHEN Exited = 1 THEN Balance ELSE 0 END) / 1e6, 1) AS balance_lost_m
FROM customers
GROUP BY Geography
ORDER BY churn_rate_pct DESC;

-- 3b. Age band  -> 50-59 churn 56.0%, 40-49 30.8%, under-30 only 7.6%
SELECT
    CASE
        WHEN Age < 30 THEN '18-29'
        WHEN Age < 40 THEN '30-39'
        WHEN Age < 50 THEN '40-49'
        WHEN Age < 60 THEN '50-59'
        ELSE '60+'
    END AS age_band,
    COUNT(*) AS customers,
    ROUND(100 * AVG(Exited), 1) AS churn_rate_pct
FROM customers
GROUP BY age_band
ORDER BY age_band;

-- 3c. Products held -> 2 products 7.6%, 1 product 27.7%, 3+ products 82.7-100%
SELECT NumOfProducts,
       COUNT(*) AS customers,
       ROUND(100 * AVG(Exited), 1) AS churn_rate_pct
FROM customers
GROUP BY NumOfProducts
ORDER BY NumOfProducts;

-- 3d. Activity -> Inactive 26.9% vs Active 14.3% (nearly 2x)
SELECT CASE WHEN IsActiveMember = 1 THEN 'Active' ELSE 'Inactive' END AS status,
       COUNT(*) AS customers,
       ROUND(100 * AVG(Exited), 1) AS churn_rate_pct
FROM customers
GROUP BY status;

-- 3e. Gender -> Female 25.1% vs Male 16.5%
SELECT Gender, COUNT(*) AS customers, ROUND(100 * AVG(Exited), 1) AS churn_rate_pct
FROM customers
GROUP BY Gender;

-- ---------------------------------------------------------------------
-- 4. HIGH-RISK SEGMENT (CTE)
--    Inactive customers aged 40-59:
--    17.7% of customers -> 40.9% of all churn, 47.1% churn rate, $75.0M lost
-- ---------------------------------------------------------------------
WITH high_risk AS (
    SELECT *
    FROM customers
    WHERE Age BETWEEN 40 AND 59
      AND IsActiveMember = 0
)
SELECT
    COUNT(*)                                                           AS customers,
    SUM(Exited)                                                        AS churned,
    ROUND(100 * AVG(Exited), 1)                                        AS churn_rate_pct,
    ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM customers), 1)        AS pct_of_customer_base,
    ROUND(100 * SUM(Exited) / (SELECT SUM(Exited) FROM customers), 1)  AS pct_of_all_churn,
    ROUND(SUM(CASE WHEN Exited = 1 THEN Balance ELSE 0 END) / 1e6, 1)  AS balance_lost_m
FROM high_risk;

-- ---------------------------------------------------------------------
-- 5. WINDOW FUNCTION: rank country x age-band segments by churn rate
--    (segments with at least 100 customers)
-- ---------------------------------------------------------------------
WITH seg AS (
    SELECT Geography,
           CASE WHEN Age < 30 THEN '18-29' WHEN Age < 40 THEN '30-39'
                WHEN Age < 50 THEN '40-49' WHEN Age < 60 THEN '50-59' ELSE '60+' END AS age_band,
           COUNT(*) AS customers,
           ROUND(100 * AVG(Exited), 1) AS churn_rate_pct
    FROM customers
    GROUP BY Geography, age_band
    HAVING COUNT(*) >= 100
)
SELECT *,
       RANK() OVER (ORDER BY churn_rate_pct DESC) AS risk_rank
FROM seg
ORDER BY risk_rank;
