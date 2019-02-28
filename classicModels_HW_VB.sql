USE classicmodels;
-- before the join , lets see how big our tables are.
SELECT count(*) FROM customers; -- 122
SELECT count(*) FROM employees; -- 23
SELECT count(*) FROM offices; -- 7
SELECT count(*) FROM orderdetails; -- 2996
SELECT count(*) FROM orders; -- 326
SELECT count(*) FROM payments; -- 273
SELECT count(*) FROM productLines; -- 7
SELECT count(*) FROM products; -- 110



-- ------------------ JOINS ------------------------

-- ________________ Layer "Employees" _________________
-- on diagramm I created layers of related tables. First lets look at the  layer "Employees" which include two tables: employees(23 records) & offices(7 records). when we join them, the number of records should not be more than 23.

-- SELECT count(*)
SELECT 
    *
FROM
    employees e
        JOIN
    offices o ON e.officeCode = o.officeCode;



-- ________________ Layer "Orders & Products" _________________

-- Layer "Orders" include four tables: 
-- orders (326), orderdetails (2996), products (110), productlines (7). the result without duplicates should be 2996

-- SELECT count(*) -- 2996
SELECT 
    *
FROM
    orderdetails od
        JOIN
    orders ord ON od.orderNumber = ord.orderNumber
        JOIN
    products pr ON od.productCode = pr.productCode
        JOIN
    productlines pl ON pr.productLine = pl.productLine;



-- Now lets Join customers with all layers to make one big table. 

/*2996 (do not include payments table because it creates duplicates)
JOIN payments p on c.customerNumber = p.customerNumber where c.customerNumber = 141 */

-- SELECT COUNT(*)  -- 2996
SELECT *
FROM
    customers c
        LEFT JOIN        
    employees e ON salesRepEmployeeNumber = e.employeeNumber
        JOIN
    offices o ON e.officeCode = o.officeCode
        JOIN
    (SELECT 
        ord.*,
            od.productCode,
            od.quantityOrdered,
            od.priceEach,
            od.orderLineNumber,
            pr.productName,
            pr.productLine,
            pr.productScale,
            pr.productVendor,
            pr.productDescription,
            pr.quantityInStock,
            pr.buyPrice,
            pr.MSRP,
            pl.textDescription,
            pl.htmlDescription,
            pl.image
    FROM
        customers c
    JOIN orders ord ON c.customerNumber = ord.customerNumber
    JOIN orderdetails od ON ord.orderNumber = od.orderNumber
    JOIN products pr ON od.productCode = pr.productCode
    JOIN productlines pl ON pr.productLine = pl.productLine) ordersAndProd  
    ON c.customerNumber = ordersAndProd.customerNumber;
    
    
USE classicmodels;    
    -- SELECT count(*)
SELECT *
FROM
    customers c
		LEFT JOIN
	(SELECT
        e.*,
        o.city,
        o.phone,
        o.addressLine1,
        o.addressLine2,
        o.state,
        o.country,
        o.postalCode,
        o.territory
        FROM customers c
		JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber
        JOIN offices o ON e.officeCode = o.officeCode
        ) EmployeesLayer
        ON c.salesRepEmployeeNumber = EmployeesLayer.employeeNumber
        LEFT JOIN
    (SELECT 
        ord.*,
            od.productCode,
            od.quantityOrdered,
            od.priceEach,
            od.orderLineNumber,
            pr.productName,
            pr.productLine,
            pr.productScale,
            pr.productVendor,
            pr.productDescription,
            pr.quantityInStock,
            pr.buyPrice,
            pr.MSRP,
            pl.textDescription,
            pl.htmlDescription,
            pl.image
    FROM
        customers c
    JOIN orders ord ON c.customerNumber = ord.customerNumber
    JOIN orderdetails od ON ord.orderNumber = od.orderNumber
    JOIN products pr ON od.productCode = pr.productCode
    JOIN productlines pl ON pr.productLine = pl.productLine) ordersAndProdLayer  
    ON c.customerNumber = ordersAndProdLayer.customerNumber;
    





