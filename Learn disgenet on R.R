# Get to know disgenet


# Installation
library(devtools)
install_gitlab("medbio/disgenet2r")

# Obtaining the API key
library(disgenet2r)
api_key <- "b23f2ce1-029b-43de-8050-0df6b1fa14a4"
Sys.setenv(DISGENET_API_KEY= api_key)


# ---------------------------------- #
# Code examples from disgenet
library(httr)
library(jsonlite)

# Provide your API key 
api_key <- "Yb23f2ce1-029b-43de-8050-0df6b1fa14a4"

# Specify the response format: one of 'application/json', 'application/xml', 'application/csv' 
resp_format <- "application/json"

# Query the gda endpoint by specifying the following parameters:
# - gene_ncbi_id=351: retrieve disease associated to gene with NCBI ID equal to 351
# - page_number=0: retrieve the first page of results (page number 0)
# and providing your API key (api_key) and the response format (resp_format) as HTTP headers
res <- GET("https://api.disgenet.com/api/v1/gda/summary?gene_ncbi_id=351&page_number=0",
           add_headers(.headers = c('Authorization'= api_key,
                                    'accept' = resp_format)))

# If the status code of response is 429, it means you have reached one of your query limits
# You can retrieve the time you need to wait until doing a new query in the response headers
if(res$status_code == 429) {
  timetoWait <- res$headers$`x-rate-limit-retry-after-seconds`
  print(paste0("You have reached a query limit for your user. Please wait ", timetoWait, " seconds until next query"))
  Sys.sleep(timetoWait)
  print("Your rate limit is now restored.")
  # Repeat your query
  res <- GET("http://api.disgenet.com/api/v1/gda/summary?gene_ncbi_id=351&page_number=0",
             add_headers(.headers = c('Authorization'= api_key,
                                      'accept' = resp_format)))
}

# Extract the content type of the response and parse the JSON content since we set 'accept:application/json' as HTTP header 
http_type(res) # "application/json"

query_result <- fromJSON(rawToChar(res$content))
query_result
# --------------------------------- #


## Applying code for AML

file_path <- "DISEASES_Evidence_GDA_ALL_C0023467.tsv"

# Read the TSV file
disgenet_data <- read.table(file_path, sep = "\t", header = TRUE, stringsAsFactors = FALSE)

# View the first few rows
head(disgenet_data)


# Explore the data
# Check the column names
colnames(disgenet_data)

# Summary of the dataset
summary(disgenet_data)

# Number of rows and columns
dim(disgenet_data)

# Preview specific columns "AssociationType" and "Disease"
head(disgenet_data$AssociationType)
head(disgenet_data$Disease)


library(disgenet2r)
api_key <- "b23f2ce1-029b-43de-8050-0df6b1fa14a4"
Sys.setenv(DISGENET_API_KEY= api_key)

head(disgenet_data$diseaseUMLSCUI)
# --- output --- #
# "C0023467" "C0023467" "C0023467" "C0023467" "C0023467" "C0023467"
# -------------- #

# Query Disease to Gene Associations
res <- disease2gene(
  disease = "UMLS_C0023467",  # Acute Myeloid Leukemia 
  database = "CURATED",      # Search curated databases
  score = c(0, 1)        # Include scores
)

# Check Results
if (length(res) > 0) {
  head(res)  
} else {
  print("No results found.")
}

# Save Results
write.table(res, "disease_to_gene_results.tsv", sep = "\t", row.names = FALSE)


