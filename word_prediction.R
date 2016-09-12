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
sampleBlogPct <- 0.01
sampleNewsPct <- 0.01
sampleTwitPct <- 0.001
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
sampleText <- c(sample(blogText,length(blogText)*sampleBlogPct),
                sample(newsText, length(newsText)*sampleNewsPct),
                sample(twitterText,length(twitterText)*sampleTwitPct))

# Convert text to ASCII.  Removes special non-english characters
sampleText <- iconv(sampleText, "UTF-8", "ASCII", sub = "")

# Create train and testing sets
#library(caTools) # Needed for split
#splitSample = sample.split(sampleText, 0.7) 
#trainSample = subset(sampleText, splitSample == T) 
#testSample = subset(sampleText, splitSample == F) 

#-------------------------------------------------------------------------------------------------------
#  Create the Corpus
#-------------------------------------------------------------------------------------------------------
# I decided to try quanteda.  I found the R "tm" package slow, too much memory and complex.
# Documenting along the way and trying to compare what I did using the "tm" package.


# Create the Corpus
# A corpus is a kind of vector/list that facilitates applying text processing commands
# to many texts at once.

# put them into a corpus
require(quanteda)
sampleCorpus <- corpus(sampleText)

# Convert the text to data
# by creating a document-term matrix where each row is a document and each column is a word
# or feature found in at least one of the documents.
# This would be similar to the tm_map and dtm functions in "tm"
# Remove features.  This is what's used as "tm_map" in "tm"
# concatenator option defaults to "-".  Need space for doing word predictor functionality
# removeTwitter option TRUE removes "#" and "@" characters
dfm.2 <- dfm(sampleText, ngrams=2,
             toLower = TRUE,concatenator = " ", removeNumbers = TRUE, removeSymbols=TRUE,
             removePunct = TRUE, removeSeparators = TRUE, removeTwitter = TRUE, removeURL=TRUE)

dfm.3 <- dfm(sampleText, ngrams=3,
             toLower = TRUE,concatenator = " ", removeNumbers = TRUE, removeSymbols=TRUE,
             removePunct = TRUE, removeSeparators = TRUE, removeTwitter = TRUE, removeURL=TRUE)

#-------------------------------------------------------------------------------------------------------
#  Get top features,
#  Drop frequency > 1
#-------------------------------------------------------------------------------------------------------

# 2-ngram
freqTerms.2 <- topfeatures(dfm.2, n = nfeature(dfm.2))
freqTerms.2 <-freqTerms.2[freqTerms.2 > 5]

# 3-ngram.  Create file of dropped data for good turing smoothing model
freqTerms.3 <- topfeatures(dfm.3, n = nfeature(dfm.3))
df.3.dropped <-freqTerms.3[freqTerms.3 < 6]
df.3.drop <- data.frame(word=names(df.3.dropped), freq=df.3.dropped)
# Drop frequency > 5
freqTerms.3 <-freqTerms.3[freqTerms.3 > 5]


#-------------------------------------------------------------------------------------------------------
#  Create Data Frames for prediction
#-------------------------------------------------------------------------------------------------------
# stringr used for word function
library(stringr)

#####################################################################
# 2-ngram keys for trie prefix trees
# Used "|" as separator to create uniqueness in duplicate keys
#####################################################################
df.2 <- data.frame(word=names(freqTerms.2), freq=freqTerms.2)
unigram <- word(df.2$word,1,1)
df.2$unigram <- cbind(unigram)
key<-as.character()
for (i in length(df.2$unigram):1)
  key[i] <- paste(df.2$unigram[i], sep="|", formatC(i, width=7, flag="0"))
# bind key data to 2-ngram DF
df.2$key <- cbind(key)

# 3-ngram DF
df.3 <- data.frame(word=names(freqTerms.3), freq=freqTerms.3)
bigram <- word(df.3$word,1,2)
unigram <- word(df.3$word,1,1)
df.3$bigram <- cbind(bigram)
df.3$unigram <- cbind(unigram)

#####################################################################
# 3-ngram keys for trie prefix trees
# Used "|" as separator to create uniqueness in duplicate keys
#####################################################################
key<-as.character()
for (i in length(df.3$bigram):1)
  key[i] <- paste(df.3$bigram[i], sep="|", formatC(i, width=7, flag="0"))
# bind key data to 3-ngram DF
df.3$key <- cbind(key)

#-------------------------------------------------------------------------------------------------------
#  Create Markov Chain
#-------------------------------------------------------------------------------------------------------
#load markovchain package
library(markovchain)
library(tm)

# Create data required for markov chain fit
# I couldn't find a markovchain function for using frequenices, so created raw data to fit
words.3 <- rep(df.3$word, df.3$freqTerms.3)
#words.3<-scan_tokenizer(words.3)

# Create probability matrix
fit.3 <- markovchainFit(data=words.3)

#function for prediction
inWord="whatever"
input<-as.vector(unlist(strsplit(inWord," ", fixed=TRUE))) # Input phrase
p3<-function(n) predict(fit.3$estimate, newdata=as.vector(unlist(strsplit(n," ", fixed=TRUE))), n.ahead = 2)
p3(input)



# integrating best packages to solve issue...