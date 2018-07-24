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

  e <- current_env()

  `%<<%` <- function(var, val, ...) {
    name_string <- expr_name(enexpr(var))
    .subset2(vals, 'impl')$set(name_string, val)

    eval(expr(!!enexpr(var) <- !!enexpr(val)), e)
    env_bind_fns(e, !!enexpr(var) := function(...) {
      .subset2(vals, 'impl')$get(name_string)
    })
    val
  }

  reactive_eval <- function(x) {
    eval_tidy(parse_expr(x), e)
  }

  output$out1 <- renderPrint({
    reactive_eval(input$box1)
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
# profvis::profvis({
#   runApp(shinyApp(ui, server))
# })


runApp(shinyApp(ui, server))

# promise handlers could potentially go into
# the environment bindings

# e <- new.env()
# f <- function(var) {
#   env_bind_fns(e, !!enexpr(var) := function(val) {cat("hello\n"); 1})
# }
# e$x <- 1
# e$x
# env_bind_fns(e, x = function(val) {cat("hello\n"); 1})
# e$x
#
# yl <- list(y = 1)
# env_bind_fns(e, y = function() {1})
# eval(expr(x + y), e)

