library(ggplot2)
library(dplyr)
library(tidyverse)
library(readxl)
library(tidyr)
library(shiny)
library(DT)

rm(list = ls())

setwd('/Users/basilchattha/Documents/r_projects/counting_cars_project/data')

df <- read_excel('speed_counting_cars.xlsx', .name_repair = 'universal')

ui <- fluidPage(
  titlePanel("Vehicle Speed Analysis"),
  
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput("vehicle_filter", "Select Vehicle Types:",
                         choices = NULL)
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Scatter Plot",
                 plotOutput("speed_plot")
        ),
        
        tabPanel("Bar Chart & Averages",
                 plotOutput("bar_chart"),
                 h4("Average Initial Speeds by Vehicle Type"),
                 DTOutput("avg_init_speed_table"),
                 h4("Average Final Speeds by Vehicle Type"),
                 DTOutput("avg_final_speed_table")
        )
      )
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
  
  output$speed_plot <- renderPlot({
    ggplot(filtered_data(), aes(x = init_speed, y = final_speed, color = vehicle_type)) +
      geom_point(alpha = 0.7, size = 3) +
      labs(title = "Initial vs Final Speed",
           x = "Initial Speed",
           y = "Final Speed",
           color = "Vehicle Type") +
      theme_minimal()
  })
  
  output$bar_chart <- renderPlot({
    avg_df <- filtered_data() %>%
      group_by(vehicle_type, speed_change) %>%
      summarise(
        init = mean(init_speed, na.rm = TRUE),
        final = mean(final_speed, na.rm = TRUE),
        .groups = 'drop'
      ) %>%
      pivot_longer(cols = c("init", "final"), names_to = "Speed_Type", values_to = "Average_Speed")
    
    ggplot(avg_df, aes(x = vehicle_type, y = Average_Speed, fill = Speed_Type)) +
      geom_bar(stat = "identity", position = position_dodge(width = 0.8)) +
      facet_wrap(~ speed_change, labeller = label_both) +
      labs(title = "Average Speeds by Vehicle Type and Speed Change",
           x = "Vehicle Type",
           y = "Average Speed",
           fill = "Speed Type") +
      theme_minimal()
  })
  
  output$avg_init_speed_table <- renderDT({
    avg_init <- filtered_data() %>%
      group_by(vehicle_type) %>%
      summarise(Average_Initial_Speed = round(mean(init_speed, na.rm = TRUE), 2))
    
    datatable(avg_init, options = list(dom = 't'))
  })
  
  output$avg_final_speed_table <- renderDT({
    avg_final <- filtered_data() %>%
      group_by(vehicle_type) %>%
      summarise(Average_Final_Speed = round(mean(final_speed, na.rm = TRUE), 2))
    
    datatable(avg_final, options = list(dom = 't'))
  })
}

shinyApp(ui = ui, server = server)
