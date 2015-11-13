setwd('C:/Users/Karina/Documents/waterSharing/waterSharing/data/WellsUSGS/')

rm(list = ls(all = TRUE)) #CLEAR WORKSPACE

library(stringr)

Sys.setenv(TZ='US/Pacific')

# get list of site numbers
listSitesCali = read.table('2015-11-05_USGScurrentConditions.txt',
                           skip=1,header=T,sep='\t',colClasses = 'character')
allStationsNb = listSitesCali$Station.Number

# get latitude and longitude for each station
pageLink = paste0('http://waterservices.usgs.gov/nwis/site/?format=rdb&stateCd=CA')
thepage = readLines(pageLink)
idxKeep = which(substr(thepage,1,1)!='#') # idx of lines not starting with #
data = thepage[idxKeep]
data = str_trim(data) # get rid of tabs at begining and end of lines
listVals = strsplit(data,split = '\t')[3:length(data)]
idxKeep = which(unlist(lapply(listVals,FUN = length))==12)
tableLongLat = matrix(unlist(listVals[idxKeep]),ncol=12,byrow = T)
colnames(tableLongLat) = unlist(strsplit(data[1],split = '\t'))[1:12]

# define dates for beginning and end
beginDate = '2010-01-01'
endDate = '2015-01-01'

# create folder for storing well timeseries
dir.create('timeseries', showWarnings = FALSE)

# loop over california wells
for(i in 1:length(allStationsNb)){
  
  print(paste0('-------i=',i,'-------'))
  
  ## get long lat
  iLine = which(tableLongLat[,'site_no']==allStationsNb[i]) # line corresponding to well i
  if(length(iLine)==0){error('station number not in well list')}else{
    long = tableLongLat[iLine,'dec_lat_va']
    lat = tableLongLat[iLine,'dec_long_va']
    
    if(nchar(long)==0 | nchar(lat)==0){error('long-lat not found')}else{
      ## get well data -  read from USGS page
      # read information from the USGS page
      pageLink = paste0('http://nwis.waterdata.usgs.gov/nwis/uv?cb_72019=on&format=rdb_meas&',
                        'site_no=',allStationsNb[i],'&period=&',
                        'begin_date=',beginDate,
                        '&end_date=',endDate)
      thepage = readLines(pageLink)
      # get rid of lines starting with #
      idxKeep = which(substr(thepage,1,1)!='#') # idx of lines not starting with #
      data = thepage[idxKeep]
      data = str_trim(data) # get rid of tabs at begining and end of lines
      listVals = strsplit(data,split = '\t')[3:length(data)]
      # get rid of lines with wrong number of values
      # HERE write a way to get how many elements there should be per line
      idxKeep = which(unlist(lapply(listVals,FUN = length))==6)
      tableVals = matrix(unlist(listVals[idxKeep]),ncol=6,byrow = T)
      colnames(tableVals) = unlist(strsplit(data[1],split = '\t'))[1:6]
      
      # average one point/month
      timePOSIX = strptime(tableVals[,"datetime"],format="%Y-%m-%d %H:%M")
      
      
      
      # save data in csv
      write.table(tableVals[,c('datetime','tz_cd','01_72019')],
                  file=paste0('timeseries/',allStationsNb[i],'_',beginDate,'_',endDate,
                              '_long',long,'_lat',lat,'.csv'),
                  row.names=F,sep=';',quote=F)
      
    }
  }
}


# plot
# xDateTime = as.POSIXct(tableVals[,'datetime'],format = '%Y-%m-%d %H:%M')
# plot(x=xDateTime,y=-as.numeric(tableVals[,'01_72019']),type='l',
#      xaxt='n',xlab='',
#      ylab='groundwater depth [feet below ground]')
# axis.POSIXct(1,xDateTime,format = '%Y-%m')
