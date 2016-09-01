# In order to speed up retrieval of the training data to be used by the Capstone project, I manually
# downloaded the training data located at
# https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip.
#
# The en_us based datasets were unzipped into the capstone project data directory as: 
# en_US.news.txt
# en_US.twitter.txt
# en_US.blogs.txt

# allows for easier changes during testing

sampleBlogPct <- 0.1
sampleNewsPct <- 0.1
sampleTwitPct <- 0.1


# Included skilNul=TRUE statement to get rid of nulls from first pass.
blogText <- readLines("../data/en_US.blogs.txt",skipNul = TRUE)
newsText <- readLines("../data/en_US.news.txt", skipNul = TRUE)
twitterText <- readLines("../data/en_US.twitter.txt", skipNul = TRUE)


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

###################################### Quanteda ############################################
# I decided to try quanteda.  I found the R "tm" package slow, too much memory and complex.
# Documenting along the way and trying to compare what I did using the "tm" package.
###################################### Quanteda ############################################

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
dfm.1 <- dfm(sampleCorpus, ngrams=1, ignoredFeatures = stopwords("english"),
           toLower = TRUE,concatenator = " ", removeNumbers = TRUE, removeSymbols=TRUE,
           removePunct = TRUE, removeSeparators = TRUE, removeTwitter = TRUE, removeURL=TRUE)

dfm.2 <- dfm(sampleCorpus, ngrams=2,
             toLower = TRUE,concatenator = " ", removeNumbers = TRUE, removeSymbols=TRUE,
             removePunct = TRUE, removeSeparators = TRUE, removeTwitter = TRUE, removeURL=TRUE)

dfm.3 <- dfm(sampleCorpus, ngrams=3,
             toLower = TRUE,concatenator = " ", removeNumbers = TRUE, removeSymbols=TRUE,
             removePunct = TRUE, removeSeparators = TRUE, removeTwitter = TRUE, removeURL=TRUE)

dfm.4 <- dfm(sampleCorpus, ngrams=4,
             toLower = TRUE,concatenator = " ", removeNumbers = TRUE, removeSymbols=TRUE,
             removePunct = TRUE, removeSeparators = TRUE, removeTwitter = TRUE, removeURL=TRUE)

# Print out frequent terms
freqTerms.1 <- topfeatures(dfm.1, n = nfeature(dfm.1))
freqTerms.2 <- topfeatures(dfm.2, n = nfeature(dfm.2))
freqTerms.3 <- topfeatures(dfm.3, n = nfeature(dfm.3))
freqTerms.4 <- topfeatures(dfm.4, n = nfeature(dfm.4))

#print(freqTerms.1[freqTerms.1 >= 1000])
#print(freqTerms.2[freqTerms.2 >= 200])
#print(freqTerms.3[freqTerms.3 >= 100])
# Creating a "wordcloud" using quanteda
#require(RColorBrewer)
#plot(dfm.1, scale=c(8,.2), min.freq=3, max.words=Inf, random.order=FALSE, rot.per=.15, colors=blue)

# Create DF for output files
df.1 <- data.frame(freqTerms.1)
df.2 <- data.frame(freqTerms.2)
df.3 <- data.frame(freqTerms.3)
df.4 <- data.frame(freqTerms.4)

# Output ngram files
write.csv(df.1, file = "../ngram1.csv", row.names = TRUE)
write.csv(df.2, file = "../ngram2.csv", row.names = TRUE)
write.csv(df.3, file = "../ngram3.csv", row.names = TRUE)
write.csv(df.4, file = "../ngram4.csv", row.names = TRUE)


