/******************************************************************************
 * DEMO PROJECT: MerchMasters
 * Script: Create Database
 * 
 * NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 * 
 * PURPOSE:
 *   Ensure SNOWFLAKE_EXAMPLE database exists for demo objects
 * 
 * OBJECTS CREATED:
 *   - SNOWFLAKE_EXAMPLE database (if not exists)
 * 
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 * 
 * Author: SE Community | Expires: 2025-12-31
 ******************************************************************************/

-- ============================================================================
-- CONTEXT SETTING (MANDATORY)
-- ============================================================================
USE ROLE SYSADMIN;
USE WAREHOUSE SFE_MERCHMASTERS_WH;

-- Database is shared across demos - create only if not exists
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_EXAMPLE
    COMMENT = 'DEMO: Repository for example/demo projects - NOT FOR PRODUCTION';

-- Database ready for use

