
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
rm(list = ls())


url <- "https://github.com/rohaanfarrukh/data332_counting_cars/raw/refs/heads/main/counting_cars_project/rscript/speed_counting_cars.xlsx"

# Download to a temp file
temp_file <- tempfile(fileext = ".xlsx")
GET(url, write_disk(temp_file, overwrite = TRUE))

# Now read it using read_excel
df <- read_excel(temp_file, .name_repair = "universal")

# UI
ui <- fluidPage(
  theme = bs_theme(bootswatch = "darkly", base_font = font_google("Roboto Mono")),
  
  titlePanel("🚘 Vehicle Speed Analysis Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput("vehicle_filter", "Select Vehicle Types:",
                         choices = NULL)
    ),
    
    mainPanel(
      fluidRow(
        column(4, wellPanel(h4("Total Observations"), textOutput("total_obs"))),
        column(4, wellPanel(h4("Avg Initial Speed"), textOutput("avg_init"))),
        column(4, wellPanel(h4("Avg Final Speed"), textOutput("avg_final")))
      ),
      
      tabsetPanel(
        tabPanel("Scatter Plot",
                 withSpinner(plotlyOutput("speed_plot"))
        ),
        
        tabPanel("Bar Chart & Averages",
                 withSpinner(plotOutput("bar_chart")),
                 h4("Average Initial Speeds by Vehicle Type"),
                 DTOutput("avg_init_speed_table"),
                 h4("Average Final Speeds by Vehicle Type"),
                 DTOutput("avg_final_speed_table")
        ),
        
        tabPanel("Flashing Sign Effect",
                 h4("Effect of Flashing Sign on Speed (Flashing = 1)"),
                 withSpinner(plotOutput("flashing_effect_plot"))
        ),
        tabPanel("Min / Max / Mean Speeds",
                 withSpinner(plotOutput("min_max_mean_plot"))
        )
      )
    )
  )
)

# Server
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
  
  output$total_obs <- renderText({ nrow(filtered_data()) })
  output$avg_init <- renderText({ round(mean(filtered_data()$init_speed, na.rm = TRUE), 2) })
  output$avg_final <- renderText({ round(mean(filtered_data()$final_speed, na.rm = TRUE), 2) })
  
  output$speed_plot <- renderPlotly({
    p <- ggplot(filtered_data(), aes(x = init_speed, y = final_speed, color = vehicle_type)) +
      geom_point(alpha = 0.7, size = 3) +
      labs(title = "Initial vs Final Speed",
           x = "Initial Speed",
           y = "Final Speed",
           color = "Vehicle Type") +
      theme_minimal()
    ggplotly(p)
  })
  
  output$bar_chart <- renderPlot({
    avg_df <- filtered_data() %>%
      filter(speed_change == 1) %>%
      group_by(vehicle_type, speed_change) %>%
      summarise(
        init = mean(init_speed, na.rm = TRUE),
        final = mean(final_speed, na.rm = TRUE),
        .groups = 'drop'
      ) %>%
      pivot_longer(cols = c("init", "final"), names_to = "Speed_Type", values_to = "Average_Speed") %>%
      mutate(Speed_Type = factor(Speed_Type, levels = c("init", "final")))
    
    ggplot(avg_df, aes(x = vehicle_type, y = Average_Speed, fill = Speed_Type)) +
      geom_bar(stat = "identity", position = position_dodge(width = 0.8)) +
      facet_wrap(~ speed_change, labeller = label_both) +
      labs(title = "Average Speeds by Vehicle Type (Speed Change = 1)",
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
  
  output$flashing_effect_plot <- renderPlot({
    flashing_df <- df %>%
      filter(flashing == 1) %>%
      pivot_longer(cols = c(init_speed, final_speed),
                   names_to = "Speed_Type",
                   values_to = "Speed") %>%
      mutate(Speed_Type = recode(Speed_Type, init_speed = "Initial", final_speed = "Final"),
             Speed_Type = factor(Speed_Type, levels = c("Initial", "Final")))
    
    ggplot(flashing_df, aes(x = Speed_Type, y = Speed, fill = Speed_Type)) +
      geom_violin(trim = FALSE, alpha = 0.5) +
      geom_boxplot(width = 0.1, color = "black", outlier.shape = NA) +
      labs(title = "Speed Distribution Before and After Flashing Sign",
           x = "Speed Type",
           y = "Speed (mph)") +
      theme_minimal()
  })
  output$min_max_mean_plot <- renderPlot({
    stats_df <- filtered_data() %>%
      pivot_longer(cols = c(init_speed, final_speed), 
                   names_to = "Speed_Type", 
                   values_to = "Speed") %>%
      group_by(vehicle_type, Speed_Type) %>%
      summarise(
        Min = min(Speed, na.rm = TRUE),
        Mean = mean(Speed, na.rm = TRUE),
        Max = max(Speed, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      pivot_longer(cols = c(Min, Mean, Max), names_to = "Stat", values_to = "Value") %>%
      mutate(
        Speed_Type = recode(Speed_Type, init_speed = "Initial", final_speed = "Final")
      )
    
    ggplot(stats_df, aes(x = vehicle_type, y = Value, fill = Stat)) +
      geom_bar(stat = "identity", position = "dodge") +
      facet_wrap(~ Speed_Type) +
      labs(title = "Min, Mean, and Max Speeds by Vehicle Type",
           x = "Vehicle Type",
           y = "Speed (mph)",
           fill = "Statistic") +
      theme_minimal()
  })
  
}

shinyApp(ui = ui, server = server)

