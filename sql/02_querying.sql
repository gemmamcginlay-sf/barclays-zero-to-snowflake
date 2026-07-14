-- =====================================================
-- BARCLAYS ZERO TO SNOWFLAKE
-- STEP 2: QUERYING DATA
-- Duration: ~12 minutes
-- Covers: Explore, Aggregate, Window functions, Time Travel
-- =====================================================

USE WAREHOUSE BARCLAYS_DEMO_WH;
USE SCHEMA BARCLAYS_DEMO.RAW;


-- 2a. Explore the data
SELECT * FROM PAYMENTS LIMIT 10;


-- 2b. Aggregation — "if you know SQL, you know Snowflake"
SELECT
    PAYMENT_TYPE,
    COUNT(*) AS TXN_COUNT,
    SUM(AMOUNT) AS TOTAL_VALUE,
    COUNT(CASE WHEN STATUS = 'FAILED' THEN 1 END) AS FAILED,
    ROUND(AVG(PROCESSING_TIME_MS), 0) AS AVG_PROCESSING_MS
FROM PAYMENTS
GROUP BY PAYMENT_TYPE
ORDER BY TOTAL_VALUE DESC;

-- >>> Click "Chart" tab → instant bar chart


-- 2c. Window function — running total
SELECT
    PAYMENT_DATE::DATE AS DAY,
    SUM(AMOUNT) AS DAILY_VALUE,
    SUM(SUM(AMOUNT)) OVER (ORDER BY PAYMENT_DATE::DATE) AS RUNNING_TOTAL
FROM PAYMENTS
WHERE STATUS = 'COMPLETED'
GROUP BY DAY
ORDER BY DAY;


-- 2d. Time Travel — query the past, undo mistakes

-- Make a change
UPDATE PAYMENTS SET STATUS = 'CANCELLED'
WHERE STATUS = 'PENDING' AND AMOUNT < 1000;

-- Talk for ~30 seconds here...

-- What did it look like before the change?
SELECT STATUS, COUNT(*) AS CNT
FROM PAYMENTS AT(OFFSET => -30)
GROUP BY STATUS ORDER BY CNT DESC;

-- Undo instantly
CREATE TABLE PAYMENTS_RESTORED CLONE PAYMENTS AT(OFFSET => -60);
ALTER TABLE PAYMENTS SWAP WITH PAYMENTS_RESTORED;
DROP TABLE PAYMENTS_RESTORED;

-- Verify: CANCELLED is gone
SELECT STATUS, COUNT(*) AS CNT
FROM PAYMENTS GROUP BY STATUS ORDER BY CNT DESC;

-- "Time Travel + Clone + Swap = instant undo. No tickets, no backups."
