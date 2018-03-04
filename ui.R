suppressPackageStartupMessages(library("markdown"))
suppressPackageStartupMessages(library("shiny"))
suppressPackageStartupMessages(library("leaflet"))
suppressPackageStartupMessages(library("shinythemes"))

ui <- fluidPage(theme = shinytheme("united"),
  
  navbarPage("Gun Laws & Deaths",
             tabPanel("Home"),
             tabPanel("All States",
                      selectInput("yearChoice.As", label = h3("Select Year"), 
                                  choices = year.vec),
                      leafletOutput("map.As"),
                      plotOutput("lineGraph.As", hover = "lin_hover")
             ),
             tabPanel("By State",
                      sidebarPanel(
                        selectInput("stateChoice.Bs", label = h3("Select State"), 
                                  choices = state.name),
                        selectInput("yearChoice.Bs", label = h3("Select Year"), 
                                    choices = year.vec)),
                      
                      fluidRow(column(1, align = "center",
                                      plotOutput("map.Bs", hover = "map_hover")
                      ),
                      column(2, align = "center",
                             tableOutput("table.Bs")
                      )),
                      
                      plotOutput("lineGraph.Bs", hover = "line_hover")
             ),
             navbarMenu("More",
                        tabPanel("Our Interpretation of the Data"),
                        tabPanel("About Us"),
                        tabPanel("Learn More"))
  )
)

shinyUI(ui)