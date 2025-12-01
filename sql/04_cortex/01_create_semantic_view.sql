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
 *   - SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SV_MERCH_INTELLIGENCE (Semantic View)
 * 
 * VERIFIED QUERIES:
 *   1. Top products by revenue
 *   2. Year-over-year category comparison
 *   3. Location sales breakdown
 *   4. Daily sales trend for specific item
 *   5. Inventory status by category
 *   6. Vendor performance comparison
 * 
 * AGENT INTEGRATION:
 *   Used by: MERCH_INTELLIGENCE_AGENT
 *   Sample questions map 1:1 to verified queries below
 * 
 * CLEANUP:
 *   See sql/99_cleanup/teardown_all.sql
 * 
 * Author: SE Community | Expires: 2025-12-31
 ******************************************************************************/

USE DATABASE SNOWFLAKE_EXAMPLE;
USE SCHEMA SEMANTIC_MODELS;

-- ============================================================================
-- CREATE SEMANTIC VIEW
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_MERCH_INTELLIGENCE
COMMENT = 'DEMO: MerchMasters - Semantic model for tournament merchandise analytics. Enables natural language queries about sales, inventory, and performance. | Author: SE Community | Expires: 2025-12-31'
AS

-- Define logical tables
TABLES (
    -- Products dimension
    products AS (
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
            is_dated_year
        FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_PRODUCTS
    )
    PRIMARY KEY (style_number)
    WITH SYNONYMS = ('product', 'item', 'merchandise', 'sku', 'style')
    COMMENT = 'Product catalog with pricing, categories, and vendor information',

    -- Locations dimension
    locations AS (
        SELECT 
            location_id,
            location_name,
            location_type
        FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_LOCATIONS
    )
    PRIMARY KEY (location_id)
    WITH SYNONYMS = ('store', 'shop', 'retail location', 'tent', 'outlet')
    COMMENT = 'Retail locations including Pro Shop and tournament tents',

    -- Tournaments dimension
    tournaments AS (
        SELECT 
            tournament_id,
            tournament_name,
            tournament_year,
            year_label,
            start_date,
            end_date
        FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_TOURNAMENTS
    )
    PRIMARY KEY (tournament_id)
    WITH SYNONYMS = ('event', 'championship', 'competition', 'tournament year')
    COMMENT = 'Tournament calendar with prior year (2024) and current year (2025)',

    -- Dates dimension
    dates AS (
        SELECT 
            date_key,
            full_date,
            day_name,
            tournament_day_num,
            tournament_day_label,
            is_competition_day,
            tournament_id
        FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_DATES
    )
    PRIMARY KEY (date_key)
    WITH SYNONYMS = ('date', 'day', 'tournament day')
    COMMENT = 'Date dimension with tournament context (practice vs competition days)',

    -- Sales fact
    sales AS (
        SELECT 
            transaction_id,
            date_key,
            transaction_date,
            location_id,
            style_number,
            quantity_sold,
            unit_price,
            total_amount,
            total_cost,
            gross_margin,
            payment_method,
            tournament_id
        FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_SALES
    )
    PRIMARY KEY (transaction_id)
    WITH SYNONYMS = ('transaction', 'sale', 'purchase', 'order')
    COMMENT = 'Point-of-sale transactions with revenue and margin calculations',

    -- Inventory fact
    inventory AS (
        SELECT 
            inventory_id,
            date_key,
            snapshot_date,
            location_id,
            style_number,
            beginning_qty,
            received_qty,
            sold_qty,
            ending_qty,
            inventory_value_cost,
            inventory_value_retail,
            stock_status,
            tournament_id
        FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_INVENTORY
    )
    PRIMARY KEY (inventory_id)
    WITH SYNONYMS = ('stock', 'on-hand', 'inventory level', 'stock position')
    COMMENT = 'Daily inventory snapshots by location and product'
)

-- Define relationships between tables
RELATIONSHIPS (
    sales(style_number) REFERENCES products(style_number)
        COMMENT = 'Each sale references one product (many sales per product)',
    sales(location_id) REFERENCES locations(location_id)
        COMMENT = 'Each sale occurs at one location (many sales per location)',
    sales(date_key) REFERENCES dates(date_key)
        COMMENT = 'Each sale has one transaction date',
    sales(tournament_id) REFERENCES tournaments(tournament_id)
        COMMENT = 'Each sale belongs to one tournament',
    inventory(style_number) REFERENCES products(style_number)
        COMMENT = 'Each inventory record references one product',
    inventory(location_id) REFERENCES locations(location_id)
        COMMENT = 'Each inventory record is for one location',
    inventory(tournament_id) REFERENCES tournaments(tournament_id)
        COMMENT = 'Each inventory snapshot belongs to one tournament',
    dates(tournament_id) REFERENCES tournaments(tournament_id)
        COMMENT = 'Each tournament day belongs to one tournament'
)