#________________ 3 Tables _________________

######## Payments ######## 122, 273
-- renaming columns to prevent duplicates in column names
ALTER table payments change customerNumber pay_customerNumber int(11); 

drop table yourBiz.Payments;
CREATE TABLE yourBiz.Payments AS
-- SELECT count(*)-- 273
SELECT *
FROM customers c
 JOIN
payments p ON c.customerNumber = p.pay_customerNumber ;
-- where c.customerNumber = 169;



######## Employees ######## 122, 23, 7

-- renaming columns to prevent duplicates in column names
ALTER table offices change city officeCity varchar(50) DEFAULT NULL; 
ALTER table offices change phone officePhone varchar(50) DEFAULT NULL;
ALTER table offices change addressLine1 office_addressLine1 varchar(50) DEFAULT NULL;
ALTER table offices change addressLine2 office_addressLine2 varchar(50) DEFAULT NULL;
ALTER table offices change state office_state varchar(50) DEFAULT NULL;
ALTER table offices change country office_country varchar(50) DEFAULT NULL;
ALTER table offices change postalCode office_postalCode varchar(50) DEFAULT NULL;


drop table yourBiz.Employees;
-- CREATE TABLE yourBiz.Employees AS
SELECT count(*) -- 122
-- SELECT *
FROM
    customers c
        LEFT JOIN
    (SELECT 
        e.*,
            o.officeCity,
            o.officePhone,
            o.office_addressLine1,
            o.office_addressLine2,
            o.office_state,
            o.office_country,
            o.office_postalCode,
            o.territory
    FROM
        employees e
    JOIN offices o ON e.officeCode = o.officeCode) Employees 
    ON c.salesRepEmployeeNumber = Employees.employeeNumber ;
    -- where c.customerNumber = 339;


######## Orders & Products ######## 122, 326, 2996, 110, 7

-- renaming columns to prevent duplicates in column names
ALTER table orders change customerNumber  orderCustomerNumber int(11) DEFAULT NULL; 


drop table yourBiz.ordersAndProd;
CREATE TABLE yourBiz.ordersAndProd AS
-- SELECT COUNT(*) -- 2996
SELECT *
FROM
    customers c
        JOIN
    (SELECT 
            ord.*,
            od.productCode,
            od.quantityOrdered,
            od.priceEach,
            od.orderLineNumber,
            pr.productName,
            pr.productLine,
            pr.productScale,
            pr.productVendor,
            pr.productDescription,
            pr.quantityInStock,
            pr.buyPrice,
            pr.MSRP,
            pl.textDescription,
            pl.htmlDescription,
            pl.image
    FROM
        customers c
     JOIN orders ord ON c.customerNumber = ord.orderCustomerNumber
     JOIN orderdetails od ON ord.orderNumber = od.orderNumber
     JOIN products pr ON od.productCode = pr.productCode
     JOIN productlines pl ON pr.productLine = pl.productLine) ordersAndProdLayer 
    ON c.customerNumber = ordersAndProdLayer.orderCustomerNumber; 
   -- where c.customerNumber = 339;


USE yourBiz;
SELECT count(*) FROM Employees; -- 122
SELECT count(*) FROM ordersAndProd; -- 2996
SELECT count(*) FROM Payments; -- 273




-- select *   
select count(*) 
from yourBiz.ordersAndProd
where ordersAndProd.orderNumber in (10183,10307);-- 21

-- 2996
-- select *   
select count(*) 
from yourBiz.ordersAndProd p
where  p.productLine IS NOT NULL;


select *  
-- select count(DISTINCT(orderNumber))   
from yourBiz.ordersAndProd  
where ordersAndProd.customerNumber = 339;-- 2


-- 100
-- select *  
select count(*) 
from yourBiz.Employees e 
WHERE e.SalesRepEmployeeNumber = e.employeeNumber;



############################################################################################################
#########       1.  how many vendors, product lines, and products exist in the database?          ##########
############################################################################################################
#--------- vendors ------------------------

SELECT 
    COUNT(DISTINCT productVendor)
