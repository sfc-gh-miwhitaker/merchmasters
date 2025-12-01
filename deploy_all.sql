/******************************************************************************
 * MERCHMASTERS: Tournament Merchandise Intelligence Demo
 * 
 * DEPLOYMENT SCRIPT - Copy this entire file into Snowsight and click "Run All"
 * 
 * PROJECT_NAME: MerchMasters
 * AUTHOR: SE Community
 * CREATED: 2025-12-01
 * EXPIRES: 2025-12-31
 * PURPOSE: Tournament merchandise analytics using Snowflake Intelligence (Cortex Analyst)
 * LAST_UPDATED: 2025-12-01
 * GITHUB_REPO: https://github.com/sfc-gh-miwhitaker/merchmasters
 * 
 * INSTRUCTIONS:
 *   1. Open Snowsight (https://app.snowflake.com)
 *   2. Create a new SQL Worksheet
 *   3. Copy this ENTIRE script and paste it
 *   4. Click "Run All" (or Ctrl+Shift+Enter / Cmd+Shift+Enter)
 *   5. Wait ~10 minutes for completion
 * 
 * OBJECTS CREATED:
 *   - API Integration: SFE_MERCHMASTERS_GIT_API_INTEGRATION
 *   - Git Repository: sfe_merchmasters_repo
 *   - Warehouse: SFE_MERCHMASTERS_WH (X-SMALL)
 *   - Schemas: SFE_MERCH_RAW, SFE_MERCH_STAGING, SFE_MERCH_ANALYTICS
 *   - Semantic View: SV_MERCH_INTELLIGENCE
 *   - Cortex Agent: MERCH_INTELLIGENCE_AGENT
 * 
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 * 
 * Author: SE Community | Expires: 2025-12-31
 ******************************************************************************/

-- ============================================================================
-- SECTION 0: EXPIRATION CHECK
-- ============================================================================
-- This demo expires on 2025-12-31. After this date, deployment will be blocked.

EXECUTE IMMEDIATE
$$
DECLARE
    v_expiration_date DATE := '2025-12-31';
    demo_expired EXCEPTION (-20001, 'DEMO EXPIRED: This demonstration project expired. The code may contain outdated Snowflake syntax. Please contact the SE team for an updated version.');
BEGIN
    IF (CURRENT_DATE() > v_expiration_date) THEN
        RAISE demo_expired;
    END IF;
END;
$$;

-- ============================================================================
-- SECTION 1: ROLE AND CONTEXT SETUP
-- ============================================================================

USE ROLE ACCOUNTADMIN;

-- ============================================================================
-- SECTION 2: CREATE API INTEGRATION FOR GITHUB
-- ============================================================================
-- Creates secure HTTPS connection to GitHub for repository access

CREATE OR REPLACE API INTEGRATION SFE_MERCHMASTERS_GIT_API_INTEGRATION
    API_PROVIDER = git_https_api
    API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-miwhitaker/')
    ENABLED = TRUE
    COMMENT = 'DEMO: MerchMasters - Git integration for public repo access | Author: SE Community | Expires: 2025-12-31';

-- ============================================================================
-- SECTION 3: CREATE DATABASE AND GIT REPOSITORY SCHEMA
-- ============================================================================

CREATE DATABASE IF NOT EXISTS SNOWFLAKE_EXAMPLE
    COMMENT = 'DEMO: Repository for example/demo projects - NOT FOR PRODUCTION';

CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_EXAMPLE.MERCHMASTERS_GIT_REPOS
    COMMENT = 'DEMO: MerchMasters - Git repository references | Author: SE Community | Expires: 2025-12-31';

-- ============================================================================
-- SECTION 4: CREATE GIT REPOSITORY REFERENCE
-- ============================================================================

CREATE OR REPLACE GIT REPOSITORY SNOWFLAKE_EXAMPLE.MERCHMASTERS_GIT_REPOS.sfe_merchmasters_repo
    API_INTEGRATION = SFE_MERCHMASTERS_GIT_API_INTEGRATION
    ORIGIN = 'https://github.com/sfc-gh-miwhitaker/merchmasters'
    COMMENT = 'DEMO: MerchMasters - Public repo for tournament merchandise intelligence | Author: SE Community | Expires: 2025-12-31';

-- Fetch latest from repository
ALTER GIT REPOSITORY SNOWFLAKE_EXAMPLE.MERCHMASTERS_GIT_REPOS.sfe_merchmasters_repo FETCH;

-- ============================================================================
-- SECTION 5: CREATE WAREHOUSE
-- ============================================================================
-- X-SMALL warehouse with aggressive auto-suspend for cost efficiency

