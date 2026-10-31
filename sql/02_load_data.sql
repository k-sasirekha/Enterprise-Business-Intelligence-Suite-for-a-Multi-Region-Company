USE adventureworks;

-- Lookup tables first (facts depend on them)
LOAD DATA LOCAL INFILE 'C:/path/to/AdventureWorks_Dataset/AdventureWorks_Product_Categories_Lookup.csv'
INTO TABLE dim_category
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(ProductCategoryKey, CategoryName);

LOAD DATA LOCAL INFILE 'C:/path/to/AdventureWorks_Dataset/AdventureWorks_Product_Subcategories_Lookup.csv'
INTO TABLE dim_subcategory
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(ProductSubcategoryKey, SubcategoryName, ProductCategoryKey);

-- Product: the long description column is skipped (@description)
LOAD DATA LOCAL INFILE 'C:/path/to/AdventureWorks_Dataset/AdventureWorks_Product_Lookup.csv'
INTO TABLE dim_product
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(ProductKey, ProductSubcategoryKey, ProductSKU, ProductName, ModelName, @description,
 ProductColor, ProductSize, ProductStyle, ProductCost, ProductPrice);

LOAD DATA LOCAL INFILE 'C:/path/to/AdventureWorks_Dataset/AdventureWorks_Territory_Lookup.csv'
INTO TABLE dim_territory
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(TerritoryKey, Region, Country, Continent);

LOAD DATA LOCAL INFILE 'C:/path/to/AdventureWorks_Dataset/AdventureWorks_Discounts.csv'
INTO TABLE dim_discount
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(`Year`, ProductCategoryKey, DiscountRate);

-- Calendar: dates accepted as yyyy-mm-dd or dd-mm-yyyy
LOAD DATA LOCAL INFILE 'C:/path/to/AdventureWorks_Dataset/AdventureWorks_Calendar_Lookup.csv'
INTO TABLE dim_calendar
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@d)
SET `Date` = IF(@d LIKE '____-__-__', STR_TO_DATE(@d, '%Y-%m-%d'), STR_TO_DATE(@d, '%d-%m-%Y'));

-- Customer: loaded through a staging table WITHOUT the personal columns
-- (Prefix, FirstName, LastName, EmailAddress are skipped, so they never enter the database)
CREATE TABLE stg_customer (
    CustomerKey    VARCHAR(60),
    BirthDate      VARCHAR(60),
    MaritalStatus  VARCHAR(60),
    Gender         VARCHAR(60),
    AnnualIncome   VARCHAR(60),
    TotalChildren  VARCHAR(60),
    EducationLevel VARCHAR(60),
    Occupation     VARCHAR(60),
    HomeOwner      VARCHAR(60)
);

-- latin1 in MySQL = cp1252 (the customer file's encoding)
LOAD DATA LOCAL INFILE 'C:/path/to/AdventureWorks_Dataset/AdventureWorks_Customer_Lookup.csv'
INTO TABLE stg_customer
CHARACTER SET latin1
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(CustomerKey, @prefix, @firstname, @lastname, BirthDate, MaritalStatus, Gender, @email,
 AnnualIncome, TotalChildren, EducationLevel, Occupation, HomeOwner);

-- Keep only real customers: numeric key. Removes the 3 junk rows (30---), the blank row and the 2 footer lines.
INSERT INTO dim_customer
SELECT
    CAST(CustomerKey AS UNSIGNED),
    IF(BirthDate LIKE '____-__-__', STR_TO_DATE(BirthDate, '%Y-%m-%d'), STR_TO_DATE(BirthDate, '%d-%m-%Y')),
    MaritalStatus,
    Gender,
    CAST(AnnualIncome AS UNSIGNED),
    CAST(TotalChildren AS UNSIGNED),
    EducationLevel,
    Occupation,
    HomeOwner
FROM stg_customer
WHERE CustomerKey REGEXP '^[0-9]+$';

DROP TABLE stg_customer;

-- Facts
LOAD DATA LOCAL INFILE 'C:/path/to/AdventureWorks_Dataset/AdventureWorks_Sales_Data_2020.csv'
INTO TABLE fact_sales
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@od, @sd, OrderNumber, ProductKey, CustomerKey, TerritoryKey, OrderLineItem, OrderQuantity)
SET OrderDate = IF(@od LIKE '____-__-__', STR_TO_DATE(@od, '%Y-%m-%d'), STR_TO_DATE(@od, '%d-%m-%Y')),
    StockDate = IF(@sd LIKE '____-__-__', STR_TO_DATE(@sd, '%Y-%m-%d'), STR_TO_DATE(@sd, '%d-%m-%Y'));

LOAD DATA LOCAL INFILE 'C:/path/to/AdventureWorks_Dataset/AdventureWorks_Sales_Data_2021.csv'
INTO TABLE fact_sales
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@od, @sd, OrderNumber, ProductKey, CustomerKey, TerritoryKey, OrderLineItem, OrderQuantity)
SET OrderDate = IF(@od LIKE '____-__-__', STR_TO_DATE(@od, '%Y-%m-%d'), STR_TO_DATE(@od, '%d-%m-%Y')),
    StockDate = IF(@sd LIKE '____-__-__', STR_TO_DATE(@sd, '%Y-%m-%d'), STR_TO_DATE(@sd, '%d-%m-%Y'));

LOAD DATA LOCAL INFILE 'C:/path/to/AdventureWorks_Dataset/AdventureWorks_Sales_Data_2022.csv'
INTO TABLE fact_sales
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@od, @sd, OrderNumber, ProductKey, CustomerKey, TerritoryKey, OrderLineItem, OrderQuantity)
SET OrderDate = IF(@od LIKE '____-__-__', STR_TO_DATE(@od, '%Y-%m-%d'), STR_TO_DATE(@od, '%d-%m-%Y')),
    StockDate = IF(@sd LIKE '____-__-__', STR_TO_DATE(@sd, '%Y-%m-%d'), STR_TO_DATE(@sd, '%d-%m-%Y'));

LOAD DATA LOCAL INFILE 'C:/path/to/AdventureWorks_Dataset/AdventureWorks_Returns_Data.csv'
INTO TABLE fact_returns
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@rd, TerritoryKey, ProductKey, ReturnQuantity)
SET ReturnDate = IF(@rd LIKE '____-__-__', STR_TO_DATE(@rd, '%Y-%m-%d'), STR_TO_DATE(@rd, '%d-%m-%Y'));
