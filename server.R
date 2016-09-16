
# server.R -- Create back end for word prediction app
library(triebeard)
# define server
shinyServer(function(input, output) {
  
  # define reactive variable to hold user input
  user_data <- reactive({

    lookup_ngram_text(input$phrase, input$max_words_returned)

  })
  
  
  # create output for prediction as text
  output$prediction_words <- renderPrint({
    # lookup phrase, using search type and max number of return words
    words <- user_data()
    if (length(words[[1]]) > 0) {
      print(words)
    }
    else {
      print("No Words Found")
    }
    
  })
  
})