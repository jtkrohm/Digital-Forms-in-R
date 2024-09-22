library(shiny)
library(mongolite)

# Connect to MongoDB
mongo <- mongo(collection = "blood_pressure", db = "health_records_jt", url = "mongodb://localhost:27017/")

# Define UI
ui <- fluidPage(
  titlePanel("Blood Pressure Data Collection"),
  sidebarLayout(
    sidebarPanel(
      textInput("name","Name: ",value = "Jeffon Telesford"),
      numericInput("age","Age: ", value = 28),
      textInput("day_1","Day: "),
      dateInput("date_1","Date: ", format = 'dd-mm-yyyy'),
      textInput("time_1","Time: "),
      textInput("systolic", "Systolic:", value = 120),
      textInput("diastolic", "Diastolic:", value = 80),
      textInput("arm","Arm: ", value = "left"),
      actionButton("save", "Save Data")
    ),
    mainPanel(
      textOutput("status")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  observeEvent(input$save, {
    name <- input$name
    age <- input$age
    day <- input$day_1
    date <- input$date_1
    time <- input$time_1
    systolic <- as.numeric(input$systolic)
    diastolic <- as.numeric(input$diastolic)
    arm <- input$arm
    if (!is.null(systolic) && !is.null(diastolic)) {
      data <- data.frame(
        name = input$name,
        age = as.numeric(input$age),
        day = input$day_1,
        date = input$date_1,
        time = input$time_1,
        systolic_bp = as.numeric(input$systolic),
        diastolic_bp = as.numeric(input$diastolic),
        arm = input$arm
      )
      mongo$insert(data)
      output$status <- renderText("Data saved successfully!")
      updateTextInput(session, "systolic", value = "")
      updateTextInput(session, "diastolic", value = "")
      
      # Reset session to clear inputs
      session$reset()
      
    } else {
      output$status <- renderText("Please enter both systolic and diastolic values.")
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)
