# PI-to-R compiler
# Kate Newhart
# May 8, 2019
# See https://github.com/rbechalany/PI-Web-API-Client-R for more details

# Install and load piwebapi package from Github
install.packages("devtools")
library(devtools)
install_github("rbechalany/PI-Web-API-Client-R")
library(piwebapi)

# Login information
useKerberos <- TRUE
username <- "CHANGE"
password <- "CHANGE"
validateSSL <- TRUE
debug <- TRUE
piWebApiService <- piwebapi$new("https://pivision/piwebapi", useKerberos, username, password, validateSSL, debug)

# Basic - this example function pulls the previous 30 days of data
var1 <- piWebApiService$data$getRecordedValues(path="pi:\\\\applepi\\AI_K826", startTime = "y-30d", endTime = "t")[,1:2]

# Fix timestamps - this function creates an xts object from the piWebApiService function above
fix.timestamps <- function(pi.data) {
  ch.times <- pi.data[,2]
  ch.times <- sub("T", " ", ch.times)
  ch.times <- sub("Z", " ", ch.times)
  times <- as.POSIXct(ch.times)
  return(xts::xts(pi.data[,1], order.by = times))
}
var1 <- fix.timestamps(var1)

# Pro - this example creates variables from names and tags stored in a matrix
pi.tags <- matrix(c("DIS PAA N Upstream Residual", "pi:\\\\applepi\\AI_K826"), ncol = 2)
assign(make.names(pi.tags[1,1]), piWebApiService$data$getRecordedValues(path=pi.tags[1,2], startTime = "y-30d", endTime = "t")[,1:2])
assign(make.names(pi.tags[1,1]), fix.timestamps(get(make.names(pi.tags[1,1]))))