-- Analysis: Profitability Analysis
-- Business Question: Which products had the highest development and production costs in 2012 and 2013, and how did these costs impact profitability based on whether they were produced in-house or outsourced?

-- SQL STATEMENT:

WITH Thresholds AS (
    SELECT dp.CategoryName, dp.ProductSource,
           SUM(fp.ProfitMargin) / SUM(fp.OrderQty) AS Threshold_ProfitMargin
    FROM FactProductPerformance fp
    JOIN DimProduct dp ON fp.ProductID = dp.ProductID
    JOIN DimKeyDate dk ON fp.OrderDate = dk.DateKey
    WHERE dk.Year IN (2012, 2013) -- Filtering for 2012 and 2013
    GROUP BY dp.CategoryName, dp.ProductSource
),
SubcategoryData AS (
    SELECT dp.CategoryName, dp.SubcategoryName, dp.ProductSource,
           SUM(fp.OrderQty) AS OrderQty,
           SUM(fp.ActualSaleValue) / SUM(fp.OrderQty) AS AvgSaleValuePerUnit,
           SUM(fp.ProductionCost) / SUM(fp.OrderQty) AS AvgProductionCostPerUnit,
           SUM(fp.ProfitMargin) / SUM(fp.OrderQty) AS AvgProfitMarginPerUnit
    FROM FactProductPerformance fp
    JOIN DimProduct dp ON fp.ProductID = dp.ProductID
    JOIN DimKeyDate dk ON fp.OrderDate = dk.DateKey
    WHERE dk.Year IN (2012, 2013) -- Filtering for 2012 and 2013
    GROUP BY dp.CategoryName, dp.SubcategoryName, dp.ProductSource
)
SELECT s.CategoryName, s.SubcategoryName, s.ProductSource,
       s.OrderQty, s.AvgSaleValuePerUnit, s.AvgProductionCostPerUnit,
       s.AvgProfitMarginPerUnit,
       CASE
           WHEN s.AvgProfitMarginPerUnit > t.Threshold_ProfitMargin THEN 'Highly Profitable'
           WHEN s.AvgProfitMarginPerUnit < 0 THEN 'Not Yielding Profit'
           ELSE 'Low Profitable Product'
       END AS ProfitabilityCategory
FROM SubcategoryData s
JOIN Thresholds t
ON s.CategoryName = t.CategoryName AND s.ProductSource = t.ProductSource
ORDER BY s.CategoryName, s.SubcategoryName, ProfitabilityCategory;
