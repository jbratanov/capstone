

# server.R -- Create back end for word prediction app

source("word_prediction.R")


    
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
