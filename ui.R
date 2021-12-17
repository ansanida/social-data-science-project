library(shiny)
library(leaflet)
fluidPage(
  titlePanel("Median Income Level in Public College Towns"),
    mainPanel(
      hr(),
      radioButtons("map_choice", "Type of College",
                   choiceNames = list("Public Colleges", "Private Colleges"),
                   choiceValues = list("Public Colleges", "Private Colleges")),
      #leafletOutput('distPlot')
      tmapOutput("distPlot")
      )
  
    )
