library(readxl)
library(dplyr)
shiller_spreadsheet <- read_excel('US CAPE/ie_data.xls',sheet = 'Data', skip = 7) 

cape <- shiller_spreadsheet %>%  filter(!(is.na(Date))) %>% 
  mutate(date = Sys.Date()) %>% mutate(year = trunc(Date,0)) %>%
  mutate(month = (Date - year) * 100 %>% as.integer(),
         month2 = as.integer(month))

library(lubridate)

year(cape$date) <- cape$year
month(cape$date) <- cape$month2
cape$CAPE <- as.numeric(cape$CAPE)


cape <- cape %>% select(date,CAPE) %>% na.omit()

library(stringr)
library(roll)

cape_quantiles <- list()
quant_values <-  seq(0.0, 1, by=.05)
full_history_quantiles <- quantile(cape$CAPE,probs = quant_values)
full_history_quantiles_df <- data.frame(q = names(full_history_quantiles),
                                        full_history = full_history_quantiles) %>% 
  mutate(q = str_replace(q,"%","") %>% as.numeric(), q = q ) %>%
  mutate(q = paste0("q",str_pad(q, 3, pad = "0")))

n <- nrow(cape)

source('R/expanded_quantiles.R')

for (i in 1:length(quant_values)){
  
  curr_quant_name <- paste0("q",str_pad(quant_values[i]*100, 3, pad = "0"))
  cape_quantiles[[i]] <- cape %>% 
    mutate(q = curr_quant_name,
           rolling = roll::roll_quantile(CAPE,width = 120*2, p = quant_values[i]),
           expanded = expand_quantile(CAPE, p = quant_values[i],skip.first = 1),
           quantile_difference = rolling - expanded)

}
  
cq <- bind_rows(cape_quantiles)

library(tidyr)
cq <- merge(cq,full_history_quantiles_df, by = 'q')
cq <- cq %>% pivot_longer(!c(date,CAPE,q))


cq %>% filter(name != 'quantile_difference') %>%
ggplot(., aes(x= date, y = value, color = name)) + 
  geom_line() + 
  facet_wrap(~q, scales = 'free_y') + 
  theme_minimal( ) +
  ggtitle('20 year rolling quantiles of S&P 500 CAPE Ratio')

cq %>% filter(name == 'quantile_difference') %>%
  ggplot(., aes(x= date, y = value, color = name)) + 
  geom_bar(stat = 'identity') + 
  facet_wrap(~q) + 
  theme_minimal( ) +
  ggtitle('20 year rolling quantiles of S&P 500 CAPE Ratio')


cape_bt <- list()
cape_bt_entries <- seq(8.0,15,by=0.5)
cape_bt_exits <- c(rep(20,length(cape_bt_entries)))

for(i in 1:length(cape_bt_entries)){
  cape_bt[[i]] <- cape %>% na.omit() %>% mutate(entry = cape_bt_entries[i],
                                  exit = cape_bt_exits[i],
                                  position = cape_backtest(CAPE,cape_bt_entries[i],cape_bt_exits[i]),
                                  yearsIn = cumsum(position) / 12)
                                  
}

library(stringr)

cbt <- bind_rows(cape_bt) %>% 
  mutate(bt_name = paste("Entry:",entry,'Exit',exit)) %>%
  mutate(decade = year(date) - year(date) %% 20 )


ggplot(cbt, aes(x=date,y=position,fill = as.factor(decade))) + 
  geom_bar(position="stack", stat="identity")+ theme_minimal() + 
  facet_wrap(~factor(bt_name, levels = unique(cbt$bt_name))) + 
  theme(legend.position = 'none') +
  ggtitle("When you are in the trade")

ggplot(cbt, aes(x=date,y=yearsIn,fill = as.factor(decade))) + 
  geom_bar(position="stack", stat="identity")+ theme_minimal() +

  facet_wrap(~factor(bt_name, levels = unique(cbt$bt_name))) + 
  theme(legend.position = 'none')  +
  ggtitle("Cummulative years in the trade. Colors are 20 years blocks.")

