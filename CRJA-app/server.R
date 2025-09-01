

library(shiny)
library(shinyjs)

library(tidyverse)
library(ggplot2)
library(htmltools)

# server logic for selections and downloads
function(input, output, session) {
  
  library(shinyjs)
  
  report_ready <- reactiveVal(FALSE)
  
  shinyjs::disable("report") # disable download until ready
  
  # Generate the report and save data to csv
  observeEvent(input$generate, { #if the generate report event happens then do the following
    Sys.sleep(1)  # pretend processing time, can remove or make longer
    
    df <- data.frame(
      county      = input$select_county,
      race        = input$select_race,
      yearoffense = input$select_yearoffense,
      penalcode   = input$select_penalcode,
      enhancements = input$select_enhancements,
      natorigin   = input$select_natorigin,
      timestamp   = Sys.Date(), # would it be helpful to know the website's traffic using this?
      stringsAsFactors = FALSE
    )
    
    file_path <- "selections.csv" # save here
    if (!file.exists(file_path)) {
      write.csv(df, file_path, row.names = FALSE)
    } else {
      write.table(df, file_path, sep = ",", col.names = FALSE,
                  row.names = FALSE, append = TRUE)
    }
    
    report_ready(TRUE)
    shinyjs::enable("report")
  })
  
  output$report <- downloadHandler( # the report users can download
    filename = "report.pdf",
    content = function(file) {
      if (!report_ready()) return(NULL) # no download if user has not clicked "generate report"
      
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("report.Rmd", tempReport, overwrite = TRUE) # will overwrite the default report document and fill in the selected information
      
      rmarkdown::render(
        input = tempReport,
        output_file = file,
        params = list(    # From the selectInputs in ui.R, will take these parameters for report
          county = input$select_county,
          race = input$select_race,
          yearoffense = input$select_yearoffense,
          penalcode = input$select_penalcode,
          enhancements = input$select_enhancements,
          natorigin = input$select_natorigin
        ),
        envir = new.env(parent = globalenv())
      )
    }
  )
}


# to render app/update it: rsconnect::deployApp()
