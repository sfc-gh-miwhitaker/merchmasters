/******************************************************************************
 * DEMO PROJECT: MerchMasters
 * Script: Create Analytics Tables (Star Schema)
 * 
 * NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 * 
 * PURPOSE:
 *   Create dimension and fact tables for Cortex Analyst
 * 
 * OBJECTS CREATED:
 *   - SFE_DIM_PRODUCTS (product dimension)
 *   - SFE_DIM_LOCATIONS (location dimension)
 *   - SFE_DIM_TOURNAMENTS (tournament dimension)
 *   - SFE_DIM_DATES (date dimension with tournament context)
 *   - SFE_FCT_SALES (sales fact)
 *   - SFE_FCT_INVENTORY (inventory fact)
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
-- DIMENSION: PRODUCTS
-- ============================================================================
CREATE OR REPLACE TABLE SFE_DIM_PRODUCTS
COMMENT = 'DEMO: MerchMasters - Product dimension | Author: SE Community | Expires: 2026-01-31'
AS
SELECT 
    style_number,
    product_name,
    category,
    subcategory,
    collection,
    vendor,
    unit_cost,
    retail_price,
    margin_amount,
    margin_pct,
    is_dated_year,
    created_at,
    CURRENT_TIMESTAMP() AS loaded_at
FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_STAGING.SFE_STG_PRODUCTS;

-- ============================================================================
-- DIMENSION: LOCATIONS
-- ============================================================================
CREATE OR REPLACE TABLE SFE_DIM_LOCATIONS
COMMENT = 'DEMO: MerchMasters - Location dimension | Author: SE Community | Expires: 2026-01-31'
AS
SELECT 
    location_id,
    location_name,
    location_type,
    capacity_sqft,
    is_active,
    created_at,
    CURRENT_TIMESTAMP() AS loaded_at
FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_STAGING.SFE_STG_LOCATIONS;

-- ============================================================================
-- DIMENSION: TOURNAMENTS
-- ============================================================================
CREATE OR REPLACE TABLE SFE_DIM_TOURNAMENTS
COMMENT = 'DEMO: MerchMasters - Tournament dimension | Author: SE Community | Expires: 2026-01-31'
AS
SELECT 
    tournament_id,
    tournament_name,
    tournament_year,
    start_date,
    end_date,
    tournament_days,
    CASE tournament_year 
        WHEN 2024 THEN 'Prior Year'
        WHEN 2025 THEN 'Current Year'
        ELSE 'Other'
    END AS year_label,
    created_at,
    CURRENT_TIMESTAMP() AS loaded_at
FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_STAGING.SFE_STG_TOURNAMENTS;

-- ============================================================================
-- DIMENSION: DATES
-- ============================================================================
CREATE OR REPLACE TABLE SFE_DIM_DATES
COMMENT = 'DEMO: MerchMasters - Date dimension with tournament context | Author: SE Community | Expires: 2026-01-31'
AS
WITH RECURSIVE date_spine AS (
    -- Anchor: start with first day of each tournament
    SELECT 
        tournament_id,
        tournament_name,
        tournament_year,
        start_date,
        end_date,
        start_date AS full_date
    FROM SFE_DIM_TOURNAMENTS
    
    UNION ALL
    
    -- Recursive: add one day until end_date
    SELECT 
        ds.tournament_id,
        ds.tournament_name,
        ds.tournament_year,
        ds.start_date,
        ds.end_date,
        DATEADD('day', 1, ds.full_date) AS full_date
    FROM date_spine ds
    WHERE ds.full_date < ds.end_date
),
tournament_dates AS (
    SELECT 
        tournament_id,
        tournament_name,
        tournament_year,
        start_date,
        full_date,
        ROW_NUMBER() OVER (PARTITION BY tournament_id ORDER BY full_date) AS tournament_day_num
    FROM date_spine
)
SELECT 
    TO_NUMBER(TO_CHAR(td.full_date, 'YYYYMMDD')) AS date_key,
    td.full_date,
    YEAR(td.full_date) AS year_num,
    MONTH(td.full_date) AS month_num,
    DAY(td.full_date) AS day_num,
    DAYOFWEEK(td.full_date) AS day_of_week,
    DAYNAME(td.full_date) AS day_name,
    td.tournament_id,
    td.tournament_name,
    td.tournament_year,
    td.tournament_day_num,
    CASE 
        WHEN td.tournament_day_num <= 2 THEN FALSE  -- Practice rounds
        ELSE TRUE  -- Competition days
    END AS is_competition_day,
    CASE 
        WHEN td.tournament_day_num = 1 THEN 'Practice Round 1'
        WHEN td.tournament_day_num = 2 THEN 'Practice Round 2'
        WHEN td.tournament_day_num = 3 THEN 'Round 1'
        WHEN td.tournament_day_num = 4 THEN 'Round 2'
        WHEN td.tournament_day_num = 5 THEN 'Round 3'
        WHEN td.tournament_day_num = 6 THEN 'Round 4 (Moving Day)'
        WHEN td.tournament_day_num = 7 THEN 'Final Round'
        ELSE 'Tournament Day ' || td.tournament_day_num
    END AS tournament_day_label,
    CURRENT_TIMESTAMP() AS loaded_at
FROM tournament_dates td;

-- ============================================================================
-- FACT: SALES
-- ============================================================================
CREATE OR REPLACE TABLE SFE_FCT_SALES
COMMENT = 'DEMO: MerchMasters - Sales fact table | Author: SE Community | Expires: 2026-01-31'
AS
SELECT 
    s.transaction_id,
    TO_NUMBER(TO_CHAR(s.transaction_date, 'YYYYMMDD')) AS date_key,
    s.transaction_date,
    s.transaction_time,
    s.transaction_timestamp,
    s.location_id,
    s.style_number,
    s.sku,
    s.quantity_sold,
    s.unit_price,
    s.total_amount,
    p.unit_cost * s.quantity_sold AS total_cost,
    s.total_amount - (p.unit_cost * s.quantity_sold) AS gross_margin,
    s.payment_method,
    s.tournament_id,
    s.day_of_week,
    s.day_name,
    CURRENT_TIMESTAMP() AS loaded_at
FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_STAGING.SFE_STG_SALES s
LEFT JOIN SFE_DIM_PRODUCTS p ON s.style_number = p.style_number;

-- ============================================================================
-- FACT: INVENTORY
-- ============================================================================
CREATE OR REPLACE TABLE SFE_FCT_INVENTORY
COMMENT = 'DEMO: MerchMasters - Inventory fact table | Author: SE Community | Expires: 2026-01-31'
AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY i.snapshot_date, i.location_id, i.style_number) AS inventory_id,
    TO_NUMBER(TO_CHAR(i.snapshot_date, 'YYYYMMDD')) AS date_key,
    i.snapshot_date,
    i.location_id,
    i.style_number,
    i.sku,
    i.beginning_qty,
    i.received_qty,
    i.sold_qty,
    i.ending_qty,
    p.unit_cost * i.ending_qty AS inventory_value_cost,
    p.retail_price * i.ending_qty AS inventory_value_retail,
    i.tournament_id,
    CASE 
        WHEN i.ending_qty <= 10 THEN 'Critical'
        WHEN i.ending_qty <= 25 THEN 'Low'
        WHEN i.ending_qty <= 50 THEN 'Medium'
        ELSE 'Adequate'
    END AS stock_status,
    CURRENT_TIMESTAMP() AS loaded_at
FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_STAGING.SFE_STG_INVENTORY i
LEFT JOIN SFE_DIM_PRODUCTS p ON i.style_number = p.style_number;

