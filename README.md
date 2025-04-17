# data332_counting_cars
### Link to the shiny app
[Vehicle data Analysis](https://rohaanfarrukhdata332.shinyapps.io/shiny/)
## Data Collection
We collected the data together at the same time on sunday

The dataset is stored on GitHub and loaded directly into the app:
Contains:
- vehicle_type
- init_speed (Initial speed)
- final_speed (Speed after passing sign)
- speed_change (Whether speed changed)
- flashing (Whether flashing sign was active)

📊 Features
- Vehicle Filter – Select which types of vehicles to view.
- KPIs – Total observations, average initial speed, and average final speed.
- Scatter Plot – Shows relationship between initial and final speed.
- Bar Chart & Averages – Average initial/final speeds by vehicle type.
- Flashing Sign Effect – Visualizes the change in speed when a flashing sign is present.
- Min / Max / Mean Summary – Shows statistical summary (min, mean, max) for both speed types.

## Libraries
```r
library(rsconnect)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(readxl)
library(tidyr)
library(shiny)
library(DT)
library(plotly)
library(bslib)
library(shinycssloaders)
library(httr)
```

## Analysis
To analyze
