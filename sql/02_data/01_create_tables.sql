/******************************************************************************
 * DEMO PROJECT: MerchMasters
 * Script: Create Raw Tables
 * 
 * NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 * 
 * PURPOSE:
 *   Create raw tables for synthetic merchandise data landing
 * 
 * OBJECTS CREATED:
 *   - SFE_RAW_PRODUCTS (product catalog)
 *   - SFE_RAW_LOCATIONS (retail locations)
 *   - SFE_RAW_TOURNAMENTS (tournament calendar)
 *   - SFE_RAW_SALES (POS transactions)
 *   - SFE_RAW_INVENTORY (inventory snapshots)
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
USE SCHEMA SFE_MERCH_RAW;

-- ============================================================================
-- PRODUCTS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE SFE_RAW_PRODUCTS (
    style_number        VARCHAR(20) NOT NULL,
    product_name        VARCHAR(200) NOT NULL,
    category            VARCHAR(50) NOT NULL,
    subcategory         VARCHAR(50),
    collection          VARCHAR(100),
    vendor              VARCHAR(100),
    unit_cost           NUMBER(10,2),
    retail_price        NUMBER(10,2),
    is_dated_year       BOOLEAN DEFAULT FALSE,
    created_at          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'DEMO: MerchMasters - Product catalog | Author: SE Community | Expires: 2026-01-31';

-- ============================================================================
-- LOCATIONS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE SFE_RAW_LOCATIONS (
    location_id         INTEGER NOT NULL,
    location_name       VARCHAR(100) NOT NULL,
    location_type       VARCHAR(50) NOT NULL,
    capacity_sqft       INTEGER,
    is_active           BOOLEAN DEFAULT TRUE,
    created_at          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'DEMO: MerchMasters - Retail locations | Author: SE Community | Expires: 2026-01-31';

-- ============================================================================
-- TOURNAMENTS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE SFE_RAW_TOURNAMENTS (
    tournament_id       INTEGER NOT NULL,
    tournament_name     VARCHAR(200) NOT NULL,
    tournament_year     INTEGER NOT NULL,
    start_date          DATE NOT NULL,
    end_date            DATE NOT NULL,
    created_at          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'DEMO: MerchMasters - Tournament calendar | Author: SE Community | Expires: 2026-01-31';

-- ============================================================================
-- SALES TRANSACTIONS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE SFE_RAW_SALES (
    transaction_id      VARCHAR(50) NOT NULL,
    transaction_date    DATE NOT NULL,
    transaction_time    TIME NOT NULL,
    location_id         INTEGER NOT NULL,
    style_number        VARCHAR(20) NOT NULL,
    sku                 VARCHAR(30),
    quantity_sold       INTEGER NOT NULL,
    unit_price          NUMBER(10,2) NOT NULL,
    total_amount        NUMBER(10,2) NOT NULL,
    payment_method      VARCHAR(20),
    tournament_id       INTEGER,
    created_at          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'DEMO: MerchMasters - POS transactions | Author: SE Community | Expires: 2026-01-31';

-- ============================================================================
-- INVENTORY SNAPSHOTS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE SFE_RAW_INVENTORY (
    snapshot_date       DATE NOT NULL,
    location_id         INTEGER NOT NULL,
    style_number        VARCHAR(20) NOT NULL,
    sku                 VARCHAR(30),
    beginning_qty       INTEGER DEFAULT 0,
    received_qty        INTEGER DEFAULT 0,
    sold_qty            INTEGER DEFAULT 0,
    ending_qty          INTEGER DEFAULT 0,
    tournament_id       INTEGER,
    created_at          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'DEMO: MerchMasters - Daily inventory snapshots | Author: SE Community | Expires: 2026-01-31';

-- Tables ready for data load

