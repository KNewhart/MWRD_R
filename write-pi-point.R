library(piwebapi)

# Login information
useKerberos <- TRUE
username <- "knewhart"
password <- "Lunabear2@"
validateSSL <- TRUE
debug <- TRUE
piWebApiService <- piwebapi$new("https://pivision/piwebapi", useKerberos, username, password, validateSSL, debug)

# Data parameters
pi.path <- "\\\\APPLEPI\\Test_knewhart"
createdPoint <- piWebApiService$point$getByPath(pi.path)

# Write PI single data point
pi.timestamp <- "2019-06-26T13:40:54Z"
pi.value <- 75

timedValue <- PITimedValue(timestamp=pi.timestamp, value=pi.value)
s <- PIStreamValue(webId = createdPoint$WebId, value=timedValue)
response <- piWebApiService$stream$updateValue(webId=createdPoint$WebId, PITimedValue=timedValue,
                                               bufferOption="Buffer")

# Write multiple data points
pi.data <- data.frame(timestamps="2019-06-26T14:40:54Z", values=10,
                      stringsAsFactors = FALSE)
pi.data <- rbind(pi.data, c("2019-06-26T15:40:54Z", 20))

timedValue_ls <- list()
for(i in 1:nrow(pi.data)) {
  pi.timestamp <- pi.data$timestamps[i]
  pi.value <- pi.data$values[i]
  timedValue <- PITimedValue(timestamp=pi.timestamp, value=pi.value)
  timedValue_ls[[length(timedValue_ls)+1]] <- timedValue
}
s <- PIStreamValues(webId = createdPoint$WebId, items = timedValue_ls)
r <- piWebApiService$stream$updateValues(webId=createdPoint$WebId, values = timedValue_ls, 
                                         bufferOption="Buffer")


# Test that PI Point was created
data <- piWebApiService$data$getRecordedValues(path=paste0("pi:",pi.path), startTime = '*-600d')[,1:2]


### TESTING DIS N PAA decay rate, k
pi.path <- "\\\\APPLEPI_AF\\MWRD_Production\\Hite Treatment Plant\\07-Disinfection\\Dis_PAA\\North_PAA\\North_PAA_Dose_Cntrl\\CT Dosing Method|DIS N PAA decay rate, k"
pi.path <- paste0("af:", pi.path)






# Old - from vingette
timedValue1 <- PITimedValue(timestamp = "2019-04-26T13:40:54Z", value = 25)  
timedValue2 <- PITimedValue(timestamp = "2017-04-27T13:40:54Z", value = 50)  

timedValue3 <- PITimedValue(timestamp = "2017-04-26T12:40:54Z", value = 75)  
timedValue4 <- PITimedValue(timestamp = "2017-04-27T12:40:54Z", value = 100)  

t1 <- list(timedValue1, timedValue2)  
t2 <- list(timedValue3, timedValue4)  

s1 <- PIStreamValues(webId = createdPoint$WebId, items = t1);  
s2 <- PIStreamValues(webId = createdPoint$WebId, items = t2);  

values <- list(s1, s2)  

# response12 <- piWebApiService$streamSet$updateValuesAdHoc(values, "Buffer", "Insert")
response11 <- piWebApiService$streamSet$updateValuesAdHoc(values, "Buffer", "Replace")


