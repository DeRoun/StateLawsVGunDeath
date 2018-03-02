# Required Libraries:

suppressPackageStartupMessages(library(dplyr))

# Creates variable with raw Firearm Law Data

orig.GL <- read.csv(file = "data/raw_state_gun_laws_data.csv", stringsAsFactor = F, fileEncoding="UTF-8-BOM")

# Creates variable with raw Gun Death Data

orig.CDC <- read.csv(file = "data/raw_cdc_gun_deaths.csv", stringsAsFactor = F, fileEncoding="UTF-8-BOM")

# Simplifies firearm law data

simplify.GL <- select(orig.GL, State = state, Year = year, LawTotal = lawtotal)

# Combines CDC and Gun law datasets by state and year

combined.df <- left_join(orig.CDC, simplify.GL)

# Function that takes in a state name and outputs a data from of that state
# gun death and gun law information from 1999-2016.

simplify <- function(stateName){
  drop.cols <- c("State.Code", "Year.Code", "X..of.Total.Deaths")
  df <- combined.df %>%
    filter(State == stateName) %>%
    select(-one_of(drop.cols))
  assign(eval(stateName), df, .GlobalEnv)
  rm(drop.cols)
}

# Repeats simplify function for each state outputting 50 data frames names as the state
  # i.e California, Oregon, etc.

lapply(as.list(state.name), simplify)

