# Bank Customer Churn Analysis

**Tools:** SQL (MySQL) · Excel · Power BI · GenAI (ChatGPT)
**Dataset:** [Kaggle – Bank Customer Churn](https://www.kaggle.com/datasets/shrutimechlearn/churn-modelling) (`Churn_Modelling.csv`, 10,000 customers, 14 columns)

---

## Business Problem

A retail bank is losing **1 in 5 customers**. Management needs to know **which customer segments are leaving** and **where to focus retention spend** to protect deposits.

## Approach

| Step | What I did | Tool |
|---|---|---|
| 1. Data quality | Checked 10,000 rows for duplicates (0), missing values (0), and zero balances (3,617) | SQL |
| 2. Cleaning | Created age bands, activity status, and balance type columns | Excel |
| 3. Segment analysis | Churn rate by geography, age, products, activity, gender, balance using `GROUP BY`, `CASE`, CTEs, and window functions | SQL |
| 4. Dashboard | KPI cards and churn-rate charts by segment | Excel / Power BI |
| 5. Recommendations | Sized the high-risk segment and proposed retention actions | Excel |

GenAI (ChatGPT) was used to draft SQL queries and summarise findings; every output was checked against the data manually.

## Key KPIs

| KPI | Value |
|---|---|
| Total customers | 10,000 |
| Churned customers | 2,037 |
| **Churn rate** | **20.4%** |
| **Balance lost to churn** | **$185.6M (24.3% of all deposits)** |

## Key Findings

1. **Germany churns at 2x the rate of other markets.** 32.4% vs 16.2% (France) and 16.7% (Spain). Germany alone accounts for **$98.0M** of lost balances.
2. **Churn rises sharply with age.** Customers aged 50–59 churn at **56.0%**, vs only **7.6%** for under-30s.
3. **Inactive members churn nearly 2x more** than active members (26.9% vs 14.3%).
4. **Two products is the "sweet spot".** Churn is **7.6%** with 2 products, **27.7%** with 1, and **83–100%** with 3–4 products.
5. **Female customers churn more** than male customers (25.1% vs 16.5%).

### High-Risk Segment: inactive customers aged 40–59

| Metric | Value |
|---|---|
| Share of customer base | **17.7%** (1,769 customers) |
| Share of all churn | **40.9%** (833 customers) |
| Segment churn rate | **47.1%** |
| Balances lost | **$75.0M** |

The single riskiest segment is **German customers aged 50–59, with 70.0% churn** (window-function ranking in `churn_analysis.sql`).

## Recommendations

1. **Target inactive 40–59 customers first.** This group is under 18% of customers but drives 41% of churn. A re-engagement campaign (relationship manager call, loyalty offer) gives the highest return per rupee spent.
2. **Run a Germany-specific review.** Investigate pricing, service quality, and competitor offers in Germany, where churn is double and balance loss is highest.
3. **Move single-product customers to two products.** Cross-sell a second product (e.g., credit card or recurring deposit) to the 5,084 single-product customers.
4. **Investigate the 3–4 product group.** 83–100% churn suggests product bundling or mis-selling issues worth a separate review.

## Files

| File | Description |
|---|---|
| `churn_analysis.sql` | All SQL: data quality checks, KPIs, segment analysis, CTE, window function |
| `Bank_Churn_Dashboard.xlsx` | Excel dashboard: KPI cards, 6 segment tables with charts, high-risk segment (all live formulas) |
| `dashboard.png` | Screenshot of the Power BI dashboard |

## Author

**Dattatrieya G H**, Data Analyst | SQL • Excel • Power BI • R • GenAI
[LinkedIn](https://www.linkedin.com/in/dattatrieya-honnikhere-631808389)
