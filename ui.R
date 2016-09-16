#--------------------------------------------
# Front end for word prediction application
#--------------------------------------------

library(shiny)
library(shinythemes)


# define UI
shinyUI(fluidPage(
  
  # style screen as minimal and neutral
  theme = shinytheme("united"),

#--------------------------------------------
#Side bar layout
#--------------------------------------------
# Show application title
titlePanel("Word Prediction Application"),
br(),
br(),

# Define layout
sidebarLayout(position = "right", 
 sidebarPanel(
    helpText("Stuff"),
  br(),
  # select number of maximum word suggestions to be returned
  sliderInput(
    inputId = "max_words_returned",
    label = "Maximum number of suggested words to be returned",
    min = 1, max = 20, ticks = TRUE, value = 5
  
  )
),
#--------------------------------------------
# Main Panel

mainPanel(
              
    # Phase input
    textInput(inputId = "phrase", label = "Enter a phrase for word prediction",
              value = "",
              width = '50%',
              placeholder = ""
             ),
                  

    br(),
    br(),
                  
    # show prediction result as text
    div(style = "text-align:left; font-size:1.25em; font-weight:700;color:#777",
                     
      p(
         "The next word in your phrase is one of these:"
       )            
    ),
    verbatimTextOutput("prediction_words"),    
    
    br(),
    br(),
#------------------------------------------------------------
# Table for documentation
#------------------------------------------------------------
# define DOCUMENTATION panels
tabsetPanel(
                    
  # define INTRODUCTION panel
  tabPanel(
      "Instructions",
      br(),
                      
      p(
          "You can use this app to predict
           the next word in any short text.
           You can also use the app to learn more
           about how word prediction works,
           by seeing how tweaks to the algorithm
           affect the output",
           style = "font-size:1.1em"
        ),
       br(),
                      
       tags$ul(
                        
          tags$li(
              span("Getting predictions:", style = "font-weight:700"),
                   "To predict the next word in a phrase,
                    type or paste the phrase into the \'Enter a phrase\' box.
                    One or more predicted words will be displayed immediately..",
                    style = "font-size:1.1em"
                  ),
                        
       br(),
                        
          tags$li(
              span("How many words to return:", style = "font-weight:700"),
                   "Sometimes it\'s convenient to see one word predicted,
                    and sometimes it\'s convenient to see more.
                    Set the \'words to suggest\' slider to the number of words
                    that you\'d like to receive.",
                    style = "font-size:1.1em"
                   ),
        br(),
                        
           tags$li(
               span("How many words to analyze:", style = "font-weight:700"),
                    "It\'s interesting to see how prediction accuracy decreases
                     as the app uses fewer words at the end of each phrase for prediction.
                     To see this in action, set the number of words that the app uses
                     by changing the \'use for prediction\' slider.",
                     style = "font-size:1.1em"
                    ),
                        
         br(),
                        
            tags$li(
                span("Prediction source:", style = "font-weight:700"),
                     "Each language source has its own flavor.
                      You can see how the app uses different sources
                      to make different predictions. Use the \'Source\' slider
                      to choose the source that you\'re interested in.",
                      style = "font-size:1.1em"
                     )
                        
                  )
                      
    ),
                    
   # define panel ABOUT this app
   tabPanel(
      "About",
      br(),
                      
      p(
         "Inputs for this app's language model were 3 corpora
         of approximately 200 MB each from Twitter, news, and blogs.
         80% samples were used, with 20% reserved for testing.
         Ngram models were created from these corpora using strings of 1-4 words.
         Good-Turing smoothing was then applied to account for unseen grams."
       ),
                      
      p(
         "A series of optimizations was made to produce a working model:",
         tags$ul(
                  tags$li("A trie data structure to reduce speed complexity to a constant value, and to trim redundant storage of ngram prefixes"),
                  tags$li("Filtering out of ngrams whose instance count was 1, in order to improve prediction accuracy and reduce storage for uninformative features"),
                  tags$li("Storing terms as integer keys into a master index, in order to reduce redundant language in the model"),
                  tags$li("Converting term probabilities to quantized logarithms, in order to reduce the storage space required for double-precision, floating-point numbers")
                  )
       ),
                      
      p(
         "The app was created in RStudio using the quanteda package
         and custom code.
         Computation was performed on a MacBook Pro (mid-2014)
         with a 2.2 GHz quad-core CPU and 16 GB RAM.
         Computation time was approximately 4 hours
         to build the combined language model."
        ),
                      
       p(
          "Key references for this work were:",
           tags$ul(
                    tags$li(span("Speech and Language Processing",
                      style = "font-style:italic"),
                      "(second edition), by Jurafsky and Martin, chapter 4"),
                    tags$li(span("Statistical Machine Translation",
                      style = "font-style:italic"),
                       "by Philipp Koehn, chapter 7")
                   )
         ),
                      
        p(
           "This app was created for the capstone project
           in the Data Science specialization of Coursera."
          )
              
  ),
  style = "padding-right:2.5%")
)
)
))