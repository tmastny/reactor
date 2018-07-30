library(shiny)
library(rlang)
library(promises)
library(future)
plan(multiprocess)

ui <- fluidPage(
  tags$script(src='reactnb.js'),
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
  cell_names <- list()
  var_cells <- list()
  e <- current_env()

  `%<<%` <- function(var, val, ...) {
    name_string <- expr_name(enexpr(var))
    
    cell <- deparse(sys.calls()[[sys.parent(3)]])
    if (has_name(cell_names, name_string)) {
      if (cell_names[[name_string]] != cell)
        stop(name_string, " is defined more than once")
    }
    
    if (!is.null(var_cells[[cell]])) 
      .subset2(vals, 'impl')$set(var_cells[[cell]], NULL)
    
    var_cells[[cell]] <<- name_string
    cell_names[[name_string]] <<- cell
    .subset2(vals, 'impl')$set(name_string, val)
    

    eval(expr(!!enexpr(var) <- !!enexpr(val)), e)
    env_bind_fns(e, 
      !!enexpr(var) := ~.subset2(vals, 'impl')$get(name_string)
    )
    val
  }

  reactive_eval <- function(x) {
    eval(parse_expr(x), e)
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
  
  # for (i in 1:60) {r(i); Sys.sleep(1)}
  # f %<<% function(a){Sys.sleep(5); a + 2}
  o4 <- reactiveVal()
  observe({
    inputs <- req(input$box4)
    e$.captured_expr <- parse_expr(inputs)
    promised_expr <- eval(substitute(substitute(.captured_expr, e), e))
    isolate({
      future(eval(promised_expr)) %...T>%
        {o4(NULL)} %...>%
        o4() %...!%
        (function(e) {
          o4(NULL)
          warning(e)
          session$close()
        })
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
env_bind_fns(e, y = function(val) {print("getting called"); 1})

# binding is called
eval(parse_expr("y"), e)
eval(expr(x + y + 1), e)
1
# binding is also called
substitute(x + y + 1, e)

e$.parsed <- parse_expr("x + y + 1")
eval(substitute(substitute(.parsed, e), e))

# variables within functions work too
# need to check why that doesn't work with promise
substitute(f <- function(a) {a + y}, e)

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

# # JS function to block thread. It kills all
# # observable cells, meaning they are NOT operating
# # on cell based promises, but interacting with promise delays
# function sleep(seconds) 
# {
#   var e = new Date().getTime() + (seconds * 1000);
#   while (new Date().getTime() <= e) {}
# }

# # get name of parent function
# foo1 <- function() {
#   # match.call()[[1]]
#   as.character(sys.calls()[[sys.nframe()-1]])
# }
# 
# foo2 <- function() {
#   foo1()
# }
# 
# bar <- function() {
#   foo2()
# }




