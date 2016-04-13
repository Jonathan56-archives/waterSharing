library(maps)
library(plyr)
library(dplyr)
library(maptools)
library(RColorBrewer)
library(ggplot2)


setwd('/Users/Diego/Desktop/Projects_Code/cleanweb_hackathon/waterSharing/data/')

vars1 <- c('Supplier.Name','Stage.Invoked','Reporting.Month','Total.Monthly.Potable.Water.Production.2014','Total.Monthly.Potable.Water.Production.2013','Units','Total.Population.Served')
vars2 <- c('Supplier.Name','Stage.Invoked','Reporting.Month','REPORTED.Total.Monthly.Potable.Water.Production.2014.2015','REPORTED.Total.Monthly.Potable.Water.Production.2013','REPORTED.Units','Total.Population.Served')
vars3 <- c('Supplier.Name','Stage.Invoked','Reporting.Month','REPORTED.Total.Monthly.Potable.Water.Production.2014.2015','REPORTED.Total.Monthly.Potable.Water.Production.2013','REPORTED.Units','Total.Population.Served','Optional...Implementation','Conservation.Standard..starting.in.June.2015.')


# Reading data and mutating some variables 
file.a <- as.data.frame(read.csv('csv/uw_supplier_data120214.csv'))[vars]
file.b <- as.data.frame(read.csv('csv/uw_supplier_data110414.csv'))[vars]
file.c <- as.data.frame(read.csv('csv/uw_supplier_data100714.csv'))[vars]
file.d <- as.data.frame(read.csv('csv/june2014june2015.csv'))[vars2] %>% mutate(Total.Monthly.Potable.Water.Production.2014=REPORTED.Total.Monthly.Potable.Water.Production.2014.2015,Total.Monthly.Potable.Water.Production.2013=REPORTED.Total.Monthly.Potable.Water.Production.2013,Units=REPORTED.Units) %>% select(Supplier.Name,Stage.Invoked,Reporting.Month,Total.Monthly.Potable.Water.Production.2014,Total.Monthly.Potable.Water.Production.2013,Units,Total.Population.Served)
rationing.data <- as.data.frame(read.csv('june2014_august2015.csv'))[vars3] #This is variable that includes all data

### Quick check that my files have a good amount of town names
length(unique(file.a$Supplier.Name))
length(unique(file.d$Supplier.Name))


################################# Getting lat long names and Merging

### Writing file with uniquenames
town.names <- unique(rationing.data$Supplier.Name)
write.csv(town.names,'town_names.csv')

    ### Note I corrected some town names that were wrong:
    # California City  City of :  (35.125801, -117.985904)
    # San Jose  City of:  (37.338208, -121.886329)
    # Soledad, City of: (36.424687, -121.326319)
    # South Gate  City of: (33.954737, -118.212016)
    # Woodland City of:  (38.678516, -121.773297) 
    # Pittsburg  City of: (38.027976, -121.884681)
    # Morgan Hill  City of: (37.130501, -121.65439)
    # Livingston  City of:  (37.386883, -120.723533)
    # Winton Water & Sanitary District: (36.778261, -119.417932)

    ### After running code in Python bring back in here and merge again
    town.lat.long <- read.csv('csv/LAT_LONG_townnames.csv')
    #Quick regular expression to clean the town names
    for(i in 1:length(town.lat.long$town)) 
    {
      x <- town.lat.long$town[i]
      town.lat.long$townv2[i] <- gsub('"', '', regmatches(x, gregexpr('"([^"]*)"',x))[[1]])
    }
    
    latlong <- town.lat.long %>% mutate(Supplier.Name=townv2) %>% select(Supplier.Name,lat,long)
    write.csv(latlong,'csv/latlongclean.csv')
    
    #Merging
    ration.latlong <- join(rationing.data,latlong,by=c('Supplier.Name'),type='left',match='all')
    
############ Making sure that variables are correct before plotting the data
    
# MG - Million Gallons
# G - Gallons 
# 1 AF (Acre Feet)- 325851 gallons)
# 1 CCF (hundred cubic feet) - 748 gallons
# 1 Liter - 0.264172 gallons
    
ration.latlong$liters.2014.2015 <- ifelse(ration.latlong$REPORTED.Units == 'G',ration.latlong$REPORTED.Total.Monthly.Potable.Water.Production.2014.2015*(1/0.264172),ifelse(ration.latlong$REPORTED.Units == 'MG',ration.latlong$REPORTED.Total.Monthly.Potable.Water.Production.2014.2015*(1000000/0.264172),ifelse(ration.latlong$REPORTED.Units == 'AF',ration.latlong$REPORTED.Total.Monthly.Potable.Water.Production.2014.2015*(325851/0.264172),ration.latlong$REPORTED.Total.Monthly.Potable.Water.Production.2014.2015*(748/0.264172))))
ration.latlong$liters.normalized <- ((ration.latlong$liters.2014.2015)/max(ration.latlong$liters.2014.2015))*2
    
#2014 and 2015 per Capita
ration.latlong$liters.2014.2015.capita <- ration.latlong$liters.2014.2015/ration.latlong$Total.Population.Served
ration.latlong$capita.normalized <- ((ration.latlong$liters.2014.2015.capita)/max(ration.latlong$liters.2014.2015.capita))*2

#Adding Months and Years to the Data set
ration.latlong$Month <- substring(ration.latlong$Reporting.Month, 1, 3)
x <- as.character(ration.latlong$Reporting.Month)
ration.latlong$Year <- substr(x, nchar(x)-2+1, nchar(x))






################################# Plotting
    
#NOTE: simpy change cex to change the plot type
map("state", regions = "california")
points(ration.latlong$long,ration.latlong$lat,pch=19,col='deepskyblue',cex = 0.5)


#Total Cosumption August
#Total Consumption/Capita August
# Time Series of Consumption per time
# Merge Rationing Data with this file and plot over california - 
# Do simple analysis -- does relative rationinng make sense? are towns really rationing or is this symbolical?

# Make plots BEFORE and AFTER removing outliers

wellid <- read.csv('csv/wellids.csv')
wellid$digits <- print(wellid$wellid,digits=25)
head(wellid)
