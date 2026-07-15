-- =====================================================
-- BARCLAYS ZERO TO SNOWFLAKE
-- STEP 0: ENVIRONMENT SETUP
-- Duration: ~3 minutes
-- =====================================================

USE ROLE SYSADMIN;

-- Create demo database with EDP-aligned layered schemas
-- NOTE: EDP tiers are Raw / Base / Prepared. This demo uses RAW / STAGING / ANALYTICS / PREPARED
-- for clarity in the demo context. The mapping is:
--   RAW       = EDP Raw layer
--   STAGING   = EDP Base layer (cleansed, typed)
--   ANALYTICS = EDP Prepared layer (business logic, KPIs)
--   PREPARED  = Operational layer (Dynamic Tables, Streamlit, apps)
CREATE OR REPLACE DATABASE BARCLAYS_DEMO
    COMMENT = 'Barclays Zero to Snowflake — Payments Data Product Demo';

CREATE OR REPLACE SCHEMA BARCLAYS_DEMO.RAW
    COMMENT = 'Raw ingestion layer — source data as-is';

CREATE OR REPLACE SCHEMA BARCLAYS_DEMO.STAGING
    COMMENT = 'Staging layer — cleansed, typed, deduplicated (dbt)';

CREATE OR REPLACE SCHEMA BARCLAYS_DEMO.ANALYTICS
    COMMENT = 'Analytics layer — business logic, KPIs, AI-enriched (dbt marts)';

CREATE OR REPLACE SCHEMA BARCLAYS_DEMO.PREPARED
    COMMENT = 'Prepared layer — Dynamic Tables, operational views, Streamlit';

-- Create warehouse
CREATE OR REPLACE WAREHOUSE BARCLAYS_DEMO_WH
    WITH WAREHOUSE_SIZE = 'SMALL'
         AUTO_SUSPEND = 60
         AUTO_RESUME = TRUE
         INITIALLY_SUSPENDED = TRUE
         COMMENT = 'Barclays Zero to Snowflake demo warehouse';

-- Activate context
USE WAREHOUSE BARCLAYS_DEMO_WH;
USE DATABASE BARCLAYS_DEMO;
USE SCHEMA RAW;

-- Verify Cortex AI is available
SELECT SNOWFLAKE.CORTEX.SENTIMENT('Payment processed successfully') AS CORTEX_TEST;

SELECT 'Setup complete' AS STATUS;
