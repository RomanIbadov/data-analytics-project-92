/* ШАГ № 4
считает общее количество покупателей из таблицы customers 
*/

select count(*) as customers_count
from customers;

/* ШАГ № 5
пырвый отчет о десятке лучших продавцов
 */

select
    concat(employees.first_name, ' ', employees.last_name) as seller,
    count(sales.quantity) as operations,
    floor(sum(products.price * sales.quantity)) as income
from employees
inner join sales
    on employees.employee_id = sales.sales_person_id
inner join products
    on sales.product_id = products.product_id
group by seller
order by income desc
limit 10;

/*
второй отчет, где средняя выручка меньше средней выручки по все продовцам
 */

with tab1 as (
    select
        concat(employees.first_name, ' ', employees.last_name) as seller,
        floor(avg(products.price * sales.quantity)) as income
    from employees
    inner join sales on employees.employee_id = sales.sales_person_id
    inner join products on sales.product_id = products.product_id
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
        concat(employees.first_name, ' ', employees.last_name) as seller,
        to_char(sales.sale_date, 'day') as day_of_week,
        floor(sum(products.price * sales.quantity)) as income,
        extract(isodow from sales.sale_date) as day_week
    from employees
    inner join sales on employees.employee_id = sales.sales_person_id
    inner join products on sales.product_id = products.product_id
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
    to_char(sales.sale_date, 'YYYY-MM') as selling_month,
    count(distinct sales.customer_id) as total_customers,
    floor(sum(products.price * sales.quantity)) as income
from sales
inner join products on sales.product_id = products.product_id
group by selling_month
order by selling_month;

/* 
 Третий отчет о покупателях, первая покупка которых была в ходе проведения акций
 */

with tab1 as (
    select
        sales.sale_date,
        concat(customers.first_name, ' ', customers.last_name) as customer,
        concat(employees.first_name, ' ', employees.last_name) as seller
    from sales
    inner join customers on sales.customer_id = customers.customer_id
    inner join employees on sales.sales_person_id = employees.employee_id
    inner join products on sales.product_id = products.product_id
    where products.price = 0
    group by customer, sales.sale_date, seller, customers.customer_id
    order by customers.customer_id
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
