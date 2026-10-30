DROP DATABASE IF EXISTS adventureworks;
CREATE DATABASE adventureworks CHARACTER SET utf8mb4;
USE adventureworks;

CREATE TABLE dim_category (
    ProductCategoryKey INT NOT NULL,
    CategoryName       VARCHAR(50) NOT NULL,
    PRIMARY KEY (ProductCategoryKey)
);

CREATE TABLE dim_subcategory (
    ProductSubcategoryKey INT NOT NULL,
    SubcategoryName       VARCHAR(50) NOT NULL,
    ProductCategoryKey    INT NOT NULL,
    PRIMARY KEY (ProductSubcategoryKey),
    FOREIGN KEY (ProductCategoryKey) REFERENCES dim_category (ProductCategoryKey)
);

CREATE TABLE dim_product (
    ProductKey            INT NOT NULL,
    ProductSubcategoryKey INT NOT NULL,
    ProductSKU            VARCHAR(30),
    ProductName           VARCHAR(150),
    ModelName             VARCHAR(150),
    ProductColor          VARCHAR(30),
    ProductSize           VARCHAR(10),
    ProductStyle          VARCHAR(10),
    ProductCost           DECIMAL(12,4) NOT NULL,
    ProductPrice          DECIMAL(12,4) NOT NULL,
    PRIMARY KEY (ProductKey),
    FOREIGN KEY (ProductSubcategoryKey) REFERENCES dim_subcategory (ProductSubcategoryKey)
);

CREATE TABLE dim_customer (
    CustomerKey    INT NOT NULL,
    BirthDate      DATE,
    MaritalStatus  VARCHAR(10),
    Gender         VARCHAR(10),
    AnnualIncome   INT,
    TotalChildren  INT,
    EducationLevel VARCHAR(50),
    Occupation     VARCHAR(50),
    HomeOwner      VARCHAR(5),
    PRIMARY KEY (CustomerKey)
);

CREATE TABLE dim_territory (
    TerritoryKey INT NOT NULL,
    Region       VARCHAR(50) NOT NULL,
    Country      VARCHAR(50) NOT NULL,
    Continent    VARCHAR(50) NOT NULL,
    PRIMARY KEY (TerritoryKey)
);

CREATE TABLE dim_calendar (
    `Date` DATE NOT NULL,
    PRIMARY KEY (`Date`)
);

CREATE TABLE dim_discount (
    `Year`             INT NOT NULL,
    ProductCategoryKey INT NOT NULL,
    DiscountRate       DECIMAL(5,4) NOT NULL,
    PRIMARY KEY (`Year`, ProductCategoryKey)
);

CREATE TABLE fact_sales (
    OrderDate     DATE NOT NULL,
    StockDate     DATE NOT NULL,
    OrderNumber   VARCHAR(20) NOT NULL,
    ProductKey    INT NOT NULL,
    CustomerKey   INT NOT NULL,
    TerritoryKey  INT NOT NULL,
    OrderLineItem INT NOT NULL,
    OrderQuantity INT NOT NULL,
    PRIMARY KEY (OrderNumber, OrderLineItem),
    FOREIGN KEY (ProductKey)   REFERENCES dim_product (ProductKey),
    FOREIGN KEY (CustomerKey)  REFERENCES dim_customer (CustomerKey),
    FOREIGN KEY (TerritoryKey) REFERENCES dim_territory (TerritoryKey)
);

CREATE TABLE fact_returns (
    ReturnId       INT NOT NULL AUTO_INCREMENT,
    ReturnDate     DATE NOT NULL,
    TerritoryKey   INT NOT NULL,
    ProductKey     INT NOT NULL,
    ReturnQuantity INT NOT NULL,
    PRIMARY KEY (ReturnId),
    FOREIGN KEY (ProductKey)   REFERENCES dim_product (ProductKey),
    FOREIGN KEY (TerritoryKey) REFERENCES dim_territory (TerritoryKey)
);

-- Flattened product view: same columns and order that Power Query produced in Stage 1
CREATE VIEW vw_product AS
SELECT
    p.ProductKey,
    p.ProductSKU,
    p.ProductName,
    p.ModelName,
    c.CategoryName,
    s.SubcategoryName,
    s.ProductCategoryKey,
    p.ProductSubcategoryKey,
    p.ProductColor,
    p.ProductSize,
    p.ProductStyle,
    p.ProductCost,
    p.ProductPrice
FROM dim_product p
LEFT JOIN dim_subcategory s ON s.ProductSubcategoryKey = p.ProductSubcategoryKey
LEFT JOIN dim_category c    ON c.ProductCategoryKey    = s.ProductCategoryKey;