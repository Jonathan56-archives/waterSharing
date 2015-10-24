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


################################# Getting lat long names

### Writing file with uniquenames
town.names <- unique(rationing.data$Supplier.Name)
write.csv(town.names,'town_names.csv')

    ### After running code in Python bring back in here and merge again
    town.lat.long <- read.csv('LAT_LONG_townnames.csv')
    #Quick regular expression to clean the town names
    for(i in 1:length(town.lat.long$town)) 
    {
      x <- town.lat.long$town[i]
      town.lat.long$townv2[i] <- gsub('"', '', regmatches(x, gregexpr('"([^"]*)"',x))[[1]])
    }
    
    latlong <- town.lat.long %>% mutate(Supplier.Name=townv2) %>% select(Supplier.Name,lat,long)
    write.csv(latlong,'csv/latlongclean.csv')
        
################################# Plotting
    
ration.latlong <- join(rationing.data,latlong,by=c('Supplier.Name'),type='left',match='all')
colors <- brewer.pal(name='GnBu',n=9)
colors <- colors[ration.latlong$REPORTED.Total.Monthly.Potable.Water.Production.2014.2015]


max(ration.latlong$REPORTED.Total.Monthly.Potable.Water.Production.2014.2015)


map("state", regions = "california")
points(ration.latlong$long,ration.latlong$lat,pch=19,col='deepskyblue',cex = ration.latlong$newval)


ration.latlong$newval <- round(((ration.latlong$REPORTED.Total.Monthly.Potable.Water.Production.2014.2015)/max(ration.latlong$REPORTED.Total.Monthly.Potable.Water.Production.2014.2015,breaks=400))*2,digits=0)

hist(ration.latlong$newval)





symbols(x = ration.latlong$long, y = ration.latlong$lat, circles = rep(1, nrow(ration.latlong)), add = TRUE, inches = .05, bg = colors)


circles = rep(1, nrow(calif)), 
add = TRUE, inches = .05, bg = colors




map_data(data="state", regions = "california")
symbols(x = calif$long, y = calif$lat, circles = rep(1, nrow(calif)), 
        add = TRUE, inches = .05, bg = colors)


############ Making sure that units are correct before plotting the data

# MG - Million Gallons
# G - Gallons 
# 1 AF (Acre Feet)- 325851 gallons)
# 1 CCF (hundred cubic feet) - 748 gallons
# 1 Liter - 0.264172 gallons





    
