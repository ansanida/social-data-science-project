knitr::opts_chunk$set(echo = TRUE)

library(knitr)
library(rvest)
library(tidyverse)
library(acs)
library(tigris)
library(stringr)
library(leaflet)
library(shiny)
library(rsconnect)
#library(terra)
library(tidycensus)
#library(rlang)
#library(raster)
library(dplyr)
#library(jsonlite)
library(zipcodeR)
#library(RSQlite)
#library(maps)
#library(ggplot2)
#library(mapview)
library(sf)
library(tmap)

options(tigris_use_cache = TRUE)
#getwd()
#setwd("/Users/nidaansari/Desktop/sds_project")
public.join.table <- read.csv(file = "/Users/nidaansari/Desktop/sds_project/public_join_table.csv")
private.join.table <- read.csv(file = "/Users/nidaansari/Desktop/sds_project/private_join_table.csv")

public.town.zipcodes <- public.join.table$ZIPCODE
private.town.zipcodes <- private.join.table$ZIPCODE 

public.town.zipcodes <- paste0("0", public.town.zipcodes)
private.town.zipcodes <- paste0("0", private.town.zipcodes)
nj_income <- st_read("/Users/nidaansari/Desktop/sds_project/nj_income.shp")

nj_zctas <- zctas(cb = TRUE,
                  starts_with = c(public.town.zipcodes),
                  year = 2018)
nj_zctas <- nj_zctas %>% as_tibble()
public.join.table$ZIPCODE <- paste0("0", public.join.table$ZIPCODE)
private.join.table$ZIPCODE <- paste0("0", private.join.table$ZIPCODE)

nj_income_data <- nj_zctas %>%
  left_join(nj_income, nj_zctas, by = c("GEOID10" = "GEOID")) 
nj_income_data <- left_join(nj_income_data, public.join.table, by = c("GEOID10" = "ZIPCODE"))

private.nj_zctas <- zctas(cb = TRUE,
                          starts_with = c(private.town.zipcodes),
                          year = 2018)
private.nj_zctas <- private.nj_zctas %>% as_tibble()
private.nj_income_data <- private.nj_zctas %>% left_join(nj_income, private.nj_zctas, by = c("GEOID10" = "GEOID"))
private.nj_income_data <- left_join(private.nj_income_data, private.join.table, by = c("GEOID10" = "ZIPCODE"))

function(input, output) {
  
  view.options <- c("Public Colleges", "Private Colleges")
  user.choice <- reactive(input$map_choice)
  output$distPlot <- renderTmap({
    #tmap_mode("view")
    if(user.choice() == view.options[1]) {
      #NJ_map <- 
      tmap_mode("view")
        tm_shape(st_as_sf(nj_income_data), projection = 26918) +
        tm_fill(col = "estimate",
                palette = "Reds",
                title = "public median income level",
                id = "COLLEGE") 
      #tmap_leaflet(NJ_map)
    }
    else {
      #private.NJ_map <- 
      tmap_mode("view")
        tm_shape(st_as_sf(private.nj_income_data), projection = 26918) +
        tm_fill(col = "estimate",
                palette = "Blues",
                title = "private median income level",
                id = "COLLEGE")
      #tmap_leaflet(private.NJ_map)
    }
  })
}
