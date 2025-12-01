# Cleanup Guide - MerchMasters

**Author:** SE Community  
**Last Updated:** 2025-12-01  
**Expires:** 2025-12-31

---

## Overview

This guide explains how to remove all MerchMasters demo objects from your Snowflake account. The cleanup process takes less than 1 minute.

---

## Quick Cleanup (Recommended)

Execute the cleanup script:

```sql
-- Run from Snowsight
EXECUTE IMMEDIATE FROM @SNOWFLAKE_EXAMPLE.MERCHMASTERS_GIT_REPOS.sfe_merchmasters_repo/branches/main/sql/99_cleanup/teardown_all.sql;
```

Or copy the cleanup script directly from `sql/99_cleanup/teardown_all.sql`.

---

## Manual Cleanup

If the Git repository is no longer available, run these commands manually:

### Step 1: Drop Demo Schemas

```sql
USE ROLE ACCOUNTADMIN;

-- Drop demo schemas (preserves SNOWFLAKE_EXAMPLE database)
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.SFE_MERCH_RAW CASCADE;
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.SFE_MERCH_STAGING CASCADE;
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS CASCADE;

-- Note: SEMANTIC_MODELS schema is shared - only drop the specific view
DROP SEMANTIC VIEW IF EXISTS SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SFE_SV_MERCH_INTELLIGENCE;
```

### Step 2: Drop Demo Warehouse

```sql
DROP WAREHOUSE IF EXISTS SFE_MERCHMASTERS_WH;
```

### Step 3: Drop Git Repository (Optional)

```sql
-- Drop the Git repository reference
DROP GIT REPOSITORY IF EXISTS SNOWFLAKE_EXAMPLE.MERCHMASTERS_GIT_REPOS.sfe_merchmasters_repo;

-- Drop the Git repos schema if empty
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.MERCHMASTERS_GIT_REPOS;
```

### Step 4: Preserve Shared Infrastructure

**DO NOT DROP** these objects as they may be used by other demos:

- `SNOWFLAKE_EXAMPLE` database
- `SNOWFLAKE_EXAMPLE.GIT_REPOS` schema (if exists)
- `SFE_*` API integrations (shared across demos)

---

## Verification

After cleanup, verify objects are removed:

```sql
-- Should return no results
SHOW SCHEMAS IN DATABASE SNOWFLAKE_EXAMPLE LIKE 'SFE_MERCH%';

-- Should return no results
SHOW WAREHOUSES LIKE 'SFE_MERCHMASTERS%';

-- Should return no results
SHOW VIEWS IN SCHEMA SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS LIKE 'SFE_SV_MERCH%';
```

---

## What Gets Preserved

The cleanup process preserves:

| Object | Reason |
|--------|--------|
| `SNOWFLAKE_EXAMPLE` database | Shared by all SE demos |
| `SNOWFLAKE_EXAMPLE.GIT_REPOS` schema | Shared Git repositories |
| `SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS` schema | May contain other semantic views |
| `SFE_*` API Integrations | May be used by other demos |

---

## Complete Account Cleanup

If you want to remove ALL demo artifacts (use with caution):

```sql
-- WARNING: This removes ALL demo content
USE ROLE ACCOUNTADMIN;

-- Drop entire database (destroys all demos)
-- DROP DATABASE IF EXISTS SNOWFLAKE_EXAMPLE CASCADE;

-- Drop all demo warehouses
DROP WAREHOUSE IF EXISTS SFE_MERCHMASTERS_WH;

-- Drop all demo API integrations
-- DROP API INTEGRATION IF EXISTS SFE_MERCHMASTERS_GIT_API_INTEGRATION;
```

---

## Troubleshooting

### Error: "Object does not exist"

The object was already removed or never created. This is safe to ignore.

### Error: "Insufficient privileges"

Use ACCOUNTADMIN role:

```sql
USE ROLE ACCOUNTADMIN;
```

### Error: "Object has dependent objects"

Use CASCADE to drop dependencies:

```sql
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS CASCADE;
```

---

## Re-Deployment

To re-deploy the demo after cleanup:

1. See [Deployment Guide](01-DEPLOYMENT.md)
2. Run `deploy_all.sql` from project root

---

## Support

If you encounter issues with cleanup:

1. Check that you're using ACCOUNTADMIN role
2. Verify the object names match exactly
3. Review error messages for specific conflicts

