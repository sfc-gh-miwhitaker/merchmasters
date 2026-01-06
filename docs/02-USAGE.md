# Usage Guide - MerchMasters

**Author:** SE Community
**Last Updated:** 2025-12-01
**Expires:** 2026-01-31

---

## Overview

This guide explains how to use the MerchMasters demo, featuring two ways to explore tournament merchandise analytics:

1. **Snowflake Intelligence (Cortex Analyst)** - Ask questions in natural language
2. **The Leaderboard (Streamlit Dashboard)** - Interactive visual analytics

---

## Option 1: The Leaderboard Dashboard

For visual, interactive analytics:

1. Log into [Snowsight](https://app.snowflake.com)
2. Navigate to **Projects** → **Streamlit**
3. Select **SFE_THE_LEADERBOARD**
4. Explore the interactive dashboard!

### Dashboard Sections

| Section | What You'll See |
|---------|-----------------|
| **Executive Summary** | KPIs with YoY comparison |
| **Sales Performance** | Daily trends, category breakdown |
| **Inventory Status** | Stock alerts, items needing attention |
| **Product Analysis** | Top sellers, vendor performance |
| **Location Analysis** | Store-by-store comparison |

---

## Option 2: Snowflake Intelligence

### Step 1: Navigate to Intelligence

1. Log into [Snowsight](https://app.snowflake.com)
2. In the left navigation, click **AI & ML** → **Intelligence**
3. You should see **SFE_MERCH_INTELLIGENCE_AGENT** listed

### Step 2: Start a Conversation

1. Click on the agent to open the chat interface
2. You'll see suggested sample questions
3. Type your question or click a suggestion

---

## Sample Questions by Category

### High-Level (Executive Summary)

```
How are dated-year products performing compared to last tournament?

What's the overall revenue comparison between this year and last year?

Which vendors are performing best this tournament?

Show me the top 5 product categories by revenue.
```

### Mid-Level (Category Analysis)

```
How are golf shirts selling across different product lines?

Which T-shirt designs are selling best this week?

What is the current inventory status of hats?

How are sales varying by location for drinkware?

Compare polo shirt sales between the Pro Shop and Tournament Tent A.
```

### Detailed (Item-Level Decisions)

```
How is style GS-2024-BLU selling each day?

What's the daily sales trend for championship logo shirts?

Which items are at risk of selling out before Sunday?

Show me the top 10 fastest-selling SKUs.

What's the inventory position for style HAT-LOGO-WHT at all locations?
```

### Forecasting Questions

```
Will the championship polo sell out before the tournament ends?

Based on current trends, how many more units of style TS-EVENT-2024 should we order?

What's the projected inventory level for hats by end of tournament?
```

---

## Demo Script (10 Minutes)

### Opening (1 minute)

*"Imagine you're managing merchandise for a premier golf tournament. You have thousands of SKUs across multiple locations, and decisions need to happen fast. Let's see how Snowflake Intelligence transforms this..."*

### Part 1: Executive View (2 minutes)

Ask: **"How are dated-year products performing compared to last tournament?"**

- Show the natural language to SQL translation
- Highlight the year-over-year comparison
- Point out the automatic formatting and citations

### Part 2: Category Deep-Dive (3 minutes)

Ask: **"Which T-shirt designs are selling best?"**

- Show the breakdown by design
- Follow up: **"Show me the top 5 golf shirt styles by revenue"**
- Demonstrate the drill-down capability

### Part 3: Location Analysis (2 minutes)

Ask: **"How are hat sales varying by location?"**

- Compare Pro Shop vs Tournament Tents
- Follow up: **"Which location has the highest drinkware inventory?"**

### Part 4: Item-Level Decisions (2 minutes)

Ask: **"How is style GS-2024-BLU selling each day?"**

- Show daily sales trend
- Follow up: **"Will that item sell out before Sunday?"**
- Demonstrate the predictive capability

### Closing (1 minute)

*"Notice how Cortex Analyst cited its sources and showed the underlying data. This is powered by a semantic model that defines the business vocabulary - no SQL required. The merchandise manager can get instant answers during the tournament without waiting for IT."*

---

## Key Talking Points

### Why Snowflake Intelligence?

1. **Natural Language:** Ask questions in plain English
2. **Verified Answers:** Responses include citations and data sources
3. **No SQL Required:** Business users can self-serve
4. **Semantic Model:** Business vocabulary, not technical column names
5. **Governed:** Same RBAC as your data warehouse

### Technical Highlights

- **Semantic View:** Defines dimensions, facts, metrics, and synonyms
- **Automatic SQL:** Agent generates optimized queries
- **Time Filters:** Built-in support for "last week", "this month", etc.
- **Follow-up Questions:** Conversational context is maintained

---

## Tips for Effective Demos

### Do's

- Start with broad questions, then drill down
- Show the citation/source information
- Highlight the semantic model as the "business brain"
- Demonstrate follow-up questions
- Let the audience suggest questions

### Don'ts

- Don't ask questions outside the data scope
- Don't expect complex multi-step calculations
- Don't compare to ChatGPT (different use case)
- Don't skip the business context explanation

---

## Exploring the Data

If you want to explore the underlying data directly:

```sql
-- View the star schema
USE SCHEMA SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS;

-- Product catalog
SELECT * FROM SFE_DIM_PRODUCTS LIMIT 10;

-- Sales facts
SELECT * FROM SFE_FCT_SALES LIMIT 100;

-- Inventory snapshots
SELECT * FROM SFE_FCT_INVENTORY LIMIT 100;

-- Location summary
SELECT
    l.location_name,
    COUNT(DISTINCT s.transaction_id) as transactions,
    SUM(s.total_amount) as revenue
FROM SFE_FCT_SALES s
JOIN SFE_DIM_LOCATIONS l ON s.location_id = l.location_id
GROUP BY l.location_name
ORDER BY revenue DESC;
```

---

## Next Steps

- [Cleanup Guide](03-CLEANUP.md) - Remove demo objects when done
- [Deployment Guide](01-DEPLOYMENT.md) - Re-deploy if needed

---

## Troubleshooting

### Agent not responding

1. Check warehouse is running: `SHOW WAREHOUSES LIKE 'SFE_MERCHMASTERS%';`
2. Verify semantic view exists: `SHOW VIEWS IN SCHEMA SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS;`
3. Ensure you have USAGE privilege on the agent

### Answers seem incorrect

1. Verify data was loaded: `SELECT COUNT(*) FROM SFE_FCT_SALES;`
2. Check date ranges in questions match available data
3. Review the semantic view definition for term mappings

### Slow responses

1. Check warehouse size (X-SMALL may be slow for complex queries)
2. Consider scaling up temporarily: `ALTER WAREHOUSE SFE_MERCHMASTERS_WH SET WAREHOUSE_SIZE = 'SMALL';`
