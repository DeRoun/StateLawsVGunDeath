suppressPackageStartupMessages(library("markdown"))
suppressPackageStartupMessages(library("shiny"))
suppressPackageStartupMessages(library("leaflet"))
suppressPackageStartupMessages(library("shinydashboard"))
suppressPackageStartupMessages(library("DT"))

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
              
    selectInput("sornot", label = "Select Relevant Death Data", 
                          choices = list("All Gun Deaths" = "final.df",
                                         "Excluding Suicide" = "final.df.ns")
    ),
    
    menuItem("Start", tabName = "start", icon = icon("balance-scale")
             
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
    tabItem(tabName = "start"
            #,includeHTML("start.html")
            ),
    
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
                title = "By State", status = "danger", solidHeader = TRUE,
                collapsible = FALSE,
                leafletOutput("map.Bs")
              ),
              box(
                title = "Deathe Rate By Year", status = "warning", solidHeader = TRUE,
                collapsible = FALSE,
                plotOutput("lineGraph.Bs.r")
              ),
              box(
                title = "'Raw' Data By Year", status = "warning", solidHeader = TRUE,
                collapsible = FALSE, height = "462",
                DTOutput("table.Bs")
              ),
              box(
                title = "Law Total By Year", status = "danger", solidHeader = TRUE,
                collapsible = FALSE,
                plotOutput("lineGraph.Bs.l")
              )
              
            )
    ),
    tabItem(tabName = "int"
            #,includeHTML("interp.html")
            ),
    tabItem(tabName = "le"
            #,includeHTML("learnmore.html")
            ),
    tabItem(tabName = "ab"
            #,includeHTML("aboutus.html")
            )
 ))
  
ui <- dashboardPage(skin = "red",
  header,
  sidebar,
  body
  )
  
shinyUI(ui)