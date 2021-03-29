require(sf)
require(dplyr)


# really messy - do not use

sf <- st_read("paper/USA/shp/county_proj_4.shp")
sf$NAME_2 <- gsub(" City", "", sf$NAME_2)


nrow(sf)
tab1 <- read.csv("paper/USA/csv/stats-all-counties/Export_Output.txt")
sf <- inner_join(sf, tab1, by = "HASC_2")
nrow(sf)

tab2 <- read.csv("paper/USA/csv/stats-all-counties/co-est2019-alldata.csv")
colnames(tab2)[6] <- "NAME_1"
colnames(tab2)[7] <- "NAME_2"
tab2[,7] <- gsub(" County", "", tab2[,7])
tab2[,7] <- gsub(" city", "", tab2[,7])
tab2[,7] <- gsub(" City", "", tab2[,7])
tab2[,7] <- gsub(" Parish", "", tab2[,7])
tab2[,7] <- gsub("St\\.", "Saint", tab2[,7])
tab2[,7] <- gsub("Ste\\.", "Sainte", tab2[,7])
tab2 <- tab2[- which(tab2$SUMLEV == 40),]
tab2 <- tab2[- which(tab2$NAME_1 == "Alaska"),]
tab2 <- tab2[- which(tab2$NAME_1 == "Hawaii"),]


sf <- cbind(sf, NAME_NEW = tolower(gsub(" ", "", paste(sf$NAME_1, sf$NAME_2))))
tab2 <- cbind(tab2, NAME_NEW = tolower(gsub(" ", "", paste(tab2$NAME_1, tab2$NAME_2))) )

sf$NAME_NEW <- gsub("southdakotashannon", "southdakotaoglalalakota", sf$NAME_NEW)


sf <- inner_join(sf, tab2, by = "NAME_NEW")

tab2[which(!tab2$NAME_NEW %in% sf$NAME_NEW),] 
sf[which(!sf$NAME_NEW %in% tab2$NAME_NEW),] 

which(table(sf$NAME_NEW) > 1)                                                                                                                                                      
which(table(tab2$NAME_NEW) > 1)                                                                                                                                                    

sf <- sf %>% select(HASC_2, ID.x, NAME_1.x, NAME_2.x, AREA_KM2, POPESTIMATE2018)
sf <- st_drop_geometry(sf)    
write.csv(sf, "paper/USA/csv/stats-all-counties/area_pop_per_county.csv")



