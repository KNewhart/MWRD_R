library(piwebapi)
library(xts)

# Fix timestamps - this function creates an xts object from the piWebApiService function above
fix.timestamps <- function(pi.data) {
  ch.times <- pi.data[,2]
  ch.times <- sub("T", " ", ch.times)
  ch.times <- sub("Z", " ", ch.times)
  times <- as.POSIXct(ch.times)
  return(xts::xts(pi.data[,1], order.by = times))
}

# Login information
useKerberos <- TRUE
username <- "knewhart"
password <- "Lunabear2@"
validateSSL <- TRUE
debug <- TRUE
piWebApiService <- piwebapi$new("https://pivision/piwebapi", 
                                useKerberos, 
                                username, 
                                password, 
                                validateSSL, 
                                debug)

pi.tags <- matrix(c("Pre-dis E.coli", 
                    "af:\\\\APPLEPI_AF\\MWRD_Production\\Labworks Data\\012_700_1011-RWH North, Pre-PAA|ECIDX_G",
                    
                    "Post-dis E.coli", 
                    "af:\\\\APPLEPI_AF\\MWRD_Production\\Labworks Data\\2B-North Final Effluent Platform|ECIDX_G"
)
, ncol = 2, byrow = TRUE)

# Import E.coli
start <- paste0("2019-01-01", "T00:00:00Z")
end <- paste0(as.character(as.Date(Sys.time()) - 1), "T00:00:00Z")

for(i in 1:2) {
  assign(make.names(pi.tags[i,1]), piWebApiService$data$getRecordedValues(path=pi.tags[i,2], startTime = start, endTime = end)[,1:2])
  assign(make.names(pi.tags[i,1]), fix.timestamps(get(make.names(pi.tags[i,1]))))
}