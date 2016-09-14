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
  trie_2ngram <- trie(keys=as.character(df.2$key), values=as.character(df.2$word))
  # 3-ngram trie
  trie_3ngram <- trie(keys=as.character(df.3$key), values=as.character(df.3$word))
  
  load(trie_2ngram, trie_3ngram)
  
}


#-------------------------------------------------------------------------------------------------------
# Get text match trie data structures
#-------------------------------------------------------------------------------------------------------

lookup_ngram_text <- function(words) {
  library(stringr)
  
  
  # Get number of words in input string
  numWords <- sapply(strsplit(words, " "), length)
  
  if (numWords == 0) {
    print("null value")
    matches <- NULL
  }
  else if (numWords == 1) {
    print("ngram-2")
    # add end of data suffix for search
    words <- paste0(words, "|")
    # trie lookup
    matches <- prefix_match(trie_2ngram, words)
  }
  else
  {
    print("ngram-3")
    # get last 2 words for 3-ngram prefix match
    words <- word(words, numWords-1, numWords)
    # add end of data suffix for search
    words <- paste0(words, "|")
    # trie lookup
    matches <- prefix_match(trie_3ngram, words)
  }
  
  
  return(matches)
  
}
