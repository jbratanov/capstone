#--------------------------------------------
# Front end for word prediction application
#--------------------------------------------
library(triebeard)
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
    textInput(inputId = "phrase", label = "One moment: Loading Word Corpus",
              value = "Loading data:  Similar to turning on cell phone",
              width = '100%',
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
         "One of my goals was to do more intergation than trying to re-invent the wheel through
          pure custom code.  I  started with about 90% custom code, but as I learned more about
          existing R packages which solved many functional areas I was coding, I ended up with
          a good mix of 50% custom and 50% re-use of existing R packages.  I used the packaged 
          libraries where it had  better performance or already built API's which fit nicely
          into my project.",
         tags$ul(
           tags$li ("Input data was taken from Twitter, news, and blogs
                     of about 200 MB for each corpus file."),
           tags$li ("80% of samples were from news and blogs with 20% from twitter 
                   for the final corpus."),
           tags$li ("Due to the size of RAM, ngram files were created separately by ngram
                     level.  This means 4 separate program runs to created the required corpus."),
           tags$li ("TM (text mining) package was originally used, but changed to
                   Quanteda after test trials showed better performance and less complex
                   usage to create 4 levels of corpus files."),
           tags$li ("Final Smoothing of data was used to remove frequencies of less than 5 for
                   each ngram level to lower storage requirements and faster loading response."),
           tags$li ("Trie data structures were used for word prediction data access and retrieval
                   which improved response time significally. The triebeard package was used and saved
                   implementation time and already had built-in utilities which helped integrate
                   trie logic easily into my project."),
           tags$li ("Back off ngram method was used in identifying potential word prediction.  Phrases
                   were started at the hightest possible ngram level which gave it the highest
                   probability for a prediction match.  If a phrase didn't find a match, it drops
                   the leading word and validates against the next lower ngram level.")
         
         )
       ),
                      
                      
      p(
         "The app was created in RStudio using an HP EliteBook 8470p
         with a 2.6 GHz dual-core CPU and 8 GB RAM.  Due to the size of RAM,
         creation of ngram levels were created in the following program flow:"
        )

  ),
  style = "padding-right:2.5%")
)
)
))
