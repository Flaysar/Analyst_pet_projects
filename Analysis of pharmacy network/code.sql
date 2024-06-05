/* Задача: провести ABC и XYZ анализ аптечной сети. XYZ анализ проводится по количеству проданного товара с группировкой по неделям, т.к. данных не слишком много
Так же сделано доп. условие, чтобы товар продавался как минимум в 4-х разных неделях.
*/

with xyz as (
	select dr_ndrugs as product, 
	to_char(dr_dat, 'YYYY-WW') as ym,
	sum(dr_kol) as sales
	from sales
	group by product, ym
),
xyz_result as (
	select product,
	case
		when stddev_samp(sales)/avg(sales) > 0.25 then 'Z'
		when stddev_samp(sales)/avg(sales) > 0.1 then 'Y'
		else 'X'
	end as xyz_sales
	from xyz
	group by product
	having count(distinct ym)>=4
),
abc_sales as (
	select dr_ndrugs as product,
	sum(dr_kol) as count,
	sum(dr_kol * dr_croz - dr_sdisc) as revenue,
	sum(dr_kol * (dr_croz - dr_czak ) - dr_sdisc) as profit
	from sales
	group by dr_ndrugs
)
select 
ab.product,
case
	when sum(count) over (order by count DESC)/sum(count) over () <=0.8 then 'A'
	when sum(count) over (order by count DESC)/sum(count) over () <=0.95 then 'B'
	else 'C'
end as amount_abc,
case
	when sum(profit) over (order by profit DESC)/sum(profit) over () <=0.8 then 'A'
	when sum(profit) over (order by profit DESC)/sum(profit) over () <=0.95 then 'B'
	else 'C'
end as profit_abc,
case
	when sum(revenue) over (order by revenue DESC)/sum(revenue) over () <=0.8 then 'A'
	when sum(revenue) over (order by revenue DESC)/sum(revenue) over () <=0.95 then 'B'
	else 'C'
end as revenue_abc,
xyz_sales
from abc_sales ab
left join xyz_result xy
on ab.product = xy.product
order by product


/* Задача: провести анализ сочетаемости товаров, а именно - узнать количество раз, когда какие-либо два товара встретились вместе в одном чеке
При этом даже в рамках одного чека один и тот же товар может фигурировать в нескольких строках. 
Нужно сделать предварительную обработку так, чтобы избежать дублирования данных в результате анализа.
*/

with agg as (
	select distinct on (dr_apt, dr_nchk, dr_dat, dr_ndrugs) dr_apt as apt, dr_nchk as chek, dr_dat as dat,
	dr_ndrugs as product
	from sales
),
combinations as (
	select a1.apt || ' '|| a1.chek || ' '|| a1.dat as cheque, a1.product as product1, a2.product as product2
	from agg a1
	join agg a2
	on a1.apt = a2.apt and a1.chek = a2.chek and a1.dat=a2.dat and a1.product<a2.product
)
select product1, product2, count(distinct cheque) as cnt
from combinations
group by product1, product2
order by cnt desc


/*Задание: построить полную таблицу продаж товаров во всех аптеках в формате «аптека - товар - продано штук». 
Если вдруг в какой-то аптеке конкретный товар не продавался, то просто выводим 0.
*/

with apt_only as (
	select distinct dr_apt as apt
	from sales
),
need_col as (
select dr_apt, dr_ndrugs, dr_kol
from sales
)
select apt as "id аптеки", dr_ndrugs as product,  
round(sum(case
	when dr_apt = apt then dr_kol else 0
	end
)::numeric, 2) as cnt
from need_col n
cross join apt_only a
group by dr_ndrugs, apt