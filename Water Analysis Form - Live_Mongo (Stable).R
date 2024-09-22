library(shiny)
library(openxlsx) 
library(dplyr)
library(lubridate)
library(mongolite)


#Connect to MongoDB
mongo <- mongo(collection = "water_parameters", db = "water_treatment", url = "mongodb://localhost:27017/")

#Specificy the Document Code
document_code <- "xyzabc123"

# Specify the path to the downloads folder
downloads_path <-file.path(Sys.getenv("USERPROFILE"), "Downloads")
file_path <- file.path(downloads_path, "water_test_data.xlsx")

ui <- fluidPage(
  titlePanel("Water Test Analysis Form"),
  h4( document_code),
  sidebarLayout(
    sidebarPanel(
     # textOutput("document_code", "Document Code:"),
      textInput("time", "Time"),
      dateInput("date", "Date"),
      selectInput("sample_point", "Sample Point", choices = c("Boiler Effluent", "Boiler Feed", "Raw Water", "Treated Water")),  #You can have a variable for all the choices
      numericInput("ph", "pH", value = 7.0, min = 0, max = 14),
      numericInput("conductivity", "Conductivity (µS/cm)", value = 100, min = 0),
      numericInput("chlorine", "Chlorine (mg/L)", value = 0.5, min = 0),
      numericInput("alkalinity", "Alkalinity (mg/L)", value = 50, min = 0),
      numericInput("sulphur", "Sulphur (mg/L)", value = 2, min = 0),
      checkboxInput("retested", "Retested Sample Point"),
      actionButton("save", "Save")
    ),
    mainPanel(
      verbatimTextOutput("results")
    )
  )
)

server <- function(input, output, session) {
  output$results <- renderPrint({
    cat("Form Entry:", "\n","\n")
    cat("Document Code:", document_code, "\n")
    cat("Time:",input$time, "\n")
    cat("Date:", as.character(input$date, origin = "1970-01-01") , "\n")
    cat("Sample Point:", input$sample_point, "\n")
    cat("pH:", input$ph, "\n")
    cat("Conductivity (µS/cm):", input$conductivity, "\n")
    cat("Chlorine (mg/L):", input$chlorine, "\n")
    cat("Alkalinity (mg/L):", input$alkalinity, "\n")
    cat("Sulphur (mg/L):", input$sulphur, "\n")
    cat("Retested Sample Point:", ifelse(input$retested, "Yes", "No"), "\n")
  })
  
  if (file.exists(file_path)) {
    water_test_df <- read.xlsx(file_path)
  } else {
    # Initialize an empty dataframe
    water_test_df <- data.frame(
      Time = character(),
      Date = as.Date(character()),
      Doc_Code = character(),
      Sample_Point = as.factor(character()),
      pH = numeric(),
      Conductivity = numeric(),
      Chlorine = numeric(),
      Alkalinity = numeric(),
      Sulphur = numeric(),
      Retested = logical()
    )
   # print(water_test_df)
  }
  
  observeEvent(input$save, {
    new_row <- data.frame(
      Time = input$time,
      Date = input$date,
      Doc_Code = document_code,
      Sample_Point = input$sample_point,
      pH = input$ph,
      Conductivity = input$conductivity,
      Chlorine = input$chlorine,
      Alkalinity = input$alkalinity,
      Sulphur = input$sulphur,
      Retested = input$retested
    )
    mongo$insert(new_row)
    print("")
    print(new_row)
    print("")
  
    water_test_df <- rbind(water_test_df, new_row)
    
    print(water_test_df)
    print("")
    # Save as Excel file
    write.xlsx(water_test_df, file_path, append = TRUE)
    
    # Print a message indicating where the file was saved
    cat("Data saved to:", file_path, "\n")
    
    session$reload()
  })
  
}

shinyApp(ui, server)
