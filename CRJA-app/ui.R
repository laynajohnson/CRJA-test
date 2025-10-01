

library(shiny)
library(shinythemes)
library(shinyWidgets)
library(shinyjs)

library(tidyverse)
library(plotly)

# Loading in the data and creating selection options

test_data <- read_csv("randomly_selected_data.xlsx") # everything taken from here for data values, will need to change to database instead

counties <- c("Alameda", "Alpine", "Amador", "Butte", "Calaveras", "Colusa", "Contra Costa", "Del Norte",
  "El Dorado", "Fresno", "Glenn", "Humboldt", "Imperial", "Inyo", "Kern", "Kings", "Lake", "Lassen",
  "Los Angeles", "Madera", "Marin", "Mariposa", "Mendocino", "Merced", "Modoc", "Mono", "Monterey",
  "Napa", "Nevada", "Orange", "Placer", "Plumas", "Riverside", "Sacramento", "San Benito",
  "San Bernardino", "San Diego", "San Francisco", "San Joaquin", "San Luis Obispo", "San Mateo",
  "Santa Barbara", "Santa Clara", "Santa Cruz", "Shasta", "Sierra", "Siskiyou", "Solano", "Sonoma",
  "Stanislaus", "Sutter", "Tehama", "Trinity", "Tulare", "Tuolumne", "Ventura", "Yolo", "Yuba"
)

race <- unique(test_data$Race) 

natorigin <- unique(test_data$`Place of Birth`)

yearoffense <- 1970:2025

penalcode <- test_data %>%
  dplyr::select(
    `Offense Modifier`,
    Offense,
    Off_Enh1, Off_Enh2, Off_Enh3, Off_Enh4, Off_Enh5
  ) %>%
  unlist(use.names = FALSE) %>%
  na.omit()


# Define UI for application
fluidPage(
  useShinyjs(),
  
  tags$head(
    # Load Lato from Google Fonts
    tags$link(
      href = "https://fonts.googleapis.com/css2?family=Lato:wght@200;400;600&display=swap",
      rel = "stylesheet"
    ),
    # Apply OSPD typography & colors globally
    tags$style(HTML("
    body, h1, h2, h3, h4, h5, h6, p {
      font-family: 'Lato', sans-serif;
      color: #222;
    }
    h2 {
      font-weight: 600; 
      color: #c45722
    }
     .btn-success {
      background-color: #e18432 !important;
      color: white !important;
      border-color: #da6127 !important;
    }
    /* Hover */
    .btn-success:hover {
      background-color: #da6127 !important;
      border-color: #e18432 !important;
      color: white !important;
    }
    /* Focus (after click) */
    .btn-success:focus,
    .btn-success.focus {
      background-color: #da6127 !important;
      border-color: #e18432 !important;
      color: white !important;
      box-shadow: none !important;
    }
    /* Active (while clicking) */
    .btn-success:active,
    .btn-success.active,
    .open > .dropdown-toggle.btn-success {
      background-color: #da6127 !important;
      border-color: #e18432 !important;
      color: white !important;
      box-shadow: none !important;
    }

  "))
  ),
  
  div(
    class = "title-panel",
    style = "background-color: white; padding: 7px;",
    fluidRow(
      column(
        width = 2,
        div(
          style = "display: flex; align-items: center; justify-content: flex-start;",
          tags$img(src = "ospd-logo.png", height = "100px", style = "max-height:100px;")
        )
      ),
      column(
        width = 8,
        div(
          style = "display: flex; align-items: center; justify-content: flex-start;",
          h1("California Racial Justice Act Dashboard",
             style = "margin: 0.5; font-weight: 600; color: #444444")
        )
      )
    )
  ),
  
  tags$head(
    tags$style(HTML("
    /* Dark sidebar background & text */
    .dark-sidebar {
      background-color: #e6e6e8 !important;
      color: white !important;
      border: none;
      padding: 15px;
    }
    /* Make headings, labels, and paragraph text white */
    .dark-sidebar h1,
    .dark-sidebar h2,
    .dark-sidebar h3,
    .dark-sidebar h4,
    .dark-sidebar h5,
    .dark-sidebar h6,
    .dark-sidebar label,
    .dark-sidebar p,
    .dark-sidebar span {
      color: #222 !important;
    }
    /* Keep dropdown text readable when open */
    .dark-sidebar .selectize-input {
      background-color: white;
      color: black;
    }
    .dark-sidebar .selectize-dropdown {
      background-color: white;
      color: black;
    }
    /* Style action buttons inside sidebar */
    .dark-sidebar .btn {
      background-color: #e18432;
      color: white;
      border: none;
    }
    .dark-sidebar .btn:hover {
      background-color: #da6127;
      color: white;
    }
  "))
  ),

    # Sidebar with a drop down selection menu for user inputs
    sidebarLayout(
        sidebarPanel(
          class = "dark-sidebar",
          width = 4,
          h3(em(strong("Create Court Report", style = "color: #605e9b;"))),
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
          
          div(
            p("Select Penal Code Sections / Enhancements:", style = "font-weight: bold;"),
            p("Select every code associated with the case of interest. This section includes offense penal codes, offense modifiers, and enhancements.
              Each code can only be selected once. Choose highest/most severe base sentence if necessary."),
            selectizeInput(
              inputId = "select_penalcode",
              label = NULL,
              choices = NULL,
              multiple = TRUE
            )
          ),
          uiOutput("penalcode_details"),
        
          selectInput(
            "select_race",
            "Select Race of Interest:",
            choices = race,
            selectize = TRUE
          ),
          selectInput(
            "select_natorigin",
            "Select Place of Birth:",
            choices = natorigin,
            selectize = TRUE
          )
        ),
        
    # Show results and download button
        mainPanel(
          fluidRow(
            column(7,
                   h2("Using the Dashboard"),
                   h4("Step 1"),
                   p("Make selections in the panel to the left. First select county and year of conviction for the case. Then select every penal code associated with
            the case of interest. For each penal code selection made, a new menu will open asking for more details."),
                   h4("Step 2"),
                   p("For each menu associated with selected penal codes, select the sentence length in years and months. Life with parole and life without parole included.* Also select if the sentence was served consecutively or not.
                     Then fill in the rest of selection menus as normal."),
                   h4("Step 3", style = "margin-top: 10px;"),
                   p('After each selection is made the report will update. Click the "Download Full Report" button to save
            the entire report to device for printing. The report will contain any relevant disparity information compiled from selections.'),
                   p("*Capital punishment (death penalty) not available for this tool. Please message OSPD for details.", style = "font-size: 12px; color: #555;")),
            column(5, 
                   h4("Download the generated report below:"),
                   downloadButton("report", "Download Full Report", class = "btn-success", style = "padding: 8px 16px; font-size: 14px;"))
          ),
          br(),
          h2("Overview"),
          p("Some general stats based on user inputs."))
    )
)