-- Define dimensions (categorical/descriptive fields for grouping and filtering)
DIMENSIONS (
    -- Product dimensions
    products.style_number
        WITH SYNONYMS = ('style', 'style number', 'item number', 'product code')
        COMMENT = 'Unique product identifier (e.g., GS-001, HAT-015)',
    products.product_name
        WITH SYNONYMS = ('name', 'product', 'item name', 'description')
        COMMENT = 'Full product name with color/style variant',
    products.category
        WITH SYNONYMS = ('product category', 'type', 'product type')
        COMMENT = 'Product category: SHIRTS, HATS, DRINKWARE, ACCESSORIES, OUTERWEAR',
    products.subcategory
        WITH SYNONYMS = ('sub-category', 'product subcategory', 'sub category')
        COMMENT = 'Product subcategory (e.g., Golf Shirts, T-Shirts, Caps, Visors)',
    products.collection
        WITH SYNONYMS = ('product collection', 'line', 'product line')
        COMMENT = 'Product collection (Championship Collection, 2025 Tournament, Evergreen)',
    products.vendor
        WITH SYNONYMS = ('supplier', 'brand', 'manufacturer')
        COMMENT = 'Product vendor/supplier name',
    products.is_dated_year
        WITH SYNONYMS = ('dated', 'tournament dated', 'year specific')
        COMMENT = 'TRUE if product has tournament year branding (limited availability)',

    -- Location dimensions
    locations.location_id
        COMMENT = 'Location identifier',
    locations.location_name
        WITH SYNONYMS = ('store name', 'location', 'store')
        COMMENT = 'Retail location name (Pro Shop, Tournament Tent A/B, Clubhouse Store)',
    locations.location_type
        WITH SYNONYMS = ('store type', 'outlet type')
        COMMENT = 'Location type: PRO SHOP, TOURNAMENT TENT, CLUBHOUSE',

    -- Tournament dimensions
    tournaments.tournament_id
        COMMENT = 'Tournament identifier',
    tournaments.tournament_name
        WITH SYNONYMS = ('event name', 'championship name')
        COMMENT = 'Tournament name (The Championship Invitational)',
    tournaments.tournament_year
        WITH SYNONYMS = ('year', 'event year')
        COMMENT = 'Tournament year (2024 = prior, 2025 = current)',
    tournaments.year_label
        WITH SYNONYMS = ('year comparison', 'period')
        COMMENT = 'Year label: Prior Year (2024) or Current Year (2025)',

    -- Date dimensions
    dates.full_date
        WITH SYNONYMS = ('date', 'transaction date', 'sale date')
        COMMENT = 'Calendar date in YYYY-MM-DD format',
    dates.day_name
        WITH SYNONYMS = ('weekday', 'day of week')
        COMMENT = 'Day of week name (Monday through Sunday)',
    dates.tournament_day_num
        WITH SYNONYMS = ('day number', 'tournament day')
        COMMENT = 'Day number within tournament (1-7)',
    dates.tournament_day_label
        WITH SYNONYMS = ('round', 'round name')
        COMMENT = 'Tournament day description (Practice Round 1, Round 1, Final Round)',
    dates.is_competition_day
        WITH SYNONYMS = ('competition', 'official round')
        COMMENT = 'TRUE for competition days (Rounds 1-4), FALSE for practice rounds',

    -- Sales dimensions
    sales.payment_method
        WITH SYNONYMS = ('payment type', 'payment')
        COMMENT = 'Payment method: CREDIT CARD or CASH',

    -- Inventory dimensions
    inventory.stock_status
        WITH SYNONYMS = ('inventory status', 'stock level')
        COMMENT = 'Stock level status: Critical (<10), Low (<25), Medium (<50), Adequate (50+)'
)

