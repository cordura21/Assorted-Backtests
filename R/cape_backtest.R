cape_backtest <- function(x,entry,exit){
  backtest <- data.frame(value = x)
  require(dplyr)
  backtest <- backtest %>%
    mutate(entry = if_else(value <= entry & lag(value) > entry, 1,0)) %>%
    mutate(exit = if_else(value >= exit & lag(value) < exit,1,0)) %>%
    mutate(position = 0)
  
  for(i in 2:nrow(backtest)){
    previous_position <- backtest$position[i-1]
    backtest$position[i] <- previous_position
    
    # Entry
    if(previous_position == 0 & backtest$entry[i] == 1) {
      backtest$position[i] <- 1
  }
    
    # Exit
    if(previous_position == 1 & backtest$exit[i] == 1) {
      backtest$position[i] <- 0
    } 

}

  
    
return(backtest$position)
}

# Test
# sample_values <- c(1:4,1:10,9:1,5:4)
# cape_backtest(sample_values,3,8)
