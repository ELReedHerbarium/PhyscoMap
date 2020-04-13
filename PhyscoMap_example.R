################################################
############# Physco Map #######################
################################################

### RESOURCES ###
# https://rstudio.github.io/leaflet/shiny.html
# observations-84630_OriginalExport_2020-04-08.csv

setwd("~/PhyscoMap")

physco_obs = read.csv("observations-84630_OriginalExport_2020-04-08.csv")
colnames(physco_obs)



##################### Dataframe Manipulation ###

<<<<<<< HEAD
=======
#install.packages("tidyverse")
>>>>>>> 3be395a88d2f674b3f5a25bd2b1441cde1027be7
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
colnames(physco)
head(physco)

summary(as.Date(physco$observed_on)) #Checking out min and max of dates

### Create column of hyperlinks using url column
### currently not working

#links <- c(<iframe width="300" height="169" src="physco$url" </iframe>)
#links
#physco$links <- links



################################ Map Building ###

library(shiny)
library(leaflet)



##### Working Map w/o Observation Date Slider #####

### ui.R ###

ui <- bootstrapPage(
  tags$style(type = "text/css", 
             "html, body {width:100%;height:100%}"
             ),
  leafletOutput("PhyscoMap",
                width = "100%",
                height = "100%"
                )
)
  

### server.R ###

server <- function(input, output, session) {
  
  output$PhyscoMap <- renderLeaflet({
    
    # Use leaflet() here, and only include aspects of the map that won't need to change dynamically
    leaflet(physco) %>% 
      addTiles() %>%
      addCircleMarkers(lng = ~ longitude,
                       lat = ~ latitude,
                       popup = ~ paste(                           # creates a label that pops up when the observation point is clicked
                         "<b>Observation ID:</b>",
                         id,
                         "<br>",
                         "<b>Observation Date:</b>",
                         observed_on,
                         "<br>",
                         url,
                         sep=" "
                       ),
                       clusterOptions = markerClusterOptions()    # clusters observation points as you zoom out to avoid clutter
      ) %>%
      fitBounds(~min(longitude), ~min(latitude), ~max(longitude), ~max(latitude))
  })
}

### Run the app ###

shinyApp(ui, server)
