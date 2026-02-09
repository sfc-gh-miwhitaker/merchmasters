# Data Model - MerchMasters

**Author:** SE Community
**Last Updated:** 2025-12-01
**Expires:** 2026-04-10 (30 days)
**Status:** Reference Implementation

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)

> **Reference Implementation:** This code demonstrates production-grade architectural patterns and best practices. Review and customize security, networking, and logic for your organization's specific requirements before deployment.

## Overview

This diagram shows the star schema data model for the MerchMasters tournament merchandise analytics system. The model consists of 4 dimension tables (Products, Locations, Tournaments, Dates) and 2 fact tables (Sales, Inventory) optimized for Cortex Analyst queries.

```mermaid
erDiagram
    SFE_DIM_PRODUCTS ||--o{ SFE_FCT_SALES : "sold as"
    SFE_DIM_PRODUCTS ||--o{ SFE_FCT_INVENTORY : "stocked"
    SFE_DIM_LOCATIONS ||--o{ SFE_FCT_SALES : "sold at"
    SFE_DIM_LOCATIONS ||--o{ SFE_FCT_INVENTORY : "stored at"
    SFE_DIM_DATES ||--o{ SFE_FCT_SALES : "on date"
    SFE_DIM_DATES ||--o{ SFE_FCT_INVENTORY : "snapshot date"
    SFE_DIM_TOURNAMENTS ||--o{ SFE_DIM_DATES : "contains"

    SFE_DIM_PRODUCTS {
        varchar style_number PK
        varchar product_name
        varchar category
        varchar subcategory
        varchar collection
        varchar vendor
        decimal unit_cost
        decimal retail_price
        boolean is_dated_year
    }

    SFE_DIM_LOCATIONS {
        int location_id PK
        varchar location_name
        varchar location_type
        int capacity_sqft
    }

    SFE_DIM_TOURNAMENTS {
        int tournament_id PK
        varchar tournament_name
        int tournament_year
        date start_date
        date end_date
    }

    SFE_DIM_DATES {
        int date_key PK
        date full_date
        varchar day_name
        int tournament_day_num
        boolean is_competition_day
        int tournament_id FK
    }

    SFE_FCT_SALES {
        varchar transaction_id PK
        int date_key FK
        int location_id FK
        varchar style_number FK
        varchar sku
        int quantity_sold
        decimal unit_price
        decimal total_amount
        varchar payment_method
    }

    SFE_FCT_INVENTORY {
        int inventory_id PK
        int date_key FK
        int location_id FK
        varchar style_number FK
        varchar sku
        int beginning_qty
        int received_qty
        int sold_qty
        int ending_qty
    }
```

## Component Descriptions

### Dimension Tables

#### SFE_DIM_PRODUCTS
- **Purpose:** Master product catalog with style numbers, categories, and pricing
- **Technology:** Snowflake table in SFE_MERCH_ANALYTICS schema
- **Location:** `SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_PRODUCTS`
- **Dependencies:** Source data from SFE_MERCH_RAW.SFE_RAW_PRODUCTS
- **Key Fields:**
  - `style_number` - Primary key, unique product identifier (e.g., "GS-2024-BLU")
  - `category` - Product category (Shirts, Hats, Drinkware, Accessories)
  - `is_dated_year` - Flag for tournament-dated merchandise

#### SFE_DIM_LOCATIONS
- **Purpose:** Retail location master with store types and capacities
- **Technology:** Snowflake table in SFE_MERCH_ANALYTICS schema
- **Location:** `SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_LOCATIONS`
- **Dependencies:** Source data from SFE_MERCH_RAW.SFE_RAW_LOCATIONS
- **Key Fields:**
  - `location_id` - Primary key
  - `location_type` - Pro Shop, Tournament Tent, Clubhouse

#### SFE_DIM_TOURNAMENTS
- **Purpose:** Tournament calendar with dates and years
- **Technology:** Snowflake table in SFE_MERCH_ANALYTICS schema
- **Location:** `SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_TOURNAMENTS`
- **Dependencies:** Source data from SFE_MERCH_RAW.SFE_RAW_TOURNAMENTS

#### SFE_DIM_DATES
- **Purpose:** Date dimension with tournament context (day number, competition flag)
- **Technology:** Snowflake table in SFE_MERCH_ANALYTICS schema
- **Location:** `SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_DATES`
- **Dependencies:** Generated from tournament date ranges

### Fact Tables

#### SFE_FCT_SALES
- **Purpose:** Point-of-sale transaction facts with quantities and amounts
- **Technology:** Snowflake table in SFE_MERCH_ANALYTICS schema
- **Location:** `SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_SALES`
- **Dependencies:** All dimension tables
- **Grain:** One row per transaction line item
- **Volume:** ~100,000 records across 2 tournaments

#### SFE_FCT_INVENTORY
- **Purpose:** Daily inventory snapshots by location and SKU
- **Technology:** Snowflake table in SFE_MERCH_ANALYTICS schema
- **Location:** `SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_INVENTORY`
- **Dependencies:** All dimension tables
- **Grain:** One row per location/SKU/day

## Data Lineage

| Layer | Tables | Purpose |
|-------|--------|---------|
| RAW | SFE_RAW_* | Synthetic data landing |
| STAGING | SFE_STG_* | Cleaned and typed |
| ANALYTICS | SFE_DIM_*, SFE_FCT_* | Star schema for analysis |

## Change History

See `.cursor/DIAGRAM_CHANGELOG.md` for version history.
