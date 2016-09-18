#-------------------------------------------------------------------------------------------------------
# 
# Jbratanov Sep-2-2016

#-------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------
#  Get the data and create a sample
#-------------------------------------------------------------------------------------------------------
# Program directories
appDir="c:/Coursera/Capstone/"
dataDir="c:/Coursera/Capstone/data/"

#-------------------------------------------------------------------------------------------------------
# Function: Load trie data structures
#-------------------------------------------------------------------------------------------------------

load_trie_data_structure <- function() {
  
  library(triebeard)
  
  # 2-ngram trie
  trie_2ngram <- trie(keys=as.character(df.2$key), values=as.character(df.2$value))
  # 3-ngram trie
  trie_3ngram <- trie(keys=as.character(df.3$key), values=as.character(df.3$value))
  
  
}


#-------------------------------------------------------------------------------------------------------
# Get text match trie data structures
#-------------------------------------------------------------------------------------------------------

lookup_ngram_text <- function(words, num_words_return=5) {
  library(stringr)
  library(stringi)
  
  # remove leading and trailing spaces
  words <- stri_trim(words)
  
  # Get number of words in input string
  numWords <- sapply(strsplit(words, " "), length)
  
  if (numWords == 0) {
    #print("null value")
    return(NULL)
  }
 else if (numWords == 1) {
    #print("ngram-2")

    # add end of data suffix for search
    words <- paste0(words, "|")      

    # trie lookup
    matches <- prefix_match(trie_2ngram, words)
  }
  else  {
    #print("ngram-3")

    # get last 2 words for 3-ngram prefix match
    words <- word(words, numWords-1, numWords)

    # add end of data suffix for search
    words <- paste0(words, "|")

    # trie lookup
    matches <- prefix_match(trie_3ngram, words)
  }

  # if number of value matches is greater than requested, return only requested
  #print(length(matches[[1]]))
  #print(num_words_return)
  if (is.na(matches) == TRUE) {
    return(NULL)   
  }
  else if (length(matches[[1]]) > num_words_return) {
    return(matches[[1]][1:num_words_return])
  }  
  else {
  
    return(matches)
  }
  
}
