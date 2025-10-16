# Overview

This project analyzes sales and route data for a mock company using datasets from Circana, Liberty, and Route Schedule sources. The goal is to perform end-to-end business analysis across product sales, regional performance, and route efficiency — answering key business questions through SQL queries, Excel dashboards, and data modeling.  

# Project Components

__1. Data Understanding:__  
Reviewed and interpreted the structure of each dataset:
- **Circana Data:** Store-level sales performance (Dollar Sales, County, City).  
- **Liberty Data:** Transaction-level product details (Plant, Sales Group, Product Type, TS).  
- **Route Schedule Data:** Plant and route coverage by customer.  
Validated data completeness, identified missing attributes (e.g., no State column in Circana), and proposed enrichment steps (e.g., county-to-state mapping).

__2. Data Preparation:__  
Cleaned, standardized, and structured data to ensure reliable insights:
- Standardized column names and formats across all datasets.  
- Converted Excel (`.xlsm`, `.xlsb`) files to CSV for Snowflake ingestion.  
- Removed size and package details from product names using regex.  
- Verified numeric and date consistency (`Dollar Sales`, `Calendar Day`, `TS`).  
- Created relationships between datasets for reporting and ad-hoc queries.

__3. Data Modeling:__  
Designed a scalable data structure for analysis and reporting:
- Defined schema hierarchy:  
  `CASE_STUDY` → `RAW`, `ANALYSIS`, and `REPORTING` schemas.  
- Created core tables: `CIRCANA_DATA`, `LIBERTY_DATA`, `ROUTE_DATA`.  
- Established links by customer ID and plant for cross-dataset insights.  
- Used Snowflake warehouse (`ANALYST_WH`) for query execution and testing.  

__4. Data Analysis:__  
Executed SQL and Excel-based analysis to answer business questions:  

- Circana:  
  - Total Dollar Sales by State (or County if State unavailable).  
  - City with highest average Dollar Sales in each County.  
  - County with most stores above county average.  
  - Count of cities per County and per State.  

- Liberty & Route:  
  - Which Plant (PC) has the most “Cobras.”  
  - Total TS for Sales Groups assigned with “Chargers.”  
  - Top-selling flavor in Brasil (excluding package size).  
  - Month with the highest total sales.  
  - Whether Sales Groups with “Chargers” perform better on average.  
  - Highest Picklejuice sales by Sales Group.  
  - Route coverage: do all plants have one of each route type?

Visualized findings in Excel dashboards with bar charts, pivots, and line graphs.  

# Files

__CaseStudy.xlsx:__ Excel workbook with one tab per question and summary visuals.

__SQL_Queries.sql:__ Snowflake-compatible SQL scripts for all business questions. 

__Python_Cleanup.ipynb (optional):__ Regex-based product name cleaning for Liberty dataset.

# Key Features

__Data Cleansing:__  
- Removed nulls and standardized text fields.  
- Normalized product names and sales metrics for accuracy.  

__Modeling:__  
- Built warehouse and schema hierarchy in Snowflake.  
- Created relational links between sales, route, and product tables.  

__Reporting:__  
- Delivered consistent metrics and visuals using Excel.  
- Designed SQL queries to scale to larger data volumes.  

# Dependencies

- **Snowflake:** Cloud-based data warehouse for SQL analysis.  
- **Excel:** PivotTables and charts for reporting and visualization.  
- **Python (optional):** Pandas and regex for preprocessing.  
- **VS Code:** SQL and version control workspace for organization.  
- **GitHub:** Repository for code, queries, and documentation.

# Technologies Used

- **SQL (Snowflake)** – for data querying, transformation, and aggregation.  
- **Excel** – for ad-hoc reporting, visuals, and presentation.  
- **Python** – for optional text cleaning and conversion to CSV.  
- **Snowflake Warehouse** – compute layer for query execution.  
- **Git/GitHub** – version control and documentation hosting.

# How to Use

1. Clone this repository to your local environment.  
2. Convert Excel datasets to CSV if needed (`.xlsm` and `.xlsb` not supported natively in Snowflake).  
3. In Snowflake, create a warehouse and database:
   ```sql
   CREATE WAREHOUSE ANALYST_WH
     WITH WAREHOUSE_SIZE='SMALL'
     AUTO_SUSPEND=300
     AUTO_RESUME=TRUE;
   CREATE DATABASE CASE_STUDY;
   CREATE SCHEMA CASE_STUDY.RAW;
