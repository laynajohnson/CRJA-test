

library(shiny)
library(shinythemes)
library(shinyWidgets)


library(shinyjs)

counties <- c(
  "Alameda", "Alpine", "Amador", "Butte", "Calaveras", "Colusa", "Contra Costa", "Del Norte",
  "El Dorado", "Fresno", "Glenn", "Humboldt", "Imperial", "Inyo", "Kern", "Kings", "Lake", "Lassen",
  "Los Angeles", "Madera", "Marin", "Mariposa", "Mendocino", "Merced", "Modoc", "Mono", "Monterey",
  "Napa", "Nevada", "Orange", "Placer", "Plumas", "Riverside", "Sacramento", "San Benito",
  "San Bernardino", "San Diego", "San Francisco", "San Joaquin", "San Luis Obispo", "San Mateo",
  "Santa Barbara", "Santa Clara", "Santa Cruz", "Shasta", "Sierra", "Siskiyou", "Solano", "Sonoma",
  "Stanislaus", "Sutter", "Tehama", "Trinity", "Tulare", "Tuolumne", "Ventura", "Yolo", "Yuba"
)

ethnicityrace <- c("Asian", "Black", "Hispanic", "Native American", "White")

gender <- c("Male", "Female", "Other", "Prefer not to respond")

# yearcharged <- c("")
# 
# charge <- c("")


# Define UI for application
fluidPage(
  useShinyjs(),

    # Application title
  tags$style(HTML("
    .title-panel {
      background-color: white;
      color: black;
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
          h3(em("Create Your Report")),
          p("Some text about selecting things, user can search to select"),
          selectInput(
            "select_county",
            "Select County:",
            choices = counties,
            selectize = TRUE
          ),
          selectInput(
            "select_ethrace",
            "Select Race/Ethnicity:",
            choices = ethnicityrace,
            selectize = TRUE
          ),
          selectInput(
            "select_gender",
            "Select Gender:",
            choices = gender,
            selectize = TRUE
          ),
          actionButton("generate", "Generate Report", class = "btn-primary")
        ),
        
    # Show results and download button (after generating report with action button)
        mainPanel(
          downloadButton("report", "Download Report", class = "btn-success", disabled = "disabled")
        )
    )
)
