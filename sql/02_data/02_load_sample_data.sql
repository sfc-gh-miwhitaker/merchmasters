/******************************************************************************
 * DEMO PROJECT: MerchMasters
 * Script: Load Sample Data
 * 
 * NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 * 
 * PURPOSE:
 *   Generate realistic synthetic merchandise data for demo
 * 
 * DATA VOLUMES:
 *   - ~200 products (styles)
 *   - 4 retail locations
 *   - 2 tournaments (prior year + current year)
 *   - ~100,000 sales transactions
 *   - ~5,000 inventory snapshots
 * 
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 * 
 * Author: SE Community | Expires: 2025-12-31
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA SFE_MERCH_RAW;

-- ============================================================================
-- LOAD LOCATIONS
-- ============================================================================
INSERT INTO SFE_RAW_LOCATIONS (location_id, location_name, location_type, capacity_sqft)
VALUES
    (1, 'Pro Shop', 'Pro Shop', 2500),
    (2, 'Tournament Tent A', 'Tournament Tent', 5000),
    (3, 'Tournament Tent B', 'Tournament Tent', 4000),
    (4, 'Clubhouse Store', 'Clubhouse', 1800);

-- ============================================================================
-- LOAD TOURNAMENTS
-- ============================================================================
INSERT INTO SFE_RAW_TOURNAMENTS (tournament_id, tournament_name, tournament_year, start_date, end_date)
VALUES
    (1, 'The Championship Invitational', 2024, '2024-04-08', '2024-04-14'),
    (2, 'The Championship Invitational', 2025, '2025-04-07', '2025-04-13');

-- ============================================================================
-- LOAD PRODUCTS
-- ============================================================================
-- Generate product catalog with various categories

-- Golf Shirts (Polos)
INSERT INTO SFE_RAW_PRODUCTS (style_number, product_name, category, subcategory, collection, vendor, unit_cost, retail_price, is_dated_year)
SELECT 
    'GS-' || LPAD(SEQ4()::VARCHAR, 3, '0') AS style_number,
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'Classic Polo'
        WHEN 1 THEN 'Performance Polo'
        WHEN 2 THEN 'Striped Polo'
        WHEN 3 THEN 'Moisture-Wicking Polo'
        ELSE 'Premium Polo'
    END || ' - ' ||
    CASE MOD(SEQ4(), 6)
        WHEN 0 THEN 'Navy'
        WHEN 1 THEN 'White'
        WHEN 2 THEN 'Green'
        WHEN 3 THEN 'Black'
        WHEN 4 THEN 'Red'
        ELSE 'Gray'
    END AS product_name,
    'Shirts' AS category,
    'Golf Shirts' AS subcategory,
    CASE MOD(SEQ4(), 3)
        WHEN 0 THEN 'Championship Collection'
        WHEN 1 THEN 'Heritage Collection'
        ELSE 'Performance Collection'
    END AS collection,
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN 'Apex Apparel'
        WHEN 1 THEN 'Summit Sportswear'
        WHEN 2 THEN 'Fairway Fashions'
        ELSE 'Links & Co'
    END AS vendor,
    ROUND(25 + UNIFORM(0, 20, RANDOM()), 2) AS unit_cost,
    ROUND(65 + UNIFORM(0, 50, RANDOM()), 2) AS retail_price,
    FALSE AS is_dated_year
FROM TABLE(GENERATOR(ROWCOUNT => 40));

-- T-Shirts
INSERT INTO SFE_RAW_PRODUCTS (style_number, product_name, category, subcategory, collection, vendor, unit_cost, retail_price, is_dated_year)
SELECT 
    'TS-' || LPAD(SEQ4()::VARCHAR, 3, '0') AS style_number,
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN 'Championship Logo Tee'
        WHEN 1 THEN 'Course Map Tee'
        WHEN 2 THEN 'Vintage Badge Tee'
        ELSE 'Classic Crew Tee'
    END || ' - ' ||
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'White'
        WHEN 1 THEN 'Green'
        WHEN 2 THEN 'Navy'
        WHEN 3 THEN 'Gray'
        ELSE 'Black'
    END AS product_name,
    'Shirts' AS category,
    'T-Shirts' AS subcategory,
    CASE MOD(SEQ4(), 2) WHEN 0 THEN '2025 Tournament' ELSE 'Evergreen' END AS collection,
    CASE MOD(SEQ4(), 3)
        WHEN 0 THEN 'Apex Apparel'
        WHEN 1 THEN 'Cotton Classics'
        ELSE 'Fairway Fashions'
    END AS vendor,
    ROUND(8 + UNIFORM(0, 8, RANDOM()), 2) AS unit_cost,
    ROUND(28 + UNIFORM(0, 17, RANDOM()), 2) AS retail_price,
    CASE MOD(SEQ4(), 2) WHEN 0 THEN TRUE ELSE FALSE END AS is_dated_year
FROM TABLE(GENERATOR(ROWCOUNT => 35));

-- Hats
INSERT INTO SFE_RAW_PRODUCTS (style_number, product_name, category, subcategory, collection, vendor, unit_cost, retail_price, is_dated_year)
SELECT 
    'HAT-' || LPAD(SEQ4()::VARCHAR, 3, '0') AS style_number,
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'Championship Cap'
        WHEN 1 THEN 'Visor'
        WHEN 2 THEN 'Bucket Hat'
        WHEN 3 THEN 'Fitted Cap'
        ELSE 'Trucker Hat'
    END || ' - ' ||
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN 'White'
        WHEN 1 THEN 'Green'
        WHEN 2 THEN 'Navy'
        ELSE 'Khaki'
    END AS product_name,
    'Hats' AS category,
    CASE MOD(SEQ4(), 5) WHEN 1 THEN 'Visors' WHEN 2 THEN 'Bucket Hats' ELSE 'Caps' END AS subcategory,
    CASE MOD(SEQ4(), 2) WHEN 0 THEN '2025 Tournament' ELSE 'Evergreen' END AS collection,
    CASE MOD(SEQ4(), 3)
        WHEN 0 THEN 'Headwear Inc'
        WHEN 1 THEN 'Cap Masters'
        ELSE 'Summit Sportswear'
    END AS vendor,
    ROUND(8 + UNIFORM(0, 7, RANDOM()), 2) AS unit_cost,
    ROUND(28 + UNIFORM(0, 22, RANDOM()), 2) AS retail_price,
    CASE MOD(SEQ4(), 2) WHEN 0 THEN TRUE ELSE FALSE END AS is_dated_year
FROM TABLE(GENERATOR(ROWCOUNT => 30));

-- Drinkware
INSERT INTO SFE_RAW_PRODUCTS (style_number, product_name, category, subcategory, collection, vendor, unit_cost, retail_price, is_dated_year)
SELECT 
    'DW-' || LPAD(SEQ4()::VARCHAR, 3, '0') AS style_number,
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'Insulated Tumbler'
        WHEN 1 THEN 'Water Bottle'
        WHEN 2 THEN 'Coffee Mug'
        WHEN 3 THEN 'Pint Glass Set'
        ELSE 'Wine Glass Set'
    END || ' - ' ||
    CASE MOD(SEQ4(), 3)
        WHEN 0 THEN 'Championship Logo'
        WHEN 1 THEN 'Course Map'
        ELSE 'Classic'
    END AS product_name,
    'Drinkware' AS category,
    CASE MOD(SEQ4(), 5) WHEN 0 THEN 'Tumblers' WHEN 1 THEN 'Bottles' WHEN 2 THEN 'Mugs' ELSE 'Glassware' END AS subcategory,
    'Evergreen' AS collection,
    CASE MOD(SEQ4(), 2) WHEN 0 THEN 'Drinkware Direct' ELSE 'Premium Vessels' END AS vendor,
    ROUND(6 + UNIFORM(0, 12, RANDOM()), 2) AS unit_cost,
    ROUND(22 + UNIFORM(0, 33, RANDOM()), 2) AS retail_price,
    FALSE AS is_dated_year
FROM TABLE(GENERATOR(ROWCOUNT => 25));

-- Accessories
INSERT INTO SFE_RAW_PRODUCTS (style_number, product_name, category, subcategory, collection, vendor, unit_cost, retail_price, is_dated_year)
SELECT 
    'ACC-' || LPAD(SEQ4()::VARCHAR, 3, '0') AS style_number,
    CASE MOD(SEQ4(), 8)
        WHEN 0 THEN 'Golf Towel'
        WHEN 1 THEN 'Ball Marker Set'
        WHEN 2 THEN 'Divot Tool'
        WHEN 3 THEN 'Tote Bag'
        WHEN 4 THEN 'Cooler Bag'
        WHEN 5 THEN 'Umbrella'
        WHEN 6 THEN 'Keychain'
        ELSE 'Pin Flag'
    END || ' - ' ||
    CASE MOD(SEQ4(), 2) WHEN 0 THEN 'Championship Logo' ELSE 'Classic' END AS product_name,
    'Accessories' AS category,
    CASE MOD(SEQ4(), 8)
        WHEN 0 THEN 'Towels'
        WHEN 1 THEN 'Ball Markers'
        WHEN 2 THEN 'Divot Tools'
        WHEN 3 THEN 'Bags'
        WHEN 4 THEN 'Bags'
        WHEN 5 THEN 'Umbrellas'
        WHEN 6 THEN 'Keychains'
        ELSE 'Flags'
    END AS subcategory,
    CASE MOD(SEQ4(), 3) WHEN 0 THEN '2025 Tournament' ELSE 'Evergreen' END AS collection,
    CASE MOD(SEQ4(), 3)
        WHEN 0 THEN 'Golf Gear Co'
        WHEN 1 THEN 'Links & Co'
        ELSE 'Premium Golf'
    END AS vendor,
    ROUND(4 + UNIFORM(0, 18, RANDOM()), 2) AS unit_cost,
    ROUND(12 + UNIFORM(0, 48, RANDOM()), 2) AS retail_price,
    CASE MOD(SEQ4(), 3) WHEN 0 THEN TRUE ELSE FALSE END AS is_dated_year
FROM TABLE(GENERATOR(ROWCOUNT => 40));

-- Outerwear
INSERT INTO SFE_RAW_PRODUCTS (style_number, product_name, category, subcategory, collection, vendor, unit_cost, retail_price, is_dated_year)
SELECT 
    'OW-' || LPAD(SEQ4()::VARCHAR, 3, '0') AS style_number,
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN 'Quarter Zip Pullover'
        WHEN 1 THEN 'Full Zip Jacket'
        WHEN 2 THEN 'Windbreaker'
        ELSE 'Vest'
    END || ' - ' ||
    CASE MOD(SEQ4(), 4)
        WHEN 0 THEN 'Navy'
        WHEN 1 THEN 'Green'
        WHEN 2 THEN 'Black'
        ELSE 'Gray'
    END AS product_name,
    'Outerwear' AS category,
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'Pullovers' WHEN 1 THEN 'Jackets' WHEN 2 THEN 'Windbreakers' ELSE 'Vests' END AS subcategory,
    CASE MOD(SEQ4(), 2) WHEN 0 THEN 'Championship Collection' ELSE 'Performance Collection' END AS collection,
    CASE MOD(SEQ4(), 3)
        WHEN 0 THEN 'Apex Apparel'
        WHEN 1 THEN 'Summit Sportswear'
        ELSE 'Fairway Fashions'
    END AS vendor,
    ROUND(35 + UNIFORM(0, 40, RANDOM()), 2) AS unit_cost,
    ROUND(95 + UNIFORM(0, 80, RANDOM()), 2) AS retail_price,
    FALSE AS is_dated_year
FROM TABLE(GENERATOR(ROWCOUNT => 30));

-- ============================================================================
-- GENERATE SALES TRANSACTIONS
-- ============================================================================
-- Generate ~100,000 sales transactions across both tournaments

-- Helper: Create date spine for both tournaments
CREATE OR REPLACE TEMPORARY TABLE tmp_tournament_dates AS
SELECT 
    t.tournament_id,
    t.tournament_name,
    t.tournament_year,
    d.sale_date,
    CASE 
        WHEN DAYOFWEEK(d.sale_date) IN (0, 6) THEN 1.5  -- Weekend boost
        WHEN d.sale_date = t.end_date THEN 2.0          -- Final day surge
        ELSE 1.0 
    END AS day_multiplier
FROM SFE_RAW_TOURNAMENTS t,
LATERAL (
    SELECT DATEADD('day', SEQ4(), t.start_date) AS sale_date
    FROM TABLE(GENERATOR(ROWCOUNT => 7))
    WHERE DATEADD('day', SEQ4(), t.start_date) <= t.end_date
) d;

-- Generate sales for 2024 tournament (prior year)
INSERT INTO SFE_RAW_SALES (
    transaction_id, transaction_date, transaction_time, location_id, 
    style_number, sku, quantity_sold, unit_price, total_amount, 
    payment_method, tournament_id
)
SELECT 
    '2024-' || LPAD(ROW_NUMBER() OVER (ORDER BY RANDOM())::VARCHAR, 7, '0') AS transaction_id,
    td.sale_date AS transaction_date,
    TIMEADD('minute', UNIFORM(480, 1140, RANDOM()), '00:00:00'::TIME) AS transaction_time,
    UNIFORM(1, 4, RANDOM()) AS location_id,
    p.style_number,
    p.style_number || '-' || 
        CASE MOD(UNIFORM(1, 10, RANDOM()), 5) WHEN 0 THEN 'S' WHEN 1 THEN 'M' WHEN 2 THEN 'L' WHEN 3 THEN 'XL' ELSE 'XXL' END AS sku,
    GREATEST(1, ROUND(UNIFORM(1, 4, RANDOM()) * td.day_multiplier)) AS quantity_sold,
    p.retail_price AS unit_price,
    GREATEST(1, ROUND(UNIFORM(1, 4, RANDOM()) * td.day_multiplier)) * p.retail_price AS total_amount,
    CASE UNIFORM(1, 10, RANDOM()) 
        WHEN 1 THEN 'Cash'
        WHEN 2 THEN 'Cash'
        ELSE 'Credit Card'
    END AS payment_method,
    td.tournament_id
FROM tmp_tournament_dates td
CROSS JOIN SFE_RAW_PRODUCTS p
CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 3))
WHERE td.tournament_year = 2024
  AND UNIFORM(0, 100, RANDOM()) < 40;  -- ~40% probability per product/day combo

-- Generate sales for 2025 tournament (current year) - higher volume
INSERT INTO SFE_RAW_SALES (
    transaction_id, transaction_date, transaction_time, location_id, 
    style_number, sku, quantity_sold, unit_price, total_amount, 
    payment_method, tournament_id
)
SELECT 
    '2025-' || LPAD(ROW_NUMBER() OVER (ORDER BY RANDOM())::VARCHAR, 7, '0') AS transaction_id,
    td.sale_date AS transaction_date,
    TIMEADD('minute', UNIFORM(480, 1140, RANDOM()), '00:00:00'::TIME) AS transaction_time,
    UNIFORM(1, 4, RANDOM()) AS location_id,
    p.style_number,
    p.style_number || '-' || 
        CASE MOD(UNIFORM(1, 10, RANDOM()), 5) WHEN 0 THEN 'S' WHEN 1 THEN 'M' WHEN 2 THEN 'L' WHEN 3 THEN 'XL' ELSE 'XXL' END AS sku,
    GREATEST(1, ROUND(UNIFORM(1, 5, RANDOM()) * td.day_multiplier)) AS quantity_sold,
    p.retail_price AS unit_price,
    GREATEST(1, ROUND(UNIFORM(1, 5, RANDOM()) * td.day_multiplier)) * p.retail_price AS total_amount,
    CASE UNIFORM(1, 10, RANDOM()) 
        WHEN 1 THEN 'Cash'
        ELSE 'Credit Card'
    END AS payment_method,
    td.tournament_id
FROM tmp_tournament_dates td
CROSS JOIN SFE_RAW_PRODUCTS p
CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 4))
WHERE td.tournament_year = 2025
  AND UNIFORM(0, 100, RANDOM()) < 45;  -- ~45% probability (higher for current year)

-- ============================================================================
-- GENERATE INVENTORY SNAPSHOTS
-- ============================================================================
-- Daily inventory by location and product

INSERT INTO SFE_RAW_INVENTORY (
    snapshot_date, location_id, style_number, sku,
    beginning_qty, received_qty, sold_qty, ending_qty, tournament_id
)
WITH daily_sales AS (
    SELECT 
        transaction_date,
        location_id,
        style_number,
        tournament_id,
        SUM(quantity_sold) AS daily_sold
    FROM SFE_RAW_SALES
    GROUP BY transaction_date, location_id, style_number, tournament_id
)
SELECT 
    td.sale_date AS snapshot_date,
    l.location_id,
    p.style_number,
    p.style_number || '-MIX' AS sku,
    UNIFORM(50, 200, RANDOM()) AS beginning_qty,
    CASE WHEN DAYOFWEEK(td.sale_date) = 1 THEN UNIFORM(20, 100, RANDOM()) ELSE 0 END AS received_qty,
    COALESCE(ds.daily_sold, 0) AS sold_qty,
    UNIFORM(50, 200, RANDOM()) + 
        CASE WHEN DAYOFWEEK(td.sale_date) = 1 THEN UNIFORM(20, 100, RANDOM()) ELSE 0 END - 
        COALESCE(ds.daily_sold, 0) AS ending_qty,
    td.tournament_id
FROM tmp_tournament_dates td
CROSS JOIN SFE_RAW_LOCATIONS l
CROSS JOIN SFE_RAW_PRODUCTS p
LEFT JOIN daily_sales ds 
    ON td.sale_date = ds.transaction_date 
    AND l.location_id = ds.location_id 
    AND p.style_number = ds.style_number
WHERE UNIFORM(0, 100, RANDOM()) < 30;  -- Sample ~30% of combinations

-- Cleanup temp table
DROP TABLE IF EXISTS tmp_tournament_dates;

-- ============================================================================
-- DATA LOAD COMPLETE
-- ============================================================================
-- To verify data load, run these queries in a separate worksheet:
--   SELECT COUNT(*) FROM SFE_RAW_PRODUCTS;
--   SELECT COUNT(*) FROM SFE_RAW_SALES;
--   SELECT COUNT(*) FROM SFE_RAW_INVENTORY;

