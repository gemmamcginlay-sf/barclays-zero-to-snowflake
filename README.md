# Barclays Zero to Snowflake

A modular demo covering Snowflake within the Barclays Enterprise Data Platform (EDP). Runs as a full 90-minute session or can be cut into shorter delivery modes.

## Delivery Modes

| Mode | Sections | Duration | Use When |
|------|----------|----------|----------|
| **Taster** | 1, 2, 3, 5 (Analyst only), 7 | 45 min | Lunch & Learn, first intro |
| **Standard** | All 7 | 90 min | Tech Fest, enablement day |
| **Deep Dive** | 3, 4 (full dbt), 5, 6, 7 | 75 min | Data engineers who know the basics |

## Sections

| # | Title | Duration | Key Topics |
|---|-------|----------|------------|
| 1 | Snowflake at Barclays | 5 min | EDP context, Iceberg, multi-tenant |
| 2 | Navigating Snowsight | 5 min | UI orientation |
| 3 | Querying Data | 12 min | SQL, charting, Time Travel |
| 4 | Pipelines | 25 min | Views, Dynamic Tables, dbt, Streams+Tasks, Procedures |
| 5 | Cortex AI | 20 min | Sentiment, classification, LLM, AI Dynamic Tables |
| 6 | Snowflake Intelligence | 15 min | Semantic View + Agent |
| 7 | Streamlit Apps | 5 min | Payments Health Monitor |

## Quick Start

```sql
-- 1. Run setup
@sql/00_setup.sql

-- 2. Load data
@sql/01_load_data.sql

-- 3. Querying (Section 3)
@sql/02_querying.sql

-- 4. Pipelines (Section 4)
@sql/03_pipelines.sql

-- 5. Cortex AI (Section 5)
@sql/04_cortex_ai.sql

-- 6. Intelligence (Section 6)
@sql/05_intelligence.sql

-- 7. Streamlit (Section 7) — deploy via Snowsight
-- See streamlit/app.py
```

## File Structure

```
├── sql/
│   ├── 00_setup.sql           — Database, warehouse, schemas
│   ├── 01_load_data.sql       — 50K payments + supporting tables
│   ├── 02_querying.sql        — Explore, aggregate, Time Travel
│   ├── 03_pipelines.sql       — Views, DTs, dbt, Streams+Tasks
│   ├── 04_cortex_ai.sql       — Sentiment, classification, LLM, AI DTs
│   ├── 05_intelligence.sql    — Semantic View + Agent setup
│   └── 06_cleanup.sql         — Teardown
├── dbt/
│   ├── dbt_project.yml
│   ├── profiles.yml.example
│   └── models/
│       ├── staging/           — stg_payments
│       └── marts/             — mart_payment_kpis, mart_sla_compliance
├── streamlit/
│   └── app.py                 — Payments Health Monitor (dark theme)
└── guide.html                 — Interactive HTML session guide
```

## Pre-requisites

- Snowflake account with SYSADMIN access
- Cortex AI enabled (for Section 5)
- dbt (for Section 4c) — can use Cortex Code or deployed dbt project

## Cleanup

```sql
@sql/06_cleanup.sql
```
