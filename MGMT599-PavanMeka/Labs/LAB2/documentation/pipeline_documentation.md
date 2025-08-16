# My Dataflow Pipeline Documentation

## Pipeline Overview
- **Purpose:**  
  This Dataflow pipeline processes a retail Superstore CSV dataset by cleaning, transforming, and enriching the data to prepare it for structured analytics in BigQuery. It applies business logic filters to remove irrelevant or noisy records and adds derived fields for better decision-making.

- **Source:**  
  The data originates from a CSV file stored in a Google Cloud Storage (GCS) bucket:
  `gs://pavanmeka-lab2-bucket/superstore_dataset.csv`

- **Transformations:**  
  The pipeline applies the following transformations:
  - Parses each CSV row into structured fields using Python's `csv` module.
  - Converts `Order_Date` and `Ship_Date` to proper `DATE` types.
  - Converts numeric fields like `Profit`, `Sales`, `Discount`, `Quantity`, and `Profit_Margin` to appropriate types (`FLOAT` or `INTEGER`).
  - Filters out rows where:
    - `Profit` is negative (loss-making orders)
    - `Sales` is less than $10 (tiny transactions)
    - `Quantity` or `Sales` is 0
    - Shipping duration is less than 0 or more than 30 days
    - Customer or Product Name contains 'test' or 'sample'
  - Adds a derived column `Shipping_Days` (difference between `Ship_Date` and `Order_Date`)
  - Adds a `Discount_Bucket` column to categorize discount levels as `None`, `Low`, `Medium`, or `High`
  - Standardizes customer names to uppercase and city names to title case

- **Destination:**  
  The cleaned and transformed data is written to the following BigQuery table:
  `mgmt599-pavanmeka-lab1:pipeline_processed_data.superstore_transformed`

## Pipeline Configuration
- **Job name:** `mgmt599-pavanmeka-pipeline`
- **Region:** `us-central1`
- **Machine type:** Default Dataflow worker machine type
- **Max workers:** Not explicitly configured (uses Dataflow autoscaling defaults)

## Data Flow
1. **Read from:** `gs://pavanmeka-lab2-bucket/superstore_dataset.csv`
2. **Transform:**
   - Parse and convert fields
   - Apply business filters
   - Derive `Shipping_Days` and `Discount_Bucket`
   - Standardize text fields
3. **Write to:** `mgmt599-pavanmeka-lab1:pipeline_processed_data.superstore_transformed`

## Lessons Learned
- **What was challenging?**  
  The most challenging part was handling data quality issues and implementing row-level filters that preserve meaningful data while removing invalid or noisy entries. Debugging and testing transformations on the cloud can also be time-consuming without side-output logging or local validation.

- **What would you do differently?**  
  I would implement local unit tests for transformation logic before running the full Dataflow job. I'd also use side outputs or logs to capture filtered-out records for audit or inspection. Additionally, using parameterized templates for flexible GCS paths and BigQuery targets would make the pipeline more reusable.