CREATE OR REPLACE WAREHOUSE SFE_MERCHMASTERS_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = FALSE
    COMMENT = 'DEMO: MerchMasters - Demo compute warehouse | Author: SE Community | Expires: 2025-12-31';

-- Set warehouse context for subsequent operations
USE WAREHOUSE SFE_MERCHMASTERS_WH;

-- ============================================================================
-- SECTION 6: EXECUTE SETUP SCRIPTS FROM GIT
-- ============================================================================
-- Creates database, schemas, and base infrastructure

EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.MERCHMASTERS_GIT_REPOS.sfe_merchmasters_repo/branches/main/sql/01_setup/01_create_database.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.MERCHMASTERS_GIT_REPOS.sfe_merchmasters_repo/branches/main/sql/01_setup/02_create_schemas.sql;

-- ============================================================================
-- SECTION 7: EXECUTE DATA SCRIPTS FROM GIT
-- ============================================================================
-- Creates tables and loads synthetic sample data

EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.MERCHMASTERS_GIT_REPOS.sfe_merchmasters_repo/branches/main/sql/02_data/01_create_tables.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.MERCHMASTERS_GIT_REPOS.sfe_merchmasters_repo/branches/main/sql/02_data/02_load_sample_data.sql;

-- ============================================================================
-- SECTION 8: EXECUTE TRANSFORMATION SCRIPTS FROM GIT
-- ============================================================================
-- Creates staging views and analytics layer

EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.MERCHMASTERS_GIT_REPOS.sfe_merchmasters_repo/branches/main/sql/03_transformations/01_create_staging_views.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.MERCHMASTERS_GIT_REPOS.sfe_merchmasters_repo/branches/main/sql/03_transformations/02_create_analytics_tables.sql;

-- ============================================================================
-- SECTION 9: EXECUTE CORTEX AI SCRIPTS FROM GIT
-- ============================================================================
-- Creates semantic view and Cortex Analyst agent

EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.MERCHMASTERS_GIT_REPOS.sfe_merchmasters_repo/branches/main/sql/04_cortex/01_create_semantic_view.sql;
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.MERCHMASTERS_GIT_REPOS.sfe_merchmasters_repo/branches/main/sql/04_cortex/02_create_agent.sql;

-- ============================================================================
-- SECTION 10: GRANT PERMISSIONS
-- ============================================================================
-- Allow PUBLIC role to use demo objects

GRANT USAGE ON DATABASE SNOWFLAKE_EXAMPLE TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA SNOWFLAKE_EXAMPLE.SFE_MERCH_RAW TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA SNOWFLAKE_EXAMPLE.SFE_MERCH_STAGING TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS TO ROLE PUBLIC;

GRANT SELECT ON ALL TABLES IN SCHEMA SNOWFLAKE_EXAMPLE.SFE_MERCH_RAW TO ROLE PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA SNOWFLAKE_EXAMPLE.SFE_MERCH_STAGING TO ROLE PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS TO ROLE PUBLIC;
GRANT SELECT ON ALL VIEWS IN SCHEMA SNOWFLAKE_EXAMPLE.SFE_MERCH_STAGING TO ROLE PUBLIC;
GRANT SELECT ON ALL VIEWS IN SCHEMA SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS TO ROLE PUBLIC;

GRANT USAGE ON WAREHOUSE SFE_MERCHMASTERS_WH TO ROLE PUBLIC;

/******************************************************************************
 * DEPLOYMENT COMPLETE
 * 
 * Next Steps:
 *   1. Navigate to Snowflake Intelligence in Snowsight
 *   2. Select MERCH_INTELLIGENCE_AGENT
 *   3. Start asking questions about merchandise performance!
 * 
 * To verify deployment, run these queries in a separate worksheet:
 *   SELECT COUNT(*) FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_SALES;
 *   SELECT COUNT(*) FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_PRODUCTS;
 ******************************************************************************/

/******************************************************************************
 * TROUBLESHOOTING
 * 
 * Error: "API Integration already exists"
 *   → DROP API INTEGRATION IF EXISTS SFE_MERCHMASTERS_GIT_API_INTEGRATION;
 *   → Re-run this script
 * 
 * Error: "Insufficient privileges"
 *   → Ensure you're using ACCOUNTADMIN role
 *   → USE ROLE ACCOUNTADMIN;
 * 
 * Error: "Git repository fetch failed"
 *   → Check internet connectivity
 *   → Verify GitHub repository is accessible
 *   → Wait a few minutes and retry
 * 
 * Error: "Demo has expired"
 *   → This demo has passed its expiration date
 *   → Contact SE team for updated version
 * 
 * For cleanup instructions, see: sql/99_cleanup/teardown_all.sql
 ******************************************************************************/

