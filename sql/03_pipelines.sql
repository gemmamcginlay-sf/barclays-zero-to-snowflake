-- =====================================================
-- BARCLAYS ZERO TO SNOWFLAKE
-- SECTION 4: PIPELINES (Views, Dynamic Tables, dbt, Streams+Tasks, Notebooks, Procedures)
-- Duration: ~25 minutes
-- =====================================================

USE WAREHOUSE BARCLAYS_DEMO_WH;
USE DATABASE BARCLAYS_DEMO;


-- ─── 3a. VIEWS ─── (logical layer, always current)
CREATE OR REPLACE VIEW STAGING.PAYMENTS_CLEANSED AS
SELECT
    PAYMENT_ID,
    PAYMENT_DATE,
    PAYMENT_DATE::DATE AS PAYMENT_DAY,
    ORIGINATOR_NAME,
    BENEFICIARY_NAME,
    PAYMENT_TYPE,
    CHANNEL,
    CURRENCY,
    AMOUNT,
    CASE WHEN AMOUNT < 5000 THEN 'RETAIL'
         WHEN AMOUNT < 100000 THEN 'CORPORATE'
         ELSE 'LARGE VALUE' END AS VALUE_BAND,
    STATUS,
    PROCESSING_TIME_MS,
    ERROR_CODE,
    REGION
FROM RAW.PAYMENTS;

SELECT VALUE_BAND, COUNT(*) AS CNT, SUM(AMOUNT) AS TOTAL
FROM STAGING.PAYMENTS_CLEANSED GROUP BY VALUE_BAND ORDER BY TOTAL DESC;
-- "Zero cost, always fresh. Your STAGING layer."


-- ─── 3b. DYNAMIC TABLES ─── (materialised, auto-refreshing)
CREATE OR REPLACE DYNAMIC TABLE PREPARED.DAILY_SUMMARY
    TARGET_LAG = '1 hour'
    WAREHOUSE = BARCLAYS_DEMO_WH
AS
SELECT
    PAYMENT_DAY,
    PAYMENT_TYPE,
    REGION,
    COUNT(*) AS TXN_COUNT,
    SUM(AMOUNT) AS TOTAL_VALUE,
    ROUND(100.0 * COUNT(CASE WHEN STATUS='FAILED' THEN 1 END) / COUNT(*), 2) AS FAIL_RATE_PCT,
    ROUND(AVG(PROCESSING_TIME_MS), 0) AS AVG_PROCESSING_MS
FROM STAGING.PAYMENTS_CLEANSED
GROUP BY PAYMENT_DAY, PAYMENT_TYPE, REGION;

SELECT * FROM PREPARED.DAILY_SUMMARY ORDER BY PAYMENT_DAY DESC LIMIT 10;
-- "Declare WHAT, not WHEN. Snowflake refreshes automatically."


-- ─── 3c. dbt ─── (EDP standard — version-controlled SQL)
-- [Switch to Snowsight dbt project view OR Cortex Code]
--
-- DEMO FLOW:
-- 1. Show the dbt project structure (models/staging + models/marts)
-- 2. Show a model's SQL — "same SELECT we just wrote, wrapped in dbt"
-- 3. Show tests — schema.yml: not_null, unique, accepted_values
-- 4. Trigger a build — show incremental refresh, test results
-- 5. Show docs & lineage — auto-generated from the project
--
-- After dbt runs, validate the output:
SELECT 'STG_PAYMENTS' AS MODEL, COUNT(*) AS ROW_COUNT FROM ANALYTICS.STG_PAYMENTS
UNION ALL SELECT 'MART_PAYMENT_KPIS', COUNT(*) FROM ANALYTICS.MART_PAYMENT_KPIS
UNION ALL SELECT 'MART_SLA_COMPLIANCE', COUNT(*) FROM ANALYTICS.MART_SLA_COMPLIANCE;

-- SHOW DBT PROJECTS;
-- EXECUTE DBT PROJECT <DB>.<SCHEMA>.<PROJECT>;


