create database Zomato_Analysis;
use Zomato_Analysis;

Create table main
(RestaurantID int,
RestaurantName varchar(500),
CountryCode int,
City varchar(255),
Locality varchar(255),
Cuisines varchar(500),
Currency varchar(255),
Has_Table_booking varchar(50),
Has_Online_delivery varchar(50),
Is_delivering_now varchar(50),
Switch_to_order_menu varchar(50),
Price_range int,
Votes int,
Average_Cost_for_two int,
Rating decimal(2,1),
YearOpening year,
MonthOpening tinyint,
DayOpening tinyint
);

create table currency (
currency varchar(500),
USD_rate decimal(15,8)
);

create table country (
countryid int,
country_name varchar(255)
);

# Temporary column for average_cost_for_2

SELECT 
    m.*,
    Average_Cost_for_two,
    c.usd_rate,
    ROUND(m.average_cost_for_two * c.usd_rate) AS average_cost_for_2_usd
FROM
    main m
        JOIN
    currency c ON m.currency = c.currency;

# Permanent column in main table for average_cost_for_2

ALTER TABLE main
ADD COLUMN average_cost_for_two_usd INT;

# Updating the column using the usd rate

UPDATE main m
        JOIN
    currency c ON m.currency = c.currency 
SET 
    m.average_cost_for_two_usd = ROUND(m.average_cost_for_two * c.usd_rate, 0);

# Temporary column country name

SELECT 
  m.*, 
  c.country_name
FROM 
  main m
JOIN 
  country c ON m.CountryCode = c.countryid;
  
# Permanent column country name

alter table main
add column countryname varchar(255);

# updating the column

UPDATE main m
        JOIN
    country c ON m.CountryCode = c.countryid 
SET 
    m.countryname = c.country_name;

# Adding date column

ALTER TABLE main
ADD COLUMN open_date DATE;

# Date temporary column

SELECT 
    *,
    STR_TO_DATE(
        CONCAT(YearOpening, '-', LPAD(MonthOpening, 2, '0'), '-', LPAD(DayOpening, 2, '0')),
        '%Y-%m-%d'
    ) AS date_opening
FROM main;

# adding permanent date column

ALTER TABLE main
ADD COLUMN open_date DATE;

# updating the date column

UPDATE main
SET open_date = STR_TO_DATE(CONCAT(YearOpening, '-', 
                                   LPAD(MonthOpening, 2, '0'), '-', 
                                   LPAD(DayOpening, 2, '0')), '%Y-%m-%d');


-- Total Resturants,country,city,cuisines,votes and ratings

SELECT 
    COUNT(RestaurantID) AS Resturants,
    COUNT(DISTINCT CountryCode) AS countries,
    COUNT(DISTINCT City) AS Cities,
    CONCAT(ROUND(SUM(Votes) / 1000000, 2), 'M') AS Total_Votes,
    COUNT(DISTINCT (Cuisines)) AS Total_Cuisines,
    ROUND(AVG(Rating), 2) AS Average_Rating
FROM
    main;

# No of restaurants by country

SELECT 
    countryname,
    COUNT(*) AS restaurant_count
FROM main
GROUP BY countryname
ORDER BY restaurant_count DESC;

# No of restaurants by city

SELECT 
    City,
    COUNT(*) AS restaurant_count
FROM main
GROUP BY City
ORDER BY restaurant_count DESC;

# No of restaurants only in india

SELECT 
    City,
    COUNT(*) AS restaurant_count
FROM main
WHERE countryname = "India"
GROUP BY City
ORDER BY restaurant_count DESC;

# No of city in each country

SELECT 
    countryname,
    COUNT(DISTINCT City) AS city_count
FROM main
GROUP BY countryname
ORDER BY city_count DESC;

# No of restaurants opening per year

SELECT 
    YearOpening,
    COUNT(*) AS NumberOfRestaurants
FROM main
GROUP BY 
    YearOpening
ORDER BY 
    YearOpening;

# No of restaurants opening per month

SELECT 
    MonthOpening,
    COUNT(*) AS NumberOfRestaurants
FROM main
GROUP BY 
    MonthOpening
ORDER BY 
    MonthOpening;
    
# -- No of restaurants opening per quarter

SELECT 
    CASE
        WHEN MonthOpening BETWEEN 1 AND 3 THEN 'Q1'
        WHEN MonthOpening BETWEEN 4 AND 6 THEN 'Q2'
        WHEN MonthOpening BETWEEN 7 AND 9 THEN 'Q3'
        WHEN MonthOpening BETWEEN 10 AND 12 THEN 'Q4'
    END AS QuarterOpening,
    COUNT(*) AS NumberOfRestaurants
FROM main
GROUP BY 
    QuarterOpening
ORDER BY 
    QuarterOpening;
    
# -- Numbers of Resturants opening based on Year , Quarter , Month in INDIA

SELECT 
    YearOpening,
    MonthOpening,
    CASE
        WHEN MonthOpening BETWEEN 1 AND 3 THEN 'Q1'
        WHEN MonthOpening BETWEEN 4 AND 6 THEN 'Q2'
        WHEN MonthOpening BETWEEN 7 AND 9 THEN 'Q3'
        WHEN MonthOpening BETWEEN 10 AND 12 THEN 'Q4'
    END AS QuarterOpening,
    COUNT(*) AS NumberOfRestaurants
