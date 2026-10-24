SELECT * , amount*100/SUM(amount)  OVER(PARTITION BY category)
 FROM random_tables.expenses;
 
-- Find the cumulative amount

SELECT * , SUM(amount)  OVER(PARTITION BY category ORDER BY date) as total_Amount_till_date
FROM random_tables.expenses; 

-- % contribution of each customer in a FY
WITH cte1 as (select c.customer, ROUND(SUM(ns.net_sales)/1000000,2) as net_sales_mln
from net_sales ns
JOIN dim_customer c ON (ns.customer_code=c.customer_code)
WHERE fiscal_year = 2021
Group by c.customer
ORDER BY net_sales_mln DESC)
select *,net_sales_mln*100/SUM(net_sales_mln) OVER() as pct_contribution from cte1;

-- % contribution of each customer per region in a given FY
WITH cte1 as (select c.customer,c.region as region, ROUND(SUM(ns.net_sales)/1000000,2) as net_sales_mln
from net_sales ns
JOIN dim_customer c ON (ns.customer_code=c.customer_code)
WHERE fiscal_year = 2021
Group by c.customer
ORDER BY net_sales_mln DESC)
select *,net_sales_mln*100/SUM(net_sales_mln) OVER(PARTITION BY region) as pct_contribution from cte1;


-- row_number() , rank() and dense_rank() window functions - Top 2 restaurant by amount
WITH cte1 as (select *, 
row_number() OVER(PARTITION BY category ORDER BY amount) as rn ,
rank() OVER(PARTITION BY category ORDER BY amount) as rnk ,
dense_rank() OVER(PARTITION BY category ORDER BY amount) as dnrk
from expenses
)
select * from cte1
WHERE dnrk<=2;

WITH cte1 as (select 
p.product,p.division,fs.sold_quantity
from dim_product  p
JOIN fact_sales_monthly fs ON(p.product_code = fs.product_code)
WHERE fs.fiscal_year=2021
GROUP BY p.product
),
cte2 as (
select  *,dense_rank() OVER(PARTITION BY cte1.division ORDER by cte1.sold_quantity DESC) dnrk from cte1
)
select * from cte2 WHERE 
dnrk<=5;


-- Retrieve the top 2 markets in every region by their gross sales amount in FY=2021.

WITH cte1 as (select c.market,c.region,(gp.gross_price_total/1000000) as gross_sales_mln 
from dim_customer c
JOIN gross_price_total gp ON(gp.customer_code=c.customer_code)
WHERE gp.fiscal_year = 2021
GROUP BY c.market
),
cte2 as (select *,dense_Rank() OVER(PARTITION BY region ORDER BY gross_sales_mln DESC) as dnrk from cte1)
select * from cte2
WHERE dnrk<=2;
