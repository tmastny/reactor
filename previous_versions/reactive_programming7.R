library(shiny)
library(rlang)
library(promises)
library(future)
plan(multiprocess)

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
  # .subset2(vals, 'impl')$set("f", function(a) {a + 1})

  reactive_eval <- function(x) {
    eval(parse_expr(x))
  }

  vars <- list()

  .out1_react <- reactive({
    a <- parse_expr(input$box1)
    if (a[[1]] == expr(`<-`)) {
      vars[[ ]] <-
    } else {
    eval(a)
    }
  })
  output$out1 <- renderPrint({
    .out1_react()
  })
  output$out2 <- renderPrint({
    reactive_eval(input$box2)
  })
  output$out3 <- renderPrint({
    reactive_eval(input$box3)
  })
  output$out4 <- renderPrint({
    reactive_eval(input$box4)
  })
  output$out5 <- renderPlot({
    reactive_eval(input$box5)
  })

}
# output$out4 <- renderPrint(y())

# profvis::profvis({
#   runApp(shinyApp(ui, server))
# })

# eval(expr(vals$UQ(enexpr(var)) <<- val))


# if (a[[1]] == "█─`%<<%`") {
#   result <- eval_tidy(parse_expr(x), isolate(reactiveValuesToList(vals)))
# } else {
#   result <- eval_tidy(parse_expr(x), reactiveValuesToList(vals))
# }

# fun <- function(expr, ...) {
#   function(...) {
#     eval_tidy(enexpr(expr), list2(...))
#   }
# }

runApp(shinyApp(ui, server))





# can I generate code with this?
# .init_react <- reactive({
#   a <- parse_expr(input$box1)
#   if (a[[1]] == expr(`<-`)) {
#     `<-` <- function(var, val) {
#       eval(!!enexpr(var) <- reactive(val))
#     }
#     eval(a)
#     output$out1 <- renderPrint(eval(!!enexpr(var)()))
#   }
#   reactive_eval(input$box1)
# })








