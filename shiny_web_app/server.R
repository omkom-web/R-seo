#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
library(googleAuthR)
library(searchConsoleR)
library(shiny)
library(shinydashboard)

source('global.R')

options("googleAuthR.scopes.selected" = getOption("searchConsoleR.scope") )
options("googleAuthR.client_id" = getOption("searchConsoleR.client_id"))
options("googleAuthR.client_secret" = getOption("searchConsoleR.client_secret"))
options("googleAuthR.webapp.client_id" = getOption("searchConsoleR.webapp.client_id"))
options("googleAuthR.webapp.client_secret" = getOption("searchConsoleR.webapp.client_secret"))

#scr_auth()
#source('functions.R')

shorten_url <- function(url){
  body = list( longUrl = url )
  
  f <- gar_api_generator("https://www.googleapis.com/urlshortener/v1/url",
                         "POST",
                         data_parse_function = function(x) x$id)
  f(the_body = body)
}

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  message("New Shiny Session - ", Sys.time())
  
  ## Create access token and render login button
  access_token <- callModule( googleAuth, "loginButton", login_text = "S'indentifier", logout_text = "Se déconnecter")
  #access_token <- googleAuthR::reactiveAccessToken(session)
  #output$loginButton <- googleAuthR::renderLogin(session, access_token())
  
  website_df <- reactive({
    validate( need( access_token(), "Authenticate") )
    with_shiny( list_websites, shiny_access_token = access_token() )
  })
  
  observe({
    www <- website_df()
    urls <- www[www$permissionLevel != "siteUnverifiedUser",'siteUrl']
    updateSelectInput(session,
                      "website_select",
                      choices = urls)
  })
  

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
    #if (!is.null(session$user)) {
      sidebarUserPanel(
        span("Logged in as ", session$user),
        subtitle = a(icon("sign-out"), "Logout", href="__logout__"))
    #}
  })
  
  output$selected_url <- renderText({
    www <- input$website_select
    if(!is.null(access_token())){
      s <- www  
    } else {
      s <- "Authenticate to see data."
    }
    s
  })
  
})
