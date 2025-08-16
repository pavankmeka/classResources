WITH
  DailySales AS (
    SELECT
      Order_Date,
      SUM(Sales) AS Daily_Total_Sales
    FROM
      `mgmt599-pavanmeka-lab1`.pipeline_processed_data.superstore_transformed
    GROUP BY Order_Date
    ORDER BY Order_Date
  ),
  DailySalesWithMovingAverages AS (
    SELECT
      Order_Date,
      Daily_Total_Sales,
      AVG(Daily_Total_Sales) OVER (
        ORDER BY Order_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS Seven_Day_Moving_Average,
      AVG(Daily_Total_Sales) OVER (
        ORDER BY Order_Date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS Thirty_Day_Moving_Average
    FROM
      DailySales
  ),
  SalesStatistics AS (
    SELECT
      AVG(Daily_Total_Sales) AS Mean_Daily_Sales,
      STDDEV(Daily_Total_Sales) AS StdDev_Daily_Sales
    FROM
      DailySales
  )
SELECT
  ds.Order_Date,
  ds.Daily_Total_Sales,
  ds.Seven_Day_Moving_Average,
  ds.Thirty_Day_Moving_Average,
  FORMAT_DATE('%Y-W%V', ds.Order_Date) AS Week_of_Year,
  FORMAT_DATE('%Y-%m', ds.Order_Date) AS Month_of_Year,
  CASE
    WHEN ds.Daily_Total_Sales > (ss.Mean_Daily_Sales + (2 * ss.StdDev_Daily_Sales)) THEN 'High Anomaly'
    WHEN ds.Daily_Total_Sales < (ss.Mean_Daily_Sales - (2 * ss.StdDev_Daily_Sales)) THEN 'Low Anomaly'
    ELSE 'Normal'
  END AS Anomaly_Flag
FROM
  DailySalesWithMovingAverages AS ds,
  SalesStatistics AS ss
ORDER BY ds.Order_Date;
