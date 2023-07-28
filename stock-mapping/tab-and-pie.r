cnt <- "DEU"

base_ <- file.path("J:/mat_stocks/stock", cnt)

dis <- list.dirs(base_, full.names=FALSE, recursive=FALSE)
ndis <- length(dis)

materials <- matrix(c(
"IRON_STEEL",                            "METALS",
"COPPER",                                "METALS",
"ALUMINUM",                              "METALS",
"ALL_OTHER_METALS",                      "METALS",
"CONCRETE",                              "MINERALS",
"BRICKS",                                "MINERALS",
"GLASS",                                 "MINERALS",
"AGGREGATE",                             "MINERALS",
"ALL_OTHER_MINERALS",                    "MINERALS",
"TIMBER",                                "BIOMASS",
"OTHER_BIOMASS_BASED_MATERIALS",         "BIOMASS",
"BITUMEN",                               "FUEL",
"ALL_OTHER_FOSSIL_FUEL_BASED_MATERIALS", "FUEL",
"ALL_OTHER_MATERIALS",                   "OTHER",
"INSULATION",                            "OTHER"), 15, 2, byrow=TRUE)
nmat <- dim(materials)[1]

categories <- matrix(c(
"BUILDING_LIGHTWEIGHT",      "BUILDING",
"BUILDING_SINGLEFAMILY",     "BUILDING",
"BUILDING_MULTIFAMILY",      "BUILDING",
"BUILDING_HIGHRISE",         "BUILDING",
"BUILDING_COMMERCIAL",       "BUILDING",
"STREET_MOTOR",              "STREETS",
"STREET_PRIMARY",            "STREETS",
"STREET_SECONDARY",          "STREETS",
"STREET_TERTIARY",           "STREETS",
"STREET_OTHER",              "STREETS",
"STREET_GRAVEL",             "STREETS",
"STREET_MOTOR_ON_BRIDGE",    "STREETS",
"STREET_BRIDGE_UNDER_MOTOR", "STREETS",
"STREET_OTHER_ON_BRIDGE",    "STREETS",
"STREET_BRIDGE_UNDER_OTHER", "STREETS",
"STREET_TUNNEL",             "STREETS",
"RAIL_RAILWAY",              "RAILS",
"RAIL_TRAM",                 "RAILS",
"RAIL_SUBWAY",               "RAILS",
"RAIL_SUBWAY_BRIDGE",        "RAILS",
"RAIL_SUBWAY_SURFACE",       "RAILS",
"RAIL_OTHER",                "RAILS",
"RAIL_BRIDGE",               "RAILS",
"RAIL_TUNNEL",               "RAILS",
"RUNWAY",                    "OTHER",
"PARKING",                   "OTHER"), 26, 2, byrow=TRUE)
ncat <- dim(categories)[1]


mat <- vector("list", ndis+1)
for (d in 1:(ndis+1)) mat[[d]] <- matrix(0, ncat, nmat+2)


for (d in 1:(ndis+1)){


  if (d <= ndis){
  
    base <- sprintf("%s/%s", base_, dis[d])

    for (i in 1:ncat){
    for (j in 1:nmat){
      
      fname <- sprintf("%s/mosaic/%s_%s_%s_%s.txt", base, dis[d], "MASS", categories[i,1], materials[j,1])
      mat[[d]][i,j] <- as.numeric(readLines(fname))/1e9
      
    }
    }

    for (i in 1:ncat){

      fname <- sprintf("%s/mosaic/%s_%s_%s.txt", base, dis[d], "AREA", categories[i,1])
      mat[[d]][i,nmat+1] <- as.numeric(readLines(fname))/1e6

    }

    for (i in 1:ncat){

      fname <- sprintf("%s/mosaic/%s_%s_%s.txt", base, dis[d], "VOLUME", categories[i,1])
      if (file.exists(fname)) mat[[d]][i,nmat+2] <- as.numeric(readLines(fname))/1e9

    }
    
    mat[[ndis+1]] <- mat[[ndis+1]]+mat[[d]]

  }
  
  rownames(mat[[d]]) <- categories[,1]
  colnames(mat[[d]]) <- c(materials[,1], "AREA", "VOLUME")


  fcsv2 <- sprintf("%s/%s_mass-in-gt_area-in-km2_volume-in-km3.csv", base_, 
    if (d > ndis) cnt else dis[d] )
  fcsv  <- sprintf("%s/%s_mass-in-gt_area-in-km2_volume-in-km3-ENLOCALE.csv", base_, 
    if (d > ndis) cnt else dis[d] )
  ftif <- sprintf("%s/%s_pie.tif", base_, 
    if (d > ndis) cnt else dis[d] )


  write.csv2(mat[[d]], fcsv2)
  write.csv(mat[[d]],  fcsv)

  tiff(ftif, width = 35, height = 28, units = "cm", pointsize = 8,
    compression="lzw", res=600, type="cairo", antialias="subpixel")
  {

    layout(matrix(1:20, 4, 5, byrow=TRUE))
    par(mai=c(0.4, 0.4, 0.4, 0.4), cex=1)

    mat_per_cat <- split(apply(mat[[d]][,1:nmat], 1, sum), categories[,2])
    lab_per_cat <- split(categories[,1], categories[,2])
    n <- length(mat_per_cat)
    pie(sapply(mat_per_cat, sum), main=round(sum(sapply(mat_per_cat, sum)),2))
    for (i in 1:n) pie(mat_per_cat[[i]], labels=lab_per_cat[[i]], main=round(sum(mat_per_cat[[i]]),2))

    mat_per_mat <- split(apply(mat[[d]][,1:nmat], 2, sum), materials[,2])
    lab_per_mat <- split(materials[,1], materials[,2])
    n <- length(mat_per_mat)
    pie(sapply(mat_per_mat, sum), main=round(sum(sapply(mat_per_mat, sum)),2))
    for (i in 1:(n-1))   pie(mat_per_mat[[i]], labels=lab_per_mat[[i]], main=round(sum(mat_per_mat[[i]]),2))

    area_per_cat <- split(mat[[d]][,nmat+1], categories[,2])
    lab_per_cat <- split(categories[,1], categories[,2])
    n <- length(area_per_cat)
    pie(sapply(area_per_cat, sum), main=round(sum(sapply(area_per_cat, sum)),2))
    for (i in 1:n) pie(area_per_cat[[i]], labels=lab_per_cat[[i]], main=round(sum(area_per_cat[[i]]),2))

    vol_per_cat <- split(mat[[d]][,nmat+2], categories[,2])
    lab_per_cat <- split(categories[,1], categories[,2])
    n <- length(area_per_cat)
    pie(sapply(vol_per_cat, sum), main=round(sum(sapply(vol_per_cat, sum)),2))
    for (i in 1:1) pie(vol_per_cat[[i]], labels=lab_per_cat[[i]], main=round(sum(vol_per_cat[[i]]),2))



  }
  dev.off()

}

