#! Rscript
# linear rule checking
library(getopt)
library(rjson)
library(editrules)

spec = matrix(c(
  'data'  , 'i', 1, "character",  
  'rules' , 'r', 1, "character",
  'checks', 'o', 1, "character"
), byrow=TRUE, ncol=4)
opt <- getopt(spec)

#job <- fromJSON(file = args[1])
main <- function(data_url, rules_url, checks_file){  
  # TODO add checks for existence of parameters

  # read data into data.frame
  dat <- read.csv(data_url)

  # create an linear rule checking matrix
  E <- editmatrix(readLines(rules_url))

  # check for violatedEdits
  ve <- violatedEdits(E, dat)
  # convert to 0 and 1 (opposite of violated!) 
  checks <- ifelse(ve, 0, 1)
  write.csv( checks, 
             file=checks_file,
             row.names=FALSE,
             na=""
  )
}

main(opt$data, opt$rules, opt$checks)

# data_url <- "file://example/input/data.csv"
# rules_url <- "file://example/input/rules.txt"
# checks_file <-"example/result/checks.csv"
# main(data_url, rules_url, checks_file)