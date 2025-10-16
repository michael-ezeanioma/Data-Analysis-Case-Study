--Section 2
-- S2Q1: Which Sales Group has the most ‘Cobras’?
SELECT 
    l.sales_group_assign_short_text AS SalesGroup, -- assign alias for sales group column from liberty table
    COUNT(*) AS Cobra_Count -- counting all rows where sales group is Cobra
FROM TAKE_HOME.PUBLIC.ROUTE r
JOIN TAKE_HOME.PUBLIC.LIBERTY l
    ON r.Customer = l.Customer --joining on customer column
WHERE r.Route_Type = 'Cobra' -- Selecting Cobras from route type column
GROUP BY SalesGroup -- splitting by sales group
ORDER BY Cobra_Count DESC
LIMIT 1;


-- S2Q2: What are the total TSs for Sales Group Assign with a ‘Charger’?
SELECT 
    SUM(l.ts) AS Total_TS -- adding up all TSs where charger is route type
FROM TAKE_HOME.PUBLIC.LIBERTY l
JOIN TAKE_HOME.PUBLIC.ROUTE r
    ON l.Customer = r.Customer -- joining on customer column
WHERE r.Route_Type = 'Charger';


-- S2Q3: What flavor excluding package size does the best in ‘Brasil’?
WITH flavor_clean AS ( -- start of CTE, logic creates flavor clean table
  SELECT
      sales_group_assign_short_text, -- location of sale places
      ts,
      -- Extract only the flavor name part (everything before the first digit)
      RTRIM(REGEXP_SUBSTR(material_short_text, '^[^0-9]+')) AS flavor -- rtrim takes off white space off the right. Regxp grabs everything from the start until the first number shows up. This excludes package size
  FROM TAKE_HOME.PUBLIC.LIBERTY
)
SELECT 
    flavor,
    SUM(ts) AS total_ts --get the flavor and total ts from query just created.
FROM flavor_clean
WHERE sales_group_assign_short_text = 'Brasil' -- location has to be brasil
GROUP BY flavor -- splits up by flavors
ORDER BY total_ts DESC -- gives the one by the most TS score
LIMIT 1;


-- S2Q4:What month had the highest sales?
SELECT 
    TO_DATE(TO_VARCHAR(calendar_day), 'YYYYMMDD') AS real_date, -- changing calendar_day column from varchar to DATE type to match the YYYYMMDD format
    ts
FROM TAKE_HOME.PUBLIC.LIBERTY
LIMIT 5; -- month format checker

SELECT 
    TO_CHAR(TO_DATE(TO_VARCHAR(calendar_day), 'YYYYMMDD'), 'YYYY-MM') AS sales_month, --turns DATE type into just year-month
    SUM(ts) AS total_ts -- adds ts value for each month
FROM TAKE_HOME.PUBLIC.LIBERTY
GROUP BY sales_month -- splits by month
ORDER BY total_ts DESC -- gives the ts with highest value on top
LIMIT 1; -- keeps only single highest month


-- S2Q5: Do Sales Groups with ‘Chargers’ have on average more sales than those without?
WITH sales_group_totals AS ( --CTE to calculate difference of Charger vs non-charger
    SELECT 
        l.sales_group_assign_short_text AS sales_group, -- name of the sales group
        SUM(l.ts) AS total_ts,                          -- total sales (TS) for that group
        CASE 
            WHEN COUNT_IF(r.Route_Type = 'Charger') > 0 -- this case checks if sale group has 
                 THEN 'Has Charger'                     -- any charger customers. If group more than 0 chargers, assigns charger flag. Else is no charger.
            ELSE 'No Charger'
        END AS charger_flag
    FROM TAKE_HOME.PUBLIC.LIBERTY l
    LEFT JOIN TAKE_HOME.PUBLIC.ROUTE r --left join to only bring matching rows from route table
        ON TRIM(l.Customer) = TRIM(r.Customer) -- customer is common key. Trim eliminates white spaces
    GROUP BY sales_group
),
agg AS ( -- second CTE
    SELECT 
        charger_flag,-- gives charger flag results
         ROUND(AVG(total_ts), 2) AS avg_sales_per_group
    FROM sales_group_totals
    GROUP BY charger_flag
)
SELECT * 
FROM agg -- select all cases of charger flag
UNION ALL -- unions results with below select
-- force row for "Has Charger" = 0 if missing
SELECT 'Has Charger', 0 
WHERE NOT EXISTS (SELECT 1 FROM agg WHERE charger_flag = 'Has Charger'); --grabs row where 'has charger' is present

-- Verification of no sales groups that have chargers in it
SELECT 
  COUNT(DISTINCT l.sales_group_assign_short_text) AS sales_groups_with_chargers
FROM TAKE_HOME.PUBLIC.LIBERTY l
JOIN TAKE_HOME.PUBLIC.ROUTE r
  ON TRIM(l.Customer) = TRIM(r.Customer)
WHERE TRIM(r.Route_Type) ILIKE 'charger'; -- confrims there are no customer rows linking a sales group in liberty to a charger route in route type


-- S2Q6:What Sales Group has the highest number of Picklejuice sales?
SELECT 
    l.sales_group_assign_short_text AS sales_group, --location alias
    SUM(l.ts) AS total_ts --adds up all sales for each location
FROM TAKE_HOME.PUBLIC.LIBERTY l
WHERE UPPER(l.material_short_text) LIKE '%PICKLE JUICE%' -- only grabs sales group that have pickle juice flavor
GROUP BY sales_group --split by location
ORDER BY total_ts DESC -- gets highest sales group where pickle is best selling
LIMIT 1;


-- S2Q7: Do all plants have one of each route type?
WITH route_type_count AS ( -- start of CTE
    SELECT  --counting distinct routes for each plant
        plant_assign_short_text AS plant,
        COUNT(DISTINCT Route_Type) AS route_types_present
    FROM TAKE_HOME.PUBLIC.ROUTE
    GROUP BY plant_assign_short_text -- splits by plant
),
total AS ( -- counts counts distinct total route types
    SELECT COUNT(DISTINCT Route_Type) AS total_types
    FROM TAKE_HOME.PUBLIC.ROUTE
)
SELECT 
    r.plant,
    r.route_types_present,
    t.total_types,
    CASE 
        WHEN r.route_types_present = t.total_types THEN 'Yes'
        ELSE 'No'
    END AS has_all_route_types -- case is if all route types same as total types count then yes
FROM route_type_count r
CROSS JOIN total t
ORDER BY plant;











