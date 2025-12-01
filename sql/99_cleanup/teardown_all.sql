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
 *   - Schemas: SFE_MERCH_RAW, SFE_MERCH_STAGING, SFE_MERCH_ANALYTICS
 *   - Semantic View: SV_MERCH_INTELLIGENCE
 *   - Agent: MERCH_INTELLIGENCE_AGENT
 *   - Warehouse: SFE_MERCHMASTERS_WH
 *   - Git Repository: sfe_merchmasters_repo
 *   - Git Schema: MERCHMASTERS_GIT_REPOS
 * 
 * OBJECTS PRESERVED:
 *   - SNOWFLAKE_EXAMPLE database (shared by other demos)
 *   - SEMANTIC_MODELS schema (may contain other views)
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
-- REMOVE CORTEX AGENT
-- ============================================================================
DROP AGENT IF EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS.MERCH_INTELLIGENCE_AGENT;

-- ============================================================================
-- REMOVE SEMANTIC VIEW
-- ============================================================================
DROP SEMANTIC VIEW IF EXISTS SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SV_MERCH_INTELLIGENCE;

-- ============================================================================
-- REMOVE DEMO SCHEMAS (CASCADE drops all contained objects)
-- ============================================================================
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.SFE_MERCH_RAW CASCADE;
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.SFE_MERCH_STAGING CASCADE;
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS CASCADE;

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
-- 3. SFE_MERCHMASTERS_GIT_API_INTEGRATION
--    Reason: API integrations may be shared; drop manually if unused:
--    -- DROP API INTEGRATION IF EXISTS SFE_MERCHMASTERS_GIT_API_INTEGRATION;
--
-- 4. snowflake_intelligence database/schema
--    Reason: May contain agents from other demos

/******************************************************************************
 * CLEANUP COMPLETE
 * 
 * To verify cleanup, run these queries in a separate worksheet:
 * 
 *   -- Should return no schemas
 *   SHOW SCHEMAS IN DATABASE SNOWFLAKE_EXAMPLE LIKE 'SFE_MERCH%';
 *   
 *   -- Should return no warehouse
 *   SHOW WAREHOUSES LIKE 'SFE_MERCHMASTERS%';
 *   
 *   -- Should return no semantic view
 *   SHOW VIEWS IN SCHEMA SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS LIKE 'SV_MERCH%';
 * 
 * To completely remove ALL demo infrastructure (use with caution):
 *   DROP API INTEGRATION IF EXISTS SFE_MERCHMASTERS_GIT_API_INTEGRATION;
 ******************************************************************************/

