# e-comerce-sql-analysis

# Account & Email Activity Analytics (SQL + Looker Studio)

This project delivers an analytical dataset designed to evaluate account acquisition and email engagement performance across multiple behavioral and geographic dimensions. The objective was to build a structured, BI-ready data model that supports country comparison, user segmentation, and market prioritization based on both acquisition and engagement metrics.

The solution was implemented in SQL using CTEs, aggregations, window functions, and a UNION-based architecture to preserve metric logic consistency. The final dataset is visualized in Looker Studio.

## Data Modeling Approach

All metrics are calculated across the following shared dimensions: **date**, **country**, **send_interval**, **is_verified**, and **is_unsubscribed**. 

## Metric Design

The dataset includes core acquisition and engagement metrics: 
**account_cnt** (created accounts), 
**sent_msg** (emails sent), 
**open_msg** (emails opened), 
**visit_msg** (email link visits).
In addition to these base measures, country-level totals are calculated using window functions. **total_country_account_cnt** and **total_country_sent_cnt** aggregate performance at the country level, independent of lower-level segmentation. 
Ranking is implemented using RANK() window functions to generate **rank_total_country_account_cnt** and **rank_total_country_sent_cnt**, enabling identification of top-performing markets.
The final result set is filtered to retain only countries ranked in the Top 10 by either total account creation or total email volume. 

## Output Structure

The resulting dataset contains the following fields:

date, country, send_interval, is_verified, is_unsubscribed,
account_cnt, sent_msg, open_msg, visit_msg,
total_country_account_cnt, total_country_sent_cnt,
rank_total_country_account_cnt, rank_total_country_sent_cnt.

The structure is optimized for direct integration into BI tools without additional transformations.

## Visualization

The dataset is connected to Looker Studio to produce a country-level performance overview showing acquisition volume, total email activity, and country rankings. Additionally, a time-series visualization tracks sent_msg by date to monitor engagement dynamics and detect growth or seasonal trends.
