-- Analysis: Regional performance
-- Business Question: Which product categories drive the highest sales and profit margins across different regions, and how have their sales trends changed over the past year (June 2013 - May 2014)?
WITH ProfitData AS (
    SELECT
        dl.TerritoryName,
        dp.CategoryName,
        SUM(fp.ProfitMargin) AS TotalProfitMargin
    FROM
        FactProductPerformance fp
    JOIN
        DimProduct dp ON fp.ProductID = dp.ProductID
    JOIN
        DimLocation dl ON fp.TerritoryID = dl.TerritoryID
    JOIN
        DimKeyDate dk ON fp.OrderDate = dk.DateKey
    WHERE
        dk.Year = 2013 AND dk.MonthName IN ('June', 'July', 'August', 'September', 'October', 'November', 'December')
        OR dk.Year = 2014 AND dk.MonthName IN ('January', 'February', 'March', 'April', 'May')
    GROUP BY
        dl.TerritoryName, dp.CategoryName
),
ProfitPivot AS (
    SELECT
        TerritoryName,
        ISNULL([Accessories], 0) AS Accessories_Profit,
        ISNULL([Bikes], 0) AS Bikes_Profit,
        ISNULL([Clothing], 0) AS Clothing_Profit,
        ISNULL([Components], 0) AS Components_Profit,
        ISNULL([Accessories], 0) + ISNULL([Bikes], 0) + ISNULL([Clothing], 0) + ISNULL([Components], 0) AS Total_Profit
    FROM
        ProfitData
    PIVOT (
        SUM(TotalProfitMargin)
        FOR CategoryName IN ([Accessories], [Bikes], [Clothing], [Components])
    ) AS PVT
),
SalesData AS (
    SELECT
        dl.TerritoryName,
        dp.CategoryName,
        SUM(fp.ActualSaleValue) AS TotalSales
    FROM
        FactProductPerformance fp
    JOIN
        DimProduct dp ON fp.ProductID = dp.ProductID
    JOIN
        DimLocation dl ON fp.TerritoryID = dl.TerritoryID
    JOIN
        DimKeyDate dk ON fp.OrderDate = dk.DateKey
    WHERE
        dk.Year = 2013 AND dk.MonthName IN ('June', 'July', 'August', 'September', 'October', 'November', 'December')
        OR dk.Year = 2014 AND dk.MonthName IN ('January', 'February', 'March', 'April', 'May')
    GROUP BY
        dl.TerritoryName, dp.CategoryName
),
SalesPivot AS (
    SELECT
        TerritoryName,
        ISNULL([Accessories], 0) AS Accessories_Sales,
        ISNULL([Bikes], 0) AS Bikes_Sales,
        ISNULL([Clothing], 0) AS Clothing_Sales,
        ISNULL([Components], 0) AS Components_Sales,
        ISNULL([Accessories], 0) + ISNULL([Bikes], 0) + ISNULL([Clothing], 0) + ISNULL([Components], 0) AS Total_Sales
    FROM
        SalesData
    PIVOT (
        SUM(TotalSales)
        FOR CategoryName IN ([Accessories], [Bikes], [Clothing], [Components])
    ) AS PVT
)
SELECT
    P.TerritoryName,
    P.Accessories_Profit,
    P.Bikes_Profit,
    P.Clothing_Profit,
    P.Components_Profit,
    P.Total_Profit,
    CAST((S.Accessories_Sales / NULLIF(S.Total_Sales, 0)) * 100 AS DECIMAL(5,1)) AS [%Sales_Accessories],
    CAST((S.Bikes_Sales / NULLIF(S.Total_Sales, 0)) * 100 AS DECIMAL(5,1)) AS [%Sales_Bikes],
    CAST((S.Clothing_Sales / NULLIF(S.Total_Sales, 0)) * 100 AS DECIMAL(5,1)) AS [%Sales_Clothing],
    CAST((S.Components_Sales / NULLIF(S.Total_Sales, 0)) * 100 AS DECIMAL(5,1)) AS [%Sales_Components]
FROM
    ProfitPivot P
JOIN
    SalesPivot S ON P.TerritoryName = S.TerritoryName
ORDER BY
    P.Total_Profit DESC;
