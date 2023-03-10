library(readxl)
library(dplyr)
library(PerformanceAnalytics)
library(data.table)


shiller_spreadsheet <- read_excel('US CAPE/NewData.xlsx',sheet = 'Sheet1', skip = 1) 

cape <- shiller_spreadsheet %>%  filter(!(is.na(Date))) %>% 
  mutate(date = Sys.Date()) %>% mutate(year = trunc(Date,0)) %>%
  mutate(month = (Date - year) * 100 %>% as.integer(),
         month2 = as.integer(month))

library(lubridate)

year(cape$date) <- cape$year
month(cape$date) <- cape$month2
cape$CAPE <- as.numeric(cape$CAPE)

## Corregir las fechas que estan corridas
cape <- cape %>% select(date,CAPE,`Real TR Price`)
names(cape) <- c('date','cape','price')


entry_value <- 10
exit_value <- 25

## Estrategia de reversion de cape sin tasa
cape2 <- cape %>% 
  mutate(SPReturn = TTR::ROC(price,type = 'discrete')) %>% na.omit() %>% 
  mutate(position = cross_over(cape,entry_value,exit_value),
         lag_position = shift(position,type = 'lag'),
         StrategyReturn = lag_position * SPReturn)

cape_bt_xts <- cape2 %>% select(date,StrategyReturn) %>% as.data.table() %>% as.xts.data.table()

temp_cape_bt_xts <- cape_bt_xts['1900::2022']


paste0('Entry: ',entry_value,' | Exit: ',exit_value)
Return.annualized(temp_cape_bt_xts)
StdDev.annualized(temp_cape_bt_xts)
maxDrawdown(temp_cape_bt_xts)



