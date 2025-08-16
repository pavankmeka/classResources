
# Lab 2 Summary: Pipeline Analytics

## Pipeline Configuration
- Pipeline Name: mgmt599-pavanmeka-pipeline
- Source: gs://pavanmeka-lab2-bucket/superstore_dataset.csv
- Destination: pipeline_processed_data.superstore_transformed
- Schedule: Daily at 6 AM

## Key Technical Achievements
1. Successfully built a Dataflow pipeline processing structured Superstore data
2. Automated data transformation and cleaning steps that previously required manual preprocessing
3. Created three analytical views (Time-Series, Cohort, Market Basket) using SQL for business insight

## Business Insights from Pipeline Data
1. **Time-Series:** Detected high/low sales anomalies and seasonal trends using moving averages
2. **Cohort Analysis:** Identified customer retention drops after the 2nd month post-acquisition
3. **Market Basket:** Found strong product pairs (e.g., “Canon Copier” and “Paper Refill”) with high lift and revenue impact


## DIVE Analysis Summary
- **Question:** What insights emerge from cleaned/transformed data?
- **Key Finding:** Pipeline-transformed data removed noise and allowed discovery of key patterns:
  - Technology had the highest profit and sales, while Office Supplies underperformed.
  - `Shipping_Days` revealed some orders took over 30 days to ship, which were filtered.
  - Derived `Discount_Bucket` exposed concentration of orders in the low-to-medium discount range.
- **Business Impact:** Reliable, clean data improves segmentation and campaign targeting. Enables daily decision-making on discounting, fulfillment efficiency, and product strategy. Recommended to build real-time anomaly detection and margin optimization pipelines.


## Cost Analysis
- Dataflow job: ~$0.15 per run
- BigQuery storage: ~$0.75 per month
- Total within university credits: Yes

## Challenges & Solutions
1. **Challenge:** Data inconsistencies and type mismatches in raw CSVs  
   **Solution:** Applied robust parsing, type conversions, and row-level filters during transformation
2. **Challenge:** Query complexity and runtime on large dataset  
   **Solution:** Optimized with window functions, aggregate pre-processing, and incremental filtering

## Next Steps
- Additional pipelines to build: Real-time order ingestion, customer segmentation pipeline
- Optimizations identified: Use Dataflow templates for faster redeployment; integrate anomaly alerts with Pub/Sub or Slack
