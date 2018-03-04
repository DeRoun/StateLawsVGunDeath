suppressPackageStartupMessages(library("shiny"))
suppressPackageStartupMessages(library("leaflet"))
suppressPackageStartupMessages(library("dplyr"))
suppressPackageStartupMessages(library("sp"))
suppressPackageStartupMessages(library("ggplot2"))
suppressPackageStartupMessages(library("rgdal"))
suppressPackageStartupMessages(library("htmltools"))
suppressPackageStartupMessages(library("mapview"))
suppressPackageStartupMessages(library("htmlwidgets"))
suppressPackageStartupMessages(library("albersusa"))
library("ggthemr")
server <- function(input, output){
  
  # Map data from albersusa package for USA map with compatable alaska and hawaii projections

  spdf <- rmapshaper::ms_simplify(usa_composite())
  
  output$map.As <- renderLeaflet({
    
    # Filters data frame bases on All State Control widgets
    
    remove <- c("All States")
    allStates <- filter(final.df, Year == input$yearChoice.As) %>%
      filter(!State %in% remove)
    allStates <- allStates[match(spdf$name, allStates$State),]
    
    # Sets bins for fill color, then creates colorbin with set of colors equal to
    # the bin in relation to allStates.df$Rate.
    
    bins <- seq(2, 35, by = 3)
    pal <- colorBin(c("#fff5f0", "#fee0d2", "#fcbba1", "#fc9272", "#fb6a4a", 
                      "#ef3b2c", "#cb181d", "#a50f15", "#67000d"),
                    domain = allStates$Rate, bins = bins)
    
    # Creates projection for hawaii and Alaska on all state map
    epsg2163 <- leafletCRS(
      crsClass = "L.Proj.CRS",
      code = "EPSG:2163",
      proj4def = "+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +a=6370997 +b=6370997 +units=m +no_defs",
      resolutions = 2^(16:7))
    
    # Creates label variable to be used on map
    
    labels <- paste("<p>", allStates$State, "</p>",
                    "<p>", "Gun Death Rate: ", allStates$Rate, "</p>",
                    "<p>", "Total Gun Laws: ", allStates$LawTotal, "</p>",
                    sep="")
    # Creates Leaflet Plot to be output
    
    leaflet(spdf, options = leafletOptions(crs = epsg2163)) %>%
      setView(-96, 37.8, 4) %>%
      addPolygons(fillColor = pal(allStates$Rate),
                  weight = 1,
                  smoothFactor = 0.5,
                  color = "white",
                  fillOpacity = 0.8,
                  highlight = highlightOptions(
                    weight = 5,
                    color = "#666",
                    dashArray = "",
                    fillOpacity = 0.7,
                    bringToFront = TRUE),
                  label = lapply(labels, HTML)) %>%
      addLegend(pal = pal,
                values = allStates$Rate,
                opacity = 0.7,
                title = "Rate per 100,000 People",
                position = "bottomright")
    
  })
  
  output$avgGunLawBox.As <-
    renderValueBox({
      
      allStates <- filter(final.df, Year == input$yearChoice.As) %>%
        filter(!State %in% "All States") %>%
        na.omit(LawTotal) %>%
        summarise(TotalAvg = mean(LawTotal))
      avg <- round(allStates$TotalAvg[1], digits = 2)
      
      valueBox(
        paste0(avg), "Avg. Gun Laws per State", icon = icon("balance-scale"),
        color = "olive")
    })
  
  output$avgRateBox.As <-
    renderValueBox({
      
      allStates <- filter(final.df, Year == input$yearChoice.As) %>%
        filter(!State %in% "All States") %>%
        summarise(TotalAvg = mean(Rate))
      avg <- round(allStates$TotalAvg[1], digits = 2)
      
      valueBox(
        paste0(avg), "Rate of Death per 100k", icon = icon("exclamation-circle"),
        color = "red")
    })
  
  output$yearChoiceBox.As <-
    renderValueBox({
      valueBox(
        paste(input$yearChoice.As), "Year Selected", icon = icon("calendar-alt"),
        color = "yellow")
    })
  
  
  output$lineGraph.As <- renderPlot({
    
    ggthemr("dust")
    
    # Create a new data frame "as.data" that filters All State data
    as.data <- filter(final.df, State == "All States")
    
    # Create a graph.As that takes as.data as data and Year as x-axis
    graph.As <- ggplot(as.data, aes(x = Year))
    
    # Add a line graph with Rate as y-axis with color label "Death Rate" and size 1.5 to graph.As
    graph.As <- graph.As + geom_line(aes(y = Rate, color = "Death Rate"), size = .9) 
    graph.As <- graph.As + geom_point(aes(y = Rate, color = "Death Rate"), size = 2.2)
    
    # Add a line graph with LawTotal/120 as y-axis with color label "Total Number of Laws" and size 1.5 to graph.As
    graph.As <- graph.As + geom_line(aes(y = LawTotal/120, colour = "Total Number of Laws"), size = .9)
    graph.As <- graph.As + geom_point(aes(y = LawTotal/120, colour = "Total Number of Laws"), size = 2.2)
    
    # Define a secondary y-axis scale
    graph.As <- graph.As + scale_y_continuous(sec.axis = sec_axis(trans = ~. * 120, name = "Total Number of Laws")) +
      scale_x_continuous(breaks = round(seq(min(as.data$Year), max(as.data$Year), by = 1),1))
    
    # Add labels for x-axis, y-axis, and color panel
    graph.As <- graph.As + labs(y = "Death Rate",
                                x = "Year", 
                                colour = "Legend") 
    
    return(graph.As)
  })
  
}

shinyServer(server)
