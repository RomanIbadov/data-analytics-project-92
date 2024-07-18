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
	to_char(s.sale_date, 'day') day_of_week,
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

/* ШАГ № 6
Первый отчет - количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+.
 */

select (
case
	when age between 16 and 25 then '16-25'
	when age between 26 and 40 then '26-40'
	when age > 40 then '40+'
end
	) age_category,
	count(customer_id) age_count
from customers
group by age_category
order by age_category asc;

/* 
 Второй отчет по количеству уникальных покупателей и выручке, которую они принесли.
 */

select 
	to_char(s.sale_date, 'yyyy-mm') selling_month,
	count(s.customer_id) total_customers,
	floor(sum(p.price * s.quantity)) income
from sales s
join products p on p.product_id = s.product_id
group by selling_month
order by selling_month;

/* 
 Третий отчет о покупателях, первая покупка которых была в ходе проведения акций
 */

with tab1 as (
select
	concat(c.first_name, ' ', c.last_name) customer,
	s.sale_date,
	concat(e.first_name, ' ', e.last_name) seller
from sales s 
join customers c on c.customer_id = s.customer_id 
join employees e on e.employee_id = s.sales_person_id
join products p on p.product_id = s.product_id 
where p.price = 0
group by customer, sale_date, seller, c.customer_id 
order by c.customer_id),

tab2 as (
select 
	customer,
	sale_date,
	seller,
	row_number () over(partition by customer order by sale_date) cid
from tab1
)
select 
	customer,
	sale_date,
	seller
from tab2
where cid = 1;
