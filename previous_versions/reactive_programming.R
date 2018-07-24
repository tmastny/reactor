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
  vals <- reactiveValues()
  # f %<<% function(a) {a + 1}


  `%<<%` <- function(var, val) {
    .subset2(vals, 'impl')$set(deparse(enexpr(var)), val)
    val
  }

  output$out1 <- renderPrint({
    a <- lobstr::ast(!!parse_expr(input$box1))
    if (a[[1]] == "█─`%<<%`") {
      eval_tidy(parse_expr(input$box1), isolate(reactiveValuesToList(vals)))
    } else {
      eval_tidy(parse_expr(input$box1), reactiveValuesToList(vals))
    }

    #eval_tidy(parse_expr(input$box1), isolate(reactiveValuesToList(vals)))
  })
  output$out2 <- renderPrint({
    eval_tidy(parse_expr(input$box2), reactiveValuesToList(vals))
  })
  output$out3 <- renderPrint({
    eval_tidy(parse_expr(input$box3), reactiveValuesToList(vals))
  })
  output$out4 <- renderPrint({
    eval_tidy(parse_expr(input$box4), reactiveValuesToList(vals))
  })
  output$out5 <- renderPlot({
    eval_tidy(parse_expr(input$box5), reactiveValuesToList(vals))
  })


  reactive_eval <- function(x) {
    eval_tidy(parse_expr(x))#, .subset2(vals, 'impl')$toList())
  }
}
# profvis::profvis({
#   runApp(shinyApp(ui, server))
# })

# eval(expr(vals$UQ(enexpr(var)) <<- val))

runApp(shinyApp(ui, server))











