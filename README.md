# Mutual Fund Distribution & Analytics Engine

## Project Overview
This project simulates a centralized database for Saavi ArthGrow Advisors, an AMFI-registered mutual fund distribution business. The objective is to track client portfolios, mutual fund performance, and Systematic Investment Plans (SIPs) to extract actionable business intelligence.

## Database Architecture
The relational database was built from scratch using MySQL and consists of three normalized tables:
* **clients:** Stores client demographic and KYC information.
* **mutual_funds:** Catalogs fund details, AMC affiliations, and risk profiles.
* **transactions:** Tracks historical SIP and lumpsum investments.

## Key Business Queries Executed
This repository contains complex SQL queries designed to solve real-world financial distribution challenges:

1. **The AUM Aggregator:** Calculates the total Assets Under Management (AUM) for each mutual fund category, filtering for completed transactions and specific investment thresholds (`GROUP BY`, `HAVING`).
2. **The KYC Compliance Audit:** Identifies clients who have failed to complete their KYC or have no active investments (`NOT EXISTS` Subqueries, `COALESCE` NULL handling).
3. **The AMC Leaderboard:** Determines the single highest revenue-driving fund within each Asset Management Company (`CTEs`, `DENSE_RANK()` Window Functions).
4. **The Category Whales:** Identifies the top-tier VIP clients with the highest investment volume within specific asset classes (Multi-table `INNER JOIN`s, Window Functions).

## Files in this Repository
* `Mutual Fund Distribution and Analytics Engine`: 
Contains the DDL and DML statements to create and populate the database.
Contains the advanced queries used for business intelligence extraction.
