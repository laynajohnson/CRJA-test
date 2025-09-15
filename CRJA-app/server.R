library(shiny)
library(shinyjs)
library(tidyverse)
library(ggplot2)
library(htmltools)

function(input, output, session) {
  
  library(dplyr)
  library(tibble)
  
  #Combining the penal code, enhancements, and offense modifiers into one
  penalcode_df <- bind_rows(
    tibble(
      value = as.character(na.omit(unique(test_data$Offense))),
      label = as.character(na.omit(unique(test_data$Offense))),
      optgroup = "Offense"
    ),
    tibble(
      value = as.character(na.omit(unique(test_data$`Offense Modifier`))),
      label = as.character(na.omit(unique(test_data$`Offense Modifier`))),
      optgroup = "Offense Modifier"
    ),
    tibble(
      value = as.character(na.omit(unique(c(
        test_data$Off_Enh1, test_data$Off_Enh2, test_data$Off_Enh3,
        test_data$Off_Enh4, test_data$Off_Enh5
      )))),
      label = as.character(na.omit(unique(c(
        test_data$Off_Enh1, test_data$Off_Enh2, test_data$Off_Enh3,
        test_data$Off_Enh4, test_data$Off_Enh5
      )))),
      optgroup = "Enhancements"
    )
  ) %>%
    arrange(optgroup, label)
  
  # Convert to grouped list for selectize
  penalcode_choices <- split(penalcode_df$label, penalcode_df$optgroup)
  
  updateSelectizeInput(
    session,
    inputId = "select_penalcode",
    choices = penalcode_choices,
    server = TRUE
  )
  
  output$penalcode_details <- renderUI({
    req(input$select_penalcode)  # only run if something is selected
    
    # Loop over each selected penal code and create a UI block
    lapply(input$select_penalcode, function(code) {
      wellPanel(
        h4(code),  # heading with the penal code value
        selectInput(
          inputId = paste0("sentencelen_", code),
          label = "Sentence length:",
          choices = c("0-1 years", "1-3 years", "3-5 years", "5+ years"),
          selected = NULL
        ),
        radioButtons(
          inputId = paste0("servedconsec_", code),
          label = "Served consecutively?",
          choices = c("Yes", "No", "Not sure"),
          selected = NULL,
          inline = TRUE
        )
      )
    })
  })
  
  output$penalcode_details <- renderUI({
    req(input$select_penalcode)  # only run if something is selected
    
    # Loop over each selected penal code and create a UI block
    lapply(input$select_penalcode, function(code) {
      wellPanel(
        h4(code),  # heading with the penal code value
        selectInput(
          inputId = paste0("sentencelen_", code),
          label = "Sentence length:",
          choices = c("0-1 years", "1-3 years", "3-5 years", "5+ years"),
          selected = NULL
        ),
        radioButtons(
          inputId = paste0("servedconsec_", code),
          label = "Served consecutively?",
          choices = c("Yes", "No", "Not sure"),
          selected = NULL,
          inline = TRUE
        )
      )
    })
  })
  
  # Helper to collapse multi-selects into a single string
  scalarize <- function(x, collapse = ", ") {
    if (length(x) == 0) return(NA_character_)
    if (length(x) == 1) return(as.character(x))
    paste(x, collapse = collapse)
  }
  
  output$report <- downloadHandler(
    filename = "report.pdf",
    content = function(file) {
      
      # --- Save selections to CSV ---
      df <- data.frame(
        county       = input$select_county,
        race         = input$select_race,
        yearoffense  = input$select_yearoffense,
        penalcode    = scalarize(input$select_penalcode),
        # enhancements = scalarize(input$select_enhancements),
        natorigin    = input$select_natorigin,
        timestamp    = Sys.Date(),
        stringsAsFactors = FALSE
      )
      
      file_path <- "selections.csv"
      if (!file.exists(file_path)) {
        write.csv(df, file_path, row.names = FALSE)
      } else {
        write.table(df, file_path, sep = ",", col.names = FALSE,
                    row.names = FALSE, append = TRUE)
      }
      # --- End CSV save ---
      
      # --- Render the report ---
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("report.Rmd", tempReport, overwrite = TRUE)
      
      # enh_val <- if (length(input$select_enhancements) == 0) {
      #   "None Selected"
      # } else {
      #   paste(input$select_enhancements, collapse = ", ")
      # }
      
      rmarkdown::render(
        input = tempReport,
        output_file = file,
        params = list(
          county       = input$select_county,
          race         = input$select_race,
          yearoffense  = input$select_yearoffense,
          penalcode    = input$select_penalcode,
          # enhancements = enh_val,
          natorigin    = input$select_natorigin
        ),
        envir = new.env(parent = globalenv())
      )
    }
  )
}