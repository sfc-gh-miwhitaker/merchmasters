/******************************************************************************
 * DEMO PROJECT: MerchMasters
 * Script: Create Streamlit Dashboard
 * 
 * NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 * 
 * PURPOSE:
 *   Create a Streamlit in Snowflake dashboard for tournament merchandise
 *   analytics - modeled after best practices for small retail / golf shop.
 * 
 * OBJECTS CREATED:
 *   - SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_STREAMLIT_STAGE (Stage)
 *   - SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_THE_LEADERBOARD (Streamlit App)
 * 
 * DASHBOARD SECTIONS:
 *   1. Executive Summary - KPIs and high-level metrics
 *   2. Sales Performance - Revenue trends, category breakdown
 *   3. Inventory Status - Stock levels, alerts, reorder suggestions
 *   4. Product Analysis - Top sellers, slow movers
 *   5. Location Comparison - Store performance
 * 
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 * 
 * Author: SE Community | Expires: 2026-01-31
 ******************************************************************************/

-- ============================================================================
-- CONTEXT SETTING (MANDATORY)
-- ============================================================================
USE ROLE SYSADMIN;
USE DATABASE SNOWFLAKE_EXAMPLE;
USE WAREHOUSE SFE_MERCHMASTERS_WH;
USE SCHEMA SFE_MERCH_ANALYTICS;

-- ============================================================================
-- CREATE STAGE FOR STREAMLIT FILES
-- ============================================================================
CREATE OR REPLACE STAGE SFE_STREAMLIT_STAGE
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'DEMO: MerchMasters - Stage for Streamlit app files | Author: SE Community | Expires: 2026-01-31';

-- ============================================================================
-- COPY STREAMLIT APP FROM GIT REPOSITORY TO STAGE
-- ============================================================================
-- Copy the streamlit_app.py file from Git repo to the stage
COPY FILES 
    INTO @SFE_STREAMLIT_STAGE
    FROM @SNOWFLAKE_EXAMPLE.MERCHMASTERS_GIT_REPOS.sfe_merchmasters_repo/branches/main/sql/05_streamlit/
    PATTERN = '.*\.py';

-- ============================================================================
-- CREATE STREAMLIT APP
-- ============================================================================
-- Modern syntax: Uses FROM parameter instead of legacy ROOT_LOCATION
-- Benefits: Multi-file editing, Git integration, container runtime support
CREATE OR REPLACE STREAMLIT SFE_THE_LEADERBOARD
    FROM '@SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_STREAMLIT_STAGE'
    MAIN_FILE = 'streamlit_app.py'
    QUERY_WAREHOUSE = SFE_MERCHMASTERS_WH
    COMMENT = 'DEMO: MerchMasters - The Leaderboard Dashboard | Author: SE Community | Expires: 2026-01-31';

-- ============================================================================
-- GRANT ACCESS TO STREAMLIT APP
-- ============================================================================
GRANT USAGE ON STREAMLIT SFE_THE_LEADERBOARD TO ROLE PUBLIC;

/******************************************************************************
 * STREAMLIT DEPLOYMENT COMPLETE
 * 
 * To access the dashboard:
 *   1. Navigate to Snowsight
 *   2. Click "Projects" → "Streamlit"
 *   3. Select "SFE_THE_LEADERBOARD"
 *   4. The dashboard will open in a new tab
 * 
 * Dashboard Features:
 *   - Executive Summary with YoY comparison
 *   - Daily sales trends by tournament day
 *   - Category and vendor performance
 *   - Inventory alerts (Critical/Low/Adequate)
 *   - Location performance comparison
 ******************************************************************************/
