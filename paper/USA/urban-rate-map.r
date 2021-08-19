dplot <- "plot/multipanel"

tiff(sprintf("%s/map_%s.tif", dplot, "urban_rate"),
width = width, height = height, units = "cm", pointsize = 6,
compression = "lzw", res = 600, type = "cairo", antialias = "subpixel")

par(mai = c(0, 0, 0, 0),
    cex = 1,
    mgp = c(3, 0.5, 0))

    theme_set(theme_bw(base_size = 6))

    fig <- ggplot(df %>% 
                    filter(YEAR == 2018)) +
        geom_sf(
            aes_string(fill = "POPPCT_URBAN"),
            lwd = 0) +
        coord_sf(datum = NA) +
        scale_fill_gradientn(name = "urban population (%)", colours = brewer.pal(7, "RdYlBu")) +
        theme(legend.position = "bottom")
        
    fig  %>% plot()

dev.off()
