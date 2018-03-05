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
suppressPackageStartupMessages(library("ggthemr"))

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
      setView(-96, 37.8, 3) %>%
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
  
  output$map.Bs <- renderLeaflet({
    
    # Filters data frame bases on By State Control widgets
    
    allStates <- filter(final.df, Year == input$yearChoice.Bs) %>%
      filter(!State %in% "All States")
    byStates <- filter(allStates, State == input$stateChoice.Bs)
    byStates <- byStates[match(spdf$name, byStates$State),]
    
    #creates dataframe to be used to center states on map
    
    center <- data.frame(state.name, state.center)
    
    # Change Alaska Coord
    center$x[center$x == -127.2500] <- -112
    center$y[center$y == 49.2500] <- 27
    # Change Hawaii Coord
    center$x[center$x == -126.25000] <- -102.3
    center$y[center$y == 31.7500] <- 24.5
    
    center <- filter(center, state.name == input$stateChoice.Bs)
    
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
    
    labels <- paste("<p>", byStates$State, "</p>",
                    "<p>", "Gun Death Rate: ", byStates$Rate, "</p>",
                    "<p>", "Total Gun Laws: ", byStates$LawTotal, "</p>",
                    sep="")
    # Creates Leaflet Plot to be output
    
    leaflet(spdf, options = leafletOptions(crs = epsg2163)) %>%
      setView(center$x[1], center$y[1], 4) %>%
      addPolygons(fillColor = pal(byStates$Rate),
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
  
  output$table.Bs <-
    renderTable({
      byStates <- filter(final.df, State == input$stateChoice.Bs) %>%
        filter(!State %in% "All States") %>%
        select(Year, "Number of Total Laws" = LawTotal, "Death Rate (by Firearm)" = Rate)
      return(byStates)
    }, align = "ccc")
  
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
        paste(input$yearChoice.As), "Year Selected", icon = icon("calendar"),
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
  
  # Create a new data frame "bs.data" that filters data by state input and excludes District of Columbia
  bs.data <- reactive({
    
    bystate.data <- filter(final.df, State == input$stateChoice.Bs) %>%
    filter(State != "District of Columbia")
    
    return(bystate.data)
    
  })
  
  
  output$lineGraph.Bs.r <- renderPlot({
    
    ggthemr("dust")
    
    bs <- bs.data()
    
    graph.Bs.r <- ggplot(data = bs) +
      geom_line(aes(x = Year, y = Rate), size = .9) + 
      geom_point(aes(x = Year, y = Rate), size = 2.2) +
      labs(x = "Year",
           y = "Death Rate")
    
    return(graph.Bs.r)
    
  })
  
  output$lineGraph.Bs.l <- renderPlot({
    
    ggthemr("dust")
    
    bs <- bs.data()
    
    graph.Bs.l <- ggplot(data = bs) + 
      geom_line(aes(x = Year, y = LawTotal), size = .9) + 
      geom_point(aes(x = Year, y = LawTotal), size = 2.2) +
      labs(x = "Year",
           y = "Total Number of Laws")
    
    return(graph.Bs.l)
  })
  
  
}

shinyServer(server)
