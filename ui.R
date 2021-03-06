# ui.R

library(shiny)
library(leaflet)

source("data_input.R")

ui <- bootstrapPage(
  tags$style(type = "text/css",
             "html, body {width:100%;height:100%}"),
  
  leafletOutput("PhyscoMap", width = "100%", height = "100%"),
  
  # places the slider and color scheme selection in bottom right corner of map window, but makes it movable
  absolutePanel(top=10, 
                right = 10,
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
                ),
  )
)


### Haley's Additions ###

# Need to creat a new panel to house sliders, search bars, and selectable layers