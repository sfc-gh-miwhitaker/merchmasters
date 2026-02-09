/******************************************************************************
 * DEMO PROJECT: MerchMasters
 * Script: Create Staging Views
 *
 * NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 *
 * PURPOSE:
 *   Create staging views that clean and validate raw data
 *
 * OBJECTS CREATED:
 *   - SFE_STG_PRODUCTS (cleaned product catalog)
 *   - SFE_STG_LOCATIONS (cleaned locations)
 *   - SFE_STG_TOURNAMENTS (cleaned tournaments)
 *   - SFE_STG_SALES (cleaned sales with derived fields)
 *   - SFE_STG_INVENTORY (cleaned inventory)
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
USE SCHEMA SFE_MERCH_STAGING;

-- ============================================================================
-- STAGING: PRODUCTS
-- ============================================================================
CREATE OR REPLACE VIEW SFE_STG_PRODUCTS
COMMENT = 'DEMO: MerchMasters - Staged product catalog | Author: SE Community | Expires: 2026-04-10'
AS
SELECT
    TRIM(style_number) AS style_number,
    TRIM(product_name) AS product_name,
    UPPER(TRIM(category)) AS category,
    UPPER(TRIM(COALESCE(subcategory, 'OTHER'))) AS subcategory,
    TRIM(COALESCE(collection, 'Evergreen')) AS collection,
    TRIM(COALESCE(vendor, 'Unknown')) AS vendor,
    COALESCE(unit_cost, 0) AS unit_cost,
    COALESCE(retail_price, 0) AS retail_price,
    retail_price - unit_cost AS margin_amount,
    CASE WHEN unit_cost > 0 THEN ROUND((retail_price - unit_cost) / unit_cost * 100, 2) ELSE 0 END AS margin_pct,
    COALESCE(is_dated_year, FALSE) AS is_dated_year,
    created_at
FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_RAW.SFE_RAW_PRODUCTS
WHERE style_number IS NOT NULL;

-- ============================================================================
-- STAGING: LOCATIONS
-- ============================================================================
CREATE OR REPLACE VIEW SFE_STG_LOCATIONS
COMMENT = 'DEMO: MerchMasters - Staged retail locations | Author: SE Community | Expires: 2026-04-10'
AS
SELECT
    location_id,
    TRIM(location_name) AS location_name,
    UPPER(TRIM(location_type)) AS location_type,
    COALESCE(capacity_sqft, 0) AS capacity_sqft,
    COALESCE(is_active, TRUE) AS is_active,
    created_at
FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_RAW.SFE_RAW_LOCATIONS
WHERE location_id IS NOT NULL;

-- ============================================================================
-- STAGING: TOURNAMENTS
-- ============================================================================
CREATE OR REPLACE VIEW SFE_STG_TOURNAMENTS
COMMENT = 'DEMO: MerchMasters - Staged tournament calendar | Author: SE Community | Expires: 2026-04-10'
AS
SELECT
    tournament_id,
    TRIM(tournament_name) AS tournament_name,
    tournament_year,
    start_date,
    end_date,
    DATEDIFF('day', start_date, end_date) + 1 AS tournament_days,
    created_at
FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_RAW.SFE_RAW_TOURNAMENTS
WHERE tournament_id IS NOT NULL
  AND start_date <= end_date;

-- ============================================================================
-- STAGING: SALES
-- ============================================================================
CREATE OR REPLACE VIEW SFE_STG_SALES
COMMENT = 'DEMO: MerchMasters - Staged sales transactions | Author: SE Community | Expires: 2026-04-10'
AS
SELECT
    transaction_id,
    transaction_date,
    transaction_time,
    TIMESTAMP_FROM_PARTS(transaction_date, transaction_time) AS transaction_timestamp,
    location_id,
    TRIM(style_number) AS style_number,
    TRIM(COALESCE(sku, style_number || '-STD')) AS sku,
    GREATEST(quantity_sold, 1) AS quantity_sold,
    COALESCE(unit_price, 0) AS unit_price,
    COALESCE(total_amount, quantity_sold * unit_price) AS total_amount,
    UPPER(TRIM(COALESCE(payment_method, 'UNKNOWN'))) AS payment_method,
    tournament_id,
    DAYOFWEEK(transaction_date) AS day_of_week,
    DAYNAME(transaction_date) AS day_name,
    created_at
FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_RAW.SFE_RAW_SALES
WHERE transaction_id IS NOT NULL
  AND quantity_sold > 0;

-- ============================================================================
-- STAGING: INVENTORY
-- ============================================================================
CREATE OR REPLACE VIEW SFE_STG_INVENTORY
COMMENT = 'DEMO: MerchMasters - Staged inventory snapshots | Author: SE Community | Expires: 2026-04-10'
AS
SELECT
    snapshot_date,
    location_id,
    TRIM(style_number) AS style_number,
    TRIM(COALESCE(sku, style_number || '-MIX')) AS sku,
    COALESCE(beginning_qty, 0) AS beginning_qty,
    COALESCE(received_qty, 0) AS received_qty,
    COALESCE(sold_qty, 0) AS sold_qty,
    COALESCE(ending_qty, beginning_qty + received_qty - sold_qty) AS ending_qty,
    tournament_id,
    created_at
FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_RAW.SFE_RAW_INVENTORY
WHERE snapshot_date IS NOT NULL;
