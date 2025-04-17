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
For the analysis we used 4 different graphs 
<div align = "center">
<img src = "https://github.com/rohaanfarrukh/data332_counting_cars/blob/main/counting_cars_project/rscript/graphs/scatter%20plot.png" width = "450")>
</div>
This graph shows the different types of cars compared to their initial and final speed. It shows that there are no alot of change in the speeds. 
We do have 1 outlier that had a final speed of 40.

<div align = "center">
<img src = "https://github.com/rohaanfarrukh/data332_counting_cars/blob/main/counting_cars_project/rscript/graphs/barchart.png" width = "450")>
</div>
The bar graph shows us the difference between averavage inital and final speed that did change while the ones that did not have a change in speed were removed from this graph

<div align = "center">
<img src = "https://github.com/rohaanfarrukh/data332_counting_cars/blob/main/counting_cars_project/rscript/graphs/flashing%20light.png" width = "450")>
</div>
This graph show us the intial speed of people that were going way above the speed limit and that they did slow down when the board started flashing. but they did not slow down
much as shown by their final speeds.

<div align = "center">
<img src = "https://github.com/rohaanfarrukh/data332_counting_cars/blob/main/counting_cars_project/rscript/graphs/minmax.png" width = "450")>
</div>
The graph shows us the max/min/mean of all the types of vehicles that were recorded

Final thoughts the people did not change their speed much when seeing the meter. but they were going around the speed limit as the average speed for all the 
vehicles were between 30-31mph. We also think that as we were standing there recording the data people started slowing down becuase of that.
