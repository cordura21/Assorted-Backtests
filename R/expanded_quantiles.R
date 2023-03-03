## Función para percentil que se va expandiendo 
expand_quantile <- function(x, p, skip.first,exclude.last = -1,...){
  x.length <- length(x)
  
  if(x.length < skip.first){
    return(rep(NA,x.length))
    # Not enough samples
  }
  
  #start the return vector with NAs
  exp_quantile_vector <- vector(length = x.length)
  exp_quantile_vector[1:x.length] <- NA
  
  for(iLoop in skip.first:length(x)){
    exp_quantile_vector[iLoop] <- quantile(x[1:(iLoop + min(0,exclude.last)) ],p = p[1])
  }
  
  return(exp_quantile_vector) 
  
}