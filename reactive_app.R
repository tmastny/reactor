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
  plotOutput("out5"),
  tags$style(
    type = "text/css",
    ".shiny-output-error { visibility: hidden; }",
    ".shiny-output-error:before { visibility: hidden; }"
  )
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
  # o4 <- reactiveVal()
  # observe({
  #   inputs <- req(input$box4)
  #   e$.captured_expr <- parse_expr(inputs)
  #   promised_expr <- eval(substitute(substitute(.captured_expr, e), e))
  #   isolate({
  #     future(eval(promised_expr)) %...T>%
  #       {o4(NULL)} %...>%
  #       o4() %...!%
  #       (function(e) {
  #         o4(NULL)
  #         warning(e)
  #         session$close()
  #       })
  #   })
  #   
  #   NULL
  # })
  output$out4 <- renderPrint({
    reactive_eval(input$box4) 
    #req(o4())
  })
  output$out5 <- renderPlot({
    reactive_eval(input$box5)
  })

}

shinyApp(ui, server)