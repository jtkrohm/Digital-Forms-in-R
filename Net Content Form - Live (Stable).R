library(shiny)
library(openxlsx)
library(dplyr)
library(lubridate)


# Create a shiny form that collects current time, date, bottle code, ddm, SKU, 
# bottle size, bottle weight. This form can be used on the bottling line at 
# different bottling companies by qc technicians to periodically measure 
# net content values to assess the net content process capability of the
# filling machine. The alcohol density (anton paar) and bottle weight 
# (weighing machine) will give a calculation of the volume of alcohol in the bottle


#Specificy the Document Code
document_code <- "xyzabc123"

sku_list <- c('Pure White','Old Grog','Campeche')
capacity_list <- c(375,750,1000,5000)

#Define path to output file
downloads_path <- file.path(Sys.getenv("USERPROFILE"),"Downloads")
file_path <- file.path(downloads_path,"net_content_data.xlsx")

#Define Application UI

ui <- fluidPage(titlePanel("Net Content Analysis Form"),
                h4("Document Code: ", document_code),
                sidebarLayout(
                  sidebarPanel(
                   # textInput("time","Time"),
                    dateInput("date","Date"),
                    selectInput("sku","SKU", choices = sku_list),
                    numericInput("bottle_number","Bottle Number", value=100, min = 0),
                    numericInput("bottle_capacity","Bottle Capacity (mL)",value = 750, min = 150 ), #replace with select input
                    numericInput("bottle_weight","Bottle Weight (g)",value = 750, min=150),
                    numericInput("startup_density", "Startup Density (Kg/m3)",value = 0.937, min = 0.4),
                    numericInput("net_content","Net Content",""),
                    #checkboxInput("retested", "Retested Sample Point"),
                    actionButton("submit", "Submit"),
                   
                  ),
                  mainPanel( 
                    tabsetPanel(
                      tabPanel("Form to be Entered",verbatimTextOutput("results")),
                      tabPanel("Time",verbatimTextOutput("time_panel")),
                      tabPanel("Data Table", tableOutput("data_table"))
                    )
                  )
                )
)
  


#Define Server Logic

server <- function(input, output, session) {

  output$results <- renderPrint({
    cat("Form to be Entered:", "\n", "\n")
    cat("Document Code: ", document_code, "\n")
    cat("Date: ", input$date, "\n")
    cat("SKU: ", input$sku, "\n")
    cat("Bottle Number: ", input$bottle_number, "\n")
    cat("Bottle Capacity (mL): ", input$bottle_capacity, "\n")
    cat("Bottle Weight (g): ", input$bottle_weight, "\n") 
    cat("Startup Density (KG/m3): ", input$startup_density, "\n")
    cat("Net Content (mL): ", input$net_content, "\n")
  })
  output$time_panel <- renderText({
    invalidateLater(1000, session)  # Invalidate this reactive expression every 1 second
    format(Sys.time(), "%Y-%m-%d %H:%M:%S")  # Display current time
  })
  
  observeEvent(input$bottle_weight | input$startup_density, {
    updateTextInput(session, "net_content", value = paste((input$bottle_weight)/(input$startup_density)))
  })

  
  if (file.exists(file_path)) {
    net_content_df <- read.xlsx(file_path)
  } else {
    # Initialize an empty dataframe     
    net_content_df <- data.frame(
      Doc_Code = character(),
      Time = character(),
      Date = as.Date(character()),
      SKU = character(),
      Bottle_Number = numeric(),
      Bottle_Capacity = numeric(),
      Bottle_Weight = numeric(),
      Startup_Density = numeric(),
      Net_Content = numeric()
    )
    print(net_content_df)
  }

  
  observeEvent(input$submit, {    
    new_row <- data.frame(
      Doc_Code = document_code,
      Time = format(Sys.time(), "%H:%M"),  # Capture current time
      Date = input$date,
      SKU = input$sku,
      Bottle_Number= input$bottle_number,
      Bottle_Capacity = input$bottle_capacity,
      Bottle_Weight = input$bottle_weight,
      Startup_Density = input$startup_density,
      Net_Content = input$net_content
    )
    net_content_df <- rbind(net_content_df, new_row)
    
    print(net_content_df)
    
    # Save as Excel file
    write.xlsx(net_content_df, file_path, append = TRUE)
    
    # Print a message indicating where the file was saved
    cat("Data saved to:", file_path, "\n")
    
    session$reload()
    
  })
  output$data_table <- renderTable({ #Output the tail of the dataframe instead
    net_content_df
  })
}

#Start the app/server

shinyApp(ui, server)