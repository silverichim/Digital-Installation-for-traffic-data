## Loading necessary libraries---------------------
install.packages("stringr")
library("tidyverse")
library("dplyr")
library("stringr")


## Importing data---------------------------------
getwd()
setwd("D:/Detroit_Data/Traffic")
# Data source: Detroit Traffic Safety Report (Adapted from public data files)
dados <- read.csv(file = "Detroit_Traffic_Accidents_2023.csv", sep = ",")

## Defining variables-----------------------------
### Population data (Source: US Census Bureau)
pop2022 <- c(639111)   # Detroit population in 2022
pop2021 <- c(643239)   # Population in 2021
pop2020 <- c(670031)   # Population in 2020
pop2019 <- c(677116)   # Population in 2019

### Vehicle fleet data (Source: Michigan Department of Transportation)
frota2022 <- c(890000)   # Active vehicles in Detroit in 2022
frota2021 <- c(870000)   
frota2020 <- c(850000)   
frota2019 <- c(830000)   

## Data analysis-----------------------------------

str(dados) # Check the structure of the data
tibble(dados)

### Filtering data for pedestrian-related accidents
tipo_acid <- dados %>%
  select(accident_type, accident_count, month, year, state, location_code) %>%
  filter(str_detect(accident_type, "PEDESTRIAN")) %>%
  group_by(state) # Group by state for analysis (Adapted filter)

str(tipo_acid)

#### Analysis of pedestrian accidents by year (Nationwide)
acid_2022 <- tipo_acid %>%
  ungroup() %>%
  select(accident_count, year, state) %>%
  filter(year == '2022')

tibble(acid_2022)

soma_acid_2022 <- acid_2022 %>%
  select(accident_count) %>%
  colSums(acid_2022$accident_count)

media_2022 <- (soma_acid_2022 / pop2022) * 100000 # Accidents per 100,000 people
afv22 <- (soma_acid_2022 / frota2022) * 10000    # Accidents per 10,000 vehicles

#### Repeat analysis for 2021, 2020, 2019
# Structure remains the same, only changing the filter year

#### Analysis for Detroit metropolitan cities
### Includes Detroit, Dearborn, Ann Arbor, Warren
acidentes_detroit <- tipo_acid %>%
  select(accident_type, state, year, accident_count, location_code) %>%
  filter(state == 'MI') %>%
  group_by(year)

acidentes_ann_arbor <- acidentes_detroit %>%
  filter(str_detect(location_code, "Ann_Arbor")) %>%
  group_by(year)

soma_ann_arbor <- acidentes_ann_arbor %>%
  ungroup() %>%
  select(year, accident_count) %>%
  filter(year == '2020') %>%
  colSums(acidentes_ann_arbor$accident_count)

print(soma_ann_arbor)

result_ann_arbor <- data.frame(
  year = c(2019, 2020, 2021, 2022),
  accident_count = c(150, 120, 175, 140) # Placeholder data; replace with actual values
)

as_tibble(result_ann_arbor)

#### Aggregating data for Detroit metro area
Detroit_Area <- bind_rows(result_ann_arbor, result_detroit, result_dearborn, result_warren)
as_tibble(Detroit_Area)

total_accidents <- Detroit_Area %>%
  ungroup() %>%
  select(year, accident_count) %>%
  filter(year == '2020') %>%
  colSums(Detroit_Area$accident_count)

print(total_accidents)

result_detroit_area <- data.frame(
  year = c(2019, 2020, 2021, 2022),
  total_accidents = c(1200, 1000, 1500, 1300) # Placeholder data; replace with actual values
)

colSums(result_detroit_area)
