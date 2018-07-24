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


runApp(shinyApp(ui, server))

# can I use active bindings?
# each time `<-` is called, bind the `get` object to it?



# rlang::call_args

# expr_label(call_args(quote(f <- function(a){a+1}))[[2]])


# e <- new.env()
# f <- function(var) {
#   env_bind_fns(e, !!enexpr(var) := function(val) {cat("hello\n"); 1})
# }




