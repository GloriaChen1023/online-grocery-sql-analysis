install.packages("sqldf")
library(sqldf)

getwd()
setwd("/Users/gloriachen/Desktop/461 Data Visualization Data/")

#Read in the csv files for the subquery problems
OrderHeader<-read.csv("order_header_sample.csv", header=TRUE)
OrderDetail<-read.csv("order_detail_sample.csv", header=TRUE)
Customer<-read.csv("customer_sample.csv", header=TRUE)
ProductLookup<-read.csv("lookup.csv", header=TRUE)

#1.a total number of customer records
sqldf("SELECT COUNT(*) AS TotalCustomer
      FROM Customer")

#1.b total number of orders
sqldf("SELECT COUNT(DISTINCT ord_id)
      FROM OrderHeader")

#1.c mean spend per order
sqldf("SELECT AVG(it_dmnd_qy)
      FROM OrderHeader")

#2. top 25 products by units
sqldf("SELECT d.pod_id AS PodID, p.it_long_name_tx AS ProductName, SUM(d.it_qy) AS TotalUnits
      FROM OrderDetail d
      LEFT JOIN ProductLookup p
      ON d.pod_id = p.pod_id
      GROUP BY PodID, ProductName
      ORDER BY TotalUnits DESC
      LIMIT 25")

#2. top 25 products by sales
sqldf("SELECT d.pod_id AS PodID, p.it_long_name_tx AS ProductName, SUM(d.tot_pr_qy) AS TotalSales
      FROM OrderDetail d
      LEFT JOIN ProductLookup p
      ON d.pod_id = p.pod_id
      GROUP BY PodID, ProductName
      ORDER BY TotalSales DESC
      LIMIT 25")

#Write a join between the order header and the customer table. Include only the customers with a record on the order table.  
sqldf("SELECT * 
      FROM Customer c
      INNER JOIN OrderHeader h
      on c.cnsm_id = h.cnsm_id
      ")

#3. How many customers have an order
sqldf("SELECT COUNT(DISTINCT c.cnsm_id) AS CustomerCount
      FROM Customer c")

#3. Identify the customer ID with the highest sales.
sqldf("SELECT c.cnsm_id AS HighestCustomerID, SUM(h.it_dmnd_qy) AS HighestSales
      FROM Customer c
      LEFT JOIN OrderHeader h
      ON c.cnsm_id = h.cnsm_id
      GROUP BY HighestCustomerID
      ORDER BY HighestSales DESC
      LIMIT 1")

#4. Write a subquery to pull the order-line detail for the 5 orders with the highest sales on the Order Header table
sqldf("SELECT d.*
      FROM OrderDetail d
      WHERE d.ord_id IN (
      SELECT h.ord_id
      FROM OrderHeader h
      ORDER BY h. it_dmnd_qy DESC
      LIMIT 5)
      ")

#5. Write a join to connect the lookup table to the order-line detail table
sqldf("SELECT *
      FROM OrderDetail d
      LEFT JOIN ProductLookup l
      ON d.pod_id = l.pod_id")

#6. What are the top 10 brands in the order data
sqldf("SELECT l.brnd_desc AS BrandName, SUM(d.it_qy) AS TotalUnits
      FROM ProductLookup l
      LEFT JOIN OrderDetail d
      ON l.pod_id = d.pod_id
      GROUP BY BrandName
      ORDER BY TotalUnits DESC
      LIMIT 10")

#7. What are the top 10 brands in the most recent 6 months
sqldf("SELECT l.brnd_desc AS BrandName, SUM(d.it_qy) AS TotalUnits
      FROM OrderDetail d
      LEFT JOIN ProductLookup l ON d.pod_id = l.pod_id
      LEFT JOIN OrderHeader h ON d.ord_id = h.ord_id
      WHERE h.dlv_dt >= date((SELECT MAX (dlv_dt) FROM OrderHeader), '-6 months')
      GROUP BY BrandName
      ORDER BY TotalUnits DESC
      LIMIT 10")