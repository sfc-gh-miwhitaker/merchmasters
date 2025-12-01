/******************************************************************************
 * DEMO PROJECT: MerchMasters
 * Script: Create Semantic View for Cortex Analyst
 * 
 * NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 * 
 * PURPOSE:
 *   Define semantic model for tournament merchandise analytics enabling
 *   natural language queries about sales performance, inventory status,
 *   and year-over-year comparisons via Snowflake Intelligence.
 * 
 * OBJECTS CREATED:
 *   - SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SFE_SV_MERCH_INTELLIGENCE (Semantic View)
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
USE DATABASE SNOWFLAKE_EXAMPLE;
USE WAREHOUSE SFE_MERCHMASTERS_WH;
USE SCHEMA SEMANTIC_MODELS;

-- ============================================================================
-- CREATE SEMANTIC VIEW
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SFE_SV_MERCH_INTELLIGENCE

TABLES (
    products AS SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_PRODUCTS
        PRIMARY KEY (style_number),
    locations AS SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_LOCATIONS
        PRIMARY KEY (location_id),
    tournaments AS SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_TOURNAMENTS
        PRIMARY KEY (tournament_id),
    dates AS SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_DATES
        PRIMARY KEY (date_key),
    sales AS SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_SALES
        PRIMARY KEY (transaction_id),
    inventory AS SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_INVENTORY
        PRIMARY KEY (inventory_id)
)

RELATIONSHIPS (
    sales(style_number) REFERENCES products,
    sales(location_id) REFERENCES locations,
    sales(date_key) REFERENCES dates,
    sales(tournament_id) REFERENCES tournaments,
    inventory(style_number) REFERENCES products,
    inventory(location_id) REFERENCES locations,
    inventory(tournament_id) REFERENCES tournaments,
    dates(tournament_id) REFERENCES tournaments
)

FACTS (
    sales.quantity_sold AS quantity_sold
        WITH SYNONYMS ('units sold', 'qty', 'quantity', 'units'),
    sales.unit_price AS unit_price
        WITH SYNONYMS ('price', 'selling price'),
    sales.total_amount AS total_amount
        WITH SYNONYMS ('revenue', 'sales', 'sales amount', 'dollars'),
    sales.total_cost AS total_cost
        WITH SYNONYMS ('cost', 'cogs', 'cost of goods'),
    sales.gross_margin AS gross_margin
        WITH SYNONYMS ('margin', 'profit', 'gross profit'),
    products.product_cost AS unit_cost
        WITH SYNONYMS ('cost per unit', 'wholesale cost'),
    products.product_price AS retail_price
        WITH SYNONYMS ('price', 'msrp', 'list price'),
    products.product_margin_pct AS margin_pct
        WITH SYNONYMS ('margin percent', 'markup'),
    inventory.beginning_qty AS beginning_qty
        WITH SYNONYMS ('opening inventory', 'start quantity'),
    inventory.received_qty AS received_qty
        WITH SYNONYMS ('receipts', 'received', 'incoming'),
    inventory.sold_qty AS sold_qty
        WITH SYNONYMS ('sold', 'units sold from inventory'),
    inventory.ending_qty AS ending_qty
        WITH SYNONYMS ('on hand', 'current stock', 'ending inventory', 'available'),
    inventory.inventory_value_cost AS inventory_value_cost
        WITH SYNONYMS ('inventory cost value', 'stock value at cost'),
    inventory.inventory_value_retail AS inventory_value_retail
        WITH SYNONYMS ('inventory retail value', 'stock value at retail')
)

DIMENSIONS (
    products.style_number AS style_number
        WITH SYNONYMS ('style', 'style number', 'item number', 'product code'),
    products.product_name AS product_name
        WITH SYNONYMS ('name', 'product', 'item name', 'description'),
    products.category AS category
        WITH SYNONYMS ('product category', 'type', 'product type'),
    products.subcategory AS subcategory
        WITH SYNONYMS ('sub-category', 'product subcategory'),
    products.collection AS collection
        WITH SYNONYMS ('product collection', 'line', 'product line'),
    products.vendor AS vendor
        WITH SYNONYMS ('supplier', 'brand', 'manufacturer'),
    products.is_dated_year AS is_dated_year
        WITH SYNONYMS ('dated', 'tournament dated', 'year specific'),
    locations.location_id AS location_id,
    locations.location_name AS location_name
        WITH SYNONYMS ('store name', 'location', 'store'),
    locations.location_type AS location_type
        WITH SYNONYMS ('store type', 'outlet type'),
    tournaments.tournament_id AS tournament_id,
    tournaments.tournament_name AS tournament_name
        WITH SYNONYMS ('event name', 'championship name'),
    tournaments.tournament_year AS tournament_year
        WITH SYNONYMS ('year', 'event year'),
    tournaments.year_label AS year_label
        WITH SYNONYMS ('year comparison', 'period'),
    dates.full_date AS full_date
        WITH SYNONYMS ('date', 'transaction date', 'sale date'),
    dates.day_name AS day_name
        WITH SYNONYMS ('weekday', 'day of week'),
    dates.tournament_day_num AS tournament_day_num
        WITH SYNONYMS ('day number', 'tournament day'),
    dates.tournament_day_label AS tournament_day_label
        WITH SYNONYMS ('round', 'round name'),
    dates.is_competition_day AS is_competition_day
        WITH SYNONYMS ('competition', 'official round'),
    sales.payment_method AS payment_method
        WITH SYNONYMS ('payment type', 'payment'),
    inventory.stock_status AS stock_status
        WITH SYNONYMS ('inventory status', 'stock level')
)

METRICS (
    sales.total_revenue AS SUM(sales.total_amount)
        WITH SYNONYMS ('revenue', 'total sales', 'sales dollars', 'gross revenue'),
    sales.total_units_sold AS SUM(sales.quantity_sold)
        WITH SYNONYMS ('units sold', 'total quantity', 'volume'),
    sales.total_gross_margin AS SUM(sales.gross_margin)
        WITH SYNONYMS ('gross profit', 'total margin', 'profit'),
    sales.transaction_count AS COUNT(sales.transaction_id)
        WITH SYNONYMS ('number of transactions', 'sales count', 'order count'),
    sales.avg_transaction_value AS AVG(sales.total_amount)
        WITH SYNONYMS ('average sale', 'avg order value', 'aov'),
    sales.avg_units_per_transaction AS AVG(sales.quantity_sold)
        WITH SYNONYMS ('average units', 'units per sale'),
    inventory.total_ending_inventory AS SUM(inventory.ending_qty)
        WITH SYNONYMS ('total stock', 'on hand inventory', 'total on hand'),
    inventory.total_inventory_value AS SUM(inventory.inventory_value_retail)
        WITH SYNONYMS ('stock value', 'inventory dollars'),
    products.product_count AS COUNT(DISTINCT products.style_number)
        WITH SYNONYMS ('number of products', 'sku count', 'product variety')
)

COMMENT = 'DEMO: MerchMasters - Semantic model for tournament merchandise analytics | Author: SE Community | Expires: 2025-12-31';


/******************************************************************************
 * VERIFIED QUERIES
 * 
 * These queries have been designed to execute without error and return
 * actual results.
 ******************************************************************************/