FROM
    ordersAndProd; -- 13

-- names of the vendors:
SELECT DISTINCT
    (productVendor)
FROM
    ordersAndProd; 
/*
1.'Classic Metal Creations'
2. 'Red Start Diecast'
3. 'Gearbox Collectibles'
4. 'Carousel DieCast Legends'
5.'Highway 66 Mini Classics'
6. 'Welly Diecast Productions'
7. 'Motor City Art Classics'
8. 'Autoart Studio Design'
9. 'Exoto Designs'
10. 'Studio M Art Models'
11. 'Unimax Art Galleries'
12. 'Min Lin Diecast'
13. 'Second Gear Diecast'
*/
#--------- product lines ------------------------
SELECT 
    COUNT(DISTINCT (productLine))
FROM
    ordersAndProd; -- 7


#--------- products ------------------------
SELECT 
    COUNT(DISTINCT productName)
FROM
    ordersAndProd; -- 109

SELECT DISTINCT
    (productName)
FROM
    ordersAndProd;




############################################################################################################
#########         2.  what is the average price, buy price, MSRP per vendor?                      ##########
############################################################################################################

SELECT 
    productVendor,
    ROUND(AVG(priceEach), 2) AS AvgProdPrice,
    ROUND(AVG(buyPrice), 2) AS AvgBuyPrice,
    ROUND(AVG(MSRP), 2) AS Avg_MSRP
FROM
    ordersAndProd
GROUP BY productVendor;




############################################################################################################
#########         4.  what product was sold the most?                                             ##########
############################################################################################################

SELECT 
    productCode,
    productName,
    MAX(quantityOrdered) AS QuantitySold
FROM
    ordersAndProd
GROUP BY productCode , productName
ORDER BY QuantitySold DESC
LIMIT 1;
--  productCode,  productName,             QuantitySold
--  S12_4675,     '1969 Dodge Charger',    97





############################################################################################################
#########         5.  how much money was made between buyPrice and MSRP?                          ##########
############################################################################################################

SELECT 
    SUM(buyPrice - MSRP) AS difference
FROM
    ordersAndProd;
--   difference
--   -138951.78
  



############################################################################################################
#########         6.  which vendor sells 1966 Shelby Cobra?                                       ##########
############################################################################################################

SELECT DISTINCT
    (productVendor), productName
FROM
    ordersAndProd
WHERE
    productName LIKE '1966 Shelby Cobra%';

--  productVendor,                     productName
--  Carousel DieCast Legends,          1966 Shelby Cobra 427 S/C






############################################################################################################
#########         7. which vendor sells more products?                                            ##########
############################################################################################################

SELECT 
    productVendor, MAX(quantityOrdered) AS sold
FROM
    ordersAndProd
GROUP BY productVendor
ORDER BY sold DESC
LIMIT 1;
--  productVendor,               sold
--  Welly Diecast Productions,   97







############################################################################################################
#########         8.  which product is the most and least expensive?                              ##########
############################################################################################################

#-------------- mostExpensive -----------
SELECT 
    productCode, productName, MAX(priceEach) AS price
FROM
    ordersAndProd
GROUP BY productCode , productName
ORDER BY price DESC
LIMIT 1; 
--  productCode, productName,                 price
--  S10_1949,    1952 Alpine Renault 1300,    214.30




#-------------- leastExpensive -----------

SELECT 
    productCode, productName, MIN(priceEach) AS price
FROM
    ordersAndProd
GROUP BY productCode , productName
ORDER BY price ASC
LIMIT 1;
--  productCode, productName,                    price
--  S24_1937,    1939 Chevrolet Deluxe Coupe,    26.55







############################################################################################################
#########         9.  which product has the most quantityInStock?                                 ##########
############################################################################################################

SELECT 
    productCode,
    productName,
    MAX(quantityInStock) AS InStock
FROM
    ordersAndProd
GROUP BY productCode , productName
ORDER BY InStock DESC
LIMIT 1;
--   productCode,   productName,        InStock
--   S12_2823,      2002 Suzuki XREO,   9997