FROM main
WHERE countryname ="India"
GROUP BY 
    YearOpening,
    MonthOpening,
    QuarterOpening
ORDER BY 
    YearOpening,
    MonthOpening;

# -- Count of restaurants as per rating bucket

SELECT 
  CASE
    WHEN rating >= 4.5 THEN 'Excellent (4.5 - 5.0)'
    WHEN rating >= 4.0 THEN 'Very Good (4.0 - 4.4)'
    WHEN rating >= 3.5 THEN 'Good (3.5 - 3.9)'
    WHEN rating >= 3.0 THEN 'Average (3.0 - 3.4)'
    WHEN rating >= 2.5 THEN 'Below Avg (2.5 - 2.9)'
    ELSE 'Poor (< 2.5)'
  END AS Rating_Bucket,
  COUNT(*) AS Restaurant_Count
FROM main
GROUP BY Rating_Bucket
ORDER BY Restaurant_Count DESC;

# -- Count of restaurants as per rating bucket in India

SELECT 
  CASE
    WHEN rating >= 4.5 THEN 'Excellent (4.5 - 5.0)'
    WHEN rating >= 4.0 THEN 'Very Good (4.0 - 4.4)'
    WHEN rating >= 3.5 THEN 'Good (3.5 - 3.9)'
    WHEN rating >= 3.0 THEN 'Average (3.0 - 3.4)'
    WHEN rating >= 2.5 THEN 'Below Avg (2.5 - 2.9)'
    ELSE 'Poor (< 2.5)'
  END AS Rating_Bucket,
  COUNT(*) AS Restaurant_Count
FROM main
WHERE countryname = 'India'
GROUP BY Rating_Bucket
ORDER BY Restaurant_Count DESC;

# -- Count of restaurants based on average price bucket

SELECT 
  CASE
    WHEN average_cost_for_two_usd BETWEEN 0 AND 49 THEN 'Budget (0 - 49)'
    WHEN average_cost_for_two_usd BETWEEN 50 AND 99 THEN 'Affordable (50 - 99)'
    WHEN average_cost_for_two_usd BETWEEN 100 AND 199 THEN 'Moderate (100 - 199)'
    WHEN average_cost_for_two_usd BETWEEN 200 AND 299 THEN 'Premium (200 - 299)'
    WHEN average_cost_for_two_usd BETWEEN 300 AND 500 THEN 'Luxury (300 - 500)'
    ELSE 'Unknown'
  END AS Cost_Bucket,
  COUNT(*) AS Restaurant_Count
FROM main
GROUP BY Cost_Bucket
ORDER BY Restaurant_Count DESC;

# -- Count of restaurants based on average price bucket in India

SELECT 
  CASE
    WHEN average_cost_for_two_usd BETWEEN 0 AND 49 THEN 'Budget (0 - 49)'
    WHEN average_cost_for_two_usd BETWEEN 50 AND 99 THEN 'Affordable (50 - 99)'
    WHEN average_cost_for_two_usd BETWEEN 100 AND 199 THEN 'Moderate (100 - 199)'
    WHEN average_cost_for_two_usd BETWEEN 200 AND 299 THEN 'Premium (200 - 299)'
    WHEN average_cost_for_two_usd BETWEEN 300 AND 500 THEN 'Luxury (300 - 500)'
    ELSE 'Unknown'
  END AS Cost_Bucket,
  COUNT(*) AS Restaurant_Count
FROM main
WHERE countryname = 'India'
GROUP BY Cost_Bucket
ORDER BY Restaurant_Count DESC;

# -- Percentage of restaurants based on has delivery booking and has table booking

SELECT 
  Has_Table_booking,
  Has_Online_delivery,
  COUNT(*) AS count,
  ROUND(COUNT(*) / (SELECT COUNT(*) FROM main)*100.0, 2) AS percentage
FROM main
GROUP BY Has_Table_booking, Has_Online_delivery
ORDER BY percentage DESC;

# -- * Top 10 Restaurants by Country *

SELECT 
    COUNT(RestaurantID) AS Restaurants, countryname
FROM
    main
GROUP BY countryname
ORDER BY Restaurants DESC
LIMIT 10;

# -- * Top 10 Restaurants by City *

SELECT 
    COUNT(RestaurantID) AS Restaurants, City
FROM
    main
GROUP BY City
ORDER BY Restaurants DESC
LIMIT 10;

# -- * Top 10 Cuisines *

SELECT 
    Cuisines,
    COUNT(RestaurantID) AS Total_Restaurants
FROM main
GROUP BY Cuisines
ORDER BY Total_Restaurants DESC
LIMIT 10;


SELECT 
    Cuisines,
    countryname,
    Total_Restaurants
FROM (
    SELECT 
        Cuisines,
        countryname,
        COUNT(RestaurantID) AS Total_Restaurants,
        RANK() OVER (PARTITION BY Cuisines ORDER BY COUNT(RestaurantID) DESC) AS rnk
    FROM main
    GROUP BY Cuisines, countryname
) AS ranked
WHERE rnk = 1
ORDER BY Total_Restaurants DESC
LIMIT 10;
