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
names(shiller_data) <-  c('date','value')


shiller_start <- as.Date(paste0(shiller_data$date[1],'-01-01'))
shiller_end <-   as.Date(paste0(shiller_data$date[[NROW(shiller_data)]],'-01-01'))

shiller_monthly <- data.frame(date = seq.Date(shiller_start,shiller_end,by = 'months'))

library(lubridate)
shiller_monthly$year <- year(shiller_monthly$date)

# Merge Shiller's yearly data with monthly frequency data.frame
shiller_monthly <- merge(shiller_monthly,shiller_data, by.x = 'year', by.y = 'date')
shiller_monthly$year <- NULL

# Bind everything together
library(dplyr)

fred_data_1$date <- as.Date(fred_data_1$date)
fred_data_2$date <- as.Date(fred_data_2$date)

fred_data_1$source <- 1
fred_data_2$source <- 2
shiller_monthly$source <- 3

shiller_monthly <- shiller_monthly %>% filter( date < '1920-01-01')
fred_data_1 <- fred_data_1 %>% filter(date < '1934-01-01')

short_term_interest_rate <- bind_rows(shiller_monthly,fred_data_1,fred_data_2)

write.csv(short_term_interest_rate,'us_short_term_rates.csv')
