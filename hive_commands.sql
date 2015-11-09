-- DROP DATABASE using CASCADE keyword: Will work even if the database is not empty
drop database IF EXISTS custorders CASCADE;
--drop table IF EXISTS customers;
--drop table IF EXISTS orders;

--/*
--Customers File
----------------
--1000000	Quentin	Shepard	32092 West 10th Street	Prairie City	SD	57649
--1000001	Brandon	Louis	1311 North 2nd Street	Clearfield	IA	50840
--1000002	Marilyn	Ham	25831 North 25th Street	Concord	CA	94522
--1000003	Mister	Tee	11596 West 1st Street	Sterling	KS	67579

--cust_id INT, fname STRING, lname STRING, address STRING, city STRING, state CHAR(2), zipcode CHAR(5)
--*/
-- Creating a Database
create database custorders;
--
-- Once you create the DB, you need to get into it by 'using' it
use custorders;

-- Create the customers table if it does not exists. Here the input file is delimited by a tab
drop table if exists customers ;

CREATE TABLE  customers(cust_id INT, fname STRING, lname STRING, address STRING, city STRING, state CHAR(2), zipcode CHAR(5))
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '/user/cloudera/hive/customers';

-- Getting info about the table customers
describe customers;

-- Copying the customer.txt file from local to the newly created customers. 'LOCAL' keyword is used to specify the local path structure.
LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/hive/customers.txt' into table customers;

--/*
--Orders File
-----------
--5000001	1133938	06-01-2008 00:03:35
--5000002	1131278	06-01-2008 00:27:42
--5000003	1153459	06-01-2008 00:49:37

--order_id INT, cust_id INT, order_date STRING.
--Note: order_date is NOT a Timestamp field. It has the following format: 06-01-2008 00:30:35 (mm-dd-yyyy hh:mm:ss).
--*/

-- Create the orders table if it does not exists. Here the input file is delimited by a tab
CREATE TABLE IF NOT EXISTS orders(order_id INT, cust_id INT, order_date STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '/user/cloudera/hive/customers';

-- Getting detailed info about the table customers
describe formatted orders;

-- Copying the customer.txt file from local to the newly created customers. 'LOCAL' keyword is used to specify the local path structure.
LOAD DATA LOCAL INPATH '/home/cloudera/Desktop/hive/orders.txt' into table orders;

--/*
--Write a HIVE script to count the number of customers in each state and list to TOP 5 states in ascending alphabetical order.
--*/
--
INSERT OVERWRITE LOCAL DIRECTORY '/home/cloudera/Desktop/hive/query1'

SELECT state,tot
from( select state, count(cust_id) as tot 
from customers
GROUP BY state
ORDER BY tot DESC 
LIMIT 5) top
ORDER BY state ASC;
--
--/*
--(b) Write a HIVE Script to list the total number of orders in orders table for the customers in the following states: AZ, CA, WA - NOTE: requires a JOIN.
--The output should be in the following format: (nnnn are counts)
--AZ  nnnn
--CA nnnn
--WA nnnn
--/*

INSERT OVERWRITE LOCAL DIRECTORY '/home/cloudera/Desktop/hive/query2.txt'
SELECT c.state, COUNT(o.order_id) 
FROM customers c JOIN orders o ON (c.cust_id = o.cust_id)
WHERE c.state in ('AZ', 'CA', 'WA')
GROUP BY c.state;
