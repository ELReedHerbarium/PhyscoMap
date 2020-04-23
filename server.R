# server.R

library(shiny)
library(leaflet)

source("data_input.R")

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
                         "<b>Phenology Score:</b>",
                         pheno,
                         url,
                         sep=" "
                       ),
                       color = ~ pal(pheno), #use the palette we want
      ) %>%
      addLegend(position = "bottomright", pal = pal, #Adding the legend
                values = ~ pheno, 
                title = "Phenology Score",
                opacity = 1) %>%
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
                         "<b>Phenology Score:</b>",
                         pheno,
                         url,
                         sep=" "
                       ),
                       color = ~ pal(pheno), #use the palette we want
      )
  })
}