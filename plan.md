# MerchMasters: Tournament Merchandise Intelligence Demo

## GitHub Repository URL
https://github.com/sfc-gh-miwhitaker/merchmasters

---

## Business Use Case

**Industry:** Sports & Entertainment / Golf Club Operations  
**Domain:** Retail Merchandise Analytics & Inventory Management

A premier golf club needs intelligent, conversational analytics to optimize merchandise operations during high-profile tournaments. Merchandise managers currently struggle with:

1. **Performance Visibility** - No easy way to compare current tournament sales against prior events
2. **Inventory Risk** - Critical items selling out mid-tournament or over-ordering slow movers
3. **Real-time Decisions** - Need instant answers during fast-paced tournament days
4. **Demand Forecasting** - Predicting sellout dates and reorder quantities

The solution leverages **Snowflake Cortex Analyst** to provide a natural language interface over point-of-sale and inventory data, enabling merchandise managers to ask questions in plain English and get instant, accurate answers.

---

## Target Persona

**Primary:** Tournament Merchandise Manager  
- Manages retail operations across multiple locations during events
- Needs real-time visibility into sales velocity and inventory levels
- Makes rapid decisions on pricing, placement, and reordering
- Not technical - prefers conversational queries over dashboards/SQL

**Secondary:** Retail Operations Director  
- Reviews overall merchandise performance post-tournament
- Compares year-over-year trends and vendor performance
- Makes strategic decisions on product mix for future events

---

## Key Questions to Answer

### High-Level (Executive Summary)
1. How is a specific product type, collection, or vendor performing compared to last tournament?
2. How are all dated-year products (event-specific merchandise) performing vs. last tournament?

### Mid-Level (Category Analysis)
3. How are golf shirts selling across different product lines?
4. Which T-shirt designs (including all color variations) are selling best?
5. What is the current inventory status of key categories (hats, T-shirts, drinkware)?
6. How are sales for a specific category varying by location?

### Detailed (Item-Level Decisions)
7. How is a specific item (by style number) selling each day?
8. Will that item sell out, and when? (Predictive)
9. Do we need to slow sales of that item to keep it in stock through the event?
10. How many more units of that item should be ordered for the tournament?

---

## Features & Capabilities to Demonstrate

### Core: Snowflake Cortex Analyst
- **Semantic Model** defining merchandise domain concepts
- **Natural Language Queries** via conversational interface
- **Verified Answers** with source attribution
- **Follow-up Questions** for drill-down analysis

### Supporting Features
1. **Synthetic Data Generation** - Realistic POS and inventory data for 2 tournaments
2. **Time-Series Analysis** - Daily sales velocity and trend detection
3. **Inventory Forecasting** - Sellout prediction using Cortex ML FORECAST
4. **Multi-Location Support** - Compare performance across retail locations

### Snowflake Intelligence Integration
- Cortex Analyst as the primary user interface
- Semantic model with clear business definitions
- Pre-built sample questions for demo flow
- Suggested questions surfaced automatically

---

## Technical Requirements

### Data Sources (Synthetically Generated)
1. **Point of Sale (POS) Transactions**
   - Transaction ID, timestamp, location, item, quantity, price, payment method
   - 2 tournaments: "prior year" and "current year"
   - ~50,000 transactions per tournament

2. **Product Catalog**
   - Style number, name, category, subcategory, collection, vendor
   - Colors, sizes, unit cost, retail price
   - ~500 unique styles with color/size variants (~2,000 SKUs)

3. **Inventory Snapshots**
   - Daily snapshots of on-hand quantities by location
   - Beginning inventory + receipts - sales = ending inventory
   - Support for multiple retail locations (Pro Shop, Tent 1, Tent 2, etc.)

4. **Tournament Calendar**
   - Tournament name, dates, year
   - Daily schedule (practice rounds, competition days)

### Data Model Layers
- **RAW**: Landing zone for synthetic data generation
- **STAGING**: Cleaned, typed, validated data
- **ANALYTICS**: Aggregated facts and dimensions for Cortex Analyst

### Architecture
- 100% Snowflake Native (no external dependencies)
- Single database: `SNOWFLAKE_EXAMPLE`
- All objects prefixed with `SFE_` per demo standards
- Cortex Analyst semantic model as primary interface

---

## Success Criteria

### Must Have (MVP)
- [ ] Cortex Analyst successfully answers all 10 key questions
- [ ] Semantic model covers products, sales, inventory, locations, tournaments
- [ ] Synthetic data realistic enough for credible demo
- [ ] Compare current vs prior tournament with natural language
- [ ] Single deploy_all.sql for complete setup

### Should Have
- [ ] Sellout prediction using Cortex ML FORECAST
- [ ] Pre-built sample questions for demo script
- [ ] Location comparison analysis
- [ ] Vendor performance tracking

### Nice to Have
- [ ] Streamlit dashboard as alternative interface
- [ ] Automated daily inventory calculations via Tasks
- [ ] What-if scenarios for reorder recommendations

---

## Demo Narrative / Script Flow

### Opening (2 min)
"Imagine you're managing merchandise for a premier golf tournament. You have thousands of SKUs across multiple locations, and decisions need to happen fast. Let's see how Snowflake Intelligence transforms this..."

### Demo Flow (10 min)

1. **Start Broad** (Executive View)
   - "How are dated-year products performing compared to last tournament?"
   - Show YoY comparison with automatic drill-down suggestions

2. **Category Deep-Dive**
   - "Which T-shirt designs are selling best?"
   - "Show me the top 5 golf shirt styles by revenue"

3. **Location Analysis**
   - "How are hat sales varying by location?"
   - "Which location has the highest drinkware inventory?"

4. **Item-Level Decision Making**
   - "How is style ABC123 selling each day?"
   - "Will that item sell out before the tournament ends?"
   - "How many more units should I order?"

5. **Close with Value**
   - Show how Cortex Analyst cited sources
   - Highlight the semantic model as the "business brain"
   - Emphasize: No SQL, No BI tool, Just Questions → Answers

---

## Anonymization Requirements

Per customer request, all data must be anonymized:

- **Golf Course:** "Augusta National" → "Grandview Golf & Country Club"
- **Tournament:** "Masters" → "The Championship Invitational"
- **Vendors:** Use generic names (Apex Apparel, Summit Sportswear, etc.)
- **Locations:** Pro Shop, Tournament Tent A, Tournament Tent B, Clubhouse Store

---

## Estimated Costs

### Development/Demo Resources
- Warehouse: XS (for data generation and queries)
- Storage: Minimal (~100MB synthetic data)
- Cortex Analyst: Pay-per-query during demo

### Edition Requirements
- **Standard Edition:** Sufficient for core demo
- **Enterprise Edition:** Required if adding Cortex ML FORECAST

---

## Timeline Context

- **Target:** Proof of concept for 2026 tournament season
- **Delivery:** Working demo ready for internal validation
- **Iteration:** Gather feedback, refine semantic model

---

## Notes

- Data already exists in Snowflake (POS and inventory) - this demo uses synthetic equivalents
- Snowflake Intelligence = Cortex Analyst for this use case
- No external partner needed - SE team can build and support
- Focus on conversational analytics, not traditional BI dashboards

