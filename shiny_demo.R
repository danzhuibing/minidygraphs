library(shiny)
library(minidygraphs)

gexf <- system.file("examples/ediaspora.gexf.xml", package = "sigma")

ui = shinyUI(fluidPage(
  textInput("main", "main", "Time series plot"),
  textInput("x_label", "y label", "Date"),
  textInput("y_label", "x label", "Death number"),
  minidygraphsOutput('eg')
))

server = function(input, output) {
  output$eg <- renderMinidygraphs(
    minidygraph(cbind(ldeaths, mdeaths, fdeaths), input$main, input$x_label, input$y_label)
  )
}

shinyApp(ui = ui, server = server)