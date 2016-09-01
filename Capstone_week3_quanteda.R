# In order to speed up retrieval of the training data to be used by the Capstone project, I manually
# downloaded the training data located at
# https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip.
#
# The en_us based datasets were unzipped into the capstone project data directory as: 
# en_US.news.txt
# en_US.twitter.txt
# en_US.blogs.txt


# Included skilNul=TRUE statement to get rid of nulls from first pass.
blogText <- readLines("../data/en_US.blogs.txt", n=100000, skipNul = TRUE)
newsText <- readLines("../data/en_US.news.txt", n=100000, skipNul = TRUE)
twitterText <- readLines("../data/en_US.twitter.txt", n=100000, skipNul = TRUE)


# Take samples from files and merge data
# set seed to make it reproducible
set.seed(1)
sampleText <- c(sample(blogText,length(blogText)*0.1),
                    sample(newsText, length(newsText)*0.1),
                    sample(twitterText,length(twitterText)*0.1))

###################################### Quanteda ############################################
# I decided to try quanteda.  I found the R "tm" package slow and complex.  Documenting
# along the way and trying to compare what I did using the "tm" package.
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
# remove features.  This is what's used as "tm_map" in "tm"
dfm <- dfm(sampleCorpus, ignoredFeatures = stopwords("english"), stem = TRUE, toLower = TRUE,
           removeNumbers = TRUE, removePunct = TRUE, removeSeparators = TRUE, removeTwitter = FALSE)


# Print out frequent terms
#freqTerms <- topfeatures(dfm, n = nfeature(dfm))
#print(freqTerms[freqTerms >= 200])

# Creating a "wordcloud" using quanteda
#require(RColorBrewer)
#plot(dfm, scale=c(8,.2), min.freq=3, max.words=Inf, random.order=FALSE, rot.per=.15, colors=pal2)



unigramCombinedSampleDFM <- dfm(dfm, ngrams=1, verbose=FALSE, concatenator=" ", stem=TRUE)
bigramCombinedSampleDFM  <- dfm(sampleCorpus, ngrams=2, verbose=FALSE, concatenator=" ",
                                ignoredFeatures=c(stopwords("english"), profaneWords), stem=TRUE,
                                removeTwitter=TRUE)
trigramCombinedSampleDFM <- dfm(sampleCorpus, ngrams=3, verbose=FALSE, concatenator=" ",
                                ignoredFeatures=c(stopwords("english"), profaneWords), stem=TRUE,
                                removeTwitter=TRUE)






