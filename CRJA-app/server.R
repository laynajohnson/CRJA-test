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
    tibble( # does missing § symbol make this not work?? why wont it show up??
      value = as.character(na.omit(unique(test_data$`Offense Modifier`))),
      label = as.character(na.omit(unique(test_data$`Offense Modifier`))),
      optgroup = "Offense Modifier"
    ),
    tibble(
      value = as.character(na.omit(unique(test_data$Offense))),
      label = as.character(na.omit(unique(test_data$Offense))),
      optgroup = "Offense"
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
  
  senyears <- c("0 years", "1 year", paste0(2:30, " years"), "Life with Parole", "Life without Parole")
  
  
  output$penalcode_details <- renderUI({
    req(input$select_penalcode)  # only run if something is selected
    
    # Loop over each selected penal code and create a UI block
    lapply(input$select_penalcode, function(code) {
      wellPanel(
        h5(code),  # heading with the penal code value
        p("Sentence Length"),
        fluidRow(
          column(
            width = 4,
            selectInput(
              inputId = paste0("sentencelen_", code),
              label = "Years:",
              choices = senyears,
              selected = NULL
            )
          ),
          column(
            width = 4,
            selectInput(
              inputId = paste0("sentencemonths_", code),
              label = "Months:",
              choices = c("0 months", "2 months", "4 months", "6 months", "8 months", "10 months"),
              selected = NULL
            )
          )
        ),
        radioButtons(
          inputId = paste0("servedconsec_", code),
          label = "Served consecutively?",
          choices = c("Yes", "No", "Not sure"),
          selected = "Not sure",
          inline = TRUE
        )
      )
    })
  })
  
  # helper to generate next userID
  next_userid <- function(file_path) {
    # if file doesn't exist or is empty, start at 000001
    if (!file.exists(file_path) || file.info(file_path)$size == 0) {
      return(sprintf("%06d", 1))
    } else {
      existing <- read.csv(file_path, stringsAsFactors = FALSE)
      if (nrow(existing) == 0) {
        return(sprintf("%06d", 1))
      } else {
        last_id <- max(as.integer(existing$userID), na.rm = TRUE)
        return(sprintf("%06d", last_id + 1))
      }
    }
  }
  
   # --- Saving to CSV ---
   output$report <- downloadHandler(
    filename = "report.pdf",
    content = function(file) {
      
      file_path <- "selections.csv"
      userID <- next_userid(file_path)
      
      # penal codes into multiple rows
      penalcodes <- input$select_penalcode
      if (length(penalcodes) == 0) penalcodes <- NA_character_
      
      df <- do.call(rbind, lapply(penalcodes, function(code) {
        data.frame(
          userID         = userID,
          county         = input$select_county,
          race           = input$select_race,
          yearoffense    = input$select_yearoffense,
          penalcode      = code,
          sentencelen    = input[[paste0("sentencelen_", code)]],
          sentencemonths = input[[paste0("sentencemonths_", code)]],
          servedconsec   = input[[paste0("servedconsec_", code)]],
          natorigin      = input$select_natorigin,
          timestamp      = Sys.Date(),
          stringsAsFactors = FALSE
        )
      }))
      
      # Save to CSV
      if (!file.exists(file_path)) {
        write.csv(df, file_path, row.names = FALSE)
      } else {
        write.table(df, file_path, sep = ",", col.names = FALSE,
                    row.names = FALSE, append = TRUE)
      }
      
      
      
      # --- Render the report ---
      tempReport <- file.path(tempdir(), "report.Rmd") 
      file.copy("report.Rmd", tempReport, overwrite = TRUE) 
      
      #Data frame to hold penal codes
      penalcodes <- input$select_penalcode
      if (length(penalcodes) == 0) penalcodes <- NA_character_
      
      penal_df <- do.call(rbind, lapply(penalcodes, function(code) {
        data.frame(
          penalcode      = code,
          sentencelen    = input[[paste0("sentencelen_", code)]],
          sentencemonths = input[[paste0("sentencemonths_", code)]],
          servedconsec   = input[[paste0("servedconsec_", code)]],
          stringsAsFactors = FALSE
        )
      }))
      
      # render
      rmarkdown::render(
        input = tempReport,
        output_file = file,
        params = list(
          county       = input$select_county,
          race         = input$select_race,
          yearoffense  = input$select_yearoffense,
          penaldata   = penal_df,
          natorigin    = input$select_natorigin
        ),
        envir = new.env(parent = globalenv())
      )
    }
  )
}