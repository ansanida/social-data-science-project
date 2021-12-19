library(shiny)
library(leaflet)

fluidPage(
  titlePanel("Median Income Level in Towns with a Public/Private College"),
  p("Institutions such as universities have a history of gentrifying the towns they are in. The governments in the towns they reside in sometimes prioritize the university over the people living there. This leads to things such as displacement, poverty, and lack of resources for the community. Here we are analyzing if there is a pattern among the median income of towns that have a public/private college."),
    mainPanel(
      hr(),
      radioButtons("map_choice", "Type of College",
                   choiceNames = list("Public Colleges", "Private Colleges"),
                   choiceValues = list("Public Colleges", "Private Colleges")),
      #leafletOutput('distPlot')
      tmapOutput("distPlot")
      
      )
    )
