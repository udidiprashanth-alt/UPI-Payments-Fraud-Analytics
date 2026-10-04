CREATE DATABASE IF NOT EXISTS upi_fraud;

USE upi_fraud;

CREATE TABLE upi_transactions (
    transaction_id VARCHAR(20) PRIMARY KEY,
    transaction_ts DATETIME,
    city VARCHAR(50),
    bank VARCHAR(30),
    device_type VARCHAR(20),
    channel VARCHAR(20),
    amount DECIMAL(14,2),
    status VARCHAR(20),
    is_fraud INT,
    fraud_type VARCHAR(50),
    customer_risk_events INT,
    risk_score DECIMAL(6,3)
);

DESCRIBE upi_transactions;
SHOW VARIABLES LIKE 'local_infile';


LOAD DATA LOCAL INFILE
'C:/Users/udidi/Downloads/UPI_FRAUD_ANALYTICS-01/upi_transactions1.csv'
INTO TABLE upi_transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    transaction_id,
    transaction_ts,
    city,
    bank,
    device_type,
    channel,
    amount,
    status,
    is_fraud,
    fraud_type,
    customer_risk_events,
    risk_score
);


SELECT COUNT(*) AS total_transactions
FROM upi_transactions;

SELECT *
FROM upi_transactions
LIMIT 10;

-- Query 1 — Overall business performance-- 
SELECT
    COUNT(*) AS total_transactions,
    SUM(amount) AS total_transaction_value,

    SUM(
        CASE
            WHEN status = 'SUCCESS'
            THEN amount
            ELSE 0
        END
    ) AS successful_value,

    ROUND(
        100.0 *
        SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS success_rate_pct,

    SUM(is_fraud) AS fraud_transactions,

    SUM(
        CASE
            WHEN is_fraud = 1
            THEN amount
            ELSE 0
        END
    ) AS fraud_value

FROM upi_transactions;

-- Step 9 — Monthly trend

SELECT
    DATE_FORMAT(transaction_ts,'%Y-%m') AS month,
    COUNT(*) AS transactions,
    SUM(amount) AS transaction_value,
    SUM(is_fraud) AS fraud_transactions,

    SUM(
        CASE
            WHEN is_fraud = 1
            THEN amount
            ELSE 0
        END
    ) AS fraud_value

FROM upi_transactions

GROUP BY DATE_FORMAT(transaction_ts,'%Y-%m')

ORDER BY month;

-- Step 10 — Analyze banks

SELECT
    bank,
    COUNT(*) AS transactions,
    SUM(amount) AS transaction_value,

    ROUND(
        100.0 *
        SUM(CASE WHEN status='SUCCESS' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS success_rate,

    SUM(is_fraud) AS fraud_cases

FROM upi_transactions

GROUP BY bank

ORDER BY transaction_value DESC;

-- Step 11 — Analyze payment channels

SELECT
    channel,
    COUNT(*) AS transactions,
    SUM(amount) AS transaction_value,
    ROUND(AVG(amount),2) AS average_amount,
    SUM(is_fraud) AS fraud_cases,

    ROUND(
        100.0 * SUM(is_fraud) / COUNT(*),
        2
    ) AS fraud_rate

FROM upi_transactions

GROUP BY channel

ORDER BY transaction_value DESC;

-- Step 12 — Analyze cities

SELECT
    city,
    COUNT(*) AS transactions,
    SUM(is_fraud) AS fraud_cases,

    ROUND(
        100.0 * SUM(is_fraud) / COUNT(*),
        2
    ) AS fraud_rate,

    SUM(
        CASE
            WHEN is_fraud = 1
            THEN amount
            ELSE 0
        END
    ) AS fraud_value

FROM upi_transactions

GROUP BY city

ORDER BY fraud_value DESC;

-- Step 13 — Analyze fraud types

SELECT
    fraud_type,
    COUNT(*) AS fraud_cases,
    SUM(amount) AS fraud_value,
    AVG(amount) AS average_fraud_amount

FROM upi_transactions

WHERE is_fraud = 1

GROUP BY fraud_type

ORDER BY fraud_value DESC;


-- -- **-- -- Step 14 — Find high-risk transactions

SELECT
    transaction_id,
    transaction_ts,
    city,
    bank,
    channel,
    amount,
    risk_score,
    is_fraud

FROM upi_transactions

WHERE risk_score >= 0.70
   OR amount >= 100000

ORDER BY risk_score DESC, amount DESC;

-- Step 15 — Analyze fraud by time

SELECT
    HOUR(transaction_ts) AS hour,
    COUNT(*) AS transactions,
    SUM(is_fraud) AS fraud_cases,

    ROUND(
        100.0 * SUM(is_fraud) / COUNT(*),
        2
    ) AS fraud_rate

FROM upi_transactions

GROUP BY HOUR(transaction_ts)

ORDER BY hour;
