SQL Server Data Warehouse Project (Medallion Architecture)
An end-to-end SQL Server Data Warehouse project implementing the Medallion Architecture (Bronze → Silver → Gold). The goal is to demonstrate real-world analytics engineering practices: requirements-driven modeling, layered transformations, data quality checks, and documentation (architecture + star schema + catalog) in a clean, version-controlled repository.
Tech Stack
Database: Microsoft SQL Server
Language: T-SQL
Modeling Approach: Medallion Architecture + dimensional modeling (Star Schema)
Quality: SQL-based validation checks (completeness, schema, correctness, integration)
Repository Structure
sql-data-warehouse-project/
├─ Scripts/
│  ├─ 00_setup/              # DB + schemas + utilities
│  ├─ 10_bronze/             # raw ingestion (landing)
│  ├─ 20_silver/             # cleansing + standardization
│  ├─ 30_gold/               # star schema + marts
│  └─ 99_admin/              # optional: maintenance, indexes, permissions
├─ datasets/                 # source extracts / sample files (if shareable)
├─ documents/                # diagrams, catalog, architecture notes
├─ tests/                    # test queries + expected outcomes
├─ LICENSE
└─ README.md
​
Architecture (Bronze → Silver → Gold)
Bronze (Raw / Landing)
Stores data as received from source systems
Focus: traceability, minimal transformation, schema/completeness checks
Silver (Clean / Conformed)
Cleaned and standardized datasets
Focus: deduplication, type fixes, conformance, business rule validation
Gold (Business / Analytics-ready)
Dimensional model (facts + dimensions) for BI/analytics
Focus: star schema, integration checks, curated metrics
How to Run (SQL Server)
1) Create Database & Schemas
Run scripts in order:
Scripts/00_setup/01_create_database.sql
Scripts/00_setup/02_create_schemas.sql
Suggested schemas:
bronze (raw tables)
silver (clean/conformed tables)
gold (dimensional/star schema)
audit (load logs, checks, metadata) (optional but very professional)
2) Load Bronze
Execute ingestion scripts in Scripts/10_bronze/
Validate raw loads using checks in tests/ (or Scripts/10_bronze/*_checks.sql)
3) Build Silver
Execute transformations in Scripts/20_silver/
Run correctness checks from tests/
4) Publish Gold (Star Schema)
Execute modeling scripts in Scripts/30_gold/
Validate referential integrity + reconciliation checks
Data Quality & Testing
This repo includes SQL-based checks that reflect real production habits:
Completeness checks (row counts, null thresholds)
Schema checks (types, unexpected columns)
Correctness checks (domain constraints, valid ranges)
Integration checks (fact ↔ dimension joins, orphan detection)
Tests live in: tests/
Documentation
All project documentation is stored in documents/, including:
Data architecture diagram
Data flow (ETL/ELT) diagram
Star schema model
Data catalog (definitions of facts/dimensions and business rules)
Roadmap (Implemented from Project Plan)
Requirement analysis  
Data architecture design  
Data initialization (repo + naming + schemas)  
Bronze layer ingestion + validation  
Silver layer cleansing + correctness checks  
Gold layer integration + star schema + catalog  
