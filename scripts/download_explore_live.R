# load packages
library(neonUtilities)
library(raster)

options(stringsAsFactors = F)

# stack the PAR data files we downloaded
stackByTable('/Users/clunch/Desktop/NEON_par.zip')

# download the same PAR data as before, using
# neonUtilities functions
pr <- loadByProduct(dpID="DP1.00024.001", site="WREF",
                    startdate="2020-09", enddate="2020-10",
                    package="basic")
names(pr)
View(pr$PARPAR_30min)

# plot mean PAR from top of tower
plot(PARMean~startDateTime,
     data=pr$PARPAR_30min[which(pr$PARPAR_30min$verticalPosition=="080"),],
     type="l")

# download observational data
# download aquatic plant chemistry data
apchem <- loadByProduct(dpID="DP1.20063.001",
                        site=c("PRLA","SUGG","TOOK"),
                        package="expanded", check.size=F)
names(apchem)
View(apchem$apl_plantExternalLabDataPerSample)

# move tables out of named list
list2env(apchem, .GlobalEnv)

# plot d13C across the 3 sites we downloaded
boxplot(analyteConcentration~siteID,
        data=apl_plantExternalLabDataPerSample,
        subset=analyte=="d13C",
        xlab="Site", ylab="d13C")
View(apl_biomass)

# join biomass table and chemistry table
apct <- merge(apl_biomass,
              apl_plantExternalLabDataPerSample,
              by=c("sampleID", "namedLocation",
                   "domainID", "siteID"))

# plot d13C by taxonomic identification
boxplot(analyteConcentration~scientificName,
        data=apct, subset=analyte=="d13C",
        xlab=NA, ylab="d13C", las=2, cex.axis=0.7)

# remote sensing data!
# download one tile of Ecosystem structure data (Canopy Height Model)
byTileAOP(dpID="DP3.30015.001", site="WREF", year=2017,
          easting=580000, northing=5075000, 
          savepath="/Users/clunch/Desktop")
# load the tile into R
chm <- raster("/Users/clunch/Desktop/DP3.30015.001/2017/FullSite/D16/2017_WREF_1/L3/DiscreteLidar/CanopyHeightModelGtif/NEON_D16_WREF_DP3_580000_5075000_CHM.tif")
plot(chm)