############################################################################################################
#########         10.  list all products that have quantity in stock less than 20                 ##########
############################################################################################################
SELECT DISTINCT
    productCode, productName, quantityInStock
FROM
    ordersAndProd
WHERE
    quantityInStock < 20
ORDER BY quantityInStock;
--   productCode,      productName,                 quantityInStock
--      S24_2000,      1960 BSA Gold Star DBD34,    15






############################################################################################################
#########         11.  which customer has the highest and lowest credit limit?                    ##########
############################################################################################################
SELECT 
    customerNumber,
    customerName,
    MAX(creditLimit) AS highestCreditLimit
FROM
    ordersAndProd
GROUP BY customerNumber , customerName
ORDER BY highestCreditLimit DESC
LIMIT 1;
--  customerNumber,               customerName,              highestCreditLimit
--            141 ,     'Euro+ Shopping Channel',            227600.00




SELECT 
    customerNumber,
    customerName,
    MAX(creditLimit) AS lowestCreditLimit
FROM
    ordersAndProd
GROUP BY customerNumber , customerName
ORDER BY lowestCreditLimit ASC
LIMIT 1;

--  customerNumber,        customerName,           lowestCreditLimit
--             219,       'Boards & Toys Co.',     11000.00





############################################################################################################
#########         12.  rank customers by credit limit                                             ##########
############################################################################################################

SELECT DISTINCT customerNumber, customerName, 
	RANK() OVER (ORDER BY creditLimit DESC) as `rank`
FROM 
	ordersAndProd 
ORDER BY `rank`ASC;
--  customerNumber,     customerName,            rank
--  '          141,     Euro+ Shopping Channel,  1




############################################################################################################
#########         13. list the most sold product by city                                          ##########
############################################################################################################

SELECT 
    city,
    productCode,
    productName,
    MAX(quantityOrdered) AS quantitySold
FROM
    ordersAndProd
GROUP BY city , productCode , productName
ORDER BY quantitySold DESC
LIMIT 1;
--        city,    productCode,     productName,             quantitySold
--  Strasbourg,    S12_4675,       '1969 Dodge Charger',     97





############################################################################################################
#########         14.  customers in what city are the most profitable to the company?             ##########
############################################################################################################

SELECT 
    country, city, (priceEach * quantityOrdered) AS Profit
FROM
    ordersAndProd
ORDER BY Profit DESC
LIMIT 1;
--  country,      city,          Profit
--       UK,     Liverpool,      11503.14




############################################################################################################
#########         15.  what is the average number of orders per customer?                         ##########
############################################################################################################

SELECT 
    COUNT(DISTINCT e.customerNumber) AS totalcustomers,
    COUNT(o.orderNumber) AS totalOrders,
    ROUND((COUNT(o.orderNumber) / COUNT(DISTINCT e.customerNumber))) AS AvgOrdersPerCust
FROM
    ordersAndProd o
        RIGHT JOIN
    Employees e ON o.customerNumber = e.customerNumber;
--  totalcustomers,    totalOrders,    AvgOrdersPerCust
--       122,           2996,           25




############################################################################################################
#########         16.  who is the best customer?                                                  ##########
############################################################################################################

SELECT 
    customerNumber, customerName, SUM(amount) AS spentMoney
FROM
    Payments
GROUP BY customerNumber , customerName
ORDER BY spentMoney DESC
LIMIT 1;
--  customerNumber,      customerName,              spentMoney
--      141,            'Euro+ Shopping Channel',   715738.98





############################################################################################################
#########       17. customers without payment                                                     ##########
############################################################################################################

SELECT 
    (SELECT 
            COUNT(DISTINCT customerNumber)
        FROM
            Employees) - (SELECT 
            COUNT(DISTINCT customerNumber)
        FROM
            Payments) AS withoutPayment;

--  withoutPayment
--       '24'




############################################################################################################
#########        18.  what is the average number of days before the order date and ship date?     ##########
############################################################################################################

SELECT 
    ROUND(AVG(DATEDIFF(shippedDate, orderDate))) AS `Avg days before the order`
