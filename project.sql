-- Customer & Product Analysis Using SQL 

-- In this analysis, we are looking to answer three questions using by extracting data from the `stores` Database

/*
 stores Database Schema Design 
 Example: tablename(attr_1, attr_2, attr_3, ...)
 
 customers (*customerNumber, customerName, contactLastName, contactFirstName, salesRepEmployeeNumber ...)
 orders (*orderNumber, orderDate, requiredDate, shippedDate, customerNumber ...)
 payments (*customerNumber, *checkNumber, paymentDate, amount)
 orderdetails (*orderNumber, *productCode, quantityOrdered ...)
 products (*productCode, productName, productLine, productScale ...)
 productlines(*productLine, textDescription ... )
 employees( *employeeNumber, lastName, firstName, officeCode, reportsTo ...)
 offices( *officeCode, city, phone ...)
*/


-- Here is some metadata on the tables in this database 
SELECT 'Customers' AS table_name, 
       13 AS number_of_attributes,
       COUNT(*) As number_of_rows
  FROM customers
 UNION ALL 
SELECT 'Products', 9, COUNT(*) 
  FROM products
 UNION ALL
SELECT 'ProductLines', 4 ,COUNT(*) 
  FROM productlines
UNION ALL 
SELECT 'Orders', 7 ,COUNT(*) 
  FROM orders
UNION ALL
SELECT 'OrderDetails', 5 ,COUNT(*) 
  FROM orderdetails
UNION ALL 
SELECT 'Payments', 4 ,COUNT(*) 
  FROM payments
UNION ALL 
SELECT 'Employees', 8 ,COUNT(*) 
  FROM employees
UNION ALL
SELECT 'Offices', 9 ,COUNT(*) 
  FROM offices
  

-- Question 1: Which Products Should We Order More of or Less of?
-- ANS: The Products we should order more or less of are those with high product performance that are on the brink of being out of stock.

--- Here I am writing a query to compute the low stock for each product using a correlated subquery.
SELECT p.productCode,
       p.productName,
       ROUND((SELECT SUM(quantityOrdered) * 1.0
                FROM orderdetails AS od
               WHERE od.productCode = p.productCode)
             / quantityInStock, 2) AS low_stock
  FROM products AS p
 GROUP BY p.productCode, p.productName
 ORDER BY low_stock DESC
 LIMIT 10;

/* We could also write this query using joins to achieve the same result. 
SELECT p.productCode,
       p.productName,
       ROUND(SUM(quantityOrdered) / quantityInStock, 2) AS low_stock
  FROM products AS p
  JOIN orderdetails od
    ON od.productCode = p.productCode
 GROUP BY p.productCode, p.productName
 ORDER BY low_stock DESC
 LIMIT 10;
*/

-- I will combine the previous query with a Common Table Expression (CTE) of the Top Ten Product Performance to display priority products for restocking using the IN operator.

WITH top_10_product_performance AS (     
SELECT productCode
  FROM orderdetails
 GROUP BY productCode
 ORDER BY SUM(quantityOrdered * priceEach) DESC
 LIMIT 10
 )
 
SELECT p.productCode,
       p.productName,
       ROUND((SELECT SUM(quantityOrdered) * 1.0
                FROM orderdetails AS od
               WHERE od.productCode = p.productCode)
             / quantityInStock, 2) AS low_stock
  FROM products AS p
 WHERE p.productCode IN top_10_product_performance
 GROUP BY p.productCode, p.productName
 ORDER BY low_stock DESC

-- Question 2: How Should We Match Marketing and Communication Strategies to Customer Behavior?
/*
This involves categorizing customers: finding the VIP (very important person) customers and those who are less engaged.
- VIP customers bring in the most profit for the store.
- Less engaged customers bring in less profit.
*/ 
-- Here I created a CTE that will have a list of all customer and their profit 
WITH customer_profit AS (
SELECT customerNumber, 
       ROUND(SUM(quantityOrdered * (priceEach - buyPrice)),2) AS profit
  FROM orders AS o
  LEFT JOIN orderdetails AS od
    ON od.orderNumber = o.orderNumber
  LEFT JOIN products AS p
    ON p.productCode = od.productCode
 GROUP BY customerNumber
 ORDER BY profit DESC
)
-- Here I found the Top 5 VIP customers 
SELECT contactLastName,
       contactFirstName,
       city,
       country, 
       profit
  FROM customers
  JOIN customer_profit
    ON customer_profit.customerNumber = customers.customerNumber
 ORDER BY profit DESC
 LIMIT 5;

--- Here are the TOP 5 least engaging customers 
SELECT contactLastName,
       contactFirstName,
       city,
       country, 
       profit
  FROM customers
  JOIN customer_profit
    ON customer_profit.customerNumber = customers.customerNumber
 ORDER BY profit 
 LIMIT 5;

--- Question 3: How Much Can We Spend on Acquiring New Customers?


       
