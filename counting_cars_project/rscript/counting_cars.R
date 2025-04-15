library(ggplot2)
library(dplyr)
library(tidyverse)
library(readxl)
library(tidyr)
library(shiny)
library(DT)

rm(list = ls())

setwd('/Users/basilchattha/Documents/r_projects/counting_cars_project/data')

df <- read_excel('speed_counting_cars.xlsx',.name_repair = 'universal')

### Shiny app 1
ui <- fluidPage(
  titlePanel("Vehicle Speed Analysis"),
  
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput("vehicle_filter", "Select Vehicle Types:",
                         choices = NULL),
      checkboxInput("show_summary", "Show Summary Statistics", value = TRUE)
    ),
    
    mainPanel(
      conditionalPanel(
        condition = "input.show_summary == true",
        h4("Summary Statistics"),
        verbatimTextOutput("summary")
      ),
      plotOutput("speed_plot"),
      DTOutput("table")
    )
  )
)

server <- function(input, output, session) {
  observe({
    updateCheckboxGroupInput(session, "vehicle_filter",
                             choices = unique(df$vehicle_type),
                             selected = unique(df$vehicle_type))
  })
  
  filtered_data <- reactive({
    req(input$vehicle_filter)
    df %>% filter(vehicle_type %in% input$vehicle_filter)
  })
  
  output$summary <- renderPrint({
    summary(filtered_data())
  })
  
  output$speed_plot <- renderPlot({
    ggplot(filtered_data(), aes(x = init_speed, y = final_speed, color = factor(speed_change))) +
      geom_point(alpha = 0.7, size = 3) +
      labs(title = "Initial vs Final Speed",
           x = "Initial Speed",
           y = "Final Speed",
           color = "Speed Changed") +
      theme_minimal()
  })
  
  output$table <- renderDT({
    datatable(filtered_data())
  })
}

shinyApp(ui = ui, server = server)

### Shiny app 2
ui <- fluidPage(
  titlePanel("Interactive Speed Histograms"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("hist_var", "Select Variable for Histogram:",
                  choices = c("Initial Speed" = "init_speed", 
                              "Final Speed" = "final_speed")),
      sliderInput("bins", "Number of Bins:", min = 5, max = 50, value = 20),
      checkboxGroupInput("vehicle_filter", "Select Vehicle Types:",
                         choices = NULL),
      checkboxInput("color_by_change", "Color by Speed Change", value = FALSE)
    ),
    
    mainPanel(
      plotOutput("hist_plot")
    )
  )
)

server <- function(input, output, session) {
  observe({
    updateCheckboxGroupInput(session, "vehicle_filter",
                             choices = unique(df$vehicle_type),
                             selected = unique(df$vehicle_type))
  })
  
  filtered_data <- reactive({
    req(input$vehicle_filter)
    df %>% filter(vehicle_type %in% input$vehicle_filter)
  })
  
  output$hist_plot <- renderPlot({
    data <- filtered_data()
    
    ggplot(data, aes_string(x = input$hist_var,
                            fill = if (input$color_by_change) "factor(speed_change)" else NULL)) +
      geom_histogram(bins = input$bins, alpha = 0.8, color = "black", position = "identity") +
      scale_fill_manual(values = c("0" = "skyblue", "1" = "tomato"), name = "Speed Changed") +
      labs(title = paste("Histogram of", input$hist_var),
           x = input$hist_var, y = "Count") +
      theme_minimal()
  })
}

shinyApp(ui = ui, server = server)

