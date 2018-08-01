library(rlang)

ui <- fluidPage(
  singleton(tags$head(tags$script(src = "enter_bind.js"))),
  tags$input(type='command', id='command1', class='reactnb-command',
             autocomplete='off', autocorrect='off'
  ),
  tags$br(),
  tags$div(id = 'cmd1_output', class = 'output highlight-text-output')
)
server <- function(input, output) {
  
  builtinsEnv <- new.env()
  sessionEnv <- new.env(parent=builtinsEnv)
  builtinsEnv$temporal <- function(expr=NULL, period=1000) {
    invalidateLater(period, session)
    expr
  }
  
  vals <- reactiveValues()

  `%<<%` <- function(var, val, ...) {
    name_string <- expr_name(enexpr(var))
    .subset2(vals, 'impl')$set(name_string, val)
    
    eval(expr(!!enexpr(var) <- !!enexpr(val)), sessionEnv)
    env_bind_fns(sessionEnv,
      !!enexpr(var) := ~.subset2(vals, 'impl')$get(name_string)
    )
    val
  }
  
  observing_expr <- function(x) {
    e <- expr(
      observe({
        command <- !!enexpr(x)
        if (is.null(command))
          return()
        cmdId <- command$id
        cmdText <- command$text
        cmdType <- command$type
        if (!nzchar(cmdText))
          return()
        
        if (cmdType == 'plot') {
          print("in plot")
          output[[paste0(cmdId, '_output')]] <- renderPlot({
            fg <- '#F5F5F5'
            #par(bg='#303030', fg=fg, col=fg, col.axis=fg, col.lab=fg, col.main=fg, col.sub=fg)
            eval(parse(text=cmdText), envir = sessionEnv)
          })
        } else if (cmdType == 'table') {
          output[[paste0(cmdId, '_output')]] <- renderTable({
            eval(parse(text=cmdText), envir = sessionEnv)
          })
        } else if (cmdType == 'text') {
          output[[paste0(cmdId, '_output')]] <- renderText({
            eval(parse(text=cmdText), envir = sessionEnv)
          })
        } else if (cmdType == 'html' || cmdType == 'ui') {
          output[[paste0(cmdId, '_output')]] <- renderUI({
            eval(parse(text=cmdText), envir = sessionEnv)
          })
        } else {
          output[[paste0(cmdId, '_output')]] <- renderPrint({
            if (grepl('^\\s*#', cmdText))
              invisible(eval(parse(text=cmdText), envir = sessionEnv))
            else
              eval(parse(text=cmdText), envir = sessionEnv)
          })
        }
      })
    )
    eval(e, sessionEnv)
  }
  observing_expr(input$command1)
  observe({
    req(input$cmd_count)
    observing_expr(!!expr(input[[!!paste0("command", input$cmd_count)]]))
  })
}

shinyApp(ui, server)