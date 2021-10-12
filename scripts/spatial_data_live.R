# load packages
install.packages("ggplot2")
library(ggplot2)
library(neonUtilities)
library(geoNEON)

# explore spatial data for sensors
# using soil temperature as an example
# download soil temperature from Treehaven 2018-07
soilT <- loadByProduct(dpID="DP1.00041.001", site="TREE",
                       startdate="2018-07", enddate="2018-07",
                       timeIndex=30, check.size=F)
# check out sensor positions
View(soilT$sensor_positions_00041)

# create sensor positions object
pos <- soilT$sensor_positions_00041

# throw out the coordinates from after frost heave incident
pos <- pos[-intersect(grep("001.", pos$HOR.VER),
                      which(pos$end=="")),]
View(pos)
View(soilT$ST_30_minute)

# create index for horizonal and vertical that matches positions file
soilT$ST_30_minute$HOR.VER <- paste(soilT$ST_30_minute$horizontalPosition,
                                    soilT$ST_30_minute$verticalPosition,
                                    sep=".")

# join sensor positions to 30 minute data
soilTHV <- merge(soilT$ST_30_minute, pos,
                 by="HOR.VER", all.x=T)
View(soilTHV)

# plot soil temperature and soil depth
gg <- ggplot(soilTHV,
             aes(endDateTime, soilTempMean,
                 group=zOffset, color=zOffset)) +
  geom_line() +
  facet_wrap(~horizontalPosition)
gg

# remove low-quality data
gg <- ggplot(subset(soilTHV, finalQF==0),
             aes(endDateTime, soilTempMean,
                 group=zOffset, color=zOffset)) +
  geom_line() +
  facet_wrap(~horizontalPosition)
gg

# observational data!
# download vegetation structure data - everything from Wind River
vst <- loadByProduct(dpID="DP1.10098.001", site="WREF",
                     check.size=F)
names(vst)

# mapping data for individual trees are in the mappangtagging table,
# but the locations published with the data are just the plot locations
View(vst$vst_mappingandtagging)

# to get the calculated locations of individual trees, we need 
# to use the getLocTOS() function in the geoNEON package
vst.loc <- getLocTOS(data=vst$vst_mappingandtagging,
                     dataProd="vst_mappingandtagging")
View(vst.loc)
