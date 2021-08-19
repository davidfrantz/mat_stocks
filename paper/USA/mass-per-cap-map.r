dplot <- "plot/multipanel"

names <- c("mass_building",
           "mass_mobility")

lab <- c("mass of\nbuildings\n(kg/cap)",
         "mass of\nmobility\ninfrastructure\n(kg/cap)")

for (i in 1:length(names)) {

    tiff(sprintf("%s/map_%s.tif", dplot, gsub("_", "-", names[i])),
    width = width, height = height, units = "cm", pointsize = 6,
    compression = "lzw", res = 600, type = "cairo", antialias = "subpixel")

    par(mai = c(0, 0, 0, 0),
        cex = 1,
        mgp = c(3, 0.5, 0))

        theme_set(theme_bw(base_size = 6))

        fig <- ggplot(df_pop %>% 
                        filter(YEAR == 2018) %>%
                        mutate_at(vars(starts_with("mass")), .funs = funs(. * 1000))) +
            geom_sf(
                aes_string(fill = names[i]),
                lwd = 0) +
            coord_sf(datum = NA) +
            scale_fill_viridis(name = lab[i], rescaler = function(x, to = c(0,1), from = NULL) {
                upper <- quantile(x, 0.975, na.rm = TRUE)
                lower <- quantile(x, 0.025, na.rm = TRUE)
                scale <- scales::rescale(x,
                                to = to,
                                from = c(lower, upper))
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

        fig <- ggplot(df_pop %>% 
                        filter(YEAR == 2018) %>%
                        mutate_at(vars(starts_with("mass")), .funs = funs(. * 1000))) +
            geom_sf(
                aes_string(fill = names[i]),
                lwd = 0) +
            coord_sf(datum = NA) +
            scale_fill_viridis(rescaler = function(x, to = c(0,1), from = NULL) {
                upper <- quantile(x, 0.975, na.rm = TRUE)
                lower <- quantile(x, 0.025, na.rm = TRUE)
                scale <- scales::rescale(x,
                                to = to,
                                from = c(lower, upper))
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
