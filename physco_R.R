
################################################
############# Physco_R #########################
################################################

### RESOURCES ###
# https://rstudio.github.io/leaflet/shiny.html
# Physco_data.csv

setwd("~/PhyscoHunt_Map/Physco_R_practice")

physco = read.csv("Physco_data.csv")
head(physco)
summary(physco)

library(shiny)
library(leaflet)

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  
  # places the slider and color scheme selection in top right corner of map window
  absolutePanel(top = 10, right = 10,
                
                # creates the slider to change the year the specimen was observed
                sliderInput("year", "Observation Year", min(physco$year), max(physco$year),
                            value = range(physco$year), step = 1
                )
  )
)



server <- function(input, output, session) {
  
  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    physco[physco$year >= input$year[1] & physco$year <= input$year[2],]
  })
  
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(physco) %>% addTiles() %>%
      addCircleMarkers(lng = ~ longitude,
                       lat = ~ latitude,label = ~ id,
                       clusterOptions = markerClusterOptions()
      ) %>%
      fitBounds(~min(longitude), ~min(latitude), ~max(longitude), ~max(latitude))
  })
  
  observe(leafletProxy("map", data = filteredData()) %>%
            clearMarkers() %>%
            addCircleMarkers(lng = ~ longitude,
                             lat = ~ latitude,label = ~ id,
                             clusterOptions = markerClusterOptions()
            ))
}


shinyApp(ui, server)









####### Script for the quake dataset with magnitude slider

library(shiny)
library(leaflet)
library(RColorBrewer)

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  
  # places the slider and color scheme selection in top right corner of map window
  absolutePanel(top = 10, right = 10,
                
                # creates the slider to manipulate what magnitudes are shown on the map
                sliderInput("range", "Magnitudes", min(quakes$mag), max(quakes$mag),
                            value = range(quakes$mag), step = 0.1
                ),
                
                # Places a drop down menu of color schemes to select from
                selectInput("colors", "Color Scheme",
                            rownames(subset(brewer.pal.info, category %in% c("seq", "div")))
                ),
                
                # Puts a legend (in bottom right of map window) of magnitudes and their associated colors
                checkboxInput("legend", "Show legend", TRUE)
  )
)

server <- function(input, output, session) {
  
  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    quakes[quakes$mag >= input$range[1] & quakes$mag <= input$range[2],]
  })
  
  # This reactive expression represents the palette function,
  # which changes as the user makes selections in UI.
  colorpal <- reactive({
    colorNumeric(input$colors, quakes$mag)
  })
  
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(quakes) %>% addTiles() %>%
      fitBounds(~min(long), ~min(lat), ~max(long), ~max(lat))
  })
  
  # Incremental changes to the map (in this case, replacing the
  # circles when a new color is chosen) should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  observe({
    pal <- colorpal()
    
    leafletProxy("map", data = filteredData()) %>%
      clearShapes() %>%
      addCircles(radius = ~10^mag/10, weight = 1, color = "#777777",
                 fillColor = ~pal(mag), fillOpacity = 0.7, popup = ~paste(mag)
      )
  })
  
  # Use a separate observer to recreate the legend as needed.
  observe({
    proxy <- leafletProxy("map", data = quakes)
    
    # Remove any existing legend, and only if the legend is
    # enabled, create a new one.
    proxy %>% clearControls()
    if (input$legend) {
      pal <- colorpal()
      proxy %>% addLegend(position = "bottomright",
                          pal = pal, values = ~mag
      )
    }
  })
}

shinyApp(ui, server)