-- 1. Tables and Relationships
-- Users: Stores information about customers.
-- Products: Stores details of products available for purchase.
-- Orders: Stores order information (which user placed the order, when, and total amount).
-- Order Items: Tracks which products are included in each order.
-- Categories: Classifies products into categories (e.g., Electronics, Clothing).
-- Reviews: Stores product reviews submitted by users.
-- Sellers: Details of sellers who supply products.
-- Payments: Tracks payment transactions.
-- Delivery: Tracks delivery status for orders.
-- Coupons: Tracks discount coupons used by users.

-- 2. Schema Requirements

-- Delivery: table

-- delivery_id (Primary Key)
-- order_id (Foreign Key), delivery_status, delivery_date


-- creating users
create table user_id(
	id int primary key,
	name varchar(50) not null,
	email varchar(50) not null,
	phone bigint not null,
	address varchar(100) not null,
	registration_date date not null
);

-- add unique contraint
alter table user_id add constraint us_em_uk unique (email)

-- rename the table name
alter table user_id rename to users

insert into users values 
(1,'sri annamalai','srianna6778@gmail.com',8667245633,'tamil nadu, chennai','2024-05-20'),
(2,'sundar','sundarcham008@gmail.com',7358657641,'tamil nadu, sivakasi','2024-05-26'),
(3,'ebenezer','ebencrazyboy078@gmail.com',7358687641,'tamil nadu, madurai','2024-05-29'),
(4,'vivekanandan','vivek677@gmail.com',8148805657,'tamil nadu, chennai','2024-05-30'),
(5,'jayashree','jsselenophile2001@gmail.com',8667278909,'andhra, tada','2024-06-11'),
(6,'subash','subsmurugan001@gmail.com',8657892633,'tamil nadu, kancheepuram','2024-06-11'),
(7,'karan','karanc99@gmail.com',7653445633,'tamil nadu, theni','2024-07-25'),
(8,'aswin','aswinc99@gmail.com',6789545633,'tamil nadu, ramnad','2025-01-01'),
(9,'nithesh','nitheshc99@gmail.com',7654789097,'tamil nadu, chennai','2025-01-11'),
(10,'kale','kalec99@gmail.com',8893027666,'tamil nadu, madurai','2025-01-11')

--catogories table
create table catogories (
	id int primary key,
	name varchar(50) unique not null
)

-- insert into catogories
insert into catogories values 
(1,'ELECTRONICS'),
(2,'FASHION'),
(3,'FOOD'),
(4,'BEVERAGES'),
(5,'DIY'),
(6,'FURNITURES'),
(7,'PET CARE'),
(8,'BEAUTY AND PERSONAL CARE'),
(9,'BACK TO SCHOOL'),
(10,'KITCHEN ITEMS')

-- orders table:
create table orders(
	id int primary key,
	user_id int,
	order_date date,
	total_amount int,
	payment_status varchar(50),
	constraint fk_or_ui foreign key(user_id)
	references users(id)
)

-- add column coupon_id:
alter table orders add column coupon_id int not null,
add constraint fk_o_cid foreign key(coupon_id) REFERENCES Coupons (id);

-- remove not null
ALTER TABLE Orders
ALTER COLUMN coupon_id DROP NOT NULL;

-- create discount func
CREATE OR REPLACE FUNCTION apply_order_discount()
RETURNS TRIGGER AS $$
DECLARE
    discount_percentage DOUBLE PRECISION;
    discount_amount DOUBLE PRECISION;
BEGIN
    IF NEW.coupon_id IS NOT NULL THEN
        RAISE NOTICE 'Applying discount for order %', NEW.id;
        
        -- Check the discount percentage
        SELECT discount_per INTO discount_percentage FROM Coupons WHERE id = NEW.coupon_id;
        RAISE NOTICE 'Discount percentage: %', discount_percentage;
        
        -- Calculate the discount amount
        discount_amount := NEW.total_amount * (discount_percentage / 100);
        RAISE NOTICE 'Discount amount: %', discount_amount;
        
        -- Apply the discount
        NEW.total_amount := NEW.total_amount - discount_amount;
        RAISE NOTICE 'New total amount after discount: %', NEW.total_amount;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



-- Trigger to execute the function before inserting into Orders
DROP TRIGGER IF EXISTS trigger_apply_discount ON Orders;

CREATE TRIGGER trigger_apply_discount
BEFORE INSERT OR UPDATE ON Orders
FOR EACH ROW
WHEN (NEW.coupon_id IS NOT NULL)
EXECUTE FUNCTION apply_order_discount();




-- alter table data type
alter table orders alter column total_amount set data type DOUBLE PRECISION

