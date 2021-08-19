dplot <- "plot/battle-of-masses"

names <- c("building_ratio",
           "techno_bio_ratio")

lab <- c("building to mobility infrastructure ratio [%]",
         "human-made to living vegetation ratio [%")

pal <- list(
    brewer.pal(7, "BrBG"),
    brewer.pal(7, "PiYG") %>% rev())



upper_quantile <- c(0.975, 0.95)
lower_quantile <- c(0.025, 0.0)


for (i in 1:length(names)) {


    img <- raster(
        "/data/Jakku/mat_stocks/stock/USA/mosaic/techno_bio_ratio_10km.tif")

    img_spdf <- as(img, "SpatialPixelsDataFrame")
    img_df <- as.data.frame(img_spdf)
    colnames(img_df) <- c("value", "x", "y")

    img_df$value[!is.finite(img_df$value)] <- 0
    img_df <- img_df[-which(img_df$value <= 0),]


    tiff(sprintf("%s/map_raster_%s.tif", dplot, gsub("_", "-", names[i])),
    width = width, height = height, units = "cm", pointsize = 6,
    compression = "lzw", res = 600, type = "cairo", antialias = "subpixel")

    par(mai = c(0, 0, 0, 0),
        cex = 1,
        mgp = c(3, 0.5, 0))

        theme_set(theme_bw(base_size = 6))

        fig <- ggplot() +
            geom_tile(
                data = img_df,
                aes(x = x, y = y, fill = value)) +
            coord_sf(datum = NA) +
            scale_fill_gradientn(colours = pal[[i]], rescaler = function(x, to = c(0,1), from = NULL){
                upper <- quantile(x, upper_quantile[i], na.rm = TRUE)
                lower <- quantile(x, lower_quantile[i], na.rm = TRUE)
                scale <- ifelse(x < 1,
                    scales::rescale(x,
                        to = c(0, 0.5),
                        from = c(lower, 1)),
                    scales::rescale(x,
                        to = c(0.5, 1),
                        from = c(1, upper))
                )
                scale[x < lower] <- 0
                scale[x > upper] <- 1
                return(scale) }) +
                theme(panel.border = element_blank()) #+
                #theme(legend.title=element_text(size = 6))#+
            #ggtitle(lab[i]) #+
            #plot() #+
            #theme_bw()
            
        fig  %>% plot()

    dev.off()
    
}



for (i in 1:length(names)) {

    tiff(sprintf("%s/map_%s-solo.tif", dplot, gsub("_", "-", names[i])),
    width = width*1.5, height = height*1.5, units = "cm", pointsize = 6,
    compression = "lzw", res = 600, type = "cairo", antialias = "subpixel")

    par(mai = c(0, 0, 0, 0),
        cex = 1,
        mgp = c(3, 0.5, 0))

        theme_set(theme_bw(base_size = 6))

        fig <- ggplot(df %>% 
                        filter(YEAR == 2018) %>%
                        mutate_at(vars(starts_with("mass")), .funs = funs(. * 1000))) +
            geom_sf(
                aes_string(fill = names[i]),
                lwd = 0) +
            coord_sf(datum = NA) +
            scale_fill_gradientn(colours = pal[[i]], rescaler = function(x, to = c(0,1), from = NULL){
                upper <- quantile(x, 0.975, na.rm = TRUE)
                lower <- quantile(x, 0.025, na.rm = TRUE)
                scale <- ifelse(x < 100,
                    scales::rescale(x,
                        to = c(0, 0.5),
                        from = c(lower, 100)),
                    scales::rescale(x,
                        to = c(0.5, 1),
                        from = c(100, upper))
                )
                scale[x < lower] <- 0
                scale[x > upper] <- 1
                return(scale) }) +
                theme(panel.border = element_blank(),
                      legend.position = "none") #+
                #theme(legend.title=element_text(size = 6))#+
            #ggtitle(lab[i]) #+
            #plot() #+
            #theme_bw()
            
        fig  %>% plot()

    dev.off()
    
}
