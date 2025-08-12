

library(shiny)
library(shinythemes)
library(shinyWidgets)



counties <- c(
  "Alameda", "Alpine", "Amador", "Butte", "Calaveras", "Colusa", "Contra Costa", "Del Norte",
  "El Dorado", "Fresno", "Glenn", "Humboldt", "Imperial", "Inyo", "Kern", "Kings", "Lake", "Lassen",
  "Los Angeles", "Madera", "Marin", "Mariposa", "Mendocino", "Merced", "Modoc", "Mono", "Monterey",
  "Napa", "Nevada", "Orange", "Placer", "Plumas", "Riverside", "Sacramento", "San Benito",
  "San Bernardino", "San Diego", "San Francisco", "San Joaquin", "San Luis Obispo", "San Mateo",
  "Santa Barbara", "Santa Clara", "Santa Cruz", "Shasta", "Sierra", "Siskiyou", "Solano", "Sonoma",
  "Stanislaus", "Sutter", "Tehama", "Trinity", "Tulare", "Tuolumne", "Ventura", "Yolo", "Yuba"
)




# Define UI for application
fluidPage(
  

    # Application title
  tags$style(HTML("
    .title-panel {
      background-color: #873418;
      color: white;
      padding: 7px;
      font-family: Lato;
      font-weight: 600;
    }
  ")),
  
  div(class = "title-panel",
      titlePanel("California Racial Justice Act Dashboard")
  ),

    # Sidebar with a drop down selection menu
    sidebarLayout(
        sidebarPanel(
          width = 4,
          h3(em("Some title")),
          p("Some text about selecting things, user can search to select"),
          selectInput(
            "select_county",
            "Select County:",
            choices = counties,
            selectize = TRUE
          )
        ),
    # Show results and download button
        mainPanel(
          downloadButton("report", "Download Report")
        )
    )
)
