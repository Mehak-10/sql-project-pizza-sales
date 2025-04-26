CREATE DATABASE PIZZAWINGS;
drop database pizzawings;
USE PIZZAWINGS;
CREATE TABLE ORDERS(
  order_id int not null,
  order_date date not null,
  order_time time not null,
  primary key(order_id)
);

CREATE TABLE ORDERS_DETAILS(
  order_details_id int not null,
  order_id int not null,
  pizza_id text not null,
  quantity int not null,
  primary key(order_details_id)
);

-- 01 Retrieve the total number of orders placed.

SELECT COUNT(ORDER_ID)AS TOTAL_ORDERS FROM ORDERS;

-- 02 Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(ORDERS_DETAILS.quantity * PIZZAS.price),
            2) AS Total_Sales
FROM
    orders_details
        JOIN
    pizzas ON PIZZAS.pizza_id = ORDERS_DETAILS.pizza_id ;
    
-- 03 Identify the hightest-priced pizza

SELECT 
    PIZZA_TYPES.name, PIZZAS.price
FROM
    PIZZA_TYPES
        JOIN
    PIZZAS ON PIZZA_TYPES.pizza_type_id = PIZZAS.pizza_type_id
ORDER BY PIZZAS.price DESC
LIMIT 1;

-- 04 Identify the most common pizza size ordered.

SELECT 
    pizzas.size, COUNT(orders_details.order_details_id) AS ORDER_COUNT
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY PIZZAS.SIZE
ORDER BY ORDER_COUNT DESC;

-- 05 List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- 06 Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- 07 Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS HOUR, COUNT(order_id) AS ORDER_COUNT
FROM
    ORDERS
GROUP BY HOUR(order_time);

-- 08 Join relevant tables to find the category-wise distribution of pizzas.

SELECT category, COUNT(name) 
FROM pizza_types
GROUP BY category;

-- 09 Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(orders_details.quantity) AS quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    
-- 10 Determine the top 3 most ordered pizza types based on revenue.

SELECT pizza_types.name,
SUM(orders_details.quantity * pizzas.price) AS Revenue
FROM pizza_types JOIN pizzas
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN orders_details
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name ORDER BY Revenue DESC LIMIT 3;

-- 11 Calculate the percentage contribution of each pizza type to total revenue.

SELECT pizza_types.Category,
ROUND(SUM(orders_details.quantity * pizzas.price) / ( SELECT 
    ROUND(SUM(ORDERS_DETAILS.quantity * PIZZAS.price),
            2) AS Total_Sales
FROM
    orders_details
        JOIN
    pizzas ON PIZZAS.pizza_id = ORDERS_DETAILS.pizza_id )*100,2)AS Revenue
FROM pizza_types JOIN pizzas
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN orders_details
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category ORDER BY Revenue DESC;

-- 12 Analyze the cumulative revenue generated over time.

SELECT order_date,
SUM(Revenue) OVER (ORDER BY order_date) AS cumulative_Revenue
FROM
(SELECT orders.order_date,
SUM(orders_details.quantity * pizzas.price) AS revenue
FROM orders_details JOIN pizzas
ON orders_details.pizza_id = pizzas.pizza_id
JOIN orders
ON orders.order_id = orders_details.order_id
GROUP BY orders.order_date) AS Sales;

-- 13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name,revenue
FROM
(SELECT category, name, revenue,
RANK() OVER (partition by category ORDER BY revenue desc) AS rn
FROM
(SELECT pizza_types.category , pizza_types.name,
SUM((orders_details.quantity) * pizzas.price) as revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category , pizza_types.name) AS a) AS b
WHERE rn<=3;