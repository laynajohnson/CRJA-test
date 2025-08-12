

library(shiny)

library(tidyverse)
library(ggplot2)
library(htmltools)

# Define server logic for selections and downloads
function(input, output, session) {

  output$value <- renderText({input$select})
  
 
  output$report <- downloadHandler(
    filename = "report.pdf",
    content = function(file) {
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("report.Rmd", tempReport, overwrite = TRUE)
      
      rmarkdown::render(
        input = tempReport,
        output_file = file,
        params = list(n = input$select_county),
        envir = new.env(parent = globalenv())
      )
    }
  )
  

}
