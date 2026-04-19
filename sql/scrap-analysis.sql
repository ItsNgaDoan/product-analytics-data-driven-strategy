-- Analysis: Scrap analysis
-- Business Question: Which product categories and subcategories incur the highest scrap costs, and how does this impact overall production efficiency and profitability?

--SQL statement
SELECT
    dp.CategoryName, dp.SubcategoryName,
    SUM(fq.TotalScrapCost) AS TotalScrapCost,
    SUM(fq.ScrappedQty) AS TotalScrappedQty
FROM FactProductQuality fq
JOIN DimProduct dp ON fq.ProductID = dp.ProductID
GROUP BY dp.CategoryName,  dp.SubcategoryName
ORDER BY TotalScrapCost DESC, dp.CategoryName;


-- Business Question: What are the most recurring / top reasons contributing to scrap costs, and what are their associated impacts on production quality and what strategies can minimize waste in manufacturing?

--SQL statement
SELECT
    CASE
        WHEN dsr.ReasonDescription IN ('Color incorrect', 'Drill pattern incorrect') THEN 'Design Issues'
        WHEN dsr.ReasonDescription IN ('Gouge in metal', 'Wheel misaligned', 'Stress test failed',
                                       'Brake assembly not as ordered', 'Seat assembly not as ordered') THEN 'Safety Concerns'
        WHEN dsr.ReasonDescription IN ('Trim length too long', 'Trim length too short', 'Thermoform temperature too low',
                                       'Thermoform temperature too high', 'Drill size too large', 'Drill size too small',
                                       'Paint process failed', 'Primer process failed', 'Handling damage') THEN 'Manufacturing/Operational'
        ELSE 'Other'
    END AS ReasonCategory,  dsr.ReasonDescription,
    SUM(fpq.ScrappedQty) AS ScrappedQty,
    SUM(fpq.TotalScrapCost) AS TotalScrapCost
FROM [dbo].[FactProductQuality] AS fpq
RIGHT JOIN [dbo].[DimScrapReason] AS dsr ON fpq.ScrapReasonID = dsr.ScrapReasonID
GROUP BY dsr.ReasonDescription
ORDER BY ReasonCategory,ScrappedQty DESC;
