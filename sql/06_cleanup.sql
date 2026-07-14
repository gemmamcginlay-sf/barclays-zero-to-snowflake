-- =====================================================
-- BARCLAYS ZERO TO SNOWFLAKE
-- CLEANUP: Remove all demo objects
-- Run after the session to clean up your account
-- =====================================================

USE ROLE SYSADMIN;

DROP DATABASE IF EXISTS BARCLAYS_DEMO;
DROP WAREHOUSE IF EXISTS BARCLAYS_DEMO_WH;

SELECT 'Cleanup complete' AS STATUS;
