library(shiny)
fluidPage(
  titlePanel("Median Income Level in Public College Towns"),
    mainPanel(
      leafletOutput("distPlot")
    )
  )