-- Define facts (numeric measures for aggregation)
FACTS (
    -- Sales facts
    sales.quantity_sold
        WITH SYNONYMS = ('units sold', 'qty', 'quantity', 'units')
        COMMENT = 'Number of units sold in transaction. Aggregate via SUM.',
    sales.unit_price
        WITH SYNONYMS = ('price', 'selling price')
        COMMENT = 'Selling price per unit in USD.',
    sales.total_amount
        WITH SYNONYMS = ('revenue', 'sales', 'sales amount', 'dollars')
        COMMENT = 'Total transaction amount in USD (quantity x price). Aggregate via SUM.',
    sales.total_cost
        WITH SYNONYMS = ('cost', 'cogs', 'cost of goods')
        COMMENT = 'Total cost of goods sold in USD. Aggregate via SUM.',
    sales.gross_margin
        WITH SYNONYMS = ('margin', 'profit', 'gross profit')
        COMMENT = 'Gross margin in USD (revenue - cost). Aggregate via SUM.',

    -- Product facts
    products.unit_cost
        WITH SYNONYMS = ('cost per unit', 'wholesale cost')
        COMMENT = 'Product cost per unit in USD.',
    products.retail_price
        WITH SYNONYMS = ('price', 'msrp', 'list price')
        COMMENT = 'Product retail price in USD.',
    products.margin_pct
        WITH SYNONYMS = ('margin percent', 'markup')
        COMMENT = 'Margin percentage ((retail-cost)/cost * 100).',

    -- Inventory facts
    inventory.beginning_qty
        WITH SYNONYMS = ('opening inventory', 'start quantity')
        COMMENT = 'Inventory quantity at start of day.',
    inventory.received_qty
        WITH SYNONYMS = ('receipts', 'received', 'incoming')
        COMMENT = 'Units received during the day.',
    inventory.sold_qty
        WITH SYNONYMS = ('sold', 'units sold from inventory')
        COMMENT = 'Units sold during the day.',
    inventory.ending_qty
        WITH SYNONYMS = ('on hand', 'current stock', 'ending inventory', 'available')
        COMMENT = 'Inventory quantity at end of day (beginning + received - sold).',
    inventory.inventory_value_cost
        WITH SYNONYMS = ('inventory cost value', 'stock value at cost')
        COMMENT = 'Inventory value at cost in USD.',
    inventory.inventory_value_retail
        WITH SYNONYMS = ('inventory retail value', 'stock value at retail')
        COMMENT = 'Inventory value at retail price in USD.'
)

-- Define metrics (pre-computed aggregations)
METRICS (
    -- Revenue metrics
    total_revenue AS SUM(sales.total_amount)
        WITH SYNONYMS = ('revenue', 'total sales', 'sales dollars', 'gross revenue')
        COMMENT = 'Total revenue in USD. Sum of all transaction amounts.',
    
    total_units_sold AS SUM(sales.quantity_sold)
        WITH SYNONYMS = ('units sold', 'total quantity', 'volume')
        COMMENT = 'Total units sold across all transactions.',
    
    total_gross_margin AS SUM(sales.gross_margin)
        WITH SYNONYMS = ('gross profit', 'total margin', 'profit')
        COMMENT = 'Total gross margin in USD (revenue minus cost).',
    
    transaction_count AS COUNT(sales.transaction_id)
        WITH SYNONYMS = ('number of transactions', 'sales count', 'order count')
        COMMENT = 'Count of sales transactions.',
    
    avg_transaction_value AS AVG(sales.total_amount)
        WITH SYNONYMS = ('average sale', 'avg order value', 'aov')
        COMMENT = 'Average transaction value in USD.',
    
    avg_units_per_transaction AS AVG(sales.quantity_sold)
        WITH SYNONYMS = ('average units', 'units per sale')
        COMMENT = 'Average units sold per transaction.',

    -- Inventory metrics
    total_ending_inventory AS SUM(inventory.ending_qty)
        WITH SYNONYMS = ('total stock', 'on hand inventory', 'total on hand')
        COMMENT = 'Total ending inventory units across all locations.',
    
    total_inventory_value AS SUM(inventory.inventory_value_retail)
        WITH SYNONYMS = ('stock value', 'inventory dollars')
        COMMENT = 'Total inventory value at retail price in USD.',
    
    -- Product metrics
    product_count AS COUNT(DISTINCT products.style_number)
        WITH SYNONYMS = ('number of products', 'sku count', 'product variety')
        COMMENT = 'Count of distinct products/styles.'
)

-- Custom instructions for the agent
WITH CUSTOM INSTRUCTIONS =
'BUSINESS CONTEXT:
This semantic model covers merchandise sales and inventory for a premier golf tournament.
Data includes two tournaments: 2024 (prior year) and 2025 (current year) for year-over-year comparison.

