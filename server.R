

# server.R -- Create back end for word prediction app

# increase to 100MB
options(shiny.maxRequestSize=100*1024^2)

# Program directories
#appDir="c:/Coursera/Capstone/code/"
#dataDir="c:/Coursera/Capstone/data/"
appDir="./"
dataDir="./"
# Load ngram files
df.4 <- readRDS(paste0(dataDir,"df.4.rds"))
df.3 <- readRDS(paste0(dataDir,"df.3.rds"))
df.2 <- readRDS(paste0(dataDir,"df.2.rds"))

# Source loading trie ngram data structures and prediction lookup
source("word_prediction.R", local=TRUE)




    
# define server
shinyServer(function(input, output, session) {
  
  updateTextInput(session, "phrase",  label = paste("Enter a phrase for word prediction"),
                   value = paste(""))
  
  # define reactive variable to hold user input
  user_data <- reactive({
    
    lookup_ngram_text(input$phrase, input$max_words_returned)

  })
  
  
  # create output for prediction as text
  output$prediction_words <- renderText({
    # lookup phrase, using search type and max number of return words
    words <- user_data()
    if (length(words[[1]]) > 0) {
      words <- unlist(words)  
      print(words)
    }
    else {
      print("")
    }
    
  })
  
})
