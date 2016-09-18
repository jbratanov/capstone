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
#    helpText("Stuff"),
#  br(),
  # select number of maximum word suggestions to be returned
  sliderInput(
    inputId = "max_words_returned",
    label = "Maximum number of requested words to be returned",
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
         "Possible words to use:"
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
          "Enter a phrase into the text input field.",
           style = "font-size:1.1em"
        ),
       br(),
                      
       tags$ul(
                        
          tags$li(
              span("Input Data:", style = "font-weight:700"),
                   "To predict the next word in a phrase,
                    type the phrase into the Enter a phrase input text box",
                    style = "font-size:1.1em"
                  ),
                        
       br(),
                        
          tags$li(
              span("How many words to return:", style = "font-weight:700"),
                   "You can control between 1-20 number of words to be returned.
                    The order of words will be from hightest to lowest probability.
                    In some cases, the number of words requested to be returned may
                    not be available, depending on pattern usages.",
                    style = "font-size:1.1em"
                   ),
        br(),
                        
                        
                      
            tags$li(
                span("Prediction text source:", style = "font-weight:700"),
                     "Data was taken from News articles, blogs and twitter feeds
                      sources which have unique usage and phrases.",
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