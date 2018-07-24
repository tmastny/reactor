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
    #expr(vals$UQ(enexpr(var)) <- !!enexpr(val))
    .subset2(vals, 'impl')$set(deparse(enexpr(var)), val)
    val
  }

  # x %<<% 1
  # vals$f <- function(a){a+1}

  reactive_eval <- function(x) {
    a <- parse_expr(x)
    chars <- sapply(a, deparse)
    mask <- chars %in% isolate(names(reactiveValuesToList(vals)))

    if (chars[1] == "<-") mask[2] <- TRUE

    if (any(mask)) {
      if (length(a) > 1) {
        parsed <- sapply(
          purrr::map_chr(
            chars,
            function(expr) {
              expr <- paste(expr, collapse = "")
              deparse(expr(vals$UQ(sym(expr))))
            }
          ),
          parse_expr
        )
        for (i in 1:length(a)) {
          if (mask[i]) {
            a[[i]] = parsed[[i]]
          }
        }
      } else {
        a <- expr(vals$UQ(a))
      }
    }
    eval_tidy(a)
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


#
#
# purrr::map_chr(
#   chars[mask],
#   function(expr) {
#     deparse(expr(vals$UQ(ensym(expr))))
#   }
# )
#
#
(function(expr = chars[[3]]) {
  expr <- paste(expr, collapse = "")
  deparse(expr(vals$UQ(sym(expr))))
})()



