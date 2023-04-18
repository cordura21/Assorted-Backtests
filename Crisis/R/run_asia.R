## Codigo para asia ##

library(dplyr)
library(readxl)
library(xts)
library(yaml)
library(dygraphs)


select_file <- 'Crisis Asiatica.yml'
selected_case <- read_yaml(paste0('Crisis//cases//',select_file))
case_to_run <- select_file %>% basename() %>% stringr::str_remove(".yml")
case_params <- selected_case[[1]]
all_data <- readRDS('Crisis//data//Main.RDS') %>% as_tibble()
dateWindow <- c(case_params$StartDate,case_params$EndDate)




p  <- list()
for(iCharts in 2:length(selected_case)){
  
  temp_chart <- selected_case[[iCharts]] 
  
  if(!is.null(temp_chart$SecondaryAxis)){
    
    temp_series <- c(temp_chart$PrimaryAxis$Variable,temp_chart$SecondaryAxis$Variable)
    
  }else{
    
    temp_series <- temp_chart$PrimaryAxis$Variable
    
  }
  
  temp_data <- all_data %>% filter(key %in% temp_series)
  xts_data <- temp_data %>% as.data.table() %>% dcast.data.table(date~key,value.var = 'value') %>% as.xts.data.table()
  
  ## Create dygraphs
  
  if(temp_chart$Rebase && !is.null(temp_chart$SecondaryAxis)){
    print(iCharts)
    print('Con rebase y con Secondary axis')
    p[[iCharts-1]] <- 
      dygraph(xts_data,main = temp_chart$Name,group = 'A') %>% 
      dyRebase(value = 100) %>%
      dyRangeSelector(dateWindow = dateWindow) %>%  
      dyOptions(colors = RColorBrewer::brewer.pal(6, "Set2")) %>%
      dyHighlight(highlightSeriesOpts = list(strokeWidth = 3)) %>% 
      dySeries(temp_chart$SecondaryAxis$Variable, axis = 'y2') %>% 
      dyAxis("y", label = temp_chart$PrimaryAxis$Name) %>% 
      dyAxis("y2", label = temp_chart$SecondaryAxis$Name)
    
  } 
  
  if(temp_chart$Rebase && is.null(temp_chart$SecondaryAxis)){
    print(iCharts)
    print('Con rebase y sin Secondary axis')
    p[[iCharts-1]] <- 
      dygraph(xts_data,main = temp_chart$Name,group = 'A') %>% 
      dyRebase(value = 100) %>%
      dyRangeSelector(dateWindow = dateWindow) %>%  
      dyOptions(colors = RColorBrewer::brewer.pal(6, "Set1")) %>%
      dyHighlight(highlightSeriesOpts = list(strokeWidth = 3)) %>% 
      dyAxis("y", label = temp_chart$PrimaryAxis$Name) 
    
  }
  
  if(!temp_chart$Rebase && !is.null(temp_chart$SecondaryAxis)){
    print(iCharts)
    print('Sin rebase y Con Secondary axis')
    p[[iCharts-1]] <-
      dygraph(xts_data,main = temp_chart$Name,group = 'A') %>% 
      dyRangeSelector(dateWindow = dateWindow) %>%  
      dyOptions(colors = RColorBrewer::brewer.pal(6, "Set1")) %>%
      dyHighlight(highlightSeriesOpts = list(strokeWidth = 3)) %>% 
      dyAxis("y", label = temp_chart$PrimaryAxis$Name) %>% 
      dySeries(temp_chart$SecondaryAxis$Variable, axis = 'y2') %>% 
      dyAxis("y2", label = temp_chart$SecondaryAxis$Name)
    
  }
  
  if(!temp_chart$Rebase && is.null(temp_chart$SecondaryAxis)){
    print(iCharts)
    print('Sin rebase y sin Secondary axis')
    p[[iCharts-1]] <-
      dygraph(xts_data,main = temp_chart$Name,group = 'A') %>% 
      dyRangeSelector(dateWindow = dateWindow) %>%  
      dyOptions(colors = RColorBrewer::brewer.pal(6, "Set1")) %>%
      dyHighlight(highlightSeriesOpts = list(strokeWidth = 3)) %>% 
      dyAxis("y", label = temp_chart$PrimaryAxis$Name) 
    
  }
  
  
}

p
