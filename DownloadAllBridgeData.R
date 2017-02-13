library(plyr)
library(choroplethr)
library(dplyr)
library(readr)
library(data.table)

# Let's download all the data.  This will take awhile!  
# zipped, it is 50MB x 25 years = 1+ GB.  
# unzipped it is 250MB x 25 years = 5+ GB.
# If you want to access a smaller portion of the data, I have published it here:
# http://pages.stat.wisc.edu/~karlrohe/classes/data/countyBridgeSummaries.csv

back = 1
dest= rep("", 25)
for(back in 1:25){
  year = 2017 - back
  localFile <- paste("c:/data/", year,".zip", sep = "")
  sourceURL = paste("https://www.fhwa.dot.gov/bridge/nbi/", year,"hwybronlyonefile.zip", sep = "")
  download.file(sourceURL,localFile)
  
}


# unzip all the local data paths:
paths = dir("C:/data", pattern =".zip")
setwd("C:/data")
localFiles=list()
for(i in 1:length(paths)){
  localFiles[[i]]= unzip(paths[i])  # localFiles[[i]] stores the path
  print(localFiles[[i]])
} 

# Get Maintenance data
for(i in 1:length(paths)){
  # select the txt file (there are some .xls files)
  thisIsTheTXT = grep(pattern = ".txt",x = localFiles[[i]])
  dat = fread(localFiles[[i]][thisIsTheTXT]) %>% as.tbl
  tmp = dat %>% group_by(MAINTENANCE_021) %>% summarize(count = n())

  write_csv(tmp,path =  paste("small", substr(paths[[i]],1,4), ".csv",sep = ""))
}

# make the data set by combining smallXXXX.csv files.
csvpaths = dir(pattern =".csv")

addYearCSV = function(path){
  year = substr(path,6,9)
  tmp = read_csv(path)
  tmp = mutate(tmp, year = year)
  return(tmp)
}
x25 = ldply(csvpaths,  addYearCSV)
write_csv(x25, path = "countyBridgeSummaries_Jill.csv")
setwd("..")
