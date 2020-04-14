#setwd("~/PhyscoMap")

physco_obs = read.csv("observations-84630_OriginalExport_2020-04-08.csv")

### Dataframe Manipulation ###

library(tidyverse)

physco <- physco_obs %>%
  select(id, # observation UID
         observed_on, # date observation was made | in format "YYYY-MM-DD"
         quality_grade, # id confidence | want "research"
         url, # link to specimen iNaturalist observation
         image_url, #link to observation images on iNaturalist
         latitude,
         longitude,
         scientific_name)
physco$observed_on = as.Date(physco$observed_on)
