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


cape_backtest(x,entry,exit)
# Test
x <- c(1:4,1:10,9:1,5:4)
entry <- 3
exit <- 8
cape_backtest(x,entry,exit)

x <- c(1:4,1:10,9:1,5:4)
entry <- rep(3,length(sample_values))
exit <- rep(8,length(sample_values))
cross_over(x,entry,exit)



