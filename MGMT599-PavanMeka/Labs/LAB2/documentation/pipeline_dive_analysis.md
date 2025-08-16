
# Pipeline DIVE Analysis

## Chosen Question: Transformation Value
**What insights emerge from cleaned/transformed data?**

---

## D - Discover

Using this processed data summary:

```
Summary of Key Patterns and Insights from Superstore Data:

Numerical Columns:
- Sales and Profit figures show a wide range, indicating variability in order values and profitability.
- Quantity and Shipping_Days have relatively small ranges with some outliers.
- Discount values are concentrated at lower percentages, with some higher discounts applied.
- Profit Margin varies significantly, with some transactions resulting in losses.

Categorical Columns:
- 'Office Supplies' is the most frequent Category, followed by 'Technology' and 'Furniture'.
- 'Consumer' is the dominant Segment, followed by 'Corporate' and 'Home Office'.
- 'West' and 'East' are the regions with the highest number of orders, followed by 'Central' and 'South'.

Grouped Analysis:
- Technology products have the highest average Sales and Profit, indicating their high value and profitability.
- Furniture products have moderate average Sales and Profit.
- Office Supplies have the lowest average Sales and Profit.
- Average Profit and Sales are relatively similar across different Regions, with slight variations.
```

**What stands out:**
- Cleaned data enabled detection of high-performing categories and unprofitable orders.
- Filtering loss-making and unrealistic data revealed more accurate operational patterns.
- Derived fields like `Shipping_Days` and `Discount_Bucket` help highlight fulfillment delays and promotional effects.

---

## I - Investigate

Our pipeline transformed data by:
- Converting dates and numeric fields into proper types
- Filtering out invalid and test rows
- Adding derived columns for `Shipping_Days` and `Discount_Bucket`
- Standardizing customer and city names

This revealed clearer segment and region-level trends, and highlighted the impact of discounting on profitability.

**Why it matters:**
- Raw data often includes noise that skews key metrics.
- Automation surfaces hidden patterns without manual effort.
- Data is now trustworthy for downstream analytics (forecasting, basket analysis, cohort retention).

---

## V - Validate

Our pipeline assumes:
- Date fields are always valid and properly formatted
- Profit and Sales values are numeric and interpretable
- Filters (e.g. profit < 0) truly indicate invalid rows

**Risks:**
- Some profitable but delayed or discounted orders may be incorrectly excluded
- Null or malformed records might silently fail

**Validation strategies:**
- Log all dropped rows for review
- Include sanity checks on numeric ranges
- Visualize distributions post-transformation to catch anomalies

---

## E - Extend

Given our pipeline can process data in minutes with scalable Dataflow infrastructure:

**Operational Impact:**
- Teams can now access clean and standardized sales data daily
- Marketing can target high-performing regions and segments based on consistent metrics
- Finance can analyze discount efficiency by bucket and product

**Future Pipelines:**
- Real-time anomaly detection during daily order ingestion
- Separate pipeline for margin optimization alerts
- Geo-level pipelines for inventory demand prediction
