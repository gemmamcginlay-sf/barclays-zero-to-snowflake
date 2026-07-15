-- =====================================================
-- BARCLAYS ZERO TO SNOWFLAKE
-- STEP 5: SNOWFLAKE INTELLIGENCE CoWork (Agent Demo)
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
-- SNOWSIGHT UI STEPS (pre-demo setup):
--
-- 1. CREATE SEMANTIC VIEW:
--    AI & ML → Analyst → Semantic Views → Create with Autopilot
--    Source: V_PAYMENTS_ANALYSIS  |  Name: SV_PAYMENTS_BARCLAYS
--
-- 2. CREATE CORTEX AGENT:
--    AI & ML → Agents → Create Agent
--    Name: BARCLAYS_PAYMENTS_AGENT
--    + Query Structured Data → Add Semantic View → SV_PAYMENTS_BARCLAYS
--
-- 3. DEMO IN CoWork:
--    Open CoWork → select BARCLAYS_PAYMENTS_AGENT → ask questions:
--
--    "What is the total payment volume this month?"
--    "Which payment type has the lowest success rate?"
--    "Drill into the SWIFT failures — which region is worst?"
--    "Show the trend of CHAPS payments by week"
--    "Why might APAC have lower success rates?"
--    "Compare success rates across all regions and summarise"
--
-- KEY MESSAGE:
-- "Same data we've been querying all session — now accessible to
--  anyone via a conversation. No SQL required. The Agent maintains
--  context, so you can drill down and ask follow-ups naturally."
-- =====================================================

-- 5.2: After creating Semantic View, verify it exists
-- SHOW SEMANTIC VIEWS IN SCHEMA BARCLAYS_DEMO.ANALYTICS;
