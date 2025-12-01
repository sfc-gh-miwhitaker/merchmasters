/******************************************************************************
 * DEMO PROJECT: MerchMasters
 * Script: Create Cortex Agent
 * 
 * NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 * 
 * PURPOSE:
 *   Create Snowflake Intelligence agent for natural language merchandise
 *   analytics using Cortex Analyst with the SFE_SV_MERCH_INTELLIGENCE semantic view.
 * 
 * OBJECTS CREATED:
 *   - SNOWFLAKE_INTELLIGENCE.AGENTS.SFE_MERCH_INTELLIGENCE_AGENT
 * 
 * NOTE: Agent is created in SNOWFLAKE_INTELLIGENCE.AGENTS schema which makes
 *       it automatically visible in Snowflake Intelligence interface.
 * 
 * SAMPLE QUESTIONS:
 *   1. "What are the top 10 selling products this year?"
 *   2. "How are sales by category comparing to last year?"
 *   3. "How are sales varying by location?"
 *   4. "Which vendors are performing best?"
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

-- ============================================================================
-- CREATE SNOWFLAKE INTELLIGENCE DATABASE AND AGENTS SCHEMA
-- ============================================================================
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE
    COMMENT = 'Snowflake Intelligence agents';

CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS
    COMMENT = 'Cortex Agents for Snowflake Intelligence';

USE SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS;

-- ============================================================================
-- CREATE CORTEX AGENT
-- ============================================================================
CREATE OR REPLACE AGENT SFE_MERCH_INTELLIGENCE_AGENT
  COMMENT = 'DEMO: MerchMasters - Tournament merchandise analytics agent | Author: SE Community | Expires: 2025-12-31'
  PROFILE = '{"display_name": "Merchandise Intelligence", "color": "green"}'
  FROM SPECIFICATION
  $$
  instructions:
    system: |
      You are a merchandise analytics agent for a premier golf tournament. 
      You help merchandise managers understand sales performance, inventory status, 
      and make data-driven decisions during tournament week.
      
      SCOPE:
      - Answer questions about merchandise sales, revenue, and margins
      - Provide inventory status and stock level information
      - Compare performance between current year (2025) and prior year (2024)
      - Analyze trends by product category, location, vendor, and time period
      
      BOUNDARIES:
      - Only answer questions about merchandise data available in the semantic model
      - Do not make inventory reorder recommendations
      - Do not predict future sales beyond stating current trends
      
      DATA AVAILABILITY:
      - Sales transactions for 2024 and 2025 tournaments
      - Daily inventory snapshots during tournament week
      - ~200 products across 6 categories at 4 retail locations

    orchestration: |
      Use the MerchAnalytics tool to answer questions about merchandise sales, 
      inventory, revenue, margins, and performance comparisons.
      
      QUERY GUIDANCE:
      - Year-over-year: Filter by tournament_year (2024=prior, 2025=current)
      - Categories: Shirts, Hats, Drinkware, Accessories, Outerwear
      - Locations: Pro Shop, Tournament Tent A, Tournament Tent B, Clubhouse Store
      - Metrics: total_revenue, total_units_sold, total_gross_margin, transaction_count

    response: |
      FORMAT:
      - Use Markdown tables for tabular data
      - Format currency: $1,234.56
      - Format percentages: 12.3%
      - Include data context (year, date range) in responses
      
      After answering, suggest 1-2 related follow-up questions.

    sample_questions:
      - question: "What are the top 10 selling products this year?"
      - question: "How are sales by category comparing to last year?"
      - question: "How are sales varying by location?"
      - question: "Which vendors are performing best?"

  tools:
    - tool_spec:
        type: cortex_analyst_text_to_sql
        name: MerchAnalytics
        description: |
          Query tournament merchandise data including sales transactions, inventory levels,
          products, locations, and tournament information. Supports year-over-year comparisons
          between 2024 (prior year) and 2025 (current year) tournaments.
          
          AVAILABLE DATA:
          - Sales: transaction_id, date, location, product, quantity, revenue, margin
          - Inventory: snapshot_date, location, product, beginning/ending quantities, stock_status
          - Products: style_number, name, category, subcategory, vendor, pricing
          - Locations: Pro Shop, Tournament Tent A/B, Clubhouse Store
          - Tournaments: 2024 (Apr 8-14) and 2025 (Apr 7-13)
          
          KEY METRICS: total_revenue, total_units_sold, total_gross_margin, 
          transaction_count, avg_transaction_value, total_ending_inventory

  tool_resources:
    MerchAnalytics:
      semantic_view: SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SFE_SV_MERCH_INTELLIGENCE
      execution_environment:
        type: warehouse
        warehouse: SFE_MERCHMASTERS_WH
        query_timeout: 60
  $$;

-- Grant usage on the agent
GRANT USAGE ON AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.SFE_MERCH_INTELLIGENCE_AGENT TO ROLE PUBLIC;