KEY BUSINESS TERMS:
- "Dated-year products" = merchandise with tournament year branding (is_dated_year = TRUE)
- "Evergreen" = products without year-specific branding
- "Prior year" or "last year" = 2024 tournament
- "Current year" or "this year" = 2025 tournament
- "Competition days" = tournament rounds 1-4 (days 3-7)
- "Practice rounds" = days 1-2 of tournament week

COMMON QUERY PATTERNS:
- Year-over-year comparison: Filter by tournament_year or year_label
- Category analysis: Group by category or subcategory
- Location comparison: Group by location_name
- Daily trends: Group by full_date or tournament_day_label
- Vendor performance: Group by vendor

DATA FRESHNESS:
- Sales data: Transaction-level detail for both tournaments
- Inventory data: Daily snapshots during tournament week
- Product catalog: ~200 products across 6 categories

IMPORTANT NOTES:
- All monetary values are in USD
- Tournament dates: 2024 (Apr 8-14), 2025 (Apr 7-13)
- 4 retail locations: Pro Shop, Tournament Tent A, Tournament Tent B, Clubhouse Store';


/******************************************************************************
 * VERIFIED QUERIES
 * 
 * These queries have been designed to execute without error and return
 * actual results. They correspond 1:1 with agent sample_questions.
 ******************************************************************************/

-- Query 1: Top 10 products by revenue (current year)
-- Natural Language: "What are the top 10 selling products this year?"
-- Expected Output: style_number, product_name, category, total_revenue
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
-- Expected Output: category, prior_year_revenue, current_year_revenue, yoy_change
/*
SELECT 
    p.category,
    SUM(CASE WHEN t.tournament_year = 2024 THEN s.total_amount ELSE 0 END) AS prior_year_revenue,
    SUM(CASE WHEN t.tournament_year = 2025 THEN s.total_amount ELSE 0 END) AS current_year_revenue,
    ROUND((SUM(CASE WHEN t.tournament_year = 2025 THEN s.total_amount ELSE 0 END) - 
           SUM(CASE WHEN t.tournament_year = 2024 THEN s.total_amount ELSE 0 END)) / 
          NULLIF(SUM(CASE WHEN t.tournament_year = 2024 THEN s.total_amount ELSE 0 END), 0) * 100, 1) AS yoy_change_pct
FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_SALES s
JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_PRODUCTS p ON s.style_number = p.style_number
JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_TOURNAMENTS t ON s.tournament_id = t.tournament_id
GROUP BY p.category
ORDER BY current_year_revenue DESC;
*/

-- Query 3: Sales by location (current year)
-- Natural Language: "How are sales varying by location?"
-- Expected Output: location_name, total_revenue, transaction_count, avg_transaction
/*
SELECT 
    l.location_name,
    SUM(s.total_amount) AS total_revenue,
    COUNT(s.transaction_id) AS transaction_count,
    ROUND(AVG(s.total_amount), 2) AS avg_transaction_value
FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_SALES s
JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_LOCATIONS l ON s.location_id = l.location_id
JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_TOURNAMENTS t ON s.tournament_id = t.tournament_id
WHERE t.tournament_year = 2025
GROUP BY l.location_name
ORDER BY total_revenue DESC;
*/

-- Query 4: Daily sales for specific style
-- Natural Language: "How is style GS-001 selling each day?"
-- Expected Output: transaction_date, day_name, units_sold, revenue
/*
SELECT 
    s.transaction_date,
    d.day_name,
    d.tournament_day_label,
    SUM(s.quantity_sold) AS units_sold,
    SUM(s.total_amount) AS revenue
FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_SALES s
JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_DATES d ON s.date_key = d.date_key
WHERE s.style_number = 'GS-001'
GROUP BY s.transaction_date, d.day_name, d.tournament_day_label, d.tournament_day_num
ORDER BY s.transaction_date;
*/

-- Query 5: Inventory status by category
-- Natural Language: "What is the inventory status for hats?"
-- Expected Output: style_number, product_name, location_name, ending_qty, stock_status
/*
SELECT 
    p.style_number,
    p.product_name,
    l.location_name,
    i.ending_qty,
    i.stock_status
FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_INVENTORY i
JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_PRODUCTS p ON i.style_number = p.style_number
JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_LOCATIONS l ON i.location_id = l.location_id
WHERE p.category = 'HATS'
  AND i.snapshot_date = (SELECT MAX(snapshot_date) FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_INVENTORY)
ORDER BY i.ending_qty ASC;
*/

-- Query 6: Vendor performance comparison
-- Natural Language: "Which vendors are performing best?"
-- Expected Output: vendor, total_revenue, units_sold, product_count
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

