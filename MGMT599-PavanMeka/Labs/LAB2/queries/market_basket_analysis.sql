WITH
  OrderProducts AS (
    -- Get all unique products within each order
    SELECT DISTINCT
      Order_ID,
      Product_Name,
      Sales
    FROM
      `mgmt599-pavanmeka-lab1`.pipeline_processed_data.superstore_transformed
  ),
  ProductPairs AS (
    -- Create all possible pairs of products within the same order
    SELECT
      a.Product_Name AS Product_A,
      b.Product_Name AS Product_B,
      a.Order_ID
    FROM
      OrderProducts AS a
      JOIN
      OrderProducts AS b
      ON a.Order_ID = b.Order_ID
    WHERE
      a.Product_Name < b.Product_Name -- Ensures unique pairs (A,B) and not (B,A) or (A,A)
  ),
  TotalOrdersCount AS (
    -- Calculate total number of unique orders once
    SELECT
      COUNT(DISTINCT Order_ID) AS Total_Unique_Orders
    FROM
      `mgmt599-pavanmeka-lab1`.pipeline_processed_data.superstore_transformed
  ),
  ProductFrequencies AS (
    -- Calculate frequency of individual products
    SELECT
      Product_Name,
      COUNT(DISTINCT Order_ID) AS Orders_With_Product
    FROM
      OrderProducts
    GROUP BY
      Product_Name
  ),
  AssociationMetrics AS (
    -- Calculate core association metrics for each pair
    SELECT
      pp.Product_A,
      pp.Product_B,
      COUNT(DISTINCT pp.Order_ID) AS Orders_With_A_and_B,
      (SELECT Total_Unique_Orders FROM TotalOrdersCount) AS Total_Orders,
      -- Support(A,B) = P(A and B) = (Orders with A and B) / Total Orders
      COUNT(DISTINCT pp.Order_ID) / (SELECT Total_Unique_Orders FROM TotalOrdersCount) AS Support_AB,
      -- Freq A = Orders with Product A
      (SELECT Orders_With_Product FROM ProductFrequencies WHERE Product_Name = pp.Product_A) AS Freq_A,
      -- Freq B = Orders with Product B
      (SELECT Orders_With_Product FROM ProductFrequencies WHERE Product_Name = pp.Product_B) AS Freq_B,
      -- Confidence(A -> B) = P(B|A) = P(A and B) / P(A) = (Orders with A and B) / (Orders with A)
      COUNT(DISTINCT pp.Order_ID) / (SELECT Orders_With_Product FROM ProductFrequencies WHERE Product_Name = pp.Product_A) AS Confidence_A_to_B,
      -- Confidence(B -> A) = P(A|B) = P(A and B) / P(B) = (Orders with A and B) / (Orders with B)
      COUNT(DISTINCT pp.Order_ID) / (SELECT Orders_With_Product FROM ProductFrequencies WHERE Product_Name = pp.Product_B) AS Confidence_B_to_A,
      -- Sum of sales for orders containing both products A and B
      SUM(t1.Sales) AS Revenue_Impact_of_Association -- Sum of sales directly for these orders
    FROM
      ProductPairs AS pp
      JOIN `mgmt599-pavanmeka-lab1`.pipeline_processed_data.superstore_transformed t1
        ON pp.Order_ID = t1.Order_ID
      -- Ensure we only sum sales for orders that actually contain both A and B, and not just the products in the pair
      -- This join condition is more accurate for revenue associated with the *co-occurrence*
      JOIN OrderProducts op_a ON t1.Order_ID = op_a.Order_ID AND op_a.Product_Name = pp.Product_A
      JOIN OrderProducts op_b ON t1.Order_ID = op_b.Order_ID AND op_b.Product_Name = pp.Product_B
    GROUP BY
      pp.Product_A,
      pp.Product_B
  )
SELECT
  a.Product_A,
  a.Product_B,
  a.Orders_With_A_and_B,
  a.Total_Orders,
  a.Support_AB,
  a.Confidence_A_to_B,
  a.Confidence_B_to_A,
  -- Lift(A -> B) = Confidence(A -> B) / P(B) = Confidence(A -> B) / (Orders with B / Total Orders)
  -- Or: Lift(A,B) = Support(A,B) / (P(A) * P(B)) = Support_AB / ((Freq_A/Total_Orders) * (Freq_B/Total_Orders))
  a.Support_AB / ((a.Freq_A * a.Freq_B) / (a.Total_Orders * a.Total_Orders)) AS Lift,
  a.Revenue_Impact_of_Association
FROM
  AssociationMetrics AS a
WHERE
  a.Freq_A IS NOT NULL AND a.Freq_B IS NOT NULL AND a.Freq_A > 0 AND a.Freq_B > 0 -- Avoid division by zero
  AND a.Total_Orders > 0
ORDER BY
  Lift DESC, Support_AB DESC
LIMIT 20;
