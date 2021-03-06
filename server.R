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
suppressPackageStartupMessages(library("rlang"))
suppressPackageStartupMessages(library("DT"))
suppressPackageStartupMessages(library("Cairo"))

source("data_mgmt.R")

server <- function(input, output){
  
  # Produces smoother plots using Cairo library
  
  options(shiny.usecairo=T)
  
  # Map data from albersusa package for USA map with compatable alaska and hawaii projections

  spdf <- rmapshaper::ms_simplify(usa_composite())
  
  # Create a new data frame "bs.data" that filters data by state input and excludes District of Columbia
  bs.data <- reactive({
    
    bystate.data <- filter(eval(parse(text = input$sornot)), State == input$stateChoice.Bs) %>%
      filter(State != "District of Columbia")
    
    return(bystate.data)
    
  })
  
  output$map.As <- renderLeaflet({
    
    # Filters data frame bases on All State Control widgets
    
    allStates <- filter(eval(parse(text = input$sornot)), Year == input$yearChoice.As) %>%
      filter(!State %in% c("All States", "District of Columbia"))
    allStates <- allStates[match(spdf$name, allStates$State),]
    
    # Sets bins for fill color, then creates colorbin with set of colors equal to
    # the bin in relation to allStates.df$Rate.
    
    bins <- seq(min(allStates$Rate, na.rm=T), max(allStates$Rate, na.rm=T), l = 8)
    pal <- colorBin(c("#fff5f0", "#fee0d2", "#fcbba1", "#fc9272", "#fb6a4a", 
                      "#ef3b2c", "#cb181d", "#a50f15"),
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
    
    allStates <- filter(eval(parse(text = input$sornot)), Year == input$yearChoice.Bs) %>%
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
    
    bins <- seq(min(allStates$Rate,na.rm=T), max(allStates$Rate,na.rm=T), l = 8)
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
    
    # Renders Datatable of the raw-ish data used got the By stat plots as a more detailed alternative
    
    DT::renderDT({
      byStates <- filter(eval(parse(text = input$sornot)), State == input$stateChoice.Bs) %>%
        filter(!State %in% "All States") %>%
        select(Year, "Number of Total Laws" = LawTotal, "Death Rate (by Firearm)" = Rate)
      byStates <- datatable(byStates, options = list(pageLength = 7, dom = "ftipr",
                                                     initComplete = JS(
                                                       "function(settings, json) {",
                                                       "$(this.api().table().body()).css({'font-size': '125%'});",
                                                       "}")
                                                     ), rownames= FALSE)
      
      return(byStates)
    })
  
  output$avgGunLawBox.As <-
    
    # Renders Value Box for the mean of a years avg state law total
    
    renderValueBox({
      
      allStates <- filter(eval(parse(text = input$sornot)), Year == input$yearChoice.As) %>%
        filter(!State %in% "All States") %>%
        na.omit(LawTotal) %>%
        summarise(TotalAvg = mean(LawTotal))
      avg <- round(allStates$TotalAvg[1], digits = 2)
      
      valueBox(
        paste0(avg), "Avg. Gun Laws per State", icon = icon("balance-scale"),
        color = "olive")
    })
  
  output$avgRateBox.As <-
    
    # Renders Value Box for the mean of a years avg state firearm death rate
    
    renderValueBox({
      
      allStates <- filter(eval(parse(text = input$sornot)), Year == input$yearChoice.As) %>%
        filter(!State %in% "All States") %>%
        summarise(TotalAvg = mean(Rate))
      avg <- round(allStates$TotalAvg[1], digits = 2)
      
      valueBox(
        paste0(avg), "Rate of Death per 100k", icon = icon("user-times"),
        color = "red")
    })
  
  output$yearChoiceBox.As <-
    
    # Renders Value Box that tells you the year selected
    
    renderValueBox({
      valueBox(
        paste(input$yearChoice.As), "Year Selected", icon = icon("calendar"),
        color = "yellow")
    })

  output$lineGraph.Bs.r <- 
    
    # Renders a line graph showing the change in death rate over each year for a specific state
    
    renderPlot({
    
    ggthemr("dust")
    
    bs <- bs.data()
    
    graph.Bs.r <- ggplot(data = bs) +
      geom_line(aes(x = Year, y = Rate), size = .9) + 
      geom_point(aes(x = Year, y = Rate), color = "white", size = 4.4) +
      geom_point(aes(x = Year, y = Rate), size = 2.2) +
      geom_smooth(aes(x = Year, y = Rate), fill = NA, model = lm, size = .9) +
      labs(x = "Year",
           y = "Death Rate")
    
    return(graph.Bs.r)
    
  })
  
  output$lineGraph.Bs.l <- 
    
    # Renders a line graph showing the change in law totals over each year for a specific state
    
    renderPlot({
    
    ggthemr("dust")
    
    bs <- filter(final.df, State == input$stateChoice.Bs) %>%
      filter(State != "District of Columbia")
    
    graph.Bs.l <- ggplot(data = bs) + 
      geom_line(aes(x = Year, y = LawTotal), size = .9) +
      geom_point(aes(x = Year, y = LawTotal), color = "white", size = 4.4) +
      geom_point(aes(x = Year, y = LawTotal), size = 2.2) +
      labs(x = "Year",
           y = "Total Number of Laws")
    
    return(graph.Bs.l)
  })
  
  output$scatterCorr <- 
    
    # Renders a scatter plot showing the correlation between death rate and gin laws
    
    renderPlot({
    
    ggthemr("dust")
    
    corr <-filter(eval(parse(text = input$sornot)),
                  !State %in% c("All States", "District of Columbia"))
    
    plot.scatter <- ggplot(data = corr) +
      geom_jitter(aes(x = LawTotal, y = Rate)) +
      labs(x = "Total Number of Laws",
           y = "Firearm Related Death Rate") +
      geom_smooth(aes(x = LawTotal, y = Rate), model = lm, size = 1.5)
    
    return(plot.scatter)
    
  })
  
  output$corrBox <-
    
    # Renders Value Box for the correlation coefficient of the scatter plot
    
    renderValueBox({
      
      corr <-filter(eval(parse(text = input$sornot)),
                    !State %in% c("All States", "District of Columbia"))
      
      box <- valueBox(
        paste(round(cor(corr$LawTotal, corr$Rate), digits = 2)),
        "Correlation Coefficient", icon = icon("question-circle"),
        color = "green")
      
      return(box)
      
    })
  
  output$effectBox <-
    
    # Renders Value Box stateing if the correlation can save lives
    
    renderValueBox({
      valueBox(
        "Yes", "Do Gun Laws save lives?", icon = icon("heartbeat"),
        color = "red")
    })
  
}

shinyServer(server)
