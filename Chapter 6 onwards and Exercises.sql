-- Month 
-- product name 
--  variant 
-- sold quatity 
-- Gross price per Item
-- Gross Price total 
select fs.date,p.product_code as product_code, p.product as product_name,p.variant as variant,
fs.sold_quantity as sold_quantity, ROUND(fg.gross_price,2) as gross_price,
ROUND((fs.sold_quantity*fg.gross_price),2) as total_gross_price
from fact_sales_monthly  as fs
JOIN dim_product as p ON(p.product_code=fs.product_code)
JOIN fact_gross_price as fg ON (fs.product_code=fg.product_code AND fg.fiscal_year =  get_fiscal_year(fs.date))
where 
customer_code = 90002002
AND get_fiscal_year(date)=2021
AND get_fiscal_Qtr(date) = "Q1"
ORDER BY date ASC;

--  Find monthly total_gross_price for croma
select fs.date , ROUND(SUM((fg.gross_price*fs.sold_quantity)),2) AS gross_price_total
from fact_sales_monthly  as fs
JOIN fact_gross_price as fg 
ON (fs.product_code=fg.product_code AND fg.fiscal_year =  get_fiscal_year(fs.date))
where 
customer_code = 90002002
GROUP BY fs.date
ORDER by fs.date asc;

-- Generate a yearly report for Croma India where there are two columns

-- 1. Fiscal Year
-- 2. Total Gross Sales amount In that year from Croma

select fs.date as Fiscal_year, ROUND(SUM((fg.gross_price*fs.sold_quantity)),2) AS Gross_Price_Total
from fact_sales_monthly  as fs
JOIN fact_gross_price as fg 
ON (fs.product_code=fg.product_code AND fg.fiscal_year =  get_fiscal_year(fs.date))
where 
fs.customer_code = 90002002
GROUP BY fs.date
ORDER by Fiscal_Year asc;

--  Find out market Badge
select c.market,
CASE 
WHEN SUM(fs.sold_quantity)>5000000 THEN "Gold"
Else "Silver"
END as badge
from fact_sales_monthly fs
JOIN dim_customer as c ON(fs.customer_code=c.customer_code)
WHERE get_fiscal_year(fs.date)= 2022
GROUP BY c.market;

-- Find gross_sales total and pre_inc_discount_pct for all customers in a given FY
select fs.date,fs.fiscal_year as fiscal_year,
c.customer_code,c.customer as customer_name , p.product_code as product_code, p.product as product_name,p.variant as variant,
fs.sold_quantity as sold_quantity, ROUND(fg.gross_price,2) as gross_price,
ROUND((fs.sold_quantity*fg.gross_price),2) as total_gross_price,
pre.pre_invoice_discount_pct as pre_invoice_deductions_pct
from fact_sales_monthly  as fs
JOIN dim_customer as c ON (fs.customer_code = c.customer_code)
JOIN dim_product as p ON(p.product_code=fs.product_code)
JOIN fact_gross_price as fg ON (fs.product_code=fg.product_code AND fg.fiscal_year =  fs.fiscal_year)
JOIN fact_pre_invoice_deductions as pre ON(fs.customer_code = pre.customer_code AND pre.fiscal_year=fs.fiscal_year)
where 
fs.fiscal_year=2021;

-- Find Net Invoice Sales
select *, ROUND((1-pre_invoice_deductions_pct)*total_gross_price,2) as net_inv_sales from sales_preinv_discount ;


-- Find post_invoice_discount_pct

select s.*, 
ROUND((1-pre_invoice_deductions)*total_gross_price,2) as net_inv_sales,
ROUND(po.discounts_pct+po.other_deductions_pct,2) as post_inv_deductions_pct
from sales_preinv_discount as s
JOIN fact_post_invoice_deductions as po 
ON(s.date=po.date AND s.product_code=po.product_code AND s.customer_code=po.customer_code);


--  calculate net sales 
select *, ROUND((1-post_inv_deductions_pct)*net_inv_sales,2) as net_sales
from sales_post_inv_discounts;

-- Find Top markets by Net sales
select market, ROUND(SUM(net_Sales)/1000000,2) as net_sales_mln
from net_sales
WHERE fiscal_year = 2021
Group by market
ORDER BY net_sales_mln DESC
LIMIT 5;

-- top customers by net sales
select c.customer, ROUND(SUM(ns.net_sales)/1000000,2) as net_sales_mln
from net_sales ns
JOIN dim_customer c ON (ns.customer_code=c.customer_code)
WHERE fiscal_year = 2021
Group by c.customer
ORDER BY net_sales_mln DESC
LIMIT 5;

-- Write a stored procedure to get the top n products by net sales for a given year. Use product name without a variant.
SELECT
    product_name,ROUND(SUM(net_sales) / 1000000, 2) AS net_sales_mln
FROM
    net_sales
WHERE
    fiscal_year = 2020
GROUP BY product_name
ORDER BY net_sales_mln DESC
LIMIT 5;





        





