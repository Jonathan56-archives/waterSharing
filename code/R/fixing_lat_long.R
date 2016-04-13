library(plyr)
library(dplyr)

setwd('/Users/Diego/Desktop/Projects_Code/cleanweb_hackathon/waterSharing/data/csv')

data <- read.csv('forjonathannewlats.csv')
data$chr.lat <- as.character(data$lat)
data$chr.long <- as.character(data$long)
length(unique(data[c()]))

data.unique <- unique(data[c("chr.lat", "chr.long")])
length(data.unique$chr.lat)

data.subset <- subset(data,data$chr.lat == '36.778261' & data$chr.long == '-119.4179324')

#I wrote a file with repeated lat longs and then went to xls and got real lat longs from Google Maps and wrote that back into the xls and created a new file
write.csv(data.subset,'cleanlatlongs.csv')


#Reading in the new file with the new lat longs
data.new <- read.csv('newcleanlatlongs.csv')
data.clean <- subset(data,data$chr.lat != '36.778261' & data$chr.long != '-119.4179324')

#Create new file and check lat longs before exporting
data.clean.latlong <- rbind(data.new,data.clean)

write.csv(data.clean.latlong,'cleanestlatlong.csv')

