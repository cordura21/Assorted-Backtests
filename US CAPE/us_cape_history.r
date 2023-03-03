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
           expanded = expand_quantile(CAPE, p = quant_values[i],skip.first = 1))

}
  
cq <- bind_rows(cape_quantiles)

library(tidyr)
cq <- merge(cq,full_history_quantiles_df, by = 'q')
cq <- cq %>% pivot_longer(!c(date,CAPE,q))



ggplot(cq %>% filter (name != 'full_history'),
       aes(x= date, y = value, color = name)) + 
  geom_line() + 
  facet_wrap(~q, scales = 'free_y') + 
  theme_minimal( ) +
  ggtitle('20 year rolling quantiles of S&P 500 CAPE Ratio')
