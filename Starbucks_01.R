setwd("C:/Users/Marcelo/Desktop/Data Science/Starbucks/")
# Exploratory data Analysis Starbucks stores
unzip("store-locations.zip")
library(data.table)
library(dplyr)
library(ggplot2)
library(countrycode)
library(plyr)
library(highcharter)
starbucks <- read.csv("directory.csv", header = TRUE, stringsAsFactors = FALSE)
dim(starbucks)
names(starbucks)
str(starbucks)

# Grouping by country
by_country <- starbucks %>%
  group_by(Country)%>%
  dplyr::summarise(Total = round(sum(n())))
names(by_country) <- c("Country.Code", "Total")

by_country$Country.Name <- countrycode_data[match(by_country$Country.Code,
                                          countrycode_data$iso2c),"country.name"]

# Starbucks stores x Country
ggplot(data = by_country, aes(x = reorder(Country.Name, -Total), y = Total,
       fill = Total))+
  geom_bar(stat = "identity")+
  geom_hline(yintercept = mean(by_country$Total), lwd = 0.5, color = "red")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  xlab("Country Code")+
  ylab("Total Starbucks Stores")+
  ggtitle("Number of Starbucks Stores")

print("By far United States is the country with the highest number of Starbucks stores followed by China.") 

# Top 15 Countries
by_country_2 <- starbucks %>%
  group_by(Country)%>%
  dplyr::summarise(Total = round(sum(n())), 
            Percentage = round(Total/dim(starbucks)[1]*100,2)) %>%
  arrange(desc(Total)) %>%
  head(15)

by_country_2$Country.Name <- countrycode_data[match(by_country_2$Country,
                                                  countrycode_data$iso2c),"country.name"]


ggplot(data = by_country_2, aes(x = reorder(Country.Name, -Total), y = Total,
                              fill = Total, label = round(Percentage,2)))+
  geom_bar(stat = "identity")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  xlab("Country Code")+
  ylab("Number of Starbucks Stores in the Top 15 Countries")+
  ggtitle("Top 15 Countries")+
  geom_label(aes(fill = Total), colour = "white", fontface = "bold")

# % of stores in the US
print("US stores corresponds to 53.16% of the Mundial Starbucks Stores" )
print("Roughly 70% of the stores are in the TOP 3 (USA, China and CANADA)")

# Top 15 Cities
by_city <- starbucks %>%
  group_by(City)%>%
  dplyr::summarise(Total = round(sum(n())), 
            Percentage = round(Total/dim(starbucks)[1]*100,2)) %>%
  arrange(desc(Total)) %>%
  head(15)

ggplot(data = by_city, aes(x = reorder(City, -Total), y = Total,
                                fill = Total, label = round(Percentage,2)))+
  geom_bar(stat = "identity")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  xlab("City")+
  ylab("Number of Starbucks Stores in the Top 15 Cities")+
  ggtitle("Top 15 Cities")+
  geom_label(aes(fill = Total), colour = "white", fontface = "bold")

print("Top 3 Cities are in Asia, with more than 4% of the total stores.")

# Starbucks in Brazil
Br_by_city <- starbucks %>%
  group_by(Country, City)%>%
  filter(Country == "BR") %>%
  dplyr::summarise(Total = sum(n())) %>%
  arrange(desc(Total))

# replacing some city names
Br_by_city$City[10] <- c("Barueri")
Br_by_city$City[8] <- c("Sao Jose dos Campos")

#re-summarising and calculating the percentage
Br_by_city <- ddply(Br_by_city, .(Country, City), summarize, Total = sum(Total))
Br_by_city$Percentage <- round(Br_by_city$Total/(sum(Br_by_city$Total))*100,2)

# Creating a treemap inspired in the graphs published by Umesh
# https://www.kaggle.com/umeshnarayanappa/d/starbucks/store-locations/exploring-starbucks-stores/code
hchart(Br_by_city, "treemap", hcaes(x = City, value = Total, color = Total )) %>%
  hc_colorAxis(stops = color_stops(n = 10, colors = c("#440154", "#21908C", "#FDE725"))) %>%
  hc_add_theme(hc_theme_google()) %>%
  hc_title(text = "Cities in Brazil with Starbuck stores") %>%
  hc_credits(enabled = TRUE, text = "Sources: Starbucks Store Locator data by Github user chrismeller", style = list(fontSize = "10px")) %>%
  hc_legend(enabled = TRUE)

# Brazil has 27 states are represented, however, Starbucks is present in only 2 of them, S�o Paulo and Rio de Janeiro. 

# S�o Paulo has the majority of the Brazilian Stores ~ 47 %.
# Rio de Janeiro ~ 20 %.

# As an emergent market Brazil would be a great opportunity for the Starbucks growing. 

