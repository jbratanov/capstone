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
# Load trie data structures
#-------------------------------------------------------------------------------------------------------

  library(triebeard)

  # 2-ngram trie
  #print("loading 2-ngram trie")
  trie_2ngram <- trie(keys=as.character(df.2$key), values=as.character(df.2$value))
  if (length(trie_2ngram) == length(df.2$key)) {
    
    print("trie_2ngram length success")
    
  }
 
  # 3-ngram trie
  #print("loading 3-ngram trie")
  trie_3ngram <- trie(keys=as.character(df.3$key), values=as.character(df.3$value))
  if (length(trie_3ngram) == length(df.3$key)) {
  
    print("trie_3ngram length success")
  
  }

  # 4-ngram trie
  #print("loading 4-ngram trie")
  trie_4ngram <- trie(keys=as.character(df.4$key), values=as.character(df.4$value))
  if (length(trie_4ngram) == length(df.4$key)) {
  
    print("trie_4ngram length success")
  
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
  

  if (numWords > 2) {
    matches <- get_4gram(words)
    if (is.na(matches) == TRUE) {
      matches <- get_3gram(words)
      if (is.na(matches) == TRUE) {
        matches <- get_2gram(words)
      }
    }  
  }
  else if (numWords == 2) {
    matches <- get_3gram(words)
    if (is.na(matches) == TRUE) {
      matches <- get_2gram(words)
    }
  }
  else if (numWords == 1) {
    matches <- get_2gram(words)
    #print(matches)
  }
  else {
   #print("null value")
   return(NULL)
  }  
   
  # if number of value matches is greater than requested, return only requested
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


#-------------------------------------------------------------------------------------------------------
# 2-ngram logic
#-------------------------------------------------------------------------------------------------------
get_2gram <- function(words) {
  
  numWords <- sapply(strsplit(words, " "), length)
  # get last word for 2-ngram prefix match
  words <- word(words, numWords, numWords)
  # add end of data suffix for search
  words <- paste0(words, "|")      
  # 2-ngram trie lookup
  print("2-ngram")
  print(words)
  matches <- prefix_match(trie_2ngram, words)
  
  return(matches)
  
}


#-------------------------------------------------------------------------------------------------------
# 3-ngram logic
#-------------------------------------------------------------------------------------------------------
get_3gram <- function(words) {
  

  # Get number of words in input string
  numWords <- sapply(strsplit(words, " "), length)
  # get last 2 words for 3-ngram prefix match
  words <- word(words, numWords-1, numWords)
  print("3-ngram")
  print(words)
  # add end of data suffix for search
  words <- paste0(words, "|")
  # 3-ngram trie lookup
  matches <- prefix_match(trie_3ngram, words)
  
  return(matches)
  
}


#-------------------------------------------------------------------------------------------------------
# 4-ngram logic
#-------------------------------------------------------------------------------------------------------
get_4gram <- function(words) {
  
  # Get number of words in input string
  numWords <- sapply(strsplit(words, " "), length)
  # get last 3 words for 4-ngram prefix match
  words <- word(words, numWords-2, numWords)
  print("4-ngram")
  print(words)
  # add end of data suffix for search
  words <- paste0(words, "|")
  # 4-ngram trie lookup
  matches <- prefix_match(trie_4ngram, words)
  
  return(matches)
  
}