-- insert into orders
insert into orders values 
(201,1,'2024-05-20',90000.00,'paid',701),
(202,2,'2024-05-26',210000.00,'paid',701),
(203,1,'2024-05-26',360.00,'paid',null),
(204,3,'2024-05-29',116000.00,'paid',701),
(205,4,'2024-05-30',3740.00,'paid',701),
(206,5,'2024-06-11',38000.00,'paid',701),
(207,6,'2024-06-11',340.00,'paid',701),
(208,7,'2024-07-25',2400.00,'paid',701),
(209,3,'2024-07-30',178.00,'paid',null),
(210,8,'2025-01-01',9478.00,'paid',701),
(211,9,'2025-01-11',3759.00,'paid',701),
(212,10,'2025-01-11',34000.00,'paid',701)

INSERT INTO Orders (id, user_id, order_date, total_amount, payment_status, coupon_id)
VALUES (213, 1, '2025-01-12', 1000.00, 'paid', 701);

DELETE FROM Orders
WHERE id = 213;

SELECT * FROM Coupons;
SELECT * FROM Orders;

-- create sellers:
create table sellers(
	id int primary key,
	name varchar(50) unique not null,
	email varchar(50) unique not null,
	phone bigint unique not null,
	address varchar(50) not null
)

-- insert into sellers:
insert into sellers values
(1,'Techworld','techworld@gmail.com',8790473663,'tamil nadu'),
(2,'zudio','zudio@gmail.com',8790468397,'tamil nadu'),
(3,'derby','derby@gmail.com',8668973663,'andhra'),
(4,'sky ec','skyec@gmail.com',7778907654,'tamil nadu'),
(5,'vasanth & co','vasnthco@gmail.com',9876507654,'kerala'),
(6,'chennai mart','cmart@gmail.com',5674893055,'tamil nadu'),
(7,'selva rathnam','selvarathnam@gmail.com',7778976893,'tamil nadu')

-- create table products:
create table products(
	id int primary key,
	name varchar(20) unique not null,
	description varchar(20) not null,
	price double precision not null,
	stock int not null,
	seller_id int not null,
	catogory_id int not null,
	constraint fk_p_sid foreign key(seller_id) references sellers(id),
	constraint fk_p_cid foreign key(catogory_id) references catogories(id)
)
-- alter data type
alter table products alter column description set data type varchar(50);

-- insert into products
insert into products values
(101,'lenovo laptop','i5 win12 12th gen',70000.00,5,1,1),
(102,'mac book','apple os',210000.00,7,1,1),
(103,'vivo y100','16gb ram 128gb rom',20000.00,10,5,1),
(104,'ps 5','play till you hate it',76000.00,4,1,1),
(105,'t-shirt','all varients',200.00,17,2,2),
(106,'shirts','all sizes',700.00,10,3,2),
(107,'sarees','all varients',2000.00,5,2,2),
(108,'led tv','43 inches',40000.00,8,5,1),
(109,'coke','energy drink',30.00,70,1,1),
(110,'wooden cot','king and queen size',45000.00,7,5,6),
(111,'sofa','soft cusioning',34000.00,3,7,6),
(112,'mittens','cat food',340.00,31,4,7),
(113,'tuna gravy','cat food',34.00,30,4,7),
(114,'pedegree','dog food',340.00,10,4,7),
(115,'lego toy','toy',2999.00,13,7,5),
(116,'r-c car','toy',1299.00,3,7,5),
(117,'rulled note book','school essentials',89.00,39,7,9),
(118,'oven','micro wave',7599.00,7,5,10),
(119,'tupperware box','kitchen essential',580.00,12,7,10),
(120,'rain cover','a best friend when it rains',1200.00,5,3,2),
(121,'oat meal','dont have to count cal',180.00,19,6,3)

-- create coupons;
create table coupons(
	id bigserial primary key,
	code varchar(20) not null unique,
	discount_per int default 10,
	expiry_date date
)
-- drop column from a table
alter table coupons drop column expiry_date

-- insert into coupouns:
insert into coupons values
(701,'WELCOME10',10),
(702,'FESTIVE20',20)

select * from orders

-- create func
create or replace function update_product_quantity()
returns trigger as
$$
begin
	if (select stock from products where id = new.product_id) < new.quantity then
		raise exception 'Insufficient stock for product ID %', NEW.product_id;
	end if;

	update products
	set stock = stock - new.quantity
	where id = new.product_id;

	return new;

end;
$$
language plpgsql;

-- Create the trigger for the Order_Items table
CREATE TRIGGER trigger_update_quantity
AFTER INSERT ON Order_Items
FOR EACH ROW
EXECUTE FUNCTION update_product_quantity();

