/* ШАГ № 4
считает общее количество покупателей из таблицы customers 
*/

select count(*) as customers_count
from customers;

/* ШАГ № 5
пырвый отчет о десятке лучших продавцов
 */

select 
	concat(first_name, ' ', last_name) seller,
	count(s.quantity) operations,
	floor(sum(p.price * s.quantity)) income
from employees e 
join sales s on e.employee_id = s.sales_person_id
join products p on p.product_id = s.product_id 
group by seller
order by income desc limit 10;

/*
второй отчет, где средняя выручка меньше средней выручки по все продовцам
 */

with tab1 as (
	select 
		concat(first_name, ' ', last_name) seller,
		floor(avg(p.price * s.quantity)) income
	from employees e 
	join sales s on e.employee_id = s.sales_person_id
	join products p on p.product_id = s.product_id 
group by seller
order by income
), 
tab2 as (
	select 
		avg(income) avg_income from tab1
		)
select 
	seller, 
	income 
from tab1 
where income < (select avg_income from tab2);

/*
Третий отчет содержит информацию о выручке по дням недели 
 */

with dow as (
select 
	concat(first_name, ' ', last_name) seller,
	to_char(s.sale_date, 'Day') day_of_week,
	floor(sum(p.price * s.quantity)) income,
	extract(isodow from s.sale_date) day_week 
from employees e 
join sales s on e.employee_id = s.sales_person_id
join products p on p.product_id = s.product_id
group by seller, day_of_week, day_week
)
select 
	seller,
	day_of_week,
	income
from dow
order by day_week, seller;
