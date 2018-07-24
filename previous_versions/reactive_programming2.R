library(shiny)
library(rlang)

ui <- fluidPage(
  textInput("box1", NULL, ""),
  verbatimTextOutput("out1"),
  textInput("box2", NULL, ""),
  verbatimTextOutput("out2"),
  textInput("box3", NULL, ""),
  verbatimTextOutput("out3"),
  textInput("box4", NULL, ""),
  verbatimTextOutput("out4"),
  textInput("box5", NULL, ""),
  plotOutput("out5")
)
server <- function(input, output) {
  # f %<<% function(a) {a + 1}

  `%<<%` <- function(var, val) {
    eval(expr(!!enexpr(var) <<- reactive(quote(val), quoted = TRUE)))
    val
  }

  output$out1 <- renderPrint({
    eval_tidy(parse_expr(input$box1))
  })
  output$out2 <- renderPrint({
    eval(parse_expr(input$box2))
  })
  output$out3 <- renderPrint({
    eval_tidy(parse_expr(input$box3))
  })
  output$out4 <- renderPrint({
    eval_tidy(parse_expr(input$box4))
  })
  output$out5 <- renderPlot({
    eval_tidy(parse_expr(input$box5))
  })


  reactive_eval <- function(x) {
    eval_tidy(parse_expr(x))#, .subset2(vals, 'impl')$toList())
  }
}
# profvis::profvis({
#   runApp(shinyApp(ui, server))
# })

runApp(shinyApp(ui, server))











