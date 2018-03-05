suppressPackageStartupMessages(library("markdown"))
suppressPackageStartupMessages(library("shiny"))
suppressPackageStartupMessages(library("leaflet"))
suppressPackageStartupMessages(library("shinydashboard"))

header <- dashboardHeader(title = "Gun Laws & Deaths",
                          dropdownMenu(type = "notifications",
                                       icon = icon("github"),
                                       badgeStatus = NULL,
                                       headerText = "Check Us Out", 
                                       notificationItem("Github", icon = icon("github"),
                                                        href = "https://github.com/DeRoun/StateLawsVGunDeath/")
                                       ))

sidebar <- dashboardSidebar(
  sidebarMenu(id = "sidebarmenu",
    menuItem("Start", tabName = "start", icon = icon("balance-scale")),
      conditionalPanel("input.sidebarmenu === 'start'",
        selectInput("sornot", label = "Select Relevant Data", 
                         choices = list("Homicide Data Only" = 1, "Homicide and Suicide Data" = 2))
    ),
    
    menuItem("All States", tabName = "all", icon = icon("map")),
      conditionalPanel("input.sidebarmenu === 'all'",
        selectInput("yearChoice.As", label = "Select Year", 
                         choices = year.vec)
    ),
    
    menuItem("By States", tabName = "by", icon = icon("map-pin")),
      conditionalPanel("input.sidebarmenu === 'by'",
        selectInput("stateChoice.Bs", label = "Select State", 
                         choices = state.name),
        selectInput("yearChoice.Bs", label = "Select Year", 
                         choices = year.vec)),
  
    menuItem("Our Interpretation", tabName = "int", icon = icon("bookmark")),
  
    menuItem("Learn More", tabName = "le", icon = icon("leanpub")),
  
    menuItem("About Us", tabName = "ab", icon = icon("info"))
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
                title = "State Name", status = "danger", solidHeader = TRUE,
                collapsible = FALSE,
                leafletOutput("map.Bs")
              ),
              box(
                title = "State Name Graph Rate", status = "warning", solidHeader = TRUE,
                collapsible = FALSE,
                plotOutput("lineGraph.Bs.r")
              ),
              box(
                title = "State Name Data per Year", status = "warning", solidHeader = TRUE,
                collapsible = FALSE,
                tableOutput("table.Bs")
              ),
              box(
                title = "State Name Graph Law Total", status = "danger", solidHeader = TRUE,
                collapsible = FALSE,
                plotOutput("lineGraph.Bs.l")
              )
              
            )
    ),
    tabItem(tabName = "int"),
    tabItem(tabName = "le"),
    tabItem(tabName = "ab",
            
            includeHTML("html_pages/aboutUs.html"))
 ))
  
ui <- dashboardPage(skin = "red",
  header,
  sidebar,
  body
  )
  
shinyUI(ui)