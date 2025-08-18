

library(shiny)
library(shinyjs)

library(tidyverse)
library(ggplot2)
library(htmltools)

# Define server logic for selections and downloads
function(input, output, session) {
  
  library(shinyjs)
  
  report_ready <- reactiveVal(FALSE)
  
  shinyjs::disable("report") # disable download until ready
  
  # Generate the report
  observeEvent(input$generate, {
    Sys.sleep(1)  # pretend processing time
    report_ready(TRUE)
    shinyjs::enable("report")
  })
  
  output$report <- downloadHandler(
    filename = "report.pdf",
    content = function(file) {
      if (!report_ready()) return(NULL) # prevent download if not ready
      
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("report.Rmd", tempReport, overwrite = TRUE)
      
      rmarkdown::render(
        input = tempReport,
        output_file = file,
        params = list(
          county = input$select_county,
          ethrace = input$select_ethrace,
          gender = input$select_gender
        ),
        envir = new.env(parent = globalenv())
      )
    }
  )
}


# to render app/update it: rsconnect::deployApp()
