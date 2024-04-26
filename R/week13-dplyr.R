# Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(RMariaDB)
library(tidyverse)


# Data Import and Cleaning
conn <- dbConnect(MariaDB(), 
                  user="ren00172", 
                  password=key_get("latis-mysql","ren00172"), 
                  host="mysql-prod5.oit.umn.edu", 
                  port=3306, 
                  ssl.ca = 'mysql_hotel_umn_20220728_interm.cer')

dbExecute(conn, "USE cla_tntlab")
## save datasets
employees_tbl <- dbGetQuery(conn, "SELECT * FROM datascience_employees;") %>%
  as_tibble()
write_csv(employees_tbl, "../data/employees.csv")

testscores_tbl<- dbGetQuery(conn, "SELECT * FROM datascience_testscores;") %>%
  as_tibble()
write_csv(testscores_tbl, "../data/testscores.csv")

offices_tbl <- dbGetQuery(conn, "SELECT * FROM datascience_offices;") %>%
  as_tibble()
write_csv(offices_tbl, "../data/offices.csv")

week13_tbl <- employees_tbl %>%
  inner_join(testscores_tbl, by = "employee_id") %>%
  inner_join(offices_tbl, by = c("city" = "office")) %>%
  filter(!is.na(test_score))
write_csv(week13_tbl, "../out/week13.csv")

week13_tbl <- read_csv("../out/week13.csv")

# Analysis

## Total number of managers
week13_tbl %>%
  summarize(n())

## Total number of unique managers
week13_tbl %>%
  distinct(week13_tbl$employee_id) %>%
  summarize(n())

## manager by location
mbl <- week13_tbl %>%
  filter(manager_hire == "N") %>%
  group_by(city) %>%
  count()
mbl

## mean and sd
msd <- week13_tbl %>%
  group_by(performance_group) %>%
  summarize(mean = mean(yrs_employed),
         sd = sd(yrs_employed))
msd

## location classification
loc <- week13_tbl %>%
  arrange(type, desc(test_score)) %>%
  select(type, employee_id, test_score) 
loc %>% View()
