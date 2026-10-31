USE adventureworks;

SELECT MIN(OrderDate) AS first_order, MAX(OrderDate) AS last_order FROM fact_sales;

SELECT
    SUM(s.OrderQuantity)                                              AS quantity,
    ROUND(SUM(s.OrderQuantity * p.ProductPrice), 0)                   AS revenue,
    ROUND(SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)), 0) AS profit
FROM fact_sales s
JOIN dim_product p ON p.ProductKey = s.ProductKey;
