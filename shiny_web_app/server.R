#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
library(googleAuthR)
#library(searchConsoleR)
library(shiny)
library(shinydashboard)

#scr_auth()
#source('functions.R')

options(shiny.port = 1221)


options("googleAuthR.scopes.selected" = c("https://www.googleapis.com/auth/webmasters",
                                          "https://www.googleapis.com/auth/analytics"
                                          )
      )
#service_token <- gar_auth_service(json_file="~/__DEV/R-seo/secret_google.json")

shorten_url <- function(url){
  body = list( longUrl = url )
  
  f <- gar_api_generator("https://www.googleapis.com/urlshortener/v1/url",
                         "POST",
                         data_parse_function = function(x) x$id)
  f(the_body = body)
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  message("New Shiny Session - ", Sys.time())
  
  ## Create access token and render login button
  access_token <- callModule( googleAuth, "login", login_text = "S'indentifier", logout_text = "Se déconnecter")
  #ga_accounts <- reactive({
  #  validate( need( access_token(), "Authenticate") )
  #  with_shiny( google_analytics_account_list, shiny_access_token = access_token() )
  #})
  
  #short_url_output <- eventReactive(input$submit, {
    ## wrap existing function with_shiny
    ## pass the reactive token in shiny_access_token
    ## pass other named arguments
    #with_shiny(f = shorten_url, 
    #           shiny_access_token = access_token(),
    #           url=input$url)
    #})
  
  output$userpanel <- renderUI({
    # session$user is non-NULL only in authenticated sessions
    if (!is.null(session$user)) {
      sidebarUserPanel(
        span("Logged in as ", session$user),
        subtitle = a(icon("sign-out"), "Logout", href="__logout__"))
    }
  })
  
})
