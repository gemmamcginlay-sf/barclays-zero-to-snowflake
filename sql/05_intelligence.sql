-- =====================================================
-- BARCLAYS ZERO TO SNOWFLAKE
-- STEP 5: SNOWFLAKE INTELLIGENCE (Semantic View + Agent)
-- Duration: ~15 minutes
-- Pre-req: dbt marts deployed (Step 3c)
-- =====================================================

USE WAREHOUSE BARCLAYS_DEMO_WH;
USE SCHEMA BARCLAYS_DEMO.ANALYTICS;


-- 5.1: Consolidated analytics view for the Semantic Model
CREATE OR REPLACE VIEW V_PAYMENTS_ANALYSIS AS
SELECT
    k.PAYMENT_DATE,
    DATE_TRUNC('WEEK',  k.PAYMENT_DATE) AS PAYMENT_WEEK,
    DATE_TRUNC('MONTH', k.PAYMENT_DATE) AS PAYMENT_MONTH,
    YEAR(k.PAYMENT_DATE) AS YEAR,
    QUARTER(k.PAYMENT_DATE) AS QUARTER,
    k.PAYMENT_TYPE,
    k.REGION,
    k.TOTAL_PAYMENTS,
    k.TOTAL_VOLUME,
    k.SUCCESS_RATE_PCT,
    k.AVG_PROCESSING_TIME_MS,
    k.P95_PROCESSING_TIME_MS
FROM MART_PAYMENT_KPIS k;

-- Verify
SELECT * FROM V_PAYMENTS_ANALYSIS LIMIT 5;


-- =====================================================
-- SNOWSIGHT UI STEPS (no SQL required):
--
-- CREATE SEMANTIC VIEW:
--   Data → Databases → BARCLAYS_DEMO → ANALYTICS → Views
--   → V_PAYMENTS_ANALYSIS → ... → Create Semantic View
--   OR: AI & ML → Analyst → Semantic Views → Create with Autopilot
--   Name: SV_PAYMENTS_BARCLAYS  |  Schema: ANALYTICS
--
-- CREATE CORTEX AGENT:
--   AI & ML → Agents
--   Name: BARCLAYS_PAYMENTS_AGENT
--   + Query Structured Data → Add Semantic View → SV_PAYMENTS_BARCLAYS
--
-- SAMPLE QUESTIONS TO TRY:
--   "What is the total payment volume this month?"
--   "Which payment type has the lowest success rate?"
--   "Show the trend of CHAPS payments by week"
--   "What is the average processing time for Faster Payments?"
--   "Compare success rates across regions"
--   "Which region has the most failed transactions?"
--   "Show me daily volumes for SWIFT vs BACS"
-- =====================================================

-- 5.2: After creating Semantic View, verify it exists
-- SHOW SEMANTIC VIEWS IN SCHEMA BARCLAYS_DEMO.ANALYTICS;
