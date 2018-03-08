suppressPackageStartupMessages(library(dplyr))

# Creates variable with raw Firearm Law Data

orig.GL <- read.csv(file = "data/raw_state_gun_laws_data.csv", stringsAsFactor = F, fileEncoding="UTF-8-BOM")

# Creates variable with raw Gun Death Data

orig.CDC <- read.csv(file = "data/raw_cdc_gun_deaths.csv", stringsAsFactor = F, fileEncoding="UTF-8-BOM")

# Simplifies CDC gun death data

simplify.CDC <- select(orig.CDC, State, Year, Deaths, Population)

# Simplifies firearm law data

simplify.GL <- select(orig.GL, State = state, Year = year, LawTotal = lawtotal)

# Combines CDC and Gun law datasets by state and year

combined.df <- left_join(simplify.CDC, simplify.GL)

# Adds a "All States" state category that takes the combined total of all states for that year.

allStates.df <- combined.df %>%
                group_by(Year) %>%
                summarise(Deaths = sum(Deaths), Population = sum(Population),
                          LawTotal = sum(LawTotal, na.rm=TRUE)) %>%
                mutate(State = "All States")

# Adds the new "All States" rows to the combined data frame and creates a Rate column
# of the rate of death per 100,000 people

final.df <- full_join(combined.df, allStates.df) %>%
  mutate(Rate = round(Deaths / Population * 100000, digits = 2))

# Vectors and other variables to be used in Shiny

year.vec <- c(allStates.df$Year)

############################################################
######################## NO SUICIDE ########################
############################################################

# Creates variable with raw Gun Death Data (NO SUICIDE)

orig.CDC.ns <- read.csv(file = "data/raw_cdc_gun_deaths_ns.csv", stringsAsFactor = F, fileEncoding="UTF-8-BOM")

# Simplifies CDC gun death data (NO SUICIDE)

simplify.CDC.ns <- select(orig.CDC.ns, State, Year, Deaths, Population)

# Combines CDC and Gun law datasets by state and year (NO SUICIDE)

combined.df.ns <- left_join(simplify.CDC.ns, simplify.GL)

# Adds a "All States" state category that takes the combined total of all states for that year. 
# (NO SUICIDE)

allStates.df.ns <- combined.df.ns %>%
  group_by(Year) %>%
  summarise(Deaths = sum(Deaths), Population = sum(Population),
            LawTotal = sum(LawTotal, na.rm=TRUE)) %>%
  mutate(State = "All States")

# Adds the new "All States" rows to the combined data frame and creates a Rate column
# of the rate of death per 100,000 people (NO SUICIDE)

final.df.ns <- full_join(combined.df.ns, allStates.df.ns) %>%
  mutate(Rate = round(Deaths / Population * 100000, digits = 2))
