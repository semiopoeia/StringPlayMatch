
# install and load necessary packages
#if (!require(readtext)) install.packages("readtext", dependencies=TRUE)
#if (!require(tm)) install.packages("tm", dependencies=TRUE)
#if (!require(stringdist)) install.packages("stringdist", dependencies=TRUE)
#if (!require(textTinyR)) install.packages("textTinyR", dependencies=TRUE)
#if (!require(stringr)) install.packages("stringr", dependencies=TRUE)


library(readtext)
library(tm)
library(stringdist)
library(stringr)
library(textTinyR)

#read word documents
read_word_docs <- function(directory_path) {
  file_paths <- list.files(directory_path, pattern = "\\.docx$", full.names = TRUE)
  documents <- lapply(file_paths, function(file) {
    text <- readtext(file)
    return(text$text)
  })
  names(documents) <- basename(file_paths)
  return(documents)
}

# file path containing documents to match across
directory_path <- "E:/Finals/"

#read in documents
documents <- read_word_docs(directory_path)

#list of documents as "corpus"
corpus <- Corpus(VectorSource(documents))

#clean text data
clean_corpus <- tm_map(corpus, content_transformer(tolower))
clean_corpus <- tm_map(clean_corpus, removePunctuation)
clean_corpus <- tm_map(clean_corpus, removeNumbers)
clean_corpus <- tm_map(clean_corpus, removeWords, stopwords("en"))
clean_corpus <- tm_map(clean_corpus, stripWhitespace)

#put document terms into matrix form
dtm <- DocumentTermMatrix(clean_corpus)
dtm_matrix <- as.matrix(dtm)

#search term/phrase to match across documents
search_term <- 
"In this scenario, what type of reliability might we be most concerned with?"

#exact matches
exact_matches <- lapply(documents, function(doc) {
  if (grepl(search_term, doc, ignore.case = TRUE)) {
    return(doc)
  } else {
    return(NULL)
  }
})
exact_matches <- exact_matches[!sapply(exact_matches, is.null)]


#token-based matching using cosine similarity
cosine_sim <- function(a, b) {
  return(sum(a * b) / (sqrt(sum(a * a)) * sqrt(sum(b * b))))
}

search_term_vec <- rowSums(as.matrix(DocumentTermMatrix(Corpus(VectorSource(search_term)))))
cosine_similarities <- apply(dtm_matrix, 1, function(doc_vec) cosine_sim(doc_vec, search_term_vec))
cosine_similarities <- sort(cosine_similarities, decreasing = TRUE)

#fuzzy matching
fuzzy_matches <- sapply(documents, function(doc) {
  return(stringdist::stringdist(search_term, doc, method = "jw"))
})
names(fuzzy_matches) <- names(documents)
fuzzy_matches <- sort(fuzzy_matches)

#output results
cat("Exact Matches:\n")
print(exact_matches)
length(exact_matches)

#find locations of matched text
find_match_locations <- function(doc, search_term) {
  matches <- str_locate_all(doc, fixed(search_term, ignore_case = TRUE))[[1]]
  return(matches)
}

match_locations <- lapply(documents, find_match_locations, search_term = search_term)
names(match_locations) <- names(documents)

cat("Match Locations:\n")
print(match_locations)



