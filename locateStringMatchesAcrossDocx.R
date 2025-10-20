if (!require(readtext)) install.packages("readtext", dependencies=TRUE)
if (!require(stringdist)) install.packages("stringdist", dependencies=TRUE)
if (!require(stringr)) install.packages("stringr", dependencies=TRUE)

library(readtext)
library(stringdist)
library(stringr)

#function to read over word documents
read_word_docs <- function(directory_path) {
  file_paths <- list.files(directory_path, pattern = "\\.docx$", full.names = TRUE)
  documents <- lapply(file_paths, function(file) {
    text <- readtext(file)
    return(text$text)
  })
  names(documents) <- basename(file_paths)
  return(documents)
}

#set directory containing word documents
directory_path <- "E:/Finals/"

#apply read_word_doc function to diretory path object
documents <- read_word_docs(directory_path)

#term to find
search_term <- 
"Ordinal"

#function to find locations of matched text
find_match_locations <- function(doc, search_term) {
  matches <- str_locate_all(doc, fixed(search_term, ignore_case = TRUE))[[1]]
  return(matches)
}

#find match locations for each document
match_locations <- lapply(documents, find_match_locations, search_term = search_term)
names(match_locations) <- names(documents)

#output match locations
cat("Match Locations:\n")
print(match_locations)

#interpreting first few matches
for (doc_name in names(match_locations)) {
  cat("\nDocument:", doc_name, "\n")
  locations <- match_locations[[doc_name]]
  if (nrow(locations) > 0) {
    cat("Matches found at positions:\n")
    print(locations)
  } else {
    cat("No matches found.\n")
  }
}
