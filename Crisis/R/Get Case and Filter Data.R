## Select Yaml

library(dplyr)
library(readxl)
library(xts)
library(yaml)


select_file <- 'Crisis Asia Simp.yml'
selected_case <- read_yaml(paste0('Crisis//cases//',select_file))

case_to_run <- select_file %>% basename() %>% stringr::str_remove(".yml")

case_params <- selected_case[[1]]

all_data <- readRDS('Crisis//data//Main.RDS') %>% as_tibble()

## Calculate Rolling Returns 1y and 3y
roll_1y <- all_data %>% filter(nice_field == 'Price TR') %>% group_by(key) %>% 
  mutate(value = TTR::ROC(value,type = 'discrete',n = 12)) %>% 
  mutate(value = shift(value,type = 'lead',12)) %>% ungroup() %>% 
  mutate(field = 'Roll TR 1y', nice_field = 'Roll TR 1y',key = paste(variable,nice_field)) %>% na.omit()

roll_3y <- all_data %>% filter(nice_field == 'Price TR') %>% group_by(key) %>% 
  mutate(value = TTR::ROC(value,type = 'discrete',n = 36)) %>% 
  mutate(value = shift(value,type = 'lead',36)) %>% ungroup() %>% 
  mutate(field = 'Roll TR 3y', nice_field = 'Roll TR 3y',key = paste(variable,nice_field)) 

all_data <- bind_rows(all_data,roll_1y) %>% bind_rows(roll_3y)


report_path <- file.path('../results',paste0(case_to_run,'.html'))

rmarkdown::render('Crisis/R/markdown.Rmd', output_file = report_path)


