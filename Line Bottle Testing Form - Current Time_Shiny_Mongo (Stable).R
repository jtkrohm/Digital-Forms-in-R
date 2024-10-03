library(shiny)
library(openxlsx)  # For working with Excel files
library(plotly)
library(ggplot2)
library(dplyr)
library(lubridate)
library(mongolite)


#Connect to Mongo
mongo <- mongo(collection = "line_bottle_data", db = "management_systems", url="mongodb://localhost:27017")

#The dataframe should have a variable/column which identifies the document code of the associated online form

# Specify the path to the downloads folder
downloads_path <-file.path(Sys.getenv("USERPROFILE"), "Downloads")
file_path <- file.path(downloads_path, "alcohol_data.xlsx")


# Define UI
ui <- fluidPage(
  titlePanel("Line Bottle Data Collection"),
  sidebarLayout(
    sidebarPanel(
      textOutput("current_time"),  # Display current time
      dateInput("date", "Date"),
      textInput("sku", "SKU"),
      numericInput("bottle_size", "Bottle Size (ml)", value = 750),
      numericInput("fill_height", "Fill Height (mm)", value = 700),
      numericInput("weight", "Weight (g)", value = 800),
      numericInput("ph", "pH", value = 7, min = 0, max = 14),
      numericInput("conductivity", "Conductivity (µS/cm)", value = 100),
      actionButton("save", "Save")
    ),
    mainPanel( 
      tabsetPanel(
        tabPanel("Data Table", tableOutput("data_table")),
        tabPanel("Plot", plotlyOutput("plot", height = "400px"))
      )
    )
  )
)

# Define server
server <- function(input, output, session) {
  # Display current time
  output$current_time <- renderText({
    paste("Current Time:", format(Sys.time(), "%H:%M"))
  })
  
  
  if (file.exists(file_path)) {
    alcohol_df <- read.xlsx(file_path)
    print(alcohol_df)
  } else {
    # Initialize an empty dataframe
    alcohol_df <- data.frame(
      Time = character(),
      Date = character(),
      SKU = character(),
      Bottle_Size = numeric(),
      Fill_Height = numeric(),
      Weight = numeric(),
      pH = numeric(),
      Conductivity = numeric()
    )
    print(alcohol_df)
  }
  
  
  
  observeEvent(input$save, {
    new_row <- data.frame(
      Time = format(Sys.time(), "%H:%M"),  # Capture current time
      Date = as.character(input$date),
      SKU = input$sku,
      Bottle_Size = input$bottle_size,
      Fill_Height = input$fill_height,
      Weight = input$weight,
      pH = input$ph,
      Conductivity = input$conductivity
    )
    mongo$insert(new_row)
    alcohol_df <- rbind(alcohol_df, new_row)
    
    print(alcohol_df)
    
    # Save as Excel file
    write.xlsx(alcohol_df, file.path(downloads_path, "alcohol_data.xlsx"), append = TRUE)
    
    # Print a message indicating where the file was saved
    cat("Data saved to:", file.path(downloads_path, "alcohol_data.xlsx"), "\n")
    
    session$reload()  #How to Run Shiny App Without Opening RStudio
    
  })
  
  
  output$data_table <- renderTable({ #render the rail of the data frame instead
    tail(alcohol_df, 10)
  })
  
  output$plot <- renderPlotly({
   # filtered_data <- data %>% filter(Date >= input$date_range[1] & Date <= input$date_range[2])
    ggplot(alcohol_df, aes(x = Time, y = pH)) +
      geom_line(stat = "identity", color = "steelblue") +
      geom_text(aes(label = pH), vjust = -0.3, hjust = 1.5) +
      geom_hline(aes(yintercept = 7), color = "red", linetype = "dashed") +
      annotate("text", x = max(alcohol_df$Time), y = 7, label = "Min = 7", vjust = -1) +
      geom_hline(aes(yintercept = 12), color = "red", linetype = "dashed") +
      annotate("text", x = max(alcohol_df$Time), y = 12, label = "Max = 12", vjust = -1) +
      theme_minimal() +
      labs(title = "Bar Graph showing pH", x = "Time", y = "pH Value") +
      theme(plot.title = element_text(hjust = 0.5))
  })
  
}

# Run the app
shinyApp(ui, server)
