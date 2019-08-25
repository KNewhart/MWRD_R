rm(list=ls())

library(readxl)
library(xts)
library(xlsx)
library(readr)
library(doSNOW)
library(parallel)
library(neuralnet)
library(factoextra)



# Install and load piwebapi package from Github
# install.packages("devtools")
# library(devtools)
# install_github("rbechalany/PI-Web-API-Client-R")
library(piwebapi)

# Login information
useKerberos <- TRUE
username <- "knewhart"
password <- "Lunabear2@"
validateSSL <- TRUE
debug <- TRUE
piWebApiService <- piwebapi$new("https://pivision/piwebapi", useKerberos, username, password, validateSSL, debug)


pi.tags <- read_excel("C:/Users/KNewhart/Documents/GitHub/MWRD/pi-tags.xls")
pi.tags <- na.omit(pi.tags)
# Fix tags
for(i in 1:nrow(pi.tags)) {
  if(is.na(pi.tags[i,2])) next
  if(substr(pi.tags[i,2],1,12) == "\\\\APPLEPI_AF") pi.tags[i,2] <- paste0("af:", pi.tags[i,2])
  if(substr(pi.tags[i,2],1,9) == "\\\\applepi") pi.tags[i,2] <- paste0("pi:", pi.tags[i,2])
  if(substr(pi.tags[i,2],1,9) == "\\\\APPLEPI") pi.tags[i,2] <- paste0("pi:", pi.tags[i,2])
}

var <- c("Chemscan PAA")
start <- paste0("2019-05-13", "T00:00:00Z") # Make sure to convert time to GMT
end <- paste0(as.character(as.Date(Sys.time()) - 1), "T00:00:00Z")

var.n <- sapply(var, function(x) which(x == pi.tags[,1]))
# Load daily data
if (exists("all.data")) rm(all.data)
t1 <- Sys.time()
for(i in var.n) {
  # assign(make.names(pi.tags[i,1]), piWebApiService$data$getInterpolatedValues(path=unlist(pi.tags[i,2]), startTime = start, endTime = end, interval = "1d")[,1:2])
  # assign(make.names(pi.tags[i,1]), fix.timestamps(get(make.names(pi.tags[i,1]))))
  # new.objects <- c(new.objects, list(make.names(pi.tags[i,1])))
  data.holder <- piWebApiService$data$getRecordedValues(path=as.character(pi.tags[i,2]), startTime = start, endTime = end)[,1:2]
  # data.holder <- piWebApiService$data$getInterpolatedValues(path=unlist(pi.tags[i,2]), startTime = start, endTime = end, interval = "1d")[,1:2]
  data.holder <- fix.timestamps(data.holder)
  data.holder <- xts(as.numeric(data.holder[,2]), order.by = as.POSIXct(data.holder[,1], format = "%Y-%m-%d %H:%M:%S", TZ="MST")-6*60*60)
  colnames(data.holder) <- make.names(pi.tags[i,1])
  if (!exists("all.data")) {
    all.data <- data.holder
  } else {
    all.data <- merge(all.data, data.holder)
  }
}
t2 <- Sys.time()
t2-t1


