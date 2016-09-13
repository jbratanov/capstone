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
sampleBlogPct <- 1.0
sampleNewsPct <- 1.0
sampleTwitPct <- 0.4
# Program directories
appDir="c:/Coursera/Capstone/"
dataDir="c:/Coursera/Capstone/data/"

# Included skilNul=TRUE statement to get rid of nulls from first pass.
print("reading blog text")
blogText <- readLines(paste0(dataDir,"en_US.blogs.txt"), skipNul = TRUE)
print("reading news text")
newsText <- readLines(paste0(dataDir,"en_US.news.txt"), skipNul = TRUE)
print("reading twitter text")
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
df.2$unigram <- cbind(unigram)
key<-as.character()
for (i in length(df.2$unigram):1)
  key[i] <- paste(df.2$unigram[i], sep="|", formatC(i, width=7, flag="0"))
# bind key data to 2-ngram DF
df.2$key <- cbind(key)

# Save corpus freqTerms data to file
saveRDS(df.2, (paste0(dataDir,"df.2.rds")))

# Delete RFiles to save memory
rm(freqTerms.2, key)

#-------------------------------------------------------------------------------------------------------
# Load trie data structures
#-------------------------------------------------------------------------------------------------------

library(triebeard)

print("Building trie")
# 2-ngram trie
trie_2ngram <- trie(keys=as.character(df.2$key), values=as.character(df.2$word))

