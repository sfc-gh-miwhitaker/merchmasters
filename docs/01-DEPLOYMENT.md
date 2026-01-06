# Deployment Guide - MerchMasters

**Author:** SE Community
**Last Updated:** 2025-12-02
**Expires:** 2026-01-31

---

## Overview

This guide walks you through deploying the MerchMasters demo to your Snowflake account. The entire deployment takes approximately 10-15 minutes.

---

## Prerequisites

### Snowflake Account Requirements

- **Edition:** Standard or higher (Cortex Analyst available in all editions)
- **Role:** ACCOUNTADMIN (for API integration creation) or custom role with appropriate privileges
- **Warehouse:** Will be created by deployment script

### Required Privileges

The deployment script requires:
- CREATE API INTEGRATION (account-level)
- CREATE DATABASE / CREATE SCHEMA
- CREATE WAREHOUSE
- CREATE SEMANTIC VIEW
- Access to Snowflake Intelligence

---

## Deployment Method: Copy/Paste (Recommended)

### Step 1: Access the Deployment Script

1. Open `deploy_all.sql` in this repository
2. Review the script header for expiration date and objects created

### Step 2: Open Snowsight

1. Navigate to [Snowsight](https://app.snowflake.com)
2. Log in with ACCOUNTADMIN role (or equivalent)
3. Click **+ Worksheet** to create a new SQL worksheet

### Step 3: Execute Deployment

1. Copy the **entire contents** of `deploy_all.sql`
2. Paste into the Snowsight worksheet
3. Click **Run All** (or press Ctrl+Shift+Enter / Cmd+Shift+Enter)

### Step 4: Monitor Progress

The script will:
1. Check expiration date (fails if demo expired)
2. Create API integration for GitHub
3. Create Git repository reference
4. Create warehouse
5. Execute all SQL scripts from Git
6. Display completion message

**Expected runtime:** ~10 minutes

### Step 5: Verify Deployment

After completion, verify objects exist:

```sql
-- Check warehouse
SHOW WAREHOUSES LIKE 'SFE_MERCHMASTERS%';

-- Check schemas
SHOW SCHEMAS IN DATABASE SNOWFLAKE_EXAMPLE LIKE 'SFE_MERCH%';

-- Check semantic view
SHOW VIEWS IN SCHEMA SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS LIKE 'SFE_%';

-- Check sample data
SELECT COUNT(*) FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_SALES;
```

---

## Alternative: Git Integration (Advanced)

If you already have a Git API integration configured:

```sql
-- Use existing integration
USE ROLE ACCOUNTADMIN;
USE DATABASE SNOWFLAKE_EXAMPLE;

-- Create repository reference (adjust integration name)
CREATE OR REPLACE GIT REPOSITORY sfe_merchmasters_repo
  API_INTEGRATION = your_existing_git_integration
  ORIGIN = 'https://github.com/sfc-gh-miwhitaker/merchmasters';

-- Fetch and execute
ALTER GIT REPOSITORY sfe_merchmasters_repo FETCH;
EXECUTE IMMEDIATE FROM @sfe_merchmasters_repo/branches/main/deploy_all.sql;
```

---

## Troubleshooting

### Error: "API Integration already exists"

The integration may already exist from a previous deployment:

```sql
-- Check existing integrations
SHOW API INTEGRATIONS LIKE 'SFE_%';

-- Drop if needed (careful - may affect other demos)
DROP API INTEGRATION IF EXISTS SFE_MERCHMASTERS_GIT_API_INTEGRATION;
```

### Error: "Insufficient privileges"

Ensure you're using ACCOUNTADMIN role:

```sql
USE ROLE ACCOUNTADMIN;
```

### Error: "Demo has expired"

The demo has passed its expiration date. Check the README for the expiration date or contact the SE team for an updated version.

### Error: "Git repository fetch failed"

GitHub may be temporarily unavailable:

1. Wait a few minutes and retry
2. Verify the repository URL is accessible
3. Check your network connectivity

### Warehouse not starting

```sql
-- Check warehouse status
SHOW WAREHOUSES LIKE 'SFE_MERCHMASTERS%';

-- Manually resume if needed
ALTER WAREHOUSE SFE_MERCHMASTERS_WH RESUME;
```

---

## Post-Deployment

After successful deployment, you have two options:

**Option 1: The Leaderboard (Streamlit Dashboard)**
1. Navigate to **Projects** → **Streamlit** in Snowsight
2. Select **SFE_THE_LEADERBOARD**
3. Explore the interactive merchandise analytics!

**Option 2: Snowflake Intelligence (Cortex Analyst)**
1. Navigate to **AI & ML** → **Intelligence** in Snowsight
2. Select **SFE_MERCH_INTELLIGENCE_AGENT**
3. Ask natural language questions about merchandise performance!

---

## Next Steps

- [Usage Guide](02-USAGE.md) - Learn how to use the demo
- [Cleanup Guide](03-CLEANUP.md) - Remove demo objects when done

---

## Objects Created Reference

| Object Type | Name | Purpose |
|-------------|------|---------|
| Snowflake Intelligence | SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT | Agent visibility control |
| API Integration | SFE_MERCHMASTERS_GIT_API_INTEGRATION | GitHub access |
| Git Repository | sfe_merchmasters_repo | Code reference |
| Warehouse | SFE_MERCHMASTERS_WH | Demo compute |
| Schema | SFE_MERCH_RAW | Raw data |
| Schema | SFE_MERCH_STAGING | Cleaned data |
| Schema | SFE_MERCH_ANALYTICS | Star schema |
| Schema | MERCHMASTERS | Agent and procedures |
| Semantic View | SFE_SV_MERCH_INTELLIGENCE | Cortex Analyst model |
| Agent | SFE_MERCH_INTELLIGENCE_AGENT | Natural language interface |
| Streamlit App | SFE_THE_LEADERBOARD | Interactive dashboard |
