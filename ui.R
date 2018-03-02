library("markdown")
library("shiny")

ui <- fluidPage(
  
  navbarPage("Gun Laws & Deaths",
             tabPanel("Home"),
             tabPanel("All States",
                      selectInput("yearChoice.As", label = h3("Select Year"), 
                                  choices = year.vec),
                      plotOutput("map.As", hover = "map_hover"),
                      plotOutput("lineGraph.As", hover = "lin_hover")
             ),
             tabPanel("By State",
                      fluidRow(column(1,
                                      selectInput("yearChoice.Bs", label = h3("Select Year"), 
                                                  choices = year.vec),
                                      plotOutput("map.Bs", hover = "map_hover")
                      ),
                      column(2,
                             plotOutput("map.Bs", hover = "map_hover")
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