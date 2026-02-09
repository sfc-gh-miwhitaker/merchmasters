/******************************************************************************
 * DEMO PROJECT: MerchMasters
 * Script: Create Schemas
 *
 * NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Create the three-layer schema architecture for merchandise analytics
 *
 * OBJECTS CREATED:
 *   - SNOWFLAKE_EXAMPLE.SFE_MERCH_RAW (raw data landing)
 *   - SNOWFLAKE_EXAMPLE.SFE_MERCH_STAGING (cleaned data)
 *   - SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS (star schema)
 *   - SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS (Cortex Analyst views)
 *
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 *
 * Author: SE Community | Expires: 2026-04-10
 ******************************************************************************/

-- ============================================================================
-- CONTEXT SETTING (MANDATORY)
-- ============================================================================
USE ROLE SYSADMIN;
USE DATABASE SNOWFLAKE_EXAMPLE;
USE WAREHOUSE SFE_MERCHMASTERS_WH;

-- Raw data landing zone
CREATE SCHEMA IF NOT EXISTS SFE_MERCH_RAW
    COMMENT = 'DEMO: MerchMasters - Raw synthetic data landing zone | Author: SE Community | Expires: 2026-04-10';

-- Staging layer for cleaned/typed data
CREATE SCHEMA IF NOT EXISTS SFE_MERCH_STAGING
    COMMENT = 'DEMO: MerchMasters - Cleaned and validated data | Author: SE Community | Expires: 2026-04-10';

-- Analytics layer with star schema
CREATE SCHEMA IF NOT EXISTS SFE_MERCH_ANALYTICS
    COMMENT = 'DEMO: MerchMasters - Star schema for Cortex Analyst | Author: SE Community | Expires: 2026-04-10';

-- Semantic models schema (shared across demos)
CREATE SCHEMA IF NOT EXISTS SEMANTIC_MODELS
    COMMENT = 'DEMO: Semantic views for Cortex Analyst agents';

-- Schemas ready for use
