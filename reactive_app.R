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
  
  
  # d %<<% {Sys.sleep(5); head(mtcars)}
  o4 <- reactiveVal()
  observeEvent(req(input$box4), {
    captured_expr <- parse_expr(input$box4)
    future(eval(captured_expr)) %...T>%
      {o4(NULL)} %...>%
      o4() %...!%
      (function(e) {
        o4(NULL)
        warning(e)
        session$close()
      })
    
    NULL
  })
  output$out4 <- renderPrint({
    # reactive_eval(input$box4) 
    req(o4())
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



# find name of function in R
f <- function() {
  name <- match.call()[[1]]
  print(as.character(name))
}

# substitute variables from environment
# possible use: send values from reactive into 
# future instead of reactives themselves
e <- new.env()
e$x <- 1
e$y <- 1
env_bind_fns(e, y = function(val) {print("getting called"); 2})

# binding is called
eval(expr(x + y + 1), e)

# binding is also called
substitute(x + y + 1, e)

e$.parsed <- parse_expr("x + y + 1")
eval(substitute(substitute(.parsed, e), e))

# # idea:
# on <- reactiveVal()
# observeEvent(input$boxn,{
#   e$.parsed <- parse_expr(input$boxn)
#   subbed_expr <- eval(substitute(substitute(.parsed, e), e))
#   future(eval(subbed_expr)) %...>%
#     on()
# })
# output$outn <- renderPrint({
#   on()
# })
# 
# # TODO: get future to eval an expression
# expr <- parse_expr("{Sys.sleep(5); head(cars)}")
# f <- future(eval(expr))
# value(f)

