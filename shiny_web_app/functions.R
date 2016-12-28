#install.packages("devtools")
#library(devtools)
#install_github("skardhamar/rga", force = TRUE)
#install.packages(c("shiny", "googleAuthR","googleAnalyticsR","googleAnalyticsR"," shinydashboard","d3heatmap","dygraphs","ggplot2"))

#Needed <- c("tm", "SnowballCC", "RColorBrewer", "ggplot2", "wordcloud", "biclust", "cluster", "igraph", "fpc")   
#install.packages(Needed, dependencies=TRUE)   
#install.packages("Rcampdf", repos = "http://datacube.wu.ac.at/", type = "source")    

library(rga)
library(dygraphs)
library(zoo)
library(tidyr)
library(lubridate)
library(d3heatmap)
library(dplyr)
library(stringr)
library(DT)
#library(RMySQL)
#library(CausalImpact)
#library(AnomalyDetection)
library(ggplot2)
library(data.table)
#library(rjson)
library(tm)
library(FactoMineR)
library(wordcloud)

# I have the below in a file I source that is not on github
message("functions.R called from ", getwd())

# load secrets IDs
#source('secrets.R')

## Run this locally first, to store the auth token.ga.
## this is then uploaded with the shiny app for future requests.
#rga.open(instance="ga" , where="./token.rga")

get_ga_data <- function(profileID, 
                        fetch_metrics, 
                        fetch_dimensions,
                        fetch_filter = ""){
  
  ## Run this locally first, to store the auth token.
  #rga.open(instance="ga")
  
  
  all_start <-  ga$getFirstDate(profileID)
  start <- today() - options()$rga$daysBackToFetch
  yesterday <- today() -1
  
  message("# Fetching GA data")
  ga_data <- ga$getData(ids = profileID,
                        start.date = start,
                        end.date = yesterday,
                        metrics = fetch_metrics,
                        dimensions = fetch_dimensions,
                        filters = fetch_filter,
                        batch = T)
  
  return(ga_data)
  
}

gsuggest <- function(kw, hl = 'fr'){
  require(XML)
  xml.url <- paste('http://suggestqueries.google.com/complete/search?output=toolbar&inputencoding=UTF-8&outputencoding=UTF-8&hl=',hl,'&q="', kw, '"', sep='')
  doc <- xmlParse(xml.url)
  
  #message(paste("XML encoding before :", getEncoding(doc)))
  #doc <- iconv(doc, to="UTF-8")
  #doc <- iconv(as.character(doc), from = "ISO-8859-1", to = "UTF-8", toRaw = TRUE)
  #message(paste("XML encoding after :",getEncoding(doc)))
  
  gsuggest_data <- xpathSApply(doc, '//suggestion/@data')
  
  return(gsuggest_data)
}

get_gsuggest_data <- function(kw){
  g_suggest <- gsuggest(kw)
  temp <- apply(as.data.frame(g_suggest), 1, gsuggest)
  all <- data.table(Suggestions = g_suggest, temp, keep.rownames = FALSE)
  all
  return(all)
}

## Cool, but need to re-code
#gsuggestJSON <- function(kw){
#  json_file <- paste('http://suggestqueries.google.com/complete/search?output=firefox&hl=fr&q="', kw, '"', sep='')
#  json_data <- fromJSON(file=json_file)
#  gsuggest_data <- json_data
#  
#  return(gsuggest_data)
#}

create_dtm <- function(text){
  # Importation et traitement du corpus
  expressions <- Corpus(VectorSource(text))
  #summary(expressions) #résumé
  inspect(expressions) #résumé
  
  # Mettre en minuscules
  expressions <- tm_map(expressions, content_transformer(tolower))
  
  # Remplacer les ponctuations par des espaces. (attention aux apostrophes)
  expressions <- tm_map(expressions, removePunctuation)   
  #expressions <- tm_map(expressions,content_transformer(function(x) gsub("\\W", " ", x)))
  
  # Supprimer les mots courants
  expressions <- tm_map(expressions, removeWords, words = stopwords("french"))
  
  # Supprimer les terminaisons des mots (ex : e, es, ent...)
  #expressions <- tm_map(expressions, stemDocument, language = "french")
  
  # Supprimer les nombres
  #expressions <- tm_map(expressions, removeNumbers)
  
  # Supprimer les espaces superflus
  expressions <- tm_map(expressions, stripWhitespace)
  
  # Analyse
  dtm <- DocumentTermMatrix(expressions, control = list(weighting = weightTfIdf))
  #dimnames(dtm)[[1]] <- gsub(".txt", "", dimnames(dtm)[[1]])
  
  return(dtm)
}

get_kwKmean_data <- function(kw){
  dtm <- create_dtm(get_gsuggest_data(kw))
  dim(dtm)
  
  # Clustering hiérarchique
  d <- dist(dtm)
  h <- hclust(d, "ward.D")
  
  ##return(plot(h, xlab = "", ylab = "distance", main = NA, sub = NA))
  
  # Analyse en composante principale
  pca <- PCA((as.matrix(dtm)), scale.unit = F, graph=F)
  
  ##return(plot(pca, title = "Analyse en composantes principales", axes=c(1,2)))
  
  # Graphique avec les mots ayant les plus fortes pondérations
  nwords <- 20
  coord <- pca$var$coord
  d <- coord[,1]^2 + coord[,2]^2
  idx <- which(d > quantile(d, 1 - nwords/nrow(coord))) # On veut environ 20 mots
  
  return(c(plot(coord[idx, 1:2], type = "n", xaxt = "n", yaxt = "n", xlab = "Composante 1", ylab = "Composante 2"),
           text(coord[idx, 1:2], names(idx), cex=0.7),
           abline(h = 0, lty = 2, col = gray(0.5)),
           abline(v = 0, lty = 2, col = gray(0.5))))
  
}

get_kwCloud_data <- function(kw){
  dtm <- create_dtm(get_gsuggest_data(kw))
  freq <- colSums(as.matrix(dtm))   
  set.seed(142)   
  dark2 <- brewer.pal(6, "Dark2")   
  return(wordcloud(names(freq), freq, max.words=100, rot.per=0.2, colors=dark2))  
}

