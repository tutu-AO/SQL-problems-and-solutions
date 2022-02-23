USE NorthwindFull;

/*1. which shipper do we have?*/
select * from shippers;

/*2. Certain fields from Categories?*/
select category_id, category_name, description from categories;

/*3. Sales Representative?*/
select employee_id, last_name, first_name, title from employees
where title = 'Sales Representative';

/*4. Sales Representative in the US?*/
select employee_id, last_name, first_name, title from employees
where title="Sales Representative" and country="USA";

/*5. Order placed by specific employeeid?*/
select order_id, order_date, employee_id from orders 
where employee_id=5;

/*6. Supplier and ContactTitles?*/
select supplier_id, company_name, contact_title from suppliers
where contact_title <> " Marketing Manager ";

/*7. Product with "queso" productName?*/
select product_id, product_name from products
where product_name LIKE '%Queso%';

/*8. Order shipping to france or belgium?*/
select order_id, order_date, ship_country from orders
where ship_country="France" or ship_country="Belgium";

/*9. Order shipping to any country in Latin America?*/
select order_id, order_date, ship_country from orders
where ship_country in ("Argentina");

/*10. Employee in order of age?*/
select employee_id, last_name, first_name, birth_date from employees
order by birth_date desc;

/*11. Showing only the date with Datetime Field?*/
select employee_id, last_name, first_name, date_format(birth_date, '%Y-%m-%d') as birth_date from employees;

/*12. Employees fullname?*/
select employee_id, last_name, first_name, CONCAT(last_name, " ", first_name) as fullName from employees;

/*13. OrderDetails amount per line item?*/
select order_id, product_id, unit_price, quantity, (unit_price * quantity) as totalPrice from order_details
order by order_id and product_id;

/*14. How many customers?*/
select count(*) as totalNumOfCustomers from customers;

/*15. When was the first order*/
select Max(date_format(order_date, '%Y-%m-%d')) as firstDate from orders;

/*16. Countries where there are customer*/
select  country from customers
group by country;

/*17. ContactTile for customer*/
select count(*) as countForEach, contact_title from customers
group by contact_title;

/*18. Products with associated supplier names*/
select product_id, product_name, suppliers.company_name from products
join suppliers on products.supplier_id = suppliers.supplier_id
order by product_id;

/*19. Order and the shipper that was used*/
select order_id, date_format(order_date, '%Y-%m-%d') as dateOnly, company_name from orders
join shippers on orders.shipper_id = shippers.shipper_id
where order_id < 10300
order by order_id;

/*20. Categories and the product in each categories*/
select count(*) as totalProduct, category_name
from products join categories 
on products.category_id = categories.category_id
group by category_name
order by totalProduct desc;

/*21. Total Customer Per country/city*/
select country, city, count(*) as totalCustomers from customers
group by country, city
order by totalCustomers desc;

/*22. Product that need reordering*/
select product_id, product_name, units_in_stock, reorder_level from products
where units_in_stock < reorder_level
order by product_id;

/*23. Products that need reordering continued*/
select product_id, product_name, units_in_stock, units_on_order, reorder_level, discontinued from products
where units_in_stock + units_on_order <= reorder_level and discontinued = 0;

/*24. customers list by region*/
select customer_id, contact_name, region
from customers
order by case when region is null then 1 else 0 end, region;

/*25.High Freight Charges*/
select ship_country, avg(freight) as avgFreight from orders
group by ship_country
order by avgFreight desc
limit 3;

/*26. High Freight charges - 1996*/
select ship_country, avg(freight) as avgFreight from orders
where date_format(order_date, '%Y') > 1996
group by ship_country
order by avgFreight desc
limit 3;

/*27. High Freight charges with between 1996*/
select ship_country, avg(freight) as avgFreight from orders
where order_date between '1996-01-01' and '1996-12-31'
group by ship_country
order by avgFreight desc
limit 3;

/*28. High Freight charges - last year*/
select ship_country, avg(freight) as avgFreight from orders
where order_date between (Select DATE_ADD((Select Max(order_date) from orders), INTERVAL -1 YEAR)) and (Select Max(order_date) from orders)
group by ship_country
order by avgFreight desc
limit 3;

/*29. Employee/orderDetail report*/
select employees.employee_id, employees.last_name, orders.order_id, products.product_name, order_details.quantity 
from order_details 
inner join products on order_details.product_id = products.product_id
inner join orders on order_details.order_id = orders.order_id
inner join employees on orders.employee_id = employees.employee_id
order by orders.order_id, products.product_id;

/*30. Customers with no orders*/
select customers.customer_id as CUSTOMER, orders.customer_id as NO_ORDER
from orders right join customers 
on orders.customer_id = customers.customer_id
where orders.customer_id is null;

/*31. Customers with no orders for employeeId*/
select customers.customer_id as customer, orders.customer_id as no_order
from orders right join customers 
on orders.customer_id = customers.customer_id and orders.employee_id = 4
where orders.customer_id is null;

/*32. High-value customers*/
select customers.customer_id, customers.company_name, orders.order_id, round(sum(order_details.unit_price * order_details.quantity), 2) as amount
from order_details 
join orders on order_details.order_id = orders.order_id
join customers on orders.customer_id = customers.customer_id
where date_format(orders.order_date, '%Y') > 1997
group by customers.customer_id, customers.company_name, orders.order_id
having amount >= 10000
order by amount desc;

/*33. High-value customers - total orders*/
select customers.customer_id, customers.company_name, round(sum(order_details.unit_price * order_details.quantity), 2) as amount
from order_details 
join orders on order_details.order_id = orders.order_id
join customers on orders.customer_id = customers.customer_id
where date_format(orders.order_date, '%Y') > 1997
group by customers.customer_id, customers.company_name
having amount >= 15000
order by amount desc;

/*34. High-value customers - with discount*/ 
select customers.customer_id, customers.company_name, round(sum(order_details.unit_price * order_details.quantity), 2) as amount, 
round(sum(order_details.unit_price * order_details.quantity * (1 - order_details.discount)), 2) as withDiscount  /*why (1-discount)*/
from order_details 
join orders on order_details.order_id = orders.order_id
join customers on orders.customer_id = customers.customer_id
where date_format(orders.order_date, '%Y') > 1997
group by customers.customer_id, customers.company_name
having withDiscount >= 10000
order by withDiscount desc;

/*35. Month-end orders*/
select employee_id, order_id, order_date from orders
where order_date = last_day(order_date) /*use EOMONTH if you are using sql-server*/
Order by employee_id, order_id;

/*36. Orders with many line items*/
select orders.order_id, count(order_details.order_id) as totalOrderDetails from order_details
join orders on order_details.order_id = orders.order_id
group by orders.order_id
order by totalOrderDetails desc
limit 10;
