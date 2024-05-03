-- Customer & Product Analysis Using SQL 

-- In this analysis we are looking to answer three questions using byextracting data from the `stores` Database

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

--- First I will compute the low stock of each product 
SELECT p.productCode,
       p.productName,
       ROUND(SUM(quantityOrdered) / quantityInStock, 2) AS low_stock
  FROM products AS p
  JOIN orderdetails od
    ON od.productCode = p.productCode
 GROUP BY p.productCode, p.productName
 ORDER BY low_stock DESC
 LIMIT 10;
       