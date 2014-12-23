#! /usr/bin/env Rscript
# script for Reducer (R-Hadoop integration)
 
library(utils)
 

computeAbRatio <- function(vec) {

vec.ts <- ts(vec)
vec.hw <- HoltWinters(vec.ts,gamma=FALSE)
vec.smooth <- fitted.values(vec.hw)
diff <- abs(vec.ts - vec.smooth[,1])
vec.dm <- HoltWinters(diff,gamma=FALSE)
confPlus <- vec.smooth[,1] + 2 * fitted.values(vec.dm)[,1]
aberrant.all <- confPlus - vec.ts
aberrant.min <- aberrant.all[aberrant.all < 0]
abNum <- length(as.vector(aberrant.min))
abRatio <- 100*(abNum/length(as.vector(aberrant.all)))

return(abRatio)
}


input <- file("stdin", "r")

# initialize variables that keep
# track of the state

is_first_line <- TRUE
compVec <- numeric()

while(length(line <- readLines(input, n=1, warn=FALSE)) > 0) {
   line <- unlist(strsplit(line, "\t"))
   
   # current line belongs to previous
   # line's key pair
   if(!is_first_line && 
        prev_lang == line[1] ) {
        compVec <- c(compVec,as.numeric(line[2]))   
   }
   # current line belongs either to a
   # new key pair or is first line
   else {
       # new key pair - so output the last
       # key pair's result
       if(!is_first_line) {
           # machine / value
           sum <- computeAbRatio(compVec)
           cat(prev_lang,"\t",sum,"\n")
       } 
   
       # initialize state trackers
       prev_lang <- line[1]
       compVec <- c(compVec,as.numeric(line[2]))   
       is_first_line <- FALSE
   }
}

# the final record
sum <- computeAbRatio(compVec)
cat(prev_lang,"\t",sum, "\n")

close(input)
