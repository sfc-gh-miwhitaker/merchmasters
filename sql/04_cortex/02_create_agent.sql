/******************************************************************************
 * DEMO PROJECT: MerchMasters
 * Script: Create Cortex Agent
 * 
 * NOT FOR PRODUCTION USE - EXAMPLE IMPLEMENTATION ONLY
 * 
 * PURPOSE:
 *   Create Snowflake Intelligence agent for natural language merchandise
 *   analytics using Cortex Analyst with the SV_MERCH_INTELLIGENCE semantic view.
 * 
 * OBJECTS CREATED:
 *   - SNOWFLAKE_EXAMPLE.AGENTS.MERCH_INTELLIGENCE_AGENT
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

USE DATABASE SNOWFLAKE_EXAMPLE;

-- ============================================================================
-- CREATE AGENT SCHEMA
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_EXAMPLE.AGENTS
    COMMENT = 'DEMO: Cortex Agents for natural language analytics';

USE SCHEMA SNOWFLAKE_EXAMPLE.AGENTS;

-- ============================================================================
-- CREATE CORTEX AGENT
-- ============================================================================
CREATE OR REPLACE AGENT MERCH_INTELLIGENCE_AGENT
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
      For any merchandise, sales, inventory, or revenue question, use the Analyst tool 
      to query the SV_MERCH_INTELLIGENCE semantic view.
      
      QUERY PLANNING:
      - For year-over-year questions, filter or group by tournament_year
      - For category questions, use the category dimension
      - For location questions, use location_name
      - For trend questions, group by full_date

    response: |
      FORMAT:
      - Use clear Markdown formatting with headers for sections
      - Present tabular data in Markdown tables
      - Format currency with dollar signs: $1,234.56
      - Format percentages with one decimal: 12.3%
      
      After answering, suggest 1-2 related questions the user might want to explore.

    sample_questions:
      - question: "What are the top 10 selling products this year?"
      - question: "How are sales by category comparing to last year?"
      - question: "How are sales varying by location?"
      - question: "Which vendors are performing best?"

  tools:
    - tool_spec:
        type: cortex_analyst_text_to_sql
        name: Analyst
        description: Converts natural language to SQL queries for merchandise analytics

  tool_resources:
    Analyst:
      semantic_view: SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SV_MERCH_INTELLIGENCE
  $$;

-- Grant usage to PUBLIC
GRANT USAGE ON AGENT SNOWFLAKE_EXAMPLE.AGENTS.MERCH_INTELLIGENCE_AGENT TO ROLE PUBLIC;
