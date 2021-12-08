knitr::opts_chunk$set(echo = TRUE)

library(rmarkdown)
library(knitr)
library(rvest)
library(tidyverse)
library(acs)
library(tigris)
library(stringr)
library(leaflet)
library(shiny)
library(rsconnect)
library(terra)
library(tidycensus)
library(rlang)
library(raster)
library(dplyr)
library(jsonlite)
library(zipcodeR)
#library(RSQlite)
library(maps)
library(ggplot2)
library(mapview)
library(sf)
library(tmap)
library(usmap)

options(tigris_use_cache = TRUE)

api.key.install(key="dac12f3ed655e75501a1e94bf4ec1801dff51509")
wiki <- read_html("https://en.wikipedia.org/wiki/List_of_colleges_and_universities_in_New_Jersey") 
t <- wiki %>% html_nodes("table.wikitable") %>% html_table(header = TRUE)
public.colleges <- t[[2]] %>% as_tibble()
collegeTowns <- unlist(strsplit(public.colleges$Location, ", ")) %>% as_tibble()
collegeTowns$value[2] <- sub("and Hillside", "", collegeTowns$value[2])
collegeTowns$value[9] <- sub("and ", "", collegeTowns$value[9])
collegeTowns$value[13] <- sub("and ", "", collegeTowns$value[13])
collegeTowns <- distinct(collegeTowns, value)
collegeTowns$poverty.percent <- NA
collegeTowns$poverty.percent <- c(10.2, 19.6, 6.9, 17.2, 27.4,
                                  4.9, 24.4, 36.4, 9.1, 34.4, 7.5,
                                  5.9, 28.9, 3.5)
collegeTowns$college <- c(public.colleges$School, "Rutgers University", 
                          "Rutgers University", "Rowan University")
collegeTowns$college[8] <- "Rutgers University, Rowan University"
collegeTowns$college[9] <- "Rowan University"
collegeTowns$college[10] <- "Rutgers University"
collegeTowns$college[11] <- "Rutgers University"
collegeTowns$college[12] <- "Stockton University"
collegeTowns$college[13] <- "Thomas Edison State University"
collegeTowns$college[14] <- "William Paterson University"

zipcodes <- c(08618, 08628, 08638, 07083,
              07042, 07043, 07044, 07300, 07097,
              07302,07303,07304,07305, 07306, 07307, 
              07308, 07309, 07310, 07311, 07399,
              07100,07101,07102,07102, 07103,07104,
              07105,07106,07107, 07108,07109,07109,07110,
              07111,07112,07114,07175,07183,07184,07185, 
              07187, 07188,07189,07190,07191,07192,
              07193,07194,07195,07197, 07198,07199, 
              07430, 07495, 07498, 08028, 08100, 08101,
              08102, 08103, 08104, 08105, 08106, 08107,
              08108, 08109, 08110, 08084, 08899, 08901, 
              08902, 08903, 08904, 08905, 08906, 08922,
              08933, 08988, 08989, 08854, 08855, 08205,
              07470, 07474, 07477, 08600,
              08601,08602,08603,08604,08605,08606, 08607,
              08608,08609,08610,08611,08618,08619,08620,
              08625,08628,08629, 08638,08640,08641,08645,
              08646,08647,08648,08650,08666,08677, 08690, 
              08691,08695)

zipcode_string <- paste(zipcodes[1:length(zipcodes)])
zipcode_string <- paste0("0", zipcode_string)
zip <- c("08901", "08902")
nj_income <- get_acs(geography = "zip code tabulation area",
                     variables = "B19013_001",state = "NJ", 
                     geometry = TRUE) 
nj_zctas <- zctas(cb = TRUE,
                  starts_with = zipcode_string,
                  year = 2018)
nj_zctas <- nj_zctas %>% as_tibble()

nj_income_data <- nj_zctas %>%
  left_join(nj_income, nj_zctas, by = c("GEOID10" = "GEOID")) 

NJ_map <- tm_shape(st_as_sf(nj_income_data), projection = 26918) +
  tm_fill(col = "estimate",
          palette = "Reds",
          title = "median income level")
tmap_leaflet(NJ_map)

function(input, output) {
  
  output$distPlot <- renderLeaflet({
    NJ_map <- tm_shape(st_as_sf(nj_income_data), projection = 26918) +
      tm_fill(col = "estimate",
              palette = "Reds",
              title = "median income level")
    tmap_leaflet(NJ_map)
  })
  
}