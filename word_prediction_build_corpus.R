#-------------------------------------------------------------------------------------------------------
# 
# Jbratanov Sep-2-2016
# In order to speed up retrieval of the training data to be used by the Capstone project, I manually
# downloaded the training data located at
# https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip.
#
# The en_us based datasets were unzipped into the capstone project data directory as: 
# en_US.news.txt
# en_US.twitter.txt
# en_US.blogs.txt
#-------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------------
#  Get the data and create a sample
#-------------------------------------------------------------------------------------------------------

# allows for easier changes during testing
sampleBlogPct <- 0.7
sampleNewsPct <- 0.7
sampleTwitPct <- 0.2
# Program directories
appDir="c:/Coursera/Capstone/"
dataDir="c:/Coursera/Capstone/data/"

# Included skilNul=TRUE statement to get rid of nulls from first pass.
blogText <- readLines(paste0(dataDir,"en_US.blogs.txt"), skipNul = TRUE)
newsText <- readLines(paste0(dataDir,"en_US.news.txt"), skipNul = TRUE)
twitterText <- readLines(paste0(dataDir,"en_US.twitter.txt"), skipNul = TRUE)

# Take samples from files and merge data
# set seed to make it reproducible
set.seed(1)
print("Getting sample text")
sampleText <- c(sample(blogText,length(blogText)*sampleBlogPct),
                sample(newsText, length(newsText)*sampleNewsPct),
                sample(twitterText,length(twitterText)*sampleTwitPct))

# Convert text to ASCII.  Removes special non-english characters
sampleText <- iconv(sampleText, "UTF-8", "ASCII", sub = "")

# Save sample text file to file
saveRDS(sampleText, (paste0(dataDir,"sampleText.rds")))

# Delete RFiles to save memory
rm(blogText, newsText, twitterText)


# Create train and testing sets
#library(caTools) # Needed for split
#splitSample = sample.split(sampleText, 0.7) 
#trainSample = subset(sampleText, splitSample == T) 
#testSample = subset(sampleText, splitSample == F) 

#-------------------------------------------------------------------------------------------------------
#  Create the Corpus
#-------------------------------------------------------------------------------------------------------
require(quanteda)

#######################################
# Get 2-ngram corpus data
#######################################

# Create Doc Term Matrix for 2-ngram
print("Building dfm.2 data")
dfm.2 <- dfm(sampleText, ngrams=2,
             toLower = TRUE,concatenator = " ", removeNumbers = TRUE, removeSymbols=TRUE,
             removePunct = TRUE, removeSeparators = TRUE, removeTwitter = TRUE, removeURL=TRUE)

# Save dfm n-gram data to file
saveRDS(dfm.2, (paste0(dataDir,"dfm.2.rds")))

# Get frequency for each unigram
print("Building freqTerms.2 data")
freqTerms.2 <- topfeatures(dfm.2, n = nfeature(dfm.2))
freqTerms.2 <-freqTerms.2[freqTerms.2 > 5]

# Save corpus freqTerms data to file
saveRDS(freqTerms.2, (paste0(dataDir,"freqTerms.2.rds")))

# Delete RFiles to save memory
rm(dfm.2)

#######################################
# Get 3-ngram corpus data
#######################################

# Create Doc Term Matrix for 3-ngram
print("Building dfm.3 data")
dfm.3 <- dfm(sampleText, ngrams=3,
             toLower = TRUE,concatenator = " ", removeNumbers = TRUE, removeSymbols=TRUE,
             removePunct = TRUE, removeSeparators = TRUE, removeTwitter = TRUE, removeURL=TRUE)

# Save dfm n-gram data to file
saveRDS(dfm.3, (paste0(dataDir,"dfm.3.rds")))

# Get frequency for each bigram.
# Create file of dropped data for good turing smoothing model
print("Building freqTerms.3 data")
freqTerms.3 <- topfeatures(dfm.3, n = nfeature(dfm.3))
#df.3.dropped <-freqTerms.3[freqTerms.3 < 6]  # Drop frequency > 5 to drop file
#df.3.drop <- data.frame(word=names(df.3.dropped), freq=df.3.dropped)
freqTerms.3 <-freqTerms.3[freqTerms.3 > 5] # Keep freqency > 5 to word prediction file

# Save corpus freqTerms data to file
saveRDS(freqTerms.3, (paste0(dataDir,"freqTerms.3.rds")))

# Delete RFiles to save memory
rm(dfm.3)

# Delete raw data sample text RFile to save memory
rm(sampleText)


#-------------------------------------------------------------------------------------------------------
#  Create Data Frames for prediction
#-------------------------------------------------------------------------------------------------------
# stringr used for word function
library(stringr)

#####################################################################
# 2-ngram keys for trie prefix trees
# Used "|" as separator to create uniqueness in duplicate keys
#####################################################################
print("Building df.2 DF")
df.2 <- data.frame(word=names(freqTerms.2), freq=freqTerms.2)
unigram <- word(df.2$word,1,1)
value <- word(df.2$word,2,2)
df.2$unigram <- cbind(unigram)
df.2$value <- cbind(value)
key<-as.character()
for (i in length(df.2$unigram):1)
  key[i] <- paste(df.2$unigram[i], sep="|", formatC(i, width=7, flag="0"))
# bind key data to 2-ngram DF
df.2$key <- cbind(key)

# Save corpus freqTerms data to file
saveRDS(df.2, (paste0(dataDir,"df.2.rds")))

# Delete RFiles to save memory
rm(freqTerms.2)

# 3-ngram DF
print("Building df.3 DF")
df.3 <- data.frame(word=names(freqTerms.3), freq=freqTerms.3)
bigram <- word(df.3$word,1,2)
value <- word(df.3$word,3,3)
df.3$bigram <- cbind(bigram)
df.3$value <- cbind(value)

# Delete RFiles to save memory
rm(unigram, bigram, freqTerms.3)

#####################################################################
# 3-ngram keys for trie prefix trees
# Used "|" as separator to create uniqueness in duplicate keys
#####################################################################
key<-as.character()
for (i in length(df.3$bigram):1)
  key[i] <- paste(df.3$bigram[i], sep="|", formatC(i, width=7, flag="0"))
# bind key data to 3-ngram DF
df.3$key <- cbind(key)

# Save corpus freqTerms data to file
saveRDS(df.3, (paste0(dataDir,"df.3.rds")))

# Delete RFiles to save memory
rm(key)


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

lookup_ngram_text <- function(words, num_words_return) {
  library(stringr)
  library(stringi)
  
  # remove leading and trailing spaces
  words <- stri_trim(words)
  
  # Get number of words in input string
  numWords <- sapply(strsplit(words, " "), length)
  
  if (numWords == 0) {
    print("null value")
    matches <- NULL
  }
  else if (numWords == 1) {
    #print("ngram-2")
    # add end of data suffix for search
    words <- paste0(words, "|")
    # trie lookup
    matches <- prefix_match(trie_2ngram, words)
  }
  else
  {
    #print("ngram-3")
    
    # get last 2 words for 3-ngram prefix match
    words <- word(words, numWords-1, numWords)
    # add end of data suffix for search
    words <- paste0(words, "|")
    # trie lookup
    matches <- prefix_match(trie_3ngram, words)
  }
  
  # if number of value matches is greater than requested, return only requested
  print(length(matches[[1]]))
  if (length(matches[[1]]) > num_words_return) {
    return(matches[[1]][1:num_words_return])
  }  else {
    
    return(matches)
  }
  
  
}
