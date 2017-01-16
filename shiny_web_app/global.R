options(shiny.port = 4624)
options("googleAuthR.scopes.selected" = c("https://www.googleapis.com/auth/webmasters",
                                          "https://www.googleapis.com/auth/analytics"
                                          )
)
options("googleAuthR.client_id" = "781925119443-gbk7lnf0q4gbfg62f6pbffhqjffc2ijc.apps.googleusercontent.com ")
options("googleAuthR.client_secret" = "Wso2-BLg_bQFGc7APPqJe2tA ")
options("googleAuthR.webapp.client_id" = "781925119443-l0r95i8spq8raj7i89t8l9836sgklc5t.apps.googleusercontent.com")
options("googleAuthR.webapp.client_secret" = "OGLpqaP9eoDg9MmpuKF9txdI")


is.error <- function(test_me){
  inherits(test_me, "try-error")
}