#setwd("~/PhyscoMap")

physco_obs = read.csv("observations-84630_OriginalExport_2020-04-08.csv")

### Dataframe Manipulation ###

#library(tidyverse)

physco <- physco_obs %>%
  select(id, # observation UID
         observed_on, # date observation was made | in format "YYYY-MM-DD"
         quality_grade, # id confidence | want "research"
         url, # link to specimen iNaturalist observation
         image_url, #link to observation images on iNaturalist
         latitude,
         longitude,
         scientific_name)
physco$observed_on = as.Date(physco$observed_on) # Converts entries in the observed_on column to represent calender dates



### Haley's Additions ###


### Phenology Example Data

## Need to create a new column "phenology" to test out coloring the circle markers based on the phenology score
## Need to randomly assign a score of 0-4 to the observations (since this data does not exist yet)
## 0 - no sporophyte
## 1 - spear sporophyte (no enlarged capsule)
## 2 - green capsule
## 3 - brown capsule
## 4 - opened capsule
physco$phenology <- sample(0:4, size = nrow(physco), replace = TRUE)
#summary(physco)
#str(physco)
#head(physco)

# define the phenology categories as follows
physco$pheno = cut(physco$phenology,
                       breaks = c(0,1,2,3,4,5), right=FALSE,
                       labels = c("no sporophyte", "spear sporophyte (no enlarged capsule)", "green capsule", "brown capsule", "opened capsule"))

# Define a color pallete corresponding to the magnitude ranges
pal = colorFactor(palette = c("red", "orange", "green", "brown", "black"), domain = physco$pheno)


### Removing non-research grade IDs

#### Add this to the ui and create a checkbox layer instead of just removing needs_id

## Need to remove observation whose quality grades are not "research" from the "quality_grade" column
#summary(physco) # check to see how many categories in quality_grade there are and the number of rows associated with each category
physco <- physco[physco$quality_grade!= "needs_id", ] # removes all rows containing "needs_id" in the quality_grade column
#summary(physco) # check to see that the removal worked

