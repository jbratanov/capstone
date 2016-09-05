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


# Get top features
freqTerms.2 <- topfeatures(dfm.2, n = nfeature(dfm.2))

# Drop frequency > 1
freqTerms.2 <-freqTerms.2[freqTerms.2 > 5]

# Print out frequent terms
#print(freqTerms.1[freqTerms.1 >= 1000])
#print(freqTerms.2[freqTerms.2 >= 200])
#print(freqTerms.3[freqTerms.3 >= 100])
#print(freqTerms.4[freqTerms.4 >= 100])
# Creating a "wordcloud" using quanteda
#require(RColorBrewer)
#plot(dfm.1, scale=c(8,.2), min.freq=3, max.words=Inf, random.order=FALSE, rot.per=.15, colors=blue)

# Create DF for output files


df.2 <- data.frame(word=names(freqTerms.2), freqTerms.2)


#-------------------------------------------------------------------------------------------------------
#  Create Markov Chain
#-------------------------------------------------------------------------------------------------------
#load markovchain package
library(markovchain)
library(tm)

# Create data required for markov chain fit
# I couldn't find a function for using frequenices, so created raw data to fit
words.2 <- rep(df.2$word, df.2$freqTerms.2)
words.2<-scan_tokenizer(words.2)

# Create probability matrix
fit.2 <- markovchainFit(data=words.2)

#function for prediction
inWord="whatever"
input<-as.vector(unlist(strsplit(inWord," ", fixed=TRUE))) # Input phrase
predictText<-function(n) predict(fit.2$estimate, newdata=as.vector(unlist(strsplit(n," ", fixed=TRUE))), n.ahead = 5)
predictText(input)


`
# integrating best packages to solve issue...

