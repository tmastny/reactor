library("shiny")
library("promises")
library("dplyr")
library("future")
plan(multiprocess)

# A function to simulate a long running process
# write.csv(mtcars, "data.csv")
read_csv_async = function(sleep, path){
  log_path = "./mylog.log"
  pid = Sys.getpid()
  write(
    x = paste(format(Sys.time(), "%Y-%m-%d %H:%M:%OS"), "pid:", pid, "Async process started"), file = log_path, append = TRUE)
  Sys.sleep(sleep)
  df = read.csv(path)
  write(
    x = paste(format(Sys.time(), "%Y-%m-%d %H:%M:%OS"), "pid:", pid, "Async process work completed\n"), file = log_path, append = TRUE)
  df = read.csv(path)
  df
}

ui <- fluidPage(
  actionButton(
    inputId = "submit_and_retrieve", 
    label = "Submit short async analysis"
  ),
  br(),
  br(),
  tableOutput("user_content"),
  
  br(),
  br(),
  br(),
  hr(),
  
  sliderInput(
    inputId = "hist_slider_val",
    label = "Histogram slider",
    value = 25, 
    min = 1,
    max = 100
  ),
  
  plotOutput("userHist")
)

server <- function(input, output){
  parent_pid = Sys.getpid()
  
  # When button is clicked
  # load csv asynchronously and render table
  data <- reactiveVal()
  observeEvent(input$submit_and_retrieve, {
    future({ read_csv_async(2, "./data.csv") }) %...T>%
      {data(NULL)} %...>%
      data() %...!%  # Assign to data
      (function(e) {
        data(NULL)
        warning(e)
        session$close()
      })
    
    # Hide the async operation from Shiny by not having the promise be
    # the last expression.
    NULL
  })
  output$user_content <- renderTable({
    req(data()) %>% sample_n(5)
  })
  
  
  # Render a new histogram 
  # every time the slider is moved
  output$userHist = renderPlot({
    hist(rnorm(input$hist_slider_val))
  })
}

shinyApp(ui, server)