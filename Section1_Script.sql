--Section 1 Code
--Created view to split State Granularity
'CREATE OR REPLACE VIEW TAKE_HOME.PUBLIC.CIRC_STATE AS
SELECT
    Stores,
    Dollar_Sales,
    County,
    Latitude,
    Longitude,
    City,
    TRIM(SPLIT_PART(Stores, ',', -1)) AS State
FROM TAKE_HOME.PUBLIC.CIRCANA;'

select distinct(State) from TAKE_HOME.PUBLIC.CIRC_STATE

-- S1Q1: Give the total Red Bull Dollar Sales of each State, sorted from Highest to Lowest.
SELECT 
    State,
    '$' || TO_CHAR(ROUND(SUM(Dollar_Sales), 2), '999,999,999,990.00') AS Total_RedBull_Sales
    --giving dollar output
FROM TAKE_HOME.PUBLIC.CIRC_STATE -- my created view
GROUP BY State -- splitting by state
ORDER BY Total_RedBull_Sales DESC; --highest to lowest order


-- S1Q2: Which City has the highest average Dollar Sales in each county?
-- Top city (highest AVG Dollar Sales) in each county
SELECT
  County,
  City,
  '$' || TO_CHAR(ROUND(AVG(Dollar_Sales), 2), '999,999,999,990.00') AS Avg_Dollar_Sales
FROM TAKE_HOME.PUBLIC.CIRC_STATE
GROUP BY County, City -- congelled by county, then city
QUALIFY ROW_NUMBER() OVER ( --row_number assign unique number to each row | qualify only keeps where the city has the highest avg dollar sales
  PARTITION BY County  
  ORDER BY AVG(Dollar_Sales) DESC --conditions for window function
) = 1 -- this = 1 is the first row
ORDER BY Avg_Dollar_Sales DESC --County;
LIMIT 1;


-- S1Q3: Which County has the most stores with Dollar Sales above the county average?
SELECT 
    County,
    COUNT(*) AS Stores_Above_Avg
FROM ( -- start of subquery
    SELECT 
        County,
        Stores,
        Dollar_Sales,
        AVG(Dollar_Sales) OVER (PARTITION BY County) AS County_Avg 
        -- ^window func. calculating avg split by county
    FROM TAKE_HOME.PUBLIC.CIRC_STATE
) as t -- alias for subquery
WHERE Dollar_Sales > County_Avg -- only gives sales above county avg
GROUP BY County -- split by county
ORDER BY Stores_Above_Avg DESC -- ordered by highest to lowest
LIMIT 1;  -- gives the single county with the most


-- S1Q4: How many cities are in each county?
SELECT 
    County,
    COUNT(DISTINCT City) AS Num_Cities -- count distinct cities
FROM TAKE_HOME.PUBLIC.CIRC_STATE 
GROUP BY County -- split by county
ORDER BY Num_Cities DESC; -- gives city count greatest to least


-- S1Q5: How many cities are in each State?
SELECT 
    State,
    COUNT(DISTINCT City) AS Num_Cities -- count distinct cities
FROM TAKE_HOME.PUBLIC.CIRC_STATE
GROUP BY State -- split by state
ORDER BY Num_Cities DESC; -- gives city count greatest to least









