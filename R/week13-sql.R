# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(RMariaDB)

# Data Import and Cleaning
# Set connection
conn <- dbConnect(MariaDB(), 
                  user="ren00172", 
                  password=key_get("latis-mysql","ren00172"), 
                  host="mysql-prod5.oit.umn.edu", 
                  port=3306, 
                  ssl.ca = 'mysql_hotel_umn_20220728_interm.cer')

dbExecute(conn, "USE cla_tntlab")


# Analysis
## 1. Total number of managers 
## Use inner join to keep those who have test scores
query1 <- "SELECT COUNT(*) 
           FROM datascience_employees e
           INNER JOIN datascience_testscores t ON e.employee_id = t.employee_id 
           WHERE t.test_score IS NOT NULL;"

dbGetQuery(conn, query1)
## N = 549

## 2. Total number of unique managers
## Use inner join to keep those who have test scores
query2 <- "SELECT COUNT(DISTINCT e.employee_id)
           FROM datascience_employees e
           INNER JOIN datascience_testscores t ON e.employee_id = t.employee_id
           WHERE t.test_score IS NOT NULL;"

dbGetQuery(conn, query2)
## N = 549

## 3. Number of managers split by location for those who were not hired as managers
query3 <- "SELECT city, COUNT(*)
           FROM datascience_employees e
           INNER JOIN datascience_testscores t ON e.employee_id = t.employee_id
           WHERE t.test_score IS NOT NULL
              AND e.manager_hire = 'N'
           GROUP BY e.city;"

dbGetQuery(conn, query3)
#            city COUNT(*)
# 1       Chicago       61
# 2       Houston       20
# 3      New York      183
# 4       Toronto      189
# 5       Orlando       20
# 6 San Francisco       48

## 4. Mean and SD blablabla
query4 <- "SELECT performance_group, AVG(yrs_employed) AS mean, STDDEV(yrs_employed) AS sd
           FROM datascience_employees e
           INNER JOIN datascience_testscores t ON e.employee_id = t.employee_id
           WHERE t.test_score IS NOT NULL
           GROUP BY performance_group;"

dbGetQuery(conn, query4)
# ``performance_group    mean        sd
# 1            Bottom 4.74206 0.5348718
# 2            Middle 4.58061 0.5082812
# 3               Top 4.32581 0.5989064

## 5. Location Classification blablabla
## select type, ID, and test score and order them
query5 <-  "SELECT o.type, e.employee_id AS ID, t.test_score
            FROM datascience_employees e
            INNER JOIN datascience_testscores t ON e.employee_id = t.employee_id
            INNER JOIN datascience_offices o ON e.city = o.office
            WHERE t.test_score IS NOT NULL
            ORDER BY o.type, test_score DESC;"

dbGetQuery(conn, query5)


