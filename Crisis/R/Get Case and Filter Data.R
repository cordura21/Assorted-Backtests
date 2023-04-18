## Select Yaml
library(Rbbg)
library(dplyr)
library(readxl)
library(xts)
library(yaml)


select_file <- 'Crisis Asiatica.yml'
selected_case <- read_yaml(paste0('Crisis//cases//',select_file))

case_to_run <- select_file %>% basename() %>% stringr::str_remove(".yml")

case_params <- selected_case[[1]]

all_data <- readRDS('Crisis//data//Main.RDS') %>% as_tibble()


report_path <- file.path('../results',paste0(case_to_run,'.html'))

rmarkdown::render('Crisis/R/markdown.Rmd', output_file = report_path)


