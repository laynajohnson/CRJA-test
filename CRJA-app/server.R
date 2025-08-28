

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
  observeEvent(input$generate, {
    Sys.sleep(1)  # pretend processing time
    
    df <- data.frame(
      county      = input$select_county,
      race        = input$select_race,
      yearoffense = input$select_yearoffense,
      penalcode   = input$select_penalcode,
      enhancements = input$select_enhancements,
      ethnicity   = input$select_ethnicity,
      natorigin   = input$select_natorigin,
      timestamp   = Sys.time(), # would it be helpful to know the website's traffic using this?
      stringsAsFactors = FALSE
    )
    
    file_path <- "selections.csv"
    if (!file.exists(file_path)) {
      write.csv(df, file_path, row.names = FALSE)
    } else {
      write.table(df, file_path, sep = ",", col.names = FALSE,
                  row.names = FALSE, append = TRUE)
    }
    
    report_ready(TRUE)
    shinyjs::enable("report")
  })
  
  output$report <- downloadHandler(
    filename = "report.pdf",
    content = function(file) {
      if (!report_ready()) return(NULL) # prevent download if user has not clicked "generate report"
      
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("report.Rmd", tempReport, overwrite = TRUE)
      
      rmarkdown::render(
        input = tempReport,
        output_file = file,
        params = list(
          county = input$select_county,
          race = input$select_race,
          yearoffense = input$select_yearoffense,
          penalcode = input$select_penalcode,
          enhancements = input$select_enhancements,
          ethnicity = input$select_ethnicity,
          natorigin = input$select_natorigin
          
        ),
        envir = new.env(parent = globalenv())
      )
    }
  )
}


# to render app/update it: rsconnect::deployApp()
