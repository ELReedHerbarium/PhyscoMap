################################################
############# Physco_R #########################
################################################

### RESOURCES ###
# https://rstudio.github.io/leaflet/shiny.html
# observations-84630_OriginalExport_2020-04-08.csv

setwd("~/PhyscoMap")

physco_obs = read.csv("observations-84630_OriginalExport_2020-04-08.csv")
head(physco_obs)
colnames(physco_obs)


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
head(physco)
summary(as.Date(physco$observed_on))

### Create column of hyperlinks using url column

# links <- c(<iframe width="300" height="169" src="physco$url" </iframe>)
# links
# physco$links <- links



### Map Building ###

library(shiny)
library(leaflet)



##### Working Map w/o Slider for observation date #####

### ui.R ###

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("PhyscoMap", width = "100%", height = "100%"),
  
  # places the slider and color scheme selection in top right corner of map window
  absolutePanel(top = 10, right = 10,
                
                # creates the slider to change the date the specimen was observed
                #sliderInput("observation_date", "Observation Date", 
                #            min = min(as.Date(physco$observed_on)), # sets oldest date on slider as min of time range
                #            max = max(as.Date(physco$observed_on)), # sets most recent date on slider as max of time range
                #            value = range(as.Date(physco$observed_on)), 
                #            step = NULL,
                #            #animationOptions(interval = 1000,
                #                             #loop = TRUE,
                #                             #)
                #)
  )
)

### What are these functions
# ?sliderInput
# ?animationOptions
# ?reactive
###

server <- function(input, output, session) {
  
  # Reactive expression for the data subsetted to what the user selected
  #sliderValues <- reactive({
  #  physco[physco$observed_on >= input$observation_date[1] & physco$observed_on <= input$observation_date[2],]
  #})
  
  output$PhyscoMap <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(physco) %>% 
      addTiles() %>%
      addCircleMarkers(lng = ~ longitude,
                       lat = ~ latitude,
                       popup = ~ paste(
                         "<b>Observation ID:</b>",
                         id,
                         "<br>",
                         "<b>Observation Date:</b>",
                         observed_on,
                         "<br>",
                         url,
                         sep=" "
                       ),
                       clusterOptions = markerClusterOptions()
      ) %>%
      fitBounds(~min(longitude), ~min(latitude), ~max(longitude), ~max(latitude))
  })
  
  #observe(leafletProxy("PhyscoMap", data = sliderValues()) %>%
  #          clearMarkers() %>%
  #          addCircleMarkers(lng = ~ longitude,
  #                           lat = ~ latitude,
  #                           label = ~ id,
  #                           clusterOptions = markerClusterOptions()
  #          ))
}


shinyApp(ui, server)



##### NOW WORKING! Map w/ Slider for observation date -> does not create clusters of data points #####

### ui.R ###

ui <- bootstrapPage(
  tags$style(type = "text/css",
             "html, body {width:100%;height:100%}"),
  
  leafletOutput("PhyscoMap", width = "100%", height = "100%"),
  
  # places the slider and color scheme selection in bottom right corner of map window, but makes it movable
  absolutePanel(bottom = 20, 
                right = 100,
                draggable = TRUE,
                
                # creates the slider to change the date the specimen was observed
                sliderInput("date", "Observation Date", 
                            min(as.Date(physco$observed_on)), # sets oldest date on slider as min of time range
                            max(as.Date(physco$observed_on)), # sets most recent date on slider as max of time range
                            value = range(as.Date(physco$observed_on, na.rm=TRUE)), 
                            step = 1,
                            width = "100%"
                            #animationOptions(interval = 1000,
                            #                 loop = TRUE,
                            #                 )
                )
  )
)





server <- function(input, output, session) {
  
  # Reactive expression for the data subsetted to what the user selected
  sliderValues <- reactive({
 #   physco[as.Date(physco$observed_on)>=input$date[1] & as.Date(physco$observed_on)<=input$date[2],]
 #  })
  
  physco[which(physco$observed>=input$date[1] & physco$observed_on<=input$date[2]),]
  })
  
  output$PhyscoMap <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(physco) %>% 
      addTiles() %>%
      addCircleMarkers(lng = ~ longitude,
                       lat = ~ latitude,
                       popup = ~ paste(
                         "<b>Observation ID:</b>",
                         id,
                         "<br>",
                         "<b>Observation Date:</b>",
                         observed_on,
                         "<br>",
                         url,
                         sep=" "
                       ),
                       #clusterOptions = markerClusterOptions()     ### this is what's causing issues
      ) %>%
      fitBounds(~min(longitude), ~min(latitude), ~max(longitude), ~max(latitude))
  })
  
  observe({
    
    leafletProxy("PhyscoMap", data = sliderValues()) %>%
            clearMarkers() %>%
            addCircleMarkers(lng = ~ longitude,
                             lat = ~ latitude,
                             popup = ~ paste(
                               "<b>Observation ID:</b>",
                               id,
                               "<br>",
                               "<b>Observation Date:</b>",
                               observed_on,
                               "<br>",
                               url,
                               sep=" "
                             ),
                             #clusterOptions = markerClusterOptions()    ### this is what's causing issues
            )
  })
}

shinyApp(ui, server)



###### Getting decent marker labels ######################################################


leaflet(physco) %>% 
  addTiles() %>%
  addCircleMarkers(lng = ~ longitude,
                   lat = ~ latitude,
                   popup = ~ paste(
                     "<b>Observation ID:</b>",
                     id,
                     "<br>",
                     "<b>Observation Date:</b>",
                     observed_on,
                     sep=" "),
                   clusterOptions = markerClusterOptions()
  )

#############



  leaflet(physco) %>% 
    addTiles() %>%
    addCircleMarkers(lng = ~ longitude,
                     lat = ~ latitude,
                     popup = ~ paste(
                       "<b>Observation ID:</b>",
                       id,
                       "<br>",
                       "<b>Observation Date:</b>",
                       observed_on,
                       "<br>",
                       url,
                       sep=" "
                       ),
                     clusterOptions = markerClusterOptions()
    )
  
  ##############
  
  leaflet(physco) %>% 
    addTiles() %>%
    addCircleMarkers(lng = ~ longitude,
                     lat = ~ latitude,
                     popup = ~ paste(
                       "<b>Observation ID:</b>",
                       id,
                       "<br>",
                       "<b>Observation Date:</b>",
                       observed_on,
                       "<br>",
                       "<a href="url"><img src="image_url" alt="iNaturalist Page" style="width:42px;height:42px;border:0;" target="_blank"></a>",
                       sep=" "),
                     clusterOptions = markerClusterOptions()
    )