suppressPackageStartupMessages(library("markdown"))
suppressPackageStartupMessages(library("shiny"))
suppressPackageStartupMessages(library("leaflet"))
suppressPackageStartupMessages(library("shinydashboard"))


sidebar <- dashboardSidebar(
  sidebarMenu(id = "sidebarmenu",
    menuItem("Start", tabName = "start", icon = icon("balance-scale")),
    
    menuItem("All States", tabName = "all", icon = icon("map")),
      conditionalPanel("input.sidebarmenu === 'all'",
        selectInput("yearChoice.As", label = "Select Year", 
                         choices = year.vec)
    ),
    
    menuItem("By States", tabName = "by", icon = icon("map-pin")),
      conditionalPanel("input.sidebarmenu === 'a'",
        selectInput("stateChoice.Bs", label = "Select State", 
                         choices = state.name),
        selectInput("yearChoice.Bs", label = "Select Year", 
                         choices = year.vec)),
  
    menuItem("Our Interpretation", tabName = "Interpretation", icon = icon("bookmark")),
  
    menuItem("Learn More", tabName = "Learn", icon = icon("leanpub")),
  
    menuItem("About Us", tabName = "About", icon = icon("info"))
)
)

body <- dashboardBody(
  tabItems(
    tabItem(tabName = "start"),
    
    tabItem(tabName = "all",
            box(
              title = "United States", status = "danger", solidHeader = TRUE,
              width = 14, collapsible = FALSE,
              leafletOutput("map.As")
            ),
            fluidRow(
              valueBoxOutput("avgGunLawBox.As"),
              valueBoxOutput("avgRateBox.As"),
              valueBoxOutput("yearChoiceBox.As")
            )
    ),
    
    tabItem(tabName = "by",
            fluidRow(
              box(
                title = "State", status = "primary", solidHeader = TRUE,
                collapsible = FALSE,
                leafletOutput("map.Bs")
              ),
              box(
                status = "primary", solidHeader = TRUE,
                collapsible = FALSE,
                tableOutput("lineGraph.Bs")
              ),
              box(
                status = "primary", solidHeader = TRUE,
                collapsible = FALSE,
                plotOutput("table.Bs")
              )
            )
    )
 ))
  
ui <- dashboardPage(skin = "black",
  dashboardHeader(title = "Gun Laws & Deaths"),
  sidebar,
  body
  )
  
shinyUI(ui)