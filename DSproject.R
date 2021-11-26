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



rsconnect::setAccountInfo(name='nida-ansari', token='903DF3800ABD51435D2416366D149B23', secret='vlnsxdxXNNmYTeTbeHSDlBJGxTre3yXXy1AK14CE')

wiki <- read_html("https://en.wikipedia.org/wiki/List_of_colleges_and_universities_in_New_Jersey") 

t <- wiki %>% html_nodes("table.wikitable") %>% html_table(header = TRUE)
#print(t)
public.colleges <- t[[2]] %>% as_tibble()
#public.colleges

api.key.install(key="dac12f3ed655e75501a1e94bf4ec1801dff51509")

counties <- c(1, 3, 7, 13, 17, 21, 23, 31, 39)
tracts <- tracts(state = 'NJ', county = c(1, 3, 7, 13, 17, 21, 23, 31, 39), cb=TRUE)

geo<-geo.make(state=c("NJ"),
              county=c(1, 3, 7, 13, 17, 21, 23, 31, 39), tract="*")

#income<-acs.fetch(endyear = 2012, span = 5, geography = geo,
                  #table.number = "B19001", col.names = "pretty")

income<-acs.fetch(endyear = 2019, span = 5, geography = geo,
                  table.number = "B19001", col.names = "pretty")
print(income)

names(attributes(income))

attr(income, "acs.colnames")

income_df <- data.frame(paste0(str_pad(income@geography$state, 2, "left", pad="0"),
                               str_pad(income@geography$county, 3, "left", pad="0"), 
                               str_pad(income@geography$tract, 6, "left", pad="0")), 
                        income@estimate[,c( "Household Income: Total:","Household Income: $75,000 to $99,999", "Household Income: $100,000 to $124,999", "Household Income: $125,000 to $149,999", "Household Income: $150,000 to $199,999",
                                            "Household Income: $200,000 or more")], 
                        stringsAsFactors = FALSE)

income_df <- select(income_df, 1:7)

rownames(income_df)<-1:nrow(income_df)
names(income_df)<-c("GEOID", "total", "range_75", "range_100", "range_125", "range_150", "over_200")
#print(income_df)
sum_Income <- sum(income_df$range_75, income_df$range_100, income_df$range_125, income_df$range_150, income_df$over_200)
#print(sum_Income)
income_df$percent <- 100*((income_df$range_75 + income_df$range_100 + income_df$range_125 + income_df$range_150 + income_df$over_200)/income_df$total) 

#print(income_df)

income_merged<- geo_join(tracts, income_df, "GEOID", "GEOID")
# there are some tracts with no land that we should exclude
income_merged <- income_merged[income_merged$ALAND>0,]

popup <- paste0("GEOID: ", income_merged$GEOID, "<br>", "Percent of Households above $75k: ", round(income_merged$percent,2))
pal <- colorNumeric(
  palette = "YlGnBu",
  domain = income_merged$percent
)

#print(pal)

NJmap<-leaflet() %>%
    addProviderTiles("CartoDB.Positron") %>%
    addPolygons(data = income_merged, 
                fillColor = ~pal(percent), 
                color = "#918e8e", # you need to use hex colors
                fillOpacity = 0.7, 
                weight = 1, 
             smoothFactor = 0.2,
              popup = popup) %>%
   addLegend(pal = pal, 
             values = income_merged$percent, 
           position = "bottomright", 
          title = "Percent of Households<br>above $75k",
        labFormat = labelFormat(suffix = "%")) 

NJmap


