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
sampleBlogPct <- 0.2
sampleNewsPct <- 0.2
sampleTwitPct <- 0.8
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


# Create train and testing sets
#library(caTools) # Needed for split
#splitSample = sample.split(sampleText, 0.7) 
#trainSample = subset(sampleText, splitSample == T) 
#testSample = subset(sampleText, splitSample == F) 

#-------------------------------------------------------------------------------------------------------
#  Create the Corpus
#-------------------------------------------------------------------------------------------------------

require(quanteda)

# concatenator option defaults to "-".  Need space for doing word predictor functionality
# removeTwitter option TRUE removes "#" and "@" characters


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
freqTerms.3 <-freqTerms.3[freqTerms.3 > 1] # Keep freqency > 5 to word prediction file

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

# 3-ngram DF
print("Building df.3 DF")
df.3 <- data.frame(word=names(freqTerms.3), freq=freqTerms.3)
bigram <- word(df.3$word,1,2)
df.3$bigram <- cbind(bigram)
#unigram <- word(df.3$word,1,1)
#df.3$unigram <- cbind(unigram)

# Delete RFiles to save memory
rm(bigram, freqTerms.3)

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
# Load trie data structures
#-------------------------------------------------------------------------------------------------------

library(triebeard)

print("Building trie")
# 3-ngram trie
trie_3ngram <- trie(keys=as.character(df.3$key), values=as.character(df.3$word))



# integrating best packages to solve issue...