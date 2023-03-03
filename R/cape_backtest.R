cape_backtest <- function(x,entry,exit){
  require(dplyr)
  crossover_entry <- ifelse(x >= entry & lag(x) < entry,1,0)
  crossover_exit <- ifelse(x<= exit & lag(x) > exit,-1,0)
  return(crossover_entry)
}