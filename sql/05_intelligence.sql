-- =====================================================
-- BARCLAYS ZERO TO SNOWFLAKE
-- SECTION 6: SNOWFLAKE INTELLIGENCE CoWork (Agent Demo)
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
-- 5.2: CREATE SEMANTIC VIEW
-- Defines business-level metrics and dimensions for the AI agent
-- =====================================================

CREATE OR REPLACE SEMANTIC VIEW SV_PAYMENTS_BARCLAYS

  TABLES (
    payments AS BARCLAYS_DEMO.ANALYTICS.V_PAYMENTS_ANALYSIS
      PRIMARY KEY (PAYMENT_DATE, PAYMENT_TYPE, REGION)
      WITH SYNONYMS ('payments', 'transactions', 'payment data')
      COMMENT = 'Daily payment KPIs by type and region'
  )

  DIMENSIONS (
    payments.payment_date AS PAYMENT_DATE
      COMMENT = 'Date of payment activity',
    payments.payment_week AS PAYMENT_WEEK
      COMMENT = 'Week (Monday start) of payment activity',
    payments.payment_month AS PAYMENT_MONTH
      COMMENT = 'Month of payment activity',
    payments.year AS YEAR
      COMMENT = 'Year of payment activity',
    payments.quarter AS QUARTER
      COMMENT = 'Quarter of payment activity (1-4)',
    payments.payment_type AS PAYMENT_TYPE
      WITH SYNONYMS = ('payment method', 'rail', 'scheme')
      COMMENT = 'Payment rail: SWIFT, BACS, CHAPS, Faster Payments, SEPA, Wire Transfer',
    payments.region AS REGION
      WITH SYNONYMS = ('geography', 'geo', 'location')
      COMMENT = 'Geographic region: EMEA, APAC, AMERICAS'
  )

  METRICS (
    payments.total_payments AS SUM(TOTAL_PAYMENTS)
      WITH SYNONYMS = ('transaction count', 'volume', 'number of payments')
      COMMENT = 'Total number of payment transactions',
    payments.total_volume AS SUM(TOTAL_VOLUME)
      WITH SYNONYMS = ('value', 'amount', 'payment value')
      COMMENT = 'Total monetary value of payments in GBP',
    payments.avg_success_rate AS AVG(SUCCESS_RATE_PCT)
      WITH SYNONYMS = ('success rate', 'completion rate')
      COMMENT = 'Average percentage of payments completed successfully',
    payments.avg_processing_time AS AVG(AVG_PROCESSING_TIME_MS)
      WITH SYNONYMS = ('latency', 'processing time', 'speed')
      COMMENT = 'Average processing time in milliseconds',
    payments.avg_p95_processing_time AS AVG(P95_PROCESSING_TIME_MS)
      WITH SYNONYMS = ('p95', 'tail latency', '95th percentile')
      COMMENT = 'Average P95 processing time in milliseconds'
  )

  COMMENT = 'Payments analytics semantic model for Barclays demo';

-- Verify semantic view exists
SHOW SEMANTIC VIEWS IN SCHEMA BARCLAYS_DEMO.ANALYTICS;


-- =====================================================
-- 5.3: CREATE CORTEX AGENT
-- Conversational AI over the semantic view
-- =====================================================

CREATE OR REPLACE AGENT BARCLAYS_DEMO.ANALYTICS.BARCLAYS_PAYMENTS_AGENT
  COMMENT = 'Payments analytics agent for CoWork'
  FROM SPECIFICATION
  $$
  models:
    orchestration: claude-3-5-sonnet

  instructions:
    response: "You are a payments operations analyst for Barclays. Answer questions about payment volumes, success rates, processing times, and trends. Always be specific about time periods and payment types. If asked about failures, proactively suggest which regions or types to investigate."
    sample_questions:
      - question: "What is the total payment volume this month?"
      - question: "Which payment type has the lowest success rate?"
      - question: "Show the trend of CHAPS payments by week"

  tools:
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "PaymentsAnalyst"
        description: "Queries payment KPI data including volumes, success rates, and processing times by type and region"

  tool_resources:
    PaymentsAnalyst:
      semantic_view: "BARCLAYS_DEMO.ANALYTICS.SV_PAYMENTS_BARCLAYS"
  $$;


-- =====================================================
-- 5.4: TEST THE AGENT (optional — run from worksheet)
-- =====================================================

-- Quick test (returns structured response):
-- SELECT SNOWFLAKE.CORTEX.AGENT(
--     'BARCLAYS_PAYMENTS_AGENT',
--     'What is the total payment volume this month?'
-- );


-- =====================================================
-- DEMO FLOW (in CoWork UI):
--
-- Open CoWork → select BARCLAYS_PAYMENTS_AGENT → ask:
--   "What is the total payment volume this month?"
--   "Which payment type has the lowest success rate?"
--   "Drill into the SWIFT failures — which region is worst?"
--   "Show the trend of CHAPS payments by week"
--   "Why might APAC have lower success rates?"
--   "Compare success rates across all regions and summarise"
--
-- KEY MESSAGE:
-- "Same data we've been querying all session — now accessible to
--  anyone via a conversation. No SQL required. The Agent maintains
--  context, so you can drill down and ask follow-ups naturally."
-- =====================================================
