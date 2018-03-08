# StateLawsVGunDeath
A data visualization on the affects of the total number of state firearm legislation has on the gun related death tolls and rates of that state

**Code and Data behind [State Laws v Gun Death](https://deroun.shinyapps.io/StateLawsVGunDeath/) project:**

- `Data/raw_cdc_gun_deaths.csv`: raw data of states gun deaths collected from [CDC Wonder Tool](https://wonder.cdc.gov/mcd.html)
- `Data/raw_cdc_gun_deaths_ns.csv`: raw data of states gun deaths excluding suicides as an underlying cause of death; collected from [CDC Wonder Tool](https://wonder.cdc.gov/mcd.html)
- `raw_state_gun_laws_data.csv`: raw data of state firearm law collected from [State Firearm Law Database](https://www.statefirearmlaws.org/)
- `data/cb_2016_us_state_500k`: map files for continental United States with Alaska and Hawaii repositioned
- `data_mgmt.R`: code to load, simplify, and join different sets of data
- `server.R`: code that defines the data that will be displayed through the UI
- `ui.R`: code for User Interface that defines how the application will be displayed in the browser
