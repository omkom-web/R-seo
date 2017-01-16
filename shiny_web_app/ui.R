#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
library(googleAuthR)
library(shiny)
library(shinydashboard)
source('profile.R')

slidebar <- dashboardSidebar(
  # Custom CSS to hide the default logout panel
  tags$head(tags$style(HTML('.shiny-server-account { display: none; }'))),
  
  # The dynamically-generated user panel
  #iOutput("userpanel"),
  uiOutput("profile_nav"),
  uiOutput("profile"),
  
  #googleAuthUI("loginButton"),
  googleAuthR::googleAuthUI("loginButton"),
  selectInput("website_select", label = "Select Website",
              choices = NULL),
  
  actionButton("submit", "Get Search Console Data"),
  #INFOS : meta <- googleAnalyticsR::meta,
  sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("Tools", tabName = "tools", icon = icon("th"))
  )
)

body <- dashboardBody(
  textOutput("debug"),
  textOutput("selected_url", container = h2),
  fluidRow(
    box( 
        
    ),
    box()
  ),
  tabItems(
    tabItem(tabName = "dashboard",
            fluidRow(
              box( ),
              box()
            )
    ),
    
    # Second tab content
    tabItem(tabName = "tools",
            h2("Widgets tab content")
    )
  )
)

# Define UI for application that draws a histogram
dashboardPage(
  dashboardHeader(title = "R SEO"),
  slidebar,
  body
)