-- create order_items:
create table order_items(
	id int primary key,
	order_id int,
	product_id int,
	quantity int not null,
	price double precision not null,
	constraint fk_oi_oi foreign key(order_id) references orders(id),
	constraint fk_oi_pi foreign key(product_id) references products(id)
)

-- insert into order_id
insert into order_items values
(301,201,101,1,70000.00),
(302,201,103,1,20000.00),
(303,202,102,1,210000.00),
(304,203,121,2,360.00),
(305,204,104,1,76000.00),
(306,204,108,1,40000.00),
(307,205,112,10,3400.00),
(308,205,113,10,340.00),
(309,206,111,1,34000.00),
(310,206,106,2,4000.00),
(311,207,114,1,340.00),
(312,208,120,2,2400.00),
(313,209,117,2,178.00),
(314,210,118,1,7599.00),
(315,210,116,1,1299.00),
(316,210,119,1,580.00),
(317,211,115,1,2999.00),
(318,211,119,1,580.00),
(319,211,121,1,180.00),
(320,212,111,1,34000.00)


SELECT 
    oi.id AS order_items_id,
	o.user_id,
    -- u.name, 
    o.order_date
    -- r.reveiw_date 
FROM orders o 
INNER JOIN order_items oi 
    ON o.id = oi.order_id
LEFT JOIN users u 
    ON u.id = o.user_id
LEFT JOIN reviews r 
    ON u.id = r.user_id;



-- create table reviews
create table reviews(
	id int primary key,
	user_id int references users(id),
	product_id int references products(id),
	rating int not null,
	reveiw varchar(50) not null,
	reveiw_date date
)

-- insert into reviews
insert into reviews values
(401,1,101,5,'Excellent delevery and excellent laptop','2024-05-26'),
(402,1,103,5,'Excellent delevery and excellent mobile','2024-05-26'),
(403,2,102,3,'fast delevery but packing need to be improved','2024-05-28'),
(404,5,111,5,'sofas cussioning is exelelent loved it','2024-06-10'),
(405,4,113,1,'cat food is out dated need replacement','2024-06-10'),
(406,1,101,5,'Excellent delevery and excellent laptop','2024-06-10'),
(407,10,111,1,'didnt receive my sofa worst service','2025-01-14')


-- create table payments table 
CREATE TABLE Payments (
    id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    actual_amount DOUBLE PRECISION,
    discounted_amount DOUBLE PRECISION,
    payment_date DATE,
    payment_method VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES Orders (id)
);

-- insert into payments:
insert into payments values
(501,201,90000.00,81000.00,'2024-05-20','debit card'),
(502,202,210000.00,189000.00,'2024-05-26','credit card'),
(503,203,360.00,360.00,'2024-05-26','upi'),
(504,204,116000.00,104400.00,'2024-05-29','credit card'),
(505,205,3740.00,3366.00,'2024-05-30','upi'),
(506,206,38000.00,34200.00,'2025-06-11','upi'),
(507,207,340.00,306.00,'2024-06-11','upi'),
(508,208,2400.00,2160.00,'2024-07-25','upi'),
(509,209,178.00,178.00,'2024-07-30','upi'),
(510,210,9478.00,8530.20,'2025-01-01','upi'),
(511,211,3759.00,3383.10,'2025-01-11','upi'),
(512,212,34000.00,30600.00,'2025-01-11','debit card')

-- create table delivery:
create table delivery(
	id int primary key,
	order_items_id int references order_items(id),
	delivery_status varchar(20) not null,
	delivery_date date
)

select * from order_items

-- insert into delivery
insert into delivery values
(601,301,'delivered','2024-05-26'),
(602,302,'delivered','2024-05-26'),
(603,303,'delivered','2024-05-28'),
(604,306,'delivered','2024-06-04'),
(605,305,'delivered','2024-06-08'),
(606,304,'delivered','2024-06-10'),
(607,308,'delivered','2024-06-10'),
(608,307,'delivered','2024-06-11'),
(609,310,'delivered','2024-06-15'),
(610,309,'delivered','2024-06-16'),
(611,311,'delivered','2024-06-16'),
(612,312,'delivered','2024-07-30'),
(613,313,'delivered','2024-08-03'),
(614,314,'delivered','2025-01-04'),
(615,315,'delivered','2025-01-04'),
(616,316,'delivered','2025-01-05'),
(617,317,'delivered','2025-01-14'),
(618,318,'delivered','2025-01-15'),
(619,319,'delivered','2025-01-15'),
(620,320,'pending',null)

-- 20 logical questions

-- 1 total numbers of orders placed by each users

