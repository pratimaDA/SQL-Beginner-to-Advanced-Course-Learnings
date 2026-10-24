create table fact_act_Est(
select 
s.date as date ,
s.fiscal_year as fiscal_year,
s.product_code as product_code,
s.customer_code as customer_code,
s.sold_quantity as sold_qty,
f.forecast_quantity as forecast_qty
from fact_sales_monthly s
LEFT JOIN fact_forecast_monthly f USING(date,product_code,customer_code)

UNION 
select 
f.date as date ,
f.fiscal_year as fiscal_year,
f.product_code as product_code,
f.customer_code as customer_code,
s.sold_quantity as sold_qty,
f.forecast_quantity as forecast_qty
from fact_forecast_monthly f
LEFT JOIN fact_sales_monthly s USING(date,product_code,customer_code)
);

update fact_act_est 
SET sold_qty = 0 
WHERE sold_qty IS NULL;

-- Net Err , Abs Err , Net_Err_pct , Abs_Err_pct 

WITH forcast_err_pct as (
select 
customer_code ,
forecast_quantity,
sold_quantity,
SUM(forecast_quantity - sold_quantity) as net_err,
SUM(abs(forecast_quantity - sold_quantity)) as abs_err,
SUM((forecast_quantity - sold_quantity))*100/SUM(forecast_quantity) as net_err_pct,
SUm(abs(forecast_quantity - sold_quantity))*100/SUM(forecast_quantity) as abs_err_pct
from fact_act_est fas
WHERE fas.fiscal_year = 2021
GROUP BY fas.customer_code)
select fe.* ,
 c.customer as customer_name, 
 c.market as market,
 If(abs_err_pct>100,0,(100-abs_err_pct)) as forecast_accuracy
from forcast_err_pct fe
JOIN dim_customer c 
USING(customer_code)
ORDER BY forecast_accuracy DESC;

-- Find all customers which had better forecast_accuracy in 2020 than 2021

WITH forcast_err_pct_2020 as (
select 
customer_code ,
forecast_quantity,
sold_quantity,
SUM(forecast_quantity - sold_quantity) as net_err,
SUM(abs(forecast_quantity - sold_quantity)) as abs_err,
SUM((forecast_quantity - sold_quantity))*100/SUM(forecast_quantity) as net_err_pct,
SUM(abs(forecast_quantity - sold_quantity))*100/SUM(forecast_quantity) as abs_err_pct_2020
from fact_act_est fas
WHERE fas.fiscal_year = 2020
GROUP BY fas.customer_code),
forcast_err_pct_2021 as (
select 
customer_code ,
forecast_quantity,
sold_quantity,
SUM(forecast_quantity - sold_quantity) as net_err,
SUM(abs(forecast_quantity - sold_quantity)) as abs_err,
SUM((forecast_quantity - sold_quantity))*100/SUM(forecast_quantity) as net_err_pct,
SUm(abs(forecast_quantity - sold_quantity))*100/SUM(forecast_quantity) as abs_err_pct_2021
from fact_act_est fas
WHERE fas.fiscal_year = 2021
GROUP BY fas.customer_code),
forecast_accuracy_2020_2021 as (
select f2020.customer_code, If(abs_err_pct_2020>100,0,(100-abs_err_pct_2020)) as forecast_accuracy_2020 ,
If(abs_err_pct_2021>100,0,(100-abs_err_pct_2021)) as forecast_accuracy_2021
from forcast_err_pct_2020 f2020
JOIN forcast_err_pct_2021 f2021 USING(customer_code)
)
select 
f.customer_code ,
c.customer, 
c.market,
f.forecast_accuracy_2020,
f.forecast_accuracy_2021
from forecast_accuracy_2020_2021 f
JOIN dim_customer c USING(customer_code)
WHERE forecast_accuracy_2021<forecast_accuracy_2020
ORDER BY forecast_accuracy_2020;









