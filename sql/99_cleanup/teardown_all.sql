/******************************************************************************
 * DEMO PROJECT: MerchMasters
 * Script: Teardown All Demo Objects
 * 
 * NOT FOR PRODUCTION USE - CLEANUP SCRIPT
 * 
 * PURPOSE:
 *   Remove all MerchMasters demo objects from the account.
 *   Preserves shared infrastructure (SNOWFLAKE_EXAMPLE database, shared schemas).
 * 
 * OBJECTS REMOVED:
 *   - Agent: SFE_MERCH_INTELLIGENCE_AGENT (from project schema)
 *   - Agent removed from Snowflake Intelligence object
 *   - Schemas: SFE_MERCH_RAW, SFE_MERCH_STAGING, SFE_MERCH_ANALYTICS, MERCHMASTERS
 *   - Semantic View: SFE_SV_MERCH_INTELLIGENCE
 *   - Streamlit App: SFE_THE_LEADERBOARD (in SFE_MERCH_ANALYTICS schema)
 *   - Warehouse: SFE_MERCHMASTERS_WH
 *   - Git Repository: sfe_merchmasters_repo
 *   - Git Schema: MERCHMASTERS_GIT_REPOS
 * 
 * OBJECTS PRESERVED:
 *   - SNOWFLAKE_EXAMPLE database (shared by other demos)
 *   - SEMANTIC_MODELS schema (may contain other views)
 *   - Snowflake Intelligence object (account-level, shared)
 *   - SFE_* API integrations (may be shared)
 * 
 * Author: SE Community | Expires: 2025-12-31
 ******************************************************************************/

-- ============================================================================
-- CONTEXT SETTING (MANDATORY)
-- ============================================================================
-- Note: Using SYSADMIN for most operations. Only escalate to ACCOUNTADMIN
-- if dropping account-level objects like API Integrations.
USE ROLE SYSADMIN;

-- ============================================================================
-- REMOVE AGENT FROM SNOWFLAKE INTELLIGENCE OBJECT
-- ============================================================================
-- This removes the agent from the UI visibility list (must be done before dropping agent)
ALTER SNOWFLAKE INTELLIGENCE IF EXISTS SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT 
    REMOVE AGENT SNOWFLAKE_EXAMPLE.MERCHMASTERS.SFE_MERCH_INTELLIGENCE_AGENT;

-- ============================================================================
-- REMOVE CORTEX AGENT
-- ============================================================================
DROP AGENT IF EXISTS SNOWFLAKE_EXAMPLE.MERCHMASTERS.SFE_MERCH_INTELLIGENCE_AGENT;

-- ============================================================================
-- REMOVE SEMANTIC VIEW
-- ============================================================================
DROP SEMANTIC VIEW IF EXISTS SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SFE_SV_MERCH_INTELLIGENCE;

-- ============================================================================
-- REMOVE STREAMLIT APP (Explicitly before schema drop for clarity)
-- ============================================================================
DROP STREAMLIT IF EXISTS SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_THE_LEADERBOARD;

-- ============================================================================
-- REMOVE DEMO SCHEMAS (CASCADE drops all contained objects)
-- ============================================================================
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.SFE_MERCH_RAW CASCADE;
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.SFE_MERCH_STAGING CASCADE;
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS CASCADE;
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.MERCHMASTERS CASCADE;

-- ============================================================================
-- REMOVE GIT REPOSITORY AND SCHEMA
-- ============================================================================
DROP GIT REPOSITORY IF EXISTS SNOWFLAKE_EXAMPLE.MERCHMASTERS_GIT_REPOS.sfe_merchmasters_repo;
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.MERCHMASTERS_GIT_REPOS;

-- ============================================================================
-- REMOVE WAREHOUSE
-- ============================================================================
DROP WAREHOUSE IF EXISTS SFE_MERCHMASTERS_WH;

-- ============================================================================
-- PRESERVED OBJECTS (DO NOT DROP)
-- ============================================================================
-- The following are intentionally NOT dropped as they may be shared:
--
-- 1. SNOWFLAKE_EXAMPLE database
--    Reason: Shared by all SE demos
--
-- 2. SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS schema
--    Reason: May contain semantic views from other demos
--
-- 3. SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT
--    Reason: Account-level object shared by all agents
--
-- 4. SFE_MERCHMASTERS_GIT_API_INTEGRATION
--    Reason: API integrations may be shared; drop manually if unused:
--    -- DROP API INTEGRATION IF EXISTS SFE_MERCHMASTERS_GIT_API_INTEGRATION;

/******************************************************************************
 * CLEANUP COMPLETE
 * 
 * To verify cleanup, run these queries in a separate worksheet:
 * 
 *   -- Should return no schemas
 *   SHOW SCHEMAS IN DATABASE SNOWFLAKE_EXAMPLE LIKE 'SFE_MERCH%';
 *   SHOW SCHEMAS IN DATABASE SNOWFLAKE_EXAMPLE LIKE 'MERCHMASTERS%';
 *   
 *   -- Should return no warehouse
 *   SHOW WAREHOUSES LIKE 'SFE_MERCHMASTERS%';
 *   
 *   -- Should return no semantic view
 *   SHOW VIEWS IN SCHEMA SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS LIKE 'SFE_SV_MERCH%';
 *   
 *   -- Should return no streamlit apps
 *   SHOW STREAMLITS LIKE 'SFE_MERCH%';
 *
 *   -- Should return no agent (in project schema)
 *   SHOW AGENTS IN SCHEMA SNOWFLAKE_EXAMPLE.MERCHMASTERS;
 * 
 * To completely remove ALL demo infrastructure (use with caution):
 *   DROP API INTEGRATION IF EXISTS SFE_MERCHMASTERS_GIT_API_INTEGRATION;
 ******************************************************************************/
