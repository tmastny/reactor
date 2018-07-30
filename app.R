ui <- fluidPage(
  singleton(tags$head(tags$script(src = "enter_bind.js"))),
  tags$input(type='command', id='command1', class='reactnb-command',
             autocomplete='off', autocorrect='off'
  ),
  tags$br()
  # verbatimTextOutput("o1"),
  # verbatimTextOutput("o2"),
  # verbatimTextOutput("o3")
)
server <- function(input, output) {
  output$o1 <- renderPrint({
    input$command1
  })
  output$o2 <- renderPrint({
    input$command2
  })
}

shinyApp(ui, server)