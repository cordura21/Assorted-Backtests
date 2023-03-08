# read downloaded files
fred_data_1 <- read.csv('Short rates series building/M1329AUSM193NNBR.csv')
fred_data_2 <- read.csv('Short rates series building/TB3MS.csv')

library(readxl)
shiller_data <- read_excel('Short rates series building/chapt26.xlsx', sheet = 'Data', skip = 7)

# Clean Shiller spreadsheet
shiller_data <- shiller_data[,c(1,5)]
shiller_data <- na.omit(shiller_data)

# Unify names
names(fred_data_1) <- c('date','value')
names(fred_data_2) <- c('date','value')
names(shiller_data) <-  c('year','value2')

# Convert Shiller's sheet from yyyy to yyyy-mm-dd
library(dplyr)
library(lubridate)

shiller_data$date <- Sys.Date()
year(shiller_data$date) <-  shiller_data$year
month(shiller_data$date) <-  12
day(shiller_data$date) <- 1
shiller_data$year <- NULL

# Create a monthly date vector for Shiller's data
shiller_monthly <- data.frame(date = seq.Date(first(shiller_data$date),
                                              last(shiller_data$date),
                                              by = 'months'))

# Merge Shiller's yearly data with monthly date vector

shiller_monthly <- merge(shiller_monthly,shiller_data, by = 'date',all.x = TRUE)

# Interpolate monthly rates from end-of-year rates

library(zoo)
shiller_monthly$value <- na.approx(shiller_monthly$value2)

# Bind everything together
library(dplyr)

fred_data_1$date <- as.Date(fred_data_1$date)
fred_data_1$value2 <- NA
fred_data_2$date <- as.Date(fred_data_2$date)
fred_data_2$value2 <- NA

# Document sources (see README.md on Github)
fred_data_1$source <- 1
fred_data_2$source <- 2
shiller_monthly$source <- 3

# Select dates from each data source
shiller_monthly <- shiller_monthly %>% filter( date < '1920-01-01')
fred_data_1 <- fred_data_1 %>% filter(date < '1934-01-01')

# Bind everything and write file
short_term_interest_rate <- bind_rows(shiller_monthly,fred_data_1,fred_data_2)
write.csv(short_term_interest_rate,
          'Short rates series building/us_short_term_rates.csv',
          row.names = FALSE)