FROM
    ordersAndProd;
-- 4




############################################################################################################
#########         19.  sales by year                                                              ##########
############################################################################################################

SELECT 
    YEAR(orderDate) AS `year`,
    SUM(quantityOrdered) AS totalOrders,
    SUM(quantityOrdered * priceEach) AS sales
FROM
    ordersAndProd
GROUP BY `year`;

--  year,  totalOrders,  sales
-- '2003', '36439',     '3317348.39'
-- '2004', '49487',     '4515905.51'
-- '2005', '19590',     '1770936.71'




############################################################################################################
#########         20.  how many orders are not shipped?                                           ##########
############################################################################################################

SELECT 
    YEAR(orderDate) AS `year`,
    COUNT(shippedDate) AS shipped,
    COUNT(orderDate) AS ordered,
    (COUNT(orderDate) - COUNT(shippedDate)) AS notShipped
FROM
    ordersAndProd
GROUP BY `year`;

--  year,   shipped,   ordered,   notShipped
--  2003,      1036,      1052,      16
--  2004,      1375,      1421,      46
--  2005,       444,       523,      79




############################################################################################################
#########   21. list all employees by their (full name: first + last) in alpabetical order        ##########
############################################################################################################

SELECT DISTINCT
    (employeeNumber),
    CONCAT(firstName, ' ', lastName) AS employeeName
FROM
    Employees
ORDER BY employeeName ASC;

-- employeeNumber, employeeName
-- 1611, 			Andy Fixter
-- 1504,  			Barry Jones
-- 1286, 			Foon Yue Tseng
-- 1323, 			George Vanauf
-- 1370, 			Gerard Hernandez
-- 1188, 			Julie Firrelli
-- 1501, 			Larry Bott
-- 1165, 			Leslie Jennings
-- 1166, 			Leslie Thompson
-- 1337, 			Loui Bondur
-- 1621, 			Mami Nishi
-- 1702, 			Martin Gerard
-- 1401, 			Pamela Castillo
-- 1612, 			Peter Marsh
-- 1216, 			Steve Patterson




############################################################################################################
#########         22.  list of employees  by how much they sold in 2003?                          ##########
############################################################################################################

SELECT 
    YEAR(paymentDate) AS `year`,
    salesRepEmployeeNumber,
    SUM(amount) AS sold
FROM
    Payments
WHERE
    paymentDate LIKE '2003%'
GROUP BY `year` , salesRepEmployeeNumber
ORDER BY sold DESC;

-- year, salesRepEmployeeNumber, sold
-- 2003, 1165, 					413219.85
-- 2003, 1401, 					317104.78
-- 2003, 1370, 					295246.44
-- 2003, 1621, 					267249.40
-- 2003, 1501, 					261536.95
-- 2003, 1504,					243847.90
-- 2003, 1611, 					226808.03
-- 2003, 1286, 					221887.03
-- 2003, 1188, 					220116.97
-- 2003, 1702, 					179648.58
-- 2003, 1337, 					177960.10
-- 2003, 1323, 					169288.50
-- 2003, 1166, 					119461.28
-- 2003, 1216, 					81664.41
-- 2003, 1612, 					55177.48







############################################################################################################
#########         23.  which city has the most number of employees?                               ##########
############################################################################################################
SELECT 
    COUNT(DISTINCT (employeeNumber)) AS totalEmp, officeCity
FROM
    Employees
GROUP BY officeCity
ORDER BY totalEmp DESC
LIMIT 1;


-- totalEmp, officeCity
--  4,         Paris



############################################################################################################
#########         24.  which office has the biggest sales?                                        ##########
############################################################################################################

SELECT officeCity, officeCode, SUM((priceEach * quantityOrdered)) AS sale
FROM Employees e
JOIN ordersAndProd o ON e.customerNumber = o.customerNumber
GROUP BY officeCity, officeCode
ORDER BY sale DESC
LIMIT 1;

-- officeCity, officeCode, sale
-- Paris,      4,          3083761.58





    
-- SHOW VARIABLES LIKE 'version%';