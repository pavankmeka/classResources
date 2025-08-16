WITH
  CustomerFirstPurchase AS (
    SELECT
      Customer,
      MIN(Order_Date) AS First_Purchase_Date,
      FORMAT_DATE('%Y-%m', MIN(Order_Date)) AS Cohort_Month
    FROM
      `mgmt599-pavanmeka-lab1`.pipeline_processed_data.superstore_transformed
    GROUP BY Customer
  ),
  CustomerMonthlyActivity AS (
    SELECT
      Customer,
      FORMAT_DATE('%Y-%m', Order_Date) AS Activity_Month,
      SUM(Sales) AS Monthly_Sales
    FROM
      `mgmt599-pavanmeka-lab1`.pipeline_processed_data.superstore_transformed
    GROUP BY Customer, Activity_Month
  ),
  CohortActivity AS (
    SELECT
      cfp.Cohort_Month,
      cma.Activity_Month,
      COUNT(DISTINCT cfp.Customer) AS Active_Customers,
      SUM(cma.Monthly_Sales) AS Total_Monthly_Sales,
      (EXTRACT(YEAR FROM PARSE_DATE('%Y-%m', cma.Activity_Month)) - EXTRACT(YEAR FROM PARSE_DATE('%Y-%m', cfp.Cohort_Month))) *
      12 + (EXTRACT(MONTH FROM PARSE_DATE('%Y-%m', cma.Activity_Month)) - EXTRACT(MONTH FROM PARSE_DATE('%Y-%m',
        cfp.Cohort_Month))) AS Months_Since_Acquisition
    FROM
      CustomerFirstPurchase AS cfp
      JOIN
      CustomerMonthlyActivity AS cma
      ON cfp.Customer = cma.Customer
    GROUP BY cfp.Cohort_Month, cma.Activity_Month
    HAVING(EXTRACT(YEAR FROM PARSE_DATE('%Y-%m', cma.Activity_Month)) - EXTRACT(YEAR FROM PARSE_DATE('%Y-%m',
      cfp.Cohort_Month))) * 12 + (EXTRACT(MONTH FROM PARSE_DATE('%Y-%m', cma.Activity_Month)) - EXTRACT(MONTH FROM PARSE_DATE('%Y-%m',
      cfp.Cohort_Month))) >= 0
  ),
  CohortSize AS (
    SELECT
      Cohort_Month,
      COUNT(DISTINCT Customer) AS Initial_Cohort_Size
    FROM
      CustomerFirstPurchase
    GROUP BY Cohort_Month
  )
SELECT
  ca.Cohort_Month,
  cs.Initial_Cohort_Size,
  ca.Months_Since_Acquisition,
  ca.Active_Customers,
  (ca.Active_Customers * 100.0 / cs.Initial_Cohort_Size) AS Retention_Percentage,
  ca.Total_Monthly_Sales AS Cohort_Revenue_Contribution,
  (ca.Total_Monthly_Sales / ca.Active_Customers) AS Average_Purchase_Value_Per_Active_Customer
FROM
  CohortActivity AS ca
  JOIN
  CohortSize AS cs
  ON ca.Cohort_Month = cs.Cohort_Month
ORDER BY ca.Cohort_Month, ca.Months_Since_Acquisition;
