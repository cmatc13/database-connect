library(DBI)
require(odbc)

#list all of the drivers on my machine
sort(unique(odbcListDrivers()[[1]]))

#connect to H+Active Database in Microsoft SQL Server
con <- DBI::dbConnect(odbc::odbc(),
               Driver = "SQL Server",
               dbname='H+Active',
               Server = 'C****\\SQLEXPRESS02',
               port = 1433,
               user = "cm******",
               password = '********')


# Connect to AdventureWorks2014 Database in Microsoft SQL Server with slightly different configuration
# to H+Active connection above 
con <- DBI::dbConnect(odbc::odbc(), 
                      Driver = "SQL Server", 
                      Server = "C*****\\SQLEXPRESS02", 
                      Database = "AdventureWorks2014", 
                      Trusted_Connection = "True")


# Connect to a PostgreSQL Database
require(RPostgres)
require(dplyr)
require(DBI)

drv <- dbDriver("PostgreSQL")


# Connection to PostgreSQL database mtcars; host comes from url for pgadmin
con <- dbConnect(drv, dbname="mtcars", host='127.0.0.1', port=5433, user='postgres', password='*******')
#returns number of rows in the database
stmt <- "SELECT count(*) FROM rainfall;"
nrows <- dbGetQuery(con, statement = stmt)

stmt <- "SELECT * FROM rainfall;"
# A dataframe object is returned in R  
df <- dbGetQuery(con, statement = stmt)

# Here tbl displays data in the database and dplyr commands are performed on the database and do not
# use memory in R
tbl(con, 'rainfall') %>% filter(year == 2014 & month == 2)

#lists all of the tables in the database
DBI::dbListTables(con)


require(ggplot2)
# Can create tables in the database from R
dbWriteTable(con, "diamonds", ggplot2::diamonds)
dbListTables(con)


# Submits and executes SQL query to the database engine but does not extract any records
res <- dbSendQuery(con, "SELECT * from rainfall")
# Fetch will return the dbSendQuery result as a dataframe; n = -1 will return all results 
data <- fetch(res, n = -1)
# Retrieves 10 records
data <- fetch(res, n = 10)


# Get number of rows of rainfall table
tbl(con, 'rainfall') %>% count()
# Other method for getting nrows
stmt <- 'select count(*) from rainfall;'
nrows_new <- dbGetQuery(con, stmt)
# Reading in 1000 rows at a time and appending to dataframe: data
# This will be helpful for very large datasets that won't fit in R in its entirety
stmt <- "select * from rainfall limit 1000;"
data <- dbGetQuery(con, stmt) 
for(i in 1:4){
    stmt <- paste("select * from rainfall limit 1000 offset", (i*1000))
    data <- bind_rows(data, dbGetQuery(con, stmt))
}
dim(data)

# Disconnect to the database for best practises
dbDisconnect(con)

