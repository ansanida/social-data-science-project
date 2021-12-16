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
library(rgdal)

options(tigris_use_cache = TRUE)
getwd()
#nj_income_data <- read.csv("/Users/nidaansari/Desktop/sds_project/nj_income_data.csv", sep = '.')
#nj_income_data

#api.key.install(key="dac12f3ed655e75501a1e94bf4ec1801dff51509")
wiki <- read_html("https://en.wikipedia.org/wiki/List_of_colleges_and_universities_in_New_Jersey") 
t <- wiki %>% html_nodes("table.wikitable") %>% html_table(header = TRUE)
#print(t)
public.colleges <- t[[2]] %>% as_tibble()
#public.colleges
private.colleges <- t[[3]] %>% as_tibble()
private.colleges

public.collegeTowns <- unlist(strsplit(public.colleges$Location, ", ")) %>% as_tibble()
#collegeTowns
#collegeTowns <- strsplit(collegeTowns, ", ")
public.collegeTowns$value[2] <- sub("and Hillside", "", public.collegeTowns$value[2])
public.collegeTowns$value[9] <- sub("and ", "", public.collegeTowns$value[9])
public.collegeTowns$value[13] <- sub("and ", "", public.collegeTowns$value[13])

colnames(public.collegeTowns) <- c("public.college")
#collegeTowns$private.college <- unlist(strsplit(private.colleges$Location, ", "))
public.collegeTowns <- distinct(public.collegeTowns, public.college)
public.collegeTowns

private.collegeTowns <- unlist(strsplit(private.colleges$Location, ", ")) %>% as_tibble()
private.collegeTowns$value[6] <- sub("and ", "", private.collegeTowns$value[6])
private.collegeTowns$value[11] <- sub("and ", "", private.collegeTowns$value[11])
private.collegeTowns$value[12] <- sub("and Rutherford", "", private.collegeTowns$value[12])
private.collegeTowns$value[17] <- sub(" Twp. and Florham Park", "town", private.collegeTowns$value[17])
#private.collegeTowns

zipcodes <- read.csv(file = "zipcodes1.csv")
#zipcodes
public.join.table <- left_join(public.collegeTowns, zipcodes, by = c("public.college" = "TOWN"))
private.join.table <- left_join(private.collegeTowns, zipcodes, by = c("value" = "TOWN"))
nj_income <- get_acs(geography = "zip code tabulation area",
                     variables = "B19013_001",state = "NJ", 
                     geometry = TRUE) 
#write.table(nj_income, sep ="\t", "nj_income.csv") 
public.town.zipcodes <- public.join.table$ZIPCODE
private.town.zipcodes <- private.join.table$ZIPCODE
public.town.zipcodes#ogrDrivers()
private.town.zipcodes#writeOGR(nj_income, dsn = "nj_income.shp", driver = FALSE)
st_write(nj_income, "nj_income.shp", driver = "ESRI Shapefile")
write.csv(public.join.table, "public_join_table.csv")
write.csv(private.join.table, "private_join_table.csv")