-- Query 1: Top 10 products by revenue (current year)
-- Natural Language: "What are the top 10 selling products this year?"
/*
SELECT 
    p.style_number,
    p.product_name,
    p.category,
    SUM(s.total_amount) AS total_revenue
FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_SALES s
JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_PRODUCTS p 
    ON s.style_number = p.style_number
JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_TOURNAMENTS t 
    ON s.tournament_id = t.tournament_id
WHERE t.tournament_year = 2025
GROUP BY p.style_number, p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 10;
*/

-- Query 2: Year-over-year category comparison
-- Natural Language: "How are sales by category comparing to last year?"
/*
SELECT 
    p.category,
    SUM(CASE WHEN t.tournament_year = 2024 THEN s.total_amount ELSE 0 END) AS prior_year_revenue,
    SUM(CASE WHEN t.tournament_year = 2025 THEN s.total_amount ELSE 0 END) AS current_year_revenue
FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_SALES s
JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_PRODUCTS p ON s.style_number = p.style_number
JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_TOURNAMENTS t ON s.tournament_id = t.tournament_id
GROUP BY p.category
ORDER BY current_year_revenue DESC;
*/

-- Query 3: Sales by location (current year)
-- Natural Language: "How are sales varying by location?"
/*
SELECT 
    l.location_name,
    SUM(s.total_amount) AS total_revenue,
    COUNT(s.transaction_id) AS transaction_count
FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_SALES s
JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_LOCATIONS l ON s.location_id = l.location_id
JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_TOURNAMENTS t ON s.tournament_id = t.tournament_id
WHERE t.tournament_year = 2025
GROUP BY l.location_name
ORDER BY total_revenue DESC;
*/

-- Query 4: Vendor performance comparison
-- Natural Language: "Which vendors are performing best?"
/*
SELECT 
    p.vendor,
    SUM(s.total_amount) AS total_revenue,
    SUM(s.quantity_sold) AS units_sold,
    COUNT(DISTINCT p.style_number) AS product_count
FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_SALES s
JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_PRODUCTS p ON s.style_number = p.style_number
JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_TOURNAMENTS t ON s.tournament_id = t.tournament_id
WHERE t.tournament_year = 2025
GROUP BY p.vendor
ORDER BY total_revenue DESC;
*/
