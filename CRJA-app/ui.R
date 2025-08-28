

library(shiny)
library(shinythemes)
library(shinyWidgets)
library(shinyjs)

library(tidyverse)

test_data <- read_csv("randomly_selected_data.xlsx")

counties <- c("Select Option",
  "Alameda", "Alpine", "Amador", "Butte", "Calaveras", "Colusa", "Contra Costa", "Del Norte",
  "El Dorado", "Fresno", "Glenn", "Humboldt", "Imperial", "Inyo", "Kern", "Kings", "Lake", "Lassen",
  "Los Angeles", "Madera", "Marin", "Mariposa", "Mendocino", "Merced", "Modoc", "Mono", "Monterey",
  "Napa", "Nevada", "Orange", "Placer", "Plumas", "Riverside", "Sacramento", "San Benito",
  "San Bernardino", "San Diego", "San Francisco", "San Joaquin", "San Luis Obispo", "San Mateo",
  "Santa Barbara", "Santa Clara", "Santa Cruz", "Shasta", "Sierra", "Siskiyou", "Solano", "Sonoma",
  "Stanislaus", "Sutter", "Tehama", "Trinity", "Tulare", "Tuolumne", "Ventura", "Yolo", "Yuba"
)

race <- unique(test_data$Race) # can recode vars Mexican and Cuban options to Hispanic

ethnicity <- unique(test_data$Ethnicity) # A bit more confusing... what to do here?

natorigin <- unique(test_data$`Place of Birth`) # can recode all of the states to be United States

yearoffense <- 1970:2025
# 
penalcode <- unique(test_data$Offense)

enhancements <- unique(test_data$Off_Enh1, test_data$Off_Enh2) %>%
  na.omit()


# Define UI for application
fluidPage(
  useShinyjs(),

    # Specifying style for the website title and levels of text and headings
  tags$style(HTML("
    .title-panel {
      background-color: white;
      color: black;
      padding: 7px;
      font-family: Lato;
      font-weight: 600;
    }
  ")),
  
  tags$style(HTML("
  h1, h2, h3, h4, h5, h6, p {
    font-family: Lato;
    }
  ")),
  
  div(class = "title-panel",
      titlePanel("California Racial Justice Act Dashboard")
  ),

    # Sidebar with a drop down selection menu
    sidebarLayout(
        sidebarPanel(
          width = 4,
          h3(em("Create Court Report")),
          p("Select from the options in the menus below to fit the specific case. User can type to search and select options."),
          selectInput(
            "select_county",
            "Select County:",
            choices = counties,
            selectize = TRUE
          ),
          selectInput(
            "select_yearoffense",
            "Select Year of Conviction:",
            choices = yearoffense,
            selectize = TRUE
          ),
          selectInput(
            "select_penalcode",
            "Select Penal Code Sections:",
            choices = penalcode,
            selectize = TRUE,
            multiple = TRUE
          ),
          selectInput(
            "select_enhancements",
            "Select Enhancement(s) (Optional):",
            choices = enhancements,
            selectize = TRUE,
            multiple = TRUE
          ),
          selectInput(
            "select_race",
            "Select Race of Interest:",
            choices = race,
            selectize = TRUE
          ),
          selectInput(
            "select_ethnicity",
            "Select Ethnicity of Interest:",
            choices = ethnicity,
            selectize = TRUE
          ),
          selectInput(
            "select_natorigin",
            "Select Nation of Origin:",
            choices = natorigin,
            selectize = TRUE
          ),
          p('After selection, click the "Generate Report" button below to see statistics and generate a court-ready document for download.'),
          actionButton("generate", "Generate Report", class = "btn-primary")
        ),
        
    # Show results and download button (after generating report with action button)
        mainPanel(
          h3("Using the Dashboard"),
          p("Disclaimer for intentions of the app and what the goals are..."),
          br(),
          h4("Download the generated report below:"),
          downloadButton("report", "Download Report", class = "btn-success", disabled = "disabled")
        )
    )
)
