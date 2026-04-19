-- Analysis: Product configuration
-- Business Question: How do different product configurations (features, color, size, and style) impact sales performance and customer preferences?

-- SQL STATEMENT:
SELECT
    dp.CategoryName,
    dp.ProductLine,
    dp.Style,
    dp.Color,
    sum(fp.OrderQty) AS TotalSalesCount,
    SUM(fp.ActualSaleValue) AS TotalSales,
    sum(fp.ProfitMargin) AS totalProfitMargin
FROM FactProductPerformance fp
JOIN DimProduct dp ON fp.ProductID = dp.ProductID
GROUP BY dp.CategoryName,dp.ProductLine, dp.Style, dp.Color
ORDER BY totalProfitMargin DESC, dp.CategoryName, dp.Style;
