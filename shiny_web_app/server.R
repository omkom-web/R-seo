#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
library(googleAuthR)
library(shiny)
library(shinydashboard)

options(shiny.port = 5572)
options("googleAuthR.scopes.selected" = c("https://www.googleapis.com/auth/webmasters",
                                          "https://www.googleapis.com/auth/analytics"
                                          )
      )

shorten_url <- function(url){
  body = list( longUrl = url )
  
  f <- gar_api_generator("https://www.googleapis.com/urlshortener/v1/url",
                         "POST",
                         data_parse_function = function(x) x$id)
  f(the_body = body)
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  ## Create access token and render login button
  access_token <- callModule(googleAuth, "loginButton")
  
  ## Create access token and render login button
  #access_token <- callModule(googleAuth, "loginButton", approval_prompt = "force")
  
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
