
-- Create a cleaned table from the raw fixedtable by splitting fields and removing header row
CREATE OR REPLACE TABLE `unique-ellipse-459113-b2.COFFEESALESTABLE.cleaned_sales` AS
SELECT
  SPLIT(s, ';')[OFFSET(0)] AS transaction_id,
  PARSE_DATE('%d-%m-%Y', SPLIT(s, ';')[OFFSET(1)]) AS transaction_date,
  SPLIT(s, ';')[OFFSET(2)] AS transaction_time,
  CAST(SPLIT(s, ';')[OFFSET(3)] AS INT64) AS transaction_qty,
  SPLIT(s, ';')[OFFSET(4)] AS store_id,
  SPLIT(s, ';')[OFFSET(5)] AS store_location,
  SPLIT(s, ';')[OFFSET(6)] AS product_id,
  SAFE_CAST(REPLACE(SPLIT(s, ';')[OFFSET(7)], ',', '.') AS FLOAT64) AS unit_price,
  SPLIT(s, ';')[OFFSET(8)] AS product_category,
  SPLIT(s, ';')[OFFSET(9)] AS product_detail,
  SAFE_CAST(REPLACE(SPLIT(s, ';')[OFFSET(7)], ',', '.') AS FLOAT64) * CAST(SPLIT(s, ';')[OFFSET(3)] AS INT64) AS total_amount
FROM `unique-ellipse-459113-b2.COFFEESALESTABLE.fixedtable` t, UNNEST([string_field_0]) AS s
WHERE s IS NOT NULL
  AND ARRAY_LENGTH(SPLIT(s, ';')) >= 10
  AND LOWER(SPLIT(s, ';')[OFFSET(0)]) != 'transaction_id';

-- Total revenue from all sales
SELECT 
  ROUND(SUM(total_amount), 2) AS total_revenue
FROM `unique-ellipse-459113-b2.COFFEESALESTABLE.cleaned_sales`;

-- Total revenue by product category
SELECT 
  product_category,
  ROUND(SUM(total_amount), 2) AS revenue
FROM `unique-ellipse-459113-b2.COFFEESALESTABLE.cleaned_sales`
GROUP BY product_category
ORDER BY revenue DESC;

-- Total revenue by hour of day
SELECT 
  SUBSTR(transaction_time, 1, 2) AS hour_of_day,
  ROUND(SUM(total_amount), 2) AS revenue
FROM `unique-ellipse-459113-b2.COFFEESALESTABLE.cleaned_sales`
GROUP BY hour_of_day
ORDER BY hour_of_day;
