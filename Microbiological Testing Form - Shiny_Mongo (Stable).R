library(shiny)
library(lubridate)
library(ggplot2)
library(mongolite)


#Connect to Mongo
mongo <- mongo(collection = "microbiological_data", db = "management_systems", url="mongodb://localhost:27017")


##TEST THIS FORM FOR USABILITY



# Specify the path to the downloads folder
downloads_path <-file.path(Sys.getenv("USERPROFILE"), "Downloads")
file_path <- file.path(downloads_path, "microbial_growth_data.xlsx")
document_code <- "xyzabc123"
inoculation_choices <- c("Yeast and Mold","Preservative Resistant Yeast", "TGE (Tryptone Glucose Extract)", "M-Coli Blue", "Enterobacter")

#Define Application UI
ui <- fluidPage(
  titlePanel("Microbiological Growth Assessment Form"),
  h5('Document Code: ',document_code),
  sidebarLayout(
    sidebarPanel(
      dateInput("observation_date","Observation Date"),
      textInput("sample_point","Sample Point", value = "Enter Sample Area"),
      textInput("sample_code","Sample Code", value = "xyzabc"),
      dateInput("sample_date", "Sample Date"),
      selectInput("inoculation_test","Inoculation Test", choices = inoculation_choices),
      numericInput("growth_count_24","Growth Count 24 Hours", value = 16),
      numericInput("growth_count_48","Growth Count 48 Hours", value = 16),
      numericInput("growth_count_72","Growth Count 72 Hours", value = 16),
      numericInput("growth_count_96","Growth Count 96 Hours", value = 16),
      numericInput("growth_count_120","Growth Count 120 Hours", value = 16),
      checkboxInput("retest","Sample Retest"),
      actionButton("submit", "Submit")
      
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Form to Be Entered",verbatimTextOutput("results")),
        tabPanel("Data Table",tableOutput("data_table")),
        tabPanel("Plot", plotlyOutput("plot", height = "400px"))
      )
    )
  )
)



#Define Server Logic 

server <- function(input,output, session) {
  output$results <- renderPrint({
    cat("Form Entry: ","\n","\n")
    cat("Observation Date: ",as.character(input$observation_date , origin = "1970-01-01"), "\n")
    cat("Sample Point: ", input$sample_point, "\n")
    cat("Sample Code: ", input$sample_code, "\n")
    cat("Sample Date: ", as.character(input$sample_date, origin = "1970-01-01"),"\n")
    cat("Inoculation Test: ",input$inoculation_test, "\n")
    cat("Growth Count (24 Hours): ", input$growth_count_24, "\n")
    cat("Growth Count (48 Hours): ", input$growth_count_48, "\n")
    cat("Growth Count (72 Hours): ", input$growth_count_72, "\n")
    cat("Growth Count (96 Hours): ", input$growth_count_96, "\n")
    cat("Growth Count (120 Hours): ", input$growth_count_120, "\n")
    cat("Retested Sample: ", ifelse(input$retest, "Yes", "No"), "\n")
    
  })
  
  
  if (file.exists(file_path)) {
    microbial_test_df <- read.xlsx(file_path)
  } else {
    # Initialize an empty dataframe
    microbial_test_df <- data.frame(
      Doc_Code = character(),
      Observation_Date = as.Date(character()),
      Sample_Point = character(),
      Sample_Code = character(),
      Sample_Date = as.Date(character()),
      Inoculation_Test = as.factor(character()),
      Growth_Count_24 = numeric(),
      Growth_Count_48 = numeric(),
      Growth_Count_72 = numeric(),
      Growth_Count_96 = numeric(),
      Growth_Count_120 = numeric(),
      Retest = logical()
    )
    # print(microbial_test_df)
  }
  
  observeEvent(input$submit, {   #FIIIIIIIIIIIIIIXXXXXX
    new_row <- data.frame(
      Doc_Code = document_code,
      Observation_Date = input$date,
      Sample_Point = input$sample_point,
      Sample_Code = input$sample_code,
      Sample_Point = input$sample_point,
      Sample_Date = input$sample_date,
      Inoculation_Test = input$inoculation_test,
      Growth_Count_24 = input$growth_count_24,
      Growth_Count_48 = input$growth_count_48,
      Growth_Count_72 = input$growth_count_72,
      Growth_Count_96 = input$growth_count_96,
      Growth_Count_120 = input$growth_count_120,
      Retest = input$retest
    )
    mongo$insert(new_row)
    print("")
    print(new_row)
    print("")
    
    microbial_test_df <- rbind( microbial_test_df, new_row)
    
    print( microbial_test_df)
    print("")
    # Save as Excel file
    write.xlsx( microbial_test_df, file_path, append = TRUE)
    
    # Print a message indicating where the file was saved
    cat("Data saved to:", file_path, "\n")
    
    session$reload()
  })
  
  output$data_table <- renderTable({ #render the rail of the data frame instead
    tail(microbial_test_df, 10)
  })
  #output$plot <- renderPlotly({ })

}

#Start the server
shinyApp(ui,server)