## Load Data ##

library(Rbbg)
library(dplyr)
library(readxl)
library(xts)

tickers <- read_excel('Crisis//tickers.xlsx') %>% as_tibble()
conn <- Rbbg::blpConnect()

for(iLoop in 1:nrow(tickers)){
  
  temp_row <- tickers[iLoop,]
  temp_key <- paste0(temp_row$ticker,' ',temp_row$field)
  
  if(paste0(temp_key,'.csv') %in% list.files('Crisis//data//')){
    next()
  }
  
  temp_raw_results <- bdh(conn, temp_row$ticker,temp_row$field,'19201231','20230331',
                      option_names = c("periodicitySelection","currency"), option_values = c('MONTHLY','USD'),
                      dates.as.row.names=FALSE,always.display.tickers = TRUE,
                      include.non.trading.days = FALSE)
  
  names(temp_raw_results) <- c('ticker','date','value')
  
  temp_results <- temp_raw_results %>% mutate(date = as.Date(date),
                                              field = temp_row$field,
                                              variable = temp_row$variable) %>% as_tibble() %>% na.omit()
  
  write.csv(temp_results,paste0('Crisis//data//',temp_key,'.csv'),row.names = FALSE)
  print(temp_key)
  
}

csv_files <- list.files('Crisis//data',pattern = '*.csv')
csv_data <- data.frame()

for(file in csv_files){
  curr_file <- csv_files[file]
  curr_file_contents <- read.csv(file.path('Crisis//Data',file))
  csv_data <- rbind(csv_data,curr_file_contents)
}

results <- csv_data %>% as_tibble() %>% 
  mutate(date = as.Date(as.yearmon(date),1)) %>% as_tibble() %>% 
  mutate(ticker = as.character(ticker),
         field = as.character(field),
         variable = as.character(variable),
         key = paste(variable,field))

saveRDS(results,'Crisis//data//Main.RDS')

