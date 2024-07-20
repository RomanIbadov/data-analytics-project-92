/* ШАГ № 4
считает общее количество покупателей из таблицы customers 
*/

select count(*) as customers_count
from customers;

/* ШАГ № 5
пырвый отчет о десятке лучших продавцов
 */

select
    concat(e.first_name, ' ', e.last_name) as seller,
    count(s.quantity) as operations,
    floor(sum(p.price * s.quantity)) as income
from employees as e
inner join sales as s
    on e.employee_id = s.sales_person_id
inner join products as p
    on s.product_id = p.product_id
group by seller
order by income desc
limit 10;

/*
второй отчет, где средняя выручка меньше средней выручки по все продовцам
 */

with tab1 as (
    select
        concat(e.first_name, ' ', e.last_name) as seller,
        floor(avg(p.price * s.quantity)) as income
    from employees as e
    inner join sales as s on e.employee_id = s.sales_person_id
    inner join products as p on s.product_id = p.product_id
    group by seller
    order by income
),

tab2 as (
    select avg(income) as avg_income
    from tab1
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
        concat(e.first_name, ' ', e.last_name) as seller,
        to_char(s.sale_date, 'Day') as day_of_week,
        floor(sum(p.price * s.quantity)) as income,
        extract(isodow from s.sale_date) as day_week
    from employees as e
    inner join sales as s on e.employee_id = s.sales_person_id
    inner join products as p on s.product_id = p.product_id
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

select
    (
        case
            when age between 16 and 25 then '16-25'
            when age between 26 and 40 then '26-40'
            when age > 40 then '40+'
        end
    ) as age_category,
    count(customer_id) as age_count
from customers
group by age_category
order by age_category asc;

/* 
 Второй отчет по количеству уникальных покупателей и выручке, которую они принесли.
 */

select
    to_char(s.sale_date, 'yyyy-mm') as selling_month,
    count(distinct s.customer_id) as total_customers,
    floor(sum(p.price * s.quantity)) as income
from sales as s
inner join products as p on s.product_id = p.product_id
group by selling_month
order by selling_month;

/* 
 Третий отчет о покупателях, первая покупка которых была в ходе проведения акций
 */

with tab1 as (
    select
        s.sale_date,
        concat(c.first_name, ' ', c.last_name) as customer,
        concat(e.first_name, ' ', e.last_name) as seller
    from sales as s
    inner join customers as c on s.customer_id = c.customer_id
    inner join employees as e on s.sales_person_id = e.employee_id
    inner join products as p on s.product_id = p.product_id
    where p.price = 0
    group by customer, s.sale_date, seller, c.customer_id
    order by c.customer_id
),

tab2 as (
    select
        customer,
        sale_date,
        seller,
        row_number() over (partition by customer order by sale_date) as cid
    from tab1
)

select
    customer,
    sale_date,
    seller
from tab2
where cid = 1;
