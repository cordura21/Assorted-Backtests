
# Cross Over Trading Strategy Backtest

# This function implements a simple crossover trading strategy backtest, where a long
# position is taken when the asset price crosses above a certain threshold (the "entry"
# point), and the position is closed when the price crosses below another threshold
# (the "exit" point). The function returns a vector with the trading positions at each time point

# Arguments:
#   x: numeric vector of asset values.
#   entry: numeric value or vector representing the entry threshold.
#   exit: numeric value or vector representing the exit threshold.

# Returns:
#   A numeric vector where 1 indicates a long position and 0 indicates no position.

# Pendings:
#   Possibility of going short

cross_over <- function(x,entry,exit){
  
  require(dplyr)
  
  # Input validation
  if (!is.numeric(x)) stop("Input 'x' must be numeric.")
  if (!is.numeric(entry)) stop("Input 'entry' must be numeric.")
  if (!is.numeric(exit)) stop("Input 'exit' must be numeric.")
  
  if(any(is.na(x))) stop("Input 'x' has at least one NA value.")
  if(any(is.na(entry))) stop("Input 'entry' has at least one NA value.")
  if(any(is.na(exit))) stop("Input 'exit' has at least one NA value.")
  
  ## Create data frame 
  backtest <- data.frame(value = x)
  backtest <- backtest %>% 
    mutate(entry_point = entry,
           exit_point = exit,
           position = ifelse(value<entry_point,1,0)) ## Create df with entry and exit points
  
  backtest[2:length(x),'position'] <- NA  ## Keep the starter position ##
  
  for(iLoop in 2:length(x)){ ## Loop to get the position on each period
    
    previous_position <- backtest[iLoop-1,'position']
    temp_value <- backtest[iLoop,'value']
    temp_entry <- backtest[iLoop,'entry_point']
    temp_exit <- backtest[iLoop,'exit_point']
    
    temp_position <- ifelse(previous_position == 1 && temp_value>temp_exit,0,
                            ifelse(previous_position == 0 && temp_value<temp_entry,1,previous_position))
    
    backtest[iLoop,'position'] <- temp_position
    
    
  }
  
  return(backtest$position)
  
}

## Test
cross_over(c(1:4,1:10,9:1,5:4),2,5)
