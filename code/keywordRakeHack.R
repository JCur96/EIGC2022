# keywordRakeHack.R
set.seed(1)
# set working directory # 
setwd("code")
# imports # 
library(litsearchr)
library(tidyr)
library(stringr)

# data inload and process # 
twitterData <- read.csv("../data/tweet_text.csv")
twitterData$text <- tolower(twitterData$text)
twitterData$text <- stringr::str_replace_all(twitterData$text, "[^a-zA-Z\\s]", " ")
twitterData$text <- stringr::str_replace_all(twitterData$text,"[\\s]+", " ")

# write out preprocessed data # 
write.csv(twitterData, "../data/processedTwitterData.csv")

# clear memory and read in clean data (this is more for my laptop running parallel scripts) # 
# rm(twitterList)
# tweets <- read.csv("../data/processedTwitterData.csv")

# take a random sample, to show proof of concept # 
randomTweets <- tweets[sample(nrow(tweets), 60000, F), ]

# write out data for use in other processes of hackathon # 
# write.csv(randomTweets, "../data/randomProcessedTweets.csv")

# keyword generation using RAKE and tagged methods # 
rakedkeywords <- litsearchr::extract_terms(
  text = paste(randomTweets$text),
  method = "fakerake",
  min_freq = 2,
  ngrams = TRUE,
  min_n = 2,
  language = "English")

taggedKeywords <- litsearchr::extract_terms(
  keywords = randomTweets$text,
  method = "tagged",
  min_freq = 2,
  ngrams = TRUE,
  min_n = 2,
  language = "English")

allKeywords <- unique(append(rakedkeywords, taggedKeywords))

dfm <- litsearchr::create_dfm(
  elements = randomTweets$text,
  features = allKeywords
)

# change min_studies to change number of tweets occurecne and min_occ for
  # number of occurences 
graph <- litsearchr::create_network(
  search_dfm = dfm,
  min_studies = 6,
  min_occ = 5
)

# graph theory method determining keywords
cutoff <- litsearchr::find_cutoff(
  graph,
  method = "changepoint",
  knot_num = 3,
  imp_method = "strength"
) 

reducedgraph <- litsearchr::reduce_graph(graph, cutoff_strength = cutoff[1])
# generate search terms for binay (OR, AND) search # 
searchterms <- litsearchr::get_keywords(reducedgraph)
head(searchterms)
searchterms

# save the search terms for future interrogation # 
write.csv(searchterms, "../data/RSearchTerms.csv")
# Now manual processing of claims into categories is required #
# which can then be read back into R and used to generate a binary search # 
# e.g. see below #
# read grouped / classified terms back into R
groupedTerms <- read.csv("../data/RSearchTermsClassified.csv")
# gather related terms of interest
climate <- groupedTerms$x[grep("climateChange", groupedTerms$classification)]
hazard <- groupedTerms$x[grep("hazard", groupedTerms$classification)]
globalWarming <- groupedTerms$x[grep("globalWarm", groupedTerms$classification)]
crazy <- groupedTerms$x[grep("crazy", groupedTerms$classification)]
abrotion <- groupedTerms$x[grep("abortion", groupedTerms$classification)]
# aggregate all groups of relevant terms
allIncludedterms <- list(climate, hazard, globalWarming, crazy, abrotion)
# create a binary search
climateBinarySearch <-
  litsearchr::write_search(
    groupdata = allIncludedterms,
    languages = "English",
    stemming = TRUE,
    closure = "none",
    exactphrase = TRUE,
    writesearch = FALSE,
    verbose = TRUE
  )
# write out to a text file
write(climateBinarySearch, "../data/climateBinarySearch.txt")
