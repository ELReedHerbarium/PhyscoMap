# ui.R

library(shiny)
library(leaflet)

source("data_input.R")

ui <- bootstrapPage(
  tags$style(type = "text/css",
             "html, body {width:100%;height:100%}"),
  
  # places the slider and color scheme selection in bottom right corner of map window, but makes it movable
  sidebarLayout(
   mainPanel(leafletOutput("PhyscoMap", width = "100%", height = "95vh")),
   sidebarPanel(
      wellPanel(
        sliderInput("date", "Observation Date", 
                    min(as.Date(physco$observed_on)), # sets oldest date on slider as min of time range
                    max(as.Date(physco$observed_on)), # sets most recent date on slider as max of time range
                    value = range(as.Date(physco$observed_on, na.rm=TRUE)), 
                    step = 1,
                    width = "100%"
        )
      ),
      wellPanel(
        selectInput("pheno","Phenology Scores",
                    choices = c("no sporophyte", "spear sporophyte (no enlarged capsule)", "green capsule", "brown capsule", "opened capsule"),
                    selected = c("no sporophyte", "spear sporophyte (no enlarged capsule)", "green capsule", "brown capsule", "opened capsule"),
                    multiple = TRUE
        )
      )
   )
))



### Haley's Additions ###

# Need to creat a new panel to house sliders, search bars, and selectable layers