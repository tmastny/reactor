
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

library(rlang)
e <- new.env()
e$y <- 1
env_bind_fns(e, y = function(val) {print("getting called"); 1})
eval(expr(x + y + 1), e)