SELECT user_id, COUNT(id) AS total_orders
FROM Orders
GROUP BY user_id
ORDER BY total_orders DESC;

-- 2 List all users who haven’t placed any orders yet

SELECT u.id, u.name FROM users u left join orders o on o.user_id = u.id WHERE o.id IS NULL

-- 3 Find the most popular product based on the total quantity ordered

SELECT p.id, p.name, SUM(oi.quantity) AS total_sold
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.id
GROUP BY p.id, p.name
ORDER BY total_sold DESC
LIMIT 1;

-- 4 Find the total discount provided for all orders that used a specific coupon

SELECT c.code, SUM(o.total_amount * (c.discount_per / 100.0)) AS total_discount
FROM Orders o
JOIN Coupons c ON o.coupon_id = c.id
GROUP BY c.code
ORDER BY total_discount DESC;

-- 5 Identify the most frequently used coupon.

SELECT coupon_id, COUNT(*) AS usage_count
FROM Orders
WHERE coupon_id IS NOT NULL
GROUP BY coupon_id
ORDER BY usage_count DESC
LIMIT 1;

-- 6 Calculate the total revenue collected in the current month.

SELECT SUM(discounted_amount) AS total_revenue
FROM Payments
WHERE EXTRACT(MONTH FROM payment_date) = EXTRACT(MONTH FROM CURRENT_DATE)
AND EXTRACT(YEAR FROM payment_date) = EXTRACT(YEAR FROM CURRENT_DATE);

-- 7 Find all payments made using a specific payment method (e.g., "Credit Card").

SELECT * FROM Payments
WHERE payment_method = 'credit card';

-- 8 List all the products purchased in a specific order.

SELECT oi.order_id, p.name, oi.quantity, oi.price
FROM Order_Items oi
JOIN Products p ON oi.product_id = p.id
WHERE oi.order_id = 203;

-- 9  Calculate the total amount spent by each user on their orders.

SELECT o.user_id, SUM(o.total_amount) AS total_spent
FROM Orders o
GROUP BY o.user_id
ORDER BY total_spent DESC;

-- 10 Identify products with no remaining stock.

SELECT * FROM Products WHERE stock = 0;

-- 11 List all products priced above the average product price.

SELECT * FROM Products
WHERE price > (SELECT AVG(price) FROM Products);

-- 12 Find all orders that are pending delivery.

SELECT * FROM Delivery
WHERE delivery_status = 'pending';

-- 13 Calculate the average delivery time for all orders.

SELECT AVG(d.delivery_date - o.order_date) AS avg_delivery_days
FROM Delivery d
JOIN Order_Items oi ON d.order_items_id = oi.id  -- Linking Deliveries with Order_Items
JOIN Orders o ON oi.order_id = o.id;            -- Getting order_date from Orders


-- 14 For each user, find the total number of products purchased (across all orders).

SELECT o.user_id, SUM(oi.quantity) AS total_products_purchased
FROM Orders o
JOIN Order_Items oi ON o.id = oi.order_id
GROUP BY o.user_id
ORDER BY total_products_purchased DESC;

-- 15 Find the most expensive single item ever purchased.

SELECT * FROM Order_Items
ORDER BY price DESC
LIMIT 1;

-- 16 List details of all orders, including user name, product names, and total amount.

SELECT o.id AS order_id, u.name AS user_name, p.name AS product_name, oi.quantity, p.price
FROM Orders o
JOIN Users u ON o.user_id = u.id
JOIN Order_Items oi ON o.id = oi.order_id
JOIN Products p ON oi.product_id = p.id
ORDER BY o.id;

-- 17 Identify users who have used the same coupon more than once.

SELECT user_id, coupon_id, COUNT(*) AS usage_count
FROM Orders
WHERE coupon_id IS NOT NULL
GROUP BY user_id, coupon_id
HAVING COUNT(*) > 1;

-- 18 Delete all expired coupons from the Coupons table.

DELETE FROM Coupons WHERE expiry_date < CURRENT_DATE;

-- 19 Validate if any order has a total amount mismatched with the sum of its order items.

SELECT o.id AS order_id, o.total_amount, SUM(oi.price * oi.quantity) AS calculated_amount
FROM Orders o
JOIN Order_Items oi ON o.id = oi.order_id
GROUP BY o.id, o.total_amount
HAVING o.total_amount <> SUM(oi.price * oi.quantity);

-- 20 Identify the top 3 customers who have spent the most money on orders.

SELECT u.id AS user_id, u.name, SUM(o.total_amount) AS total_spent
FROM Users u
JOIN Orders o ON u.id = o.user_id
GROUP BY u.id, u.name
ORDER BY total_spent DESC
LIMIT 3;










































