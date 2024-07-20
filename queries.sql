ШАГ 4
"Первый отчет считает общее количество покупателей из таблицы customers"
select count(customer_id) as "customers_count"
from public.customers;

ШАГ 5
"Первый отчет о десятке лучших продавцов"
select
    concat(public.employees.first_name, ' ', public.employees.last_name)
    as seller,
    count(public.sales.quantity)
    as operations,
    floor(sum(public.products.price * public.sales.quantity)) as income
from employees
inner join sales
    on public.employees.employee_id = public.sales.sales_person_id
inner join products
    on public.sales.product_id = public.products.product_id
group by seller
order by income desc
limit 10;

"Второй отчет о продавцах,средняя выручка меньше средней выручкипо всем продавцам"
with tab1 as (
    select
        concat(
            public.employees.first_name, ' ', public.employees.last_name
        ) as seller,
        floor(avg(public.products.price * public.sales.quantity)) as income
    from public.employees
    inner join
        public.sales
        on public.employees.employee_id = public.sales.sales_person_id
    inner join
        public.products
        on public.sales.product_id = public.products.product_id
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
"Третий отчет содержит информацию о выручке по дням недели"
with dow as (
    select
        concat(public.employees.first_name, ' ', public.employees.last_name)
        as seller,
        to_char(public.sales.sale_date, 'day') as day_of_week,
        floor(sum(public.products.price * public.sales.quantity)) as income,
        extract(isodow from public.sales.sale_date) as day_week
    from public.employees
    inner join public.sales
        on public.employees.employee_id = public.sales.sales_person_id
    inner join public.products
        on public.sales.product_id = public.products.product_id
    group by seller, day_of_week, day_week
)

select
    seller,
    day_of_week,
    income
from dow
order by day_week, seller;

ШАГ 6
"отчет количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+"
select
    (
        case
            when public.customers.age between 16 and 25 then '16-25'
            when public.customers.age between 26 and 40 then '26-40'
            when public.customers.age > 40 then '40+'
        end
    )
    as age_category,
    count(public.customers.customer_id) as age_count
from public.customers
group by age_category
order by age_category;

"отчет по количеству уникальных покупателей и выручке, которую они принесли"
select
    to_char(public.sales.sale_date, 'YYYY-MM') as selling_month,
    count(distinct public.sales.customer_id) as total_customers,
    floor(sum(public.sales.quantity * public.products.price)) as income
from public.sales
inner join public.products
    on public.sales.product_id = public.products.product_id
group by selling_month
order by selling_month;

"отчет о покупателях, первая покупка которых была в ходе проведения акций"
with tab1 as (
    select
        public.sales.sale_date,
        concat(public.customers.first_name, ' ', public.customers.last_name)
        as customer,
        concat(public.employees.first_name, ' ', public.employees.last_name)
        as seller
    from public.sales
    inner join public.customers
        on public.sales.customer_id = public.customers.customer_id
    inner join public.employees
        on public.sales.sales_person_id = public.employees.employee_id
    inner join public.products
        on public.sales.product_id = public.products.product_id
    where public.products.price = 0
    group by
        customer,
        sales.sale_date,
        seller,
        customers.customer_id
    order by public.sales.customer_id, public.sales.sale_date
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
from rn_tab
where cid = 1;
