# Data Flow - MerchMasters

**Author:** SE Community  
**Last Updated:** 2025-12-01  
**Expires:** 2025-12-31 (30 days)  
**Status:** Reference Implementation

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)

> **Reference Implementation:** This code demonstrates production-grade architectural patterns and best practices. Review and customize security, networking, and logic for your organization's specific requirements before deployment.

## Overview

This diagram shows how data flows through the MerchMasters system, from synthetic data generation through the RAW, STAGING, and ANALYTICS layers to the Cortex Analyst semantic model that powers natural language queries.

```mermaid
flowchart TB
    subgraph Sources["Data Generation"]
        GEN[Synthetic Data Generator<br/>SQL GENERATOR Function]
    end
    
    subgraph RAW["SFE_MERCH_RAW Schema"]
        RP[SFE_RAW_PRODUCTS]
        RL[SFE_RAW_LOCATIONS]
        RT[SFE_RAW_TOURNAMENTS]
        RS[SFE_RAW_SALES]
        RI[SFE_RAW_INVENTORY]
    end
    
    subgraph STG["SFE_MERCH_STAGING Schema"]
        SP[SFE_STG_PRODUCTS]
        SL[SFE_STG_LOCATIONS]
        STS[SFE_STG_TOURNAMENTS]
        SS[SFE_STG_SALES]
        SI[SFE_STG_INVENTORY]
    end
    
    subgraph ANALYTICS["SFE_MERCH_ANALYTICS Schema"]
        DP[SFE_DIM_PRODUCTS]
        DL[SFE_DIM_LOCATIONS]
        DT[SFE_DIM_TOURNAMENTS]
        DD[SFE_DIM_DATES]
        FS[SFE_FCT_SALES]
        FI[SFE_FCT_INVENTORY]
    end
    
    subgraph SEMANTIC["SEMANTIC_MODELS Schema"]
        SV[SV_MERCH_INTELLIGENCE<br/>Semantic View]
    end
    
    subgraph AGENT["snowflake_intelligence.agents"]
        AI[MERCH_INTELLIGENCE_AGENT<br/>Cortex Analyst]
    end
    
    GEN -->|INSERT| RP & RL & RT & RS & RI
    
    RP -->|Clean & Type| SP
    RL -->|Clean & Type| SL
    RT -->|Clean & Type| STS
    RS -->|Clean & Type| SS
    RI -->|Clean & Type| SI
    
    SP -->|Transform| DP
    SL -->|Transform| DL
    STS -->|Transform| DT
    STS -->|Generate| DD
    SS -->|Aggregate| FS
    SI -->|Aggregate| FI
    
    DP & DL & DT & DD & FS & FI -->|Join| SV
    SV -->|Powers| AI
```

## Component Descriptions

### Data Generation Layer

#### Synthetic Data Generator
- **Purpose:** Creates realistic POS and inventory data for demo purposes
- **Technology:** Snowflake GENERATOR() function with random seed
- **Location:** `sql/02_data/02_load_sample_data.sql`
- **Dependencies:** Schema must exist first
- **Output:** ~100,000 transaction records, product catalog, inventory snapshots

### RAW Layer (SFE_MERCH_RAW Schema)

| Table | Purpose | Volume |
|-------|---------|--------|
| SFE_RAW_PRODUCTS | Product catalog landing | ~500 styles |
| SFE_RAW_LOCATIONS | Location master landing | 4 locations |
| SFE_RAW_TOURNAMENTS | Tournament calendar landing | 2 tournaments |
| SFE_RAW_SALES | POS transaction landing | ~100K records |
| SFE_RAW_INVENTORY | Inventory snapshot landing | ~10K records |

### STAGING Layer (SFE_MERCH_STAGING Schema)

- **Purpose:** Clean, validate, and type-cast raw data
- **Technology:** Snowflake views or tables with transformations
- **Transformations Applied:**
  - Data type casting (strings to dates, numbers)
  - NULL handling and defaults
  - Data quality filters
  - Deduplication

### ANALYTICS Layer (SFE_MERCH_ANALYTICS Schema)

- **Purpose:** Star schema optimized for analytical queries
- **Technology:** Snowflake tables with proper clustering
- **Components:**
  - 4 Dimension tables (Products, Locations, Tournaments, Dates)
  - 2 Fact tables (Sales, Inventory)

### Semantic Layer (SEMANTIC_MODELS Schema)

#### SV_MERCH_INTELLIGENCE
- **Purpose:** Define business-friendly model for Cortex Analyst
- **Technology:** Snowflake Semantic View (CREATE SEMANTIC VIEW)
- **Location:** `SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SV_MERCH_INTELLIGENCE`
- **Contents:**
  - Dimension definitions with synonyms
  - Fact definitions with units
  - Metric definitions (aggregations)
  - Time filters (LAST_7_DAYS, YTD, etc.)
  - Custom business instructions

### Agent Layer

#### MERCH_INTELLIGENCE_AGENT
- **Purpose:** Natural language interface for merchandise queries
- **Technology:** Snowflake Cortex Analyst
- **Location:** `snowflake_intelligence.agents.MERCH_INTELLIGENCE_AGENT`
- **Sample Questions:** Maps 1:1 to verified queries in semantic view

## Data Transformation Summary

| Stage | Input | Transformation | Output |
|-------|-------|----------------|--------|
| Generate | GENERATOR() | Create synthetic records | RAW tables |
| Clean | RAW tables | Type cast, validate, dedupe | STAGING tables |
| Model | STAGING tables | Star schema transform | ANALYTICS tables |
| Semantic | ANALYTICS tables | Join & define business terms | Semantic View |
| Agent | Semantic View | Link to Cortex Analyst | Natural Language Q&A |

## Change History

See `.cursor/DIAGRAM_CHANGELOG.md` for version history.

