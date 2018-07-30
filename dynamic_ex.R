library(shiny)

ui <- fluidPage(
  #includeScript('www/enter_bind.js'),
  singleton(tags$head(tags$script(src = "enter_bind.js"))),
  tags$input(type='command', id='command1', class='reactnb-command',
             autocomplete='off', autocorrect='off'
  ),
  tags$br(),
  # tags$input(type='command', id='command2', class='reactnb-command',
  #            autocomplete='off', autocorrect='off'
  # ),
  verbatimTextOutput("o1"),
  verbatimTextOutput("o2"),
  verbatimTextOutput("o3")
)
server <- function(input, output) {
  output$o1 <- renderPrint({
    input$command1
  })
  output$o2 <- renderPrint({
    input$command2
  })
  output$o3 <- renderPrint({
    print(reactiveValuesToList(input))
  })
}

runApp(shinyApp(ui, server), launch.browser = TRUE)

# it looks like `input$...` works on element id. However,
# in the example app, the input is of type `shiny-bound-input`.

# I believe this happens with a call to `Shiny.inputBindings.register(...)`

