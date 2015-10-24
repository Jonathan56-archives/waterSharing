setwd('/Users/Diego/Desktop/cleanweb_hackathon/csv')

file.a <- as.data.frame(read.csv('uw_supplier_data120214.csv'))[vars]
file.b <- as.data.frame(read.csv('uw_supplier_data110414.csv'))[vars]
file.c <- as.data.frame(read.csv('uw_supplier_data100714.csv'))[vars]
file.d <- as.data.frame(read.csv('june2014june2015.csv'))[vars2] %>% mutate(Total.Monthly.Potable.Water.Production.2014=REPORTED.Total.Monthly.Potable.Water.Production.2014.2015,Total.Monthly.Potable.Water.Production.2013=REPORTED.Total.Monthly.Potable.Water.Production.2013,Units=REPORTED.Units) %>% select(Supplier.Name,Stage.Invoked,Reporting.Month,Total.Monthly.Potable.Water.Production.2014,Total.Monthly.Potable.Water.Production.2013,Units,Total.Population.Served)
file.d <- 


vars1 <- c('Supplier.Name','Stage.Invoked','Reporting.Month','Total.Monthly.Potable.Water.Production.2014','Total.Monthly.Potable.Water.Production.2013','Units','Total.Population.Served')
vars2 <- c('Supplier.Name','Stage.Invoked','Reporting.Month','REPORTED.Total.Monthly.Potable.Water.Production.2014.2015','REPORTED.Total.Monthly.Potable.Water.Production.2013','REPORTED.Units','Total.Population.Served')


### Quick check
length(unique(file.a$Supplier.Name))
length(unique(file.d$Supplier.Name))


