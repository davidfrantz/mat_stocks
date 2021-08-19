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


img <- brick(
    "/data/Jakku/mat_stocks/stock/USA/fractions/percent_rgb.tif")

img_spdf <- as(img, "SpatialPixelsDataFrame")
img_df <- as.data.frame(img_spdf)
colnames(img_df) <- c("r", "g", "b", "x", "y")

img_df <- img_df[-which(img_df$g + img_df$g + img_df$b == 0), ]
img_df <- img_df %>%
    mutate(r = pmax(r, 0)) %>%
    mutate(g = pmax(g, 0)) %>%
    mutate(b = pmax(b, 0)) %>%
    mutate(r = pmin(r, 100)) %>%
    mutate(g = pmin(g, 100)) %>%
    mutate(b = pmin(b, 100)) %>%
    mutate(r = r / 100) %>%
    mutate(g = g / 100) %>%
    mutate(b = b / 100)

sum(img_df$g > (img_df$r + img_df$b)) / sum((img_df$g + img_df$r + img_df$b) > 0)
sum((img_df$r + img_df$b)  > img_df$g) / sum((img_df$g + img_df$r + img_df$b) > 0)

sub_df <- img_df %>%
    filter((r+b) > g)

sum(sub_df$r > sub_df$b) / sum((sub_df$g + sub_df$r + sub_df$b) > 0)
sum(sub_df$b > sub_df$r) / sum((sub_df$g + sub_df$r + sub_df$b) > 0)
sum(sub_df$r == sub_df$b) / sum((sub_df$g + sub_df$r + sub_df$b) > 0)



tiff(sprintf("%s/map_raster_%s.tif", dplot, "mass_components"),
width = width, height = height, units = "cm", pointsize = 6,
compression = "lzw", res = 600, type = "cairo", antialias = "subpixel")

par(mai = c(0, 0, 0, 0),
    cex = 1,
    mgp = c(3, 0.5, 0))

    theme_set(theme_bw(base_size = 6))

    fig <- ggplot() +
        geom_tile(
            data = img_df,
            aes(x = x, y = y, fill = rgb(r, g, b))) +
        scale_fill_identity() +
        coord_sf(datum = NA) +
            theme(panel.border = element_blank()) #+
            #theme(legend.title=element_text(size = 6))#+
        #ggtitle(lab[i]) #+
        #plot() #+
        #theme_bw()
        
    fig  %>% plot()

dev.off()



tiff(sprintf("%s/map_raster_%s-solo.tif", dplot, "mass_components"),
width = width*1.45, height = height*1.45, units = "cm", pointsize = 6,
compression = "lzw", res = 600, type = "cairo", antialias = "subpixel")

par(mai = c(0, 0, 0, 0),
    cex = 1,
    mgp = c(3, 0.5, 0))

    theme_set(theme_bw(base_size = 6))

    fig <- ggplot() +
        geom_tile(
            data = img_df,
            aes(x = x, y = y, fill = rgb(r, g, b))) +
        scale_fill_identity() +
        coord_sf(datum = NA) +
        theme(panel.border = element_blank(),
                legend.position = "none") #+
            #theme(legend.title=element_text(size = 6))#+
        #ggtitle(lab[i]) #+
        #plot() #+
        #theme_bw()
        
    fig  %>% plot()

dev.off()
