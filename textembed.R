install.packages("reticulate",dep=T)
library(reticulate)

#set virtual environment and interact with OpenAI API
virtualenv_create("r-reticulate")
virtualenv_install("r-reticulate", packages = c("openai", "numpy"))
Sys.getenv("OPENAI_API_KEY")
#note the "sk-prog-..." is something you will get on OpenAI platform
#if you use the one below those tokens will bill to my personal account
#create a key here "https://platform.openai.com/settings/organization/api-keys"
Sys.setenv(OPENAI_API_KEY = "sk-proj-")

#may have to set a payment for billing in order to use API
openai<-import("openai")
client <- openai$OpenAI(api_key = Sys.getenv("OPENAI_API_KEY"))
###################################################################
##from python, here's embedding token breakdown
#My energy is low. -> [5159, 4907, 374, 3428, 13]  (count: 5 )
#I feel tired. -> [40, 2733, 19781, 13]  (count: 4 )
#I am tired. -> [40, 1097, 19781, 13]  (count: 4 )
#The people around me have fatigue. -> [791, 1274, 2212, 757, 617, 36709, 13]  (count: 7 )
#total of 20 tokens
texts <- c(
"Exam scores had a mean or 65, a median of 75, and a mode of 85. What is the shape of this distribution?", 
"To assure adequate availability of allergy mitigating medications during the spring months a pharmacy took a count of the anti-histamines sold during the months of April and May. Which would best describe the level of measurement being used for keeping track of anti-histamine sales?", 
"To mitigate the potential for cheating on an exam, four different versions of the exam were created. In this scenario, what type of reliability might we be most concerned with?",
"Scores from a skills test were normally distributed with a mean of 50 and a Standard Deviation of 10, approximately what percentage of the scores will fall between 30 and 70?")

embedding_result <- client$embeddings$create(
  model = "text-embedding-3-small",
  input = texts
)

embeddings <- lapply(embedding_result$data, function(x) x$embedding)

# Turn into a matrix
embedding_matrix <- do.call(rbind, embeddings)
dim(embedding_matrix)
embedding_matrix

#make dataframe
A<-embedding_matrix[1,]
B<-embedding_matrix[2,]
C<-embedding_matrix[3,]
D<-embedding_matrix[4,]

ebdf<-as.data.frame(cbind(A,B,C,D))
cor(ebdf)

embedmat<-write.table(embedding_matrix,"embedEG4examitems.txt",sep="\t",
		col.names=F,row.names=F)

class(embeddings)