# Barclays Zero to Snowflake

A modular demo covering Snowflake within the Barclays Enterprise Data Platform (EDP). Runs as a full ~90-minute session or can be cut into shorter delivery modes.

**Demo Guide:** [gemmamcginlay-sf.github.io/barclays-zero-to-snowflake/guide.html](https://gemmamcginlay-sf.github.io/barclays-zero-to-snowflake/guide.html)

## Delivery Modes

| Mode | Sections | Duration | Use When |
|------|----------|----------|----------|
| **Taster** | 1, 2, 3, 6 (Agent only), 7 | ~45 min | Lunch & Learn, first intro |
| **Standard** | All 7 | ~90 min | Tech Fest, enablement day |
| **Deep Dive** | 3, 4 (full dbt + Notebooks), 5, 6, 7 | ~75 min | Data engineers who know the basics |

## Sections

| # | Title | ~Duration | Key Topics |
|---|-------|-----------|------------|
| 1 | Snowflake at Barclays | 5 min | EDP context, Iceberg, multi-tenant |
| 2 | Navigating Snowsight | 5 min | UI orientation |
| 3 | Querying Data | 12 min | SQL, charting, Time Travel |
| 4 | Pipelines | 25 min | Views, Dynamic Tables, dbt, Streams+Tasks, Notebooks, Procedures |
| 5 | Cortex AI | 20 min | Sentiment, classification, LLM, AI Dynamic Tables |
| 6 | Snowflake Intelligence CoWork | 15 min | Semantic View + Agent (conversational analytics) |
| 7 | Streamlit App | 5 min | Payments Health Monitor (dark theme) |

## Quick Start

Run each SQL file in Snowsight worksheets, in order:

```
sql/00_setup.sql          — Database, warehouse, schemas
sql/01_load_data.sql      — 50K payments + supporting tables
sql/02_querying.sql       — Section 3: explore, aggregate, Time Travel
sql/03_pipelines.sql      — Section 4: views, DTs, dbt, streams+tasks
sql/04_cortex_ai.sql      — Section 5: sentiment, classification, LLM, AI DTs
sql/05_intelligence.sql   — Section 6: analytics view (Semantic View + Agent via UI)
```

For Section 4e (Notebooks): import `notebook/payments_operations_analysis.ipynb` into Snowsight.

For Section 7 (Streamlit): deploy `streamlit/app.py` via Snowsight Projects.

## File Structure

```
├── sql/
│   ├── 00_setup.sql              — Database, warehouse, schemas
│   ├── 01_load_data.sql          — 50K payments, 2K feedback, SLAs, alerts
│   ├── 02_querying.sql           — Explore, aggregate, Time Travel
│   ├── 03_pipelines.sql          — Views, DTs, dbt, Streams+Tasks, Notebooks, Procedures
│   ├── 04_cortex_ai.sql          — Sentiment, classification, LLM, AI Dynamic Tables
│   ├── 05_intelligence.sql       — Analytics view + Semantic View/Agent UI steps
│   └── 06_cleanup.sql            — Teardown
├── dbt/
│   ├── dbt_project.yml
│   ├── profiles.yml.example
│   └── models/
│       ├── staging/              — stg_payments (view)
│       └── marts/                — mart_payment_kpis, mart_sla_compliance (tables)
├── notebook/
│   └── payments_operations_analysis.ipynb  — SQL+Python analysis (import to Snowsight)
├── streamlit/
│   └── app.py                    — Payments Health Monitor (dark theme, Altair charts)
└── guide.html                    — Presenter's demo guide (hosted on GitHub Pages)
```

## Pre-requisites

- Snowflake account with SYSADMIN access
- Cortex AI enabled (for Section 5)
- Warehouse: SMALL or larger recommended for Cortex AI CTAS (~2K rows)

## EDP Notes

- Schema naming: RAW / STAGING / ANALYTICS / PREPARED (maps to EDP Raw / Base / Prepared + operational layer)
- Demo uses native tables for simplicity; production sources from S3/Iceberg via catalog integration
- Sensitive fields shown in plain text (synthetic); production data arrives pre-tokenised (Design Principle #7)

## Cleanup

```sql
-- Run sql/06_cleanup.sql
DROP DATABASE IF EXISTS BARCLAYS_DEMO;
DROP WAREHOUSE IF EXISTS BARCLAYS_DEMO_WH;
```
