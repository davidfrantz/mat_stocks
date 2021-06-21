city3d <- function(lat, lon, name, state, pop, fname, vmax){

    #remotes::install_github("tylermorganwall/rayshader")
    library(rayshader)
    library(ggplot2)
    require(raster)
    require(viridis)
    require(ggthemes)
    require(rgdal)

    dbase <- "/data/Jakku/mat_stocks/stock/USA/ALL"
    stock <- raster(sprintf("%s/mass_grand_total_kt_100m2.tif", dbase))

    width <- 15000

    map <- project(cbind(lon,lat), crs(stock) %>% as.character() , inv=FALSE)

    sub <- as(extent(map[1]-width, map[1]+width, map[2]-width, map[2]+width), 'SpatialPolygons')
    crs(sub) <- crs(stock)

    stock <- crop(stock, sub)

    #fshp <- "/data/Jakku/mat_stocks/admin/provinces_prime/USA-CONUS_5km.shp"

    #dbase <- "/data/Jakku/mat_stocks/stock/USA/US_NY/X0102_Y0059"
    #stock <- raster(sprintf("%s/mass_grand_total_Mt_1km2.tif", dbase))
    #dbase <- "/data/Jakku/mat_stocks/stock/USA/US_NY/X0102_Y0059"
    #stock <- raster(sprintf("%s/mass_grand_total_Gt_10km2.tif", dbase))



    stock_spdf <- as(stock, "SpatialPixelsDataFrame")
    #stock_spdf@data[ncol(stock), 1] <- vmax
    #if (max(stock_spdf@data) > vmax) error(sprintf("higher value than %f encountered in %s, %s", vmax, name, state))

    stock_df <- as.data.frame(stock_spdf)
    colnames(stock_df) <- c("value", "x", "y")
    stock_df[stock_df == 0] <- NA

    stock_df <- rbind(stock_df, c(
        vmax, 
        extent(stock)@xmax-res(stock)[1]/2, 
        extent(stock)@ymax-res(stock)[2]/2))

    #boundaries_ <- readOGR(dsn = fshp)
    #boundaries <- spTransform(boundaries_, crs(stock))


    gg <- ggplot() +
        geom_tile(data = stock_df, aes(x = x, y = y, fill = value)) +
        #geom_polygon(data = boundaries, aes(x = long, y = lat, group = group), 
        #    fill = NA, color = "grey25", size = 0.25) +
        scale_fill_gradientn(
            colours = c("grey95", viridis(5), "orange", "red", "magenta"),
            values = c(0, seq(0.01, 0.075, length.out = 5), 0.2, 0.3, 1),
            breaks = c(0.01, 0.1, 0.2, 0.28),
            na.value = "white") +
        #labs(fill = "Total stock [kt/10000m²]") +
        coord_equal() +
        theme_map() +
        theme(legend.position = "none") +
        ggtitle(sprintf("%s, %s - Population: %d", name, state, pop)) #+
        #theme(legend.position = "none") #+
        #theme(legend.key.width = unit(1000, "cm"))
    gg

    #tiff("2d.tif",
    #width = 8.8, height = 6, units = "cm", pointsize = 8,
    #compression = "lzw", res = 600, type = "cairo", antialias = "subpixel")
    #    gg
    #dev.off()


    gg3 <- plot_gg(gg,
        multicore = TRUE,
        width = 5,
        height = 5,
        units = "cm",
        scale = 350,
        triangulate = TRUE)#,
    gg3


    #render_highquality("3d-1",
    #    parallel = TRUE,
    #    progress = TRUE, 
    #    ambient_light = TRUE,
    #    print_scene_info = TRUE)

    render_highquality(fname,
        width = 3000,
        height = 2500,
        parallel = TRUE,
        progress = TRUE, 
        ambient_light = TRUE,
        camera_location = c(465.03, 2079.96, 1473.23), 
        print_scene_info = TRUE)
        #title_text = sprintf("%s, %s\nPopulation: %d", name, state, pop),
        #title_offset = c(250, 300),
        #title_color = "black",
        #title_size = 78)

    while (rgl::rgl.cur() > 0) { rgl::rgl.close() }

}
