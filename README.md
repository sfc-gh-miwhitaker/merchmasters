![Reference Implementation](https://img.shields.io/badge/Reference-Implementation-blue)
![Ready to Run](https://img.shields.io/badge/Ready%20to%20Run-Yes-green)
![Expires](https://img.shields.io/badge/Expires-2025--12--31-orange)
![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=flat&logo=snowflake&logoColor=white)

# MerchMasters: Tournament Merchandise Intelligence

> **DEMONSTRATION PROJECT - EXPIRES: 2025-12-31**  
> This demo uses Snowflake features current as of December 2025.  
> After expiration, this repository will be archived and made private.

**Author:** SE Community  
**Purpose:** Reference implementation for tournament merchandise analytics using Snowflake Intelligence (Cortex Analyst)  
**Created:** 2025-12-01 | **Expires:** 2025-12-31 (30 days) | **Status:** ACTIVE

---

## Overview

MerchMasters demonstrates how **Snowflake Intelligence (Cortex Analyst)** enables merchandise managers at premier golf tournaments to get instant answers about sales performance, inventory status, and demand forecasting - all through natural language queries.

### Key Questions Answered

**High-Level (Executive)**
- How is a specific product type, collection, or vendor performing compared to last tournament?
- How are all dated-year products performing vs. last tournament?

**Mid-Level (Category)**
- How are golf shirts selling across different product lines?
- Which T-shirt designs are selling best?
- What is the current inventory status of key categories?

**Detailed (Item-Level)**
- How is a specific item selling each day?
- Will that item sell out, and when?
- How many more units should be ordered?

---

## First Time Here?

Follow these steps in order:

| Step | Action | Time |
|------|--------|------|
| 1 | Read `docs/01-DEPLOYMENT.md` - Understand deployment | 2 min |
| 2 | Copy `deploy_all.sql` into Snowsight | 1 min |
| 3 | Click **Run All** in Snowsight | ~10 min |
| 4 | Access Snowflake Intelligence and start asking questions! | - |

**Total setup time: ~15 minutes**

---

## Quick Deployment

1. Open `deploy_all.sql` in this repository
2. Copy the entire script
3. Open [Snowsight](https://app.snowflake.com) → **+ Worksheet**
4. Paste the script
5. Click **Run All**
6. Wait ~10 minutes for completion

---

## What Gets Created

### Snowflake Objects

| Object Type | Name | Purpose |
|-------------|------|---------|
| **API Integration** | `SFE_MERCHMASTERS_GIT_API_INTEGRATION` | GitHub access |
| **Warehouse** | `SFE_MERCHMASTERS_WH` | Demo compute (X-SMALL) |
| **Schema** | `SNOWFLAKE_EXAMPLE.SFE_MERCH_RAW` | Raw data landing |
| **Schema** | `SNOWFLAKE_EXAMPLE.SFE_MERCH_STAGING` | Cleaned data |
| **Schema** | `SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS` | Star schema |
| **Semantic View** | `SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SV_MERCH_INTELLIGENCE` | Cortex Analyst model |
| **Agent** | `MERCH_INTELLIGENCE_AGENT` | Snowflake Intelligence interface |

### Data Model

- **~500 products** across categories (shirts, hats, drinkware, accessories)
- **~100,000 POS transactions** across 2 tournaments
- **Daily inventory snapshots** by location and SKU
- **4 retail locations** (Pro Shop, Tournament Tent A/B, Clubhouse Store)

---

## Using Snowflake Intelligence

After deployment, access the Cortex Analyst agent:

1. Navigate to **Snowflake Intelligence** in Snowsight
2. Select **MERCH_INTELLIGENCE_AGENT**
3. Ask questions in natural language!

### Sample Questions

These questions are mapped 1:1 to verified queries in the semantic model:

- "What are the top 10 selling products this year?"
- "How are sales by category comparing to last year?"
- "How are sales varying by location?"
- "How is style GS-001 selling each day?"
- "What is the inventory status for hats?"
- "Which vendors are performing best?"

---

## Architecture

### Data Flow

```
Synthetic Data → RAW Schema → STAGING Schema → ANALYTICS Schema
                                                      ↓
                                              Semantic View
                                                      ↓
                                              Cortex Analyst
                                                      ↓
                                              Natural Language Q&A
```

### Technology Stack

- **100% Snowflake Native** - No external dependencies
- **Cortex Analyst** - Natural language to SQL
- **Semantic Views** - Business-friendly data definitions
- **Synthetic Data** - Realistic POS and inventory patterns

See `diagrams/` for detailed architecture diagrams.

---

## Estimated Demo Costs

| Resource | Configuration | Est. Cost |
|----------|---------------|-----------|
| Warehouse | X-SMALL, auto-suspend 60s | ~$0.50/demo |
| Cortex Analyst | Pay-per-query | ~$0.10/demo session |
| Storage | ~100MB | < $0.01/month |

**Edition Required:** Standard (Cortex Analyst available in all editions)

**Total estimated cost per demo:** < $1.00

---

## Documentation

| Document | Description |
|----------|-------------|
| `docs/01-DEPLOYMENT.md` | Complete deployment guide |
| `docs/02-USAGE.md` | How to use the demo |
| `docs/03-CLEANUP.md` | Remove all demo objects |
| `diagrams/` | Architecture diagrams |

---

## Cleanup

To remove all demo objects, copy and run the contents of `sql/99_cleanup/teardown_all.sql` in Snowsight, or run manually:

```sql
-- Remove demo-specific objects (preserves SNOWFLAKE_EXAMPLE database)
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.SFE_MERCH_RAW CASCADE;
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.SFE_MERCH_STAGING CASCADE;
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS CASCADE;
DROP WAREHOUSE IF EXISTS SFE_MERCHMASTERS_WH;
-- Note: API Integration and Git schema preserved for other demos
```

---

## Project Structure

```
merchmasters/
├── deploy_all.sql              # One-click deployment (copy to Snowsight)
├── README.md                   # This file
├── plan.md                     # Original project plan
├── diagrams/                   # Architecture diagrams (Mermaid)
│   ├── data-model.md
│   ├── data-flow.md
│   ├── network-flow.md
│   └── auth-flow.md
├── docs/                       # User documentation
│   ├── 01-DEPLOYMENT.md
│   ├── 02-USAGE.md
│   └── 03-CLEANUP.md
└── sql/                        # SQL scripts (executed via deploy_all.sql)
    ├── 01_setup/
    ├── 02_data/
    ├── 03_transformations/
    ├── 04_cortex/
    └── 99_cleanup/
```

---

## Support

This is a reference implementation for demonstration purposes. For questions or feedback:

- Review the documentation in `docs/`
- Check the architecture diagrams in `diagrams/`
- Refer to [Snowflake Documentation](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)

---

**Built with Snowflake Intelligence** | **Author: SE Community** | **Expires: 2025-12-31**