-- ─── 3d. STREAMS + TASKS ─── (event-driven — LIVE DEMO)

-- STEP 1: Baseline — note the PENDING count
SELECT STATUS, COUNT(*) AS TXN_COUNT
FROM RAW.PAYMENTS GROUP BY STATUS ORDER BY TXN_COUNT DESC;

-- STEP 2: Create the Stream (CDC) and Task (the action)
CREATE OR REPLACE STREAM RAW.STATUS_STREAM ON TABLE RAW.PAYMENT_STATUS_UPDATES;

CREATE OR REPLACE TASK RAW.APPLY_UPDATES
    WAREHOUSE = BARCLAYS_DEMO_WH
    SCHEDULE = '5 MINUTE'
    WHEN SYSTEM$STREAM_HAS_DATA('RAW.STATUS_STREAM')
AS
    MERGE INTO RAW.PAYMENTS t
    USING RAW.STATUS_STREAM s ON t.PAYMENT_ID = s.PAYMENT_ID
    WHEN MATCHED THEN UPDATE SET t.STATUS = s.NEW_STATUS;

-- STEP 3: Simulate data arriving (upstream confirms 5 payments)
INSERT INTO RAW.PAYMENT_STATUS_UPDATES (PAYMENT_ID, NEW_STATUS, REASON)
SELECT PAYMENT_ID, 'COMPLETED', 'Cleared by beneficiary bank'
FROM RAW.PAYMENTS
WHERE STATUS = 'PENDING'
LIMIT 5;

-- STEP 4: The Stream captured it automatically
SELECT PAYMENT_ID, NEW_STATUS, REASON,
       METADATA$ACTION, METADATA$ISUPDATE
FROM RAW.STATUS_STREAM;
-- "Built-in CDC. No Kafka, no Debezium — Snowflake tracks it for you."

-- STEP 5: Fire the Task manually
EXECUTE TASK RAW.APPLY_UPDATES;

-- STEP 6: Prove it worked
SELECT COUNT(*) AS STREAM_ROWS_REMAINING FROM RAW.STATUS_STREAM;
SELECT STATUS, COUNT(*) AS TXN_COUNT
FROM RAW.PAYMENTS GROUP BY STATUS ORDER BY TXN_COUNT DESC;
-- Compare to Step 1: PENDING dropped by 5, COMPLETED went up by 5


-- ─── 3e. NOTEBOOKS ─── (Python + SQL together, deployable)
-- [Switch to Snowsight → Projects → Notebooks → Create Notebook]
--
-- DEMO FLOW:
-- 1. Create a new Notebook
-- 2. Add a SQL cell: GROUP BY PAYMENT_TYPE query (same as Section 3b)
-- 3. Add a Python cell: convert to Pandas, plot with matplotlib/altair
-- 4. Show: both cells run on Snowflake compute, no data leaves
-- 5. Show deployment: Click "Schedule" → set daily cadence → assign warehouse
-- 6. Explain: "This notebook is now a scheduled job. Same governance as Tasks."
--
-- KEY MESSAGE:
-- "Notebooks bridge SQL and Python. Use them when you need data science
--  logic alongside SQL transforms. And they deploy as scheduled pipelines
--  — not just for exploration."


-- ─── 3f. STORED PROCEDURES ─── (control flow, IF/ELSE)
CREATE OR REPLACE PROCEDURE PREPARED.FLAG_AGED_FAILURES()
    RETURNS VARCHAR LANGUAGE SQL EXECUTE AS CALLER
AS
BEGIN
    LET cnt INTEGER := 0;
    SELECT COUNT(*) INTO :cnt FROM RAW.PAYMENTS
    WHERE STATUS = 'FAILED' AND PAYMENT_DATE < DATEADD(HOUR, -24, CURRENT_TIMESTAMP());
    IF (:cnt > 0) THEN
        RETURN :cnt || ' aged failures found — flag for review';
    ELSE
        RETURN 'All clear';
    END IF;
END;

CALL PREPARED.FLAG_AGED_FAILURES();
