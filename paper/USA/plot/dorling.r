require(sf)
require(dplyr)
require(cartogram)
require(viridis)

sf <- st_read("paper/USA/shp/us_proj.shp")

stats <- read.csv("paper/USA/csv/stats-all-states/area_pop_per_state.csv")
stock <- read.csv("paper/USA/csv/mass-all-states/total_mass_all_states_ENLOCALE.csv")
colnames(stock)[1] <- "SHORT"

sf <- full_join(sf, stats, by = "ZIP")
sf <- full_join(sf, stock, by = "SHORT")

sf <- sf %>% mutate(POP_PER_KM2 = POP_2018 / AREA_KM2)
sf <- sf %>% mutate(BUILDING_RATIO = building / (street + rail + other) * 100)

sf_area <- sf %>% mutate_at(21:57, funs(. / AREA_KM2))
sf_pop  <- sf %>% mutate_at(21:57, funs(. / POP_2018))


for (i in c(21:57, 60)) {
for (i in 60) {

    name <- colnames(sf)[i]
    mai  <- c(0.4, 0.2, 0.4, 0.2)

    tiff(file.path("paper/USA/plot/dorling", sprintf("%s-tons.tif", name)),
    width = 8.8, height = 6, units = "cm", pointsize = 8,
    compression = "lzw", res = 600, type = "cairo", antialias = "subpixel")

    par(mai = mai, cex = 1)

        dor <- cartogram_dorling(sf, name)
        plot(dor[name], pal = viridis, key.width = 0.15,
            main = sprintf("%s [t]", name), reset = FALSE)
        plot(st_geometry(sf), border = "grey80", add = TRUE)
        plot(dor[name], pal = viridis, add = TRUE)

    dev.off()


    tiff(file.path("paper/USA/plot/dorling", sprintf("%s-tons-sqm.tif", name)),
    width = 8.8, height = 6, units = "cm", pointsize = 8,
    compression = "lzw", res = 600, type = "cairo", antialias = "subpixel")

    par(mai = mai, cex = 1)

        dor <- cartogram_dorling(sf_area, name)
        plot(dor[name], pal = viridis, key.width = 0.15,
            main = sprintf("%s [t/m²]", name), reset = FALSE)
        plot(st_geometry(sf), border = "grey80", add = TRUE)
        plot(dor[name], pal = viridis, add = TRUE)

    dev.off()


    tiff(file.path("paper/USA/plot/dorling", sprintf("%s-tons-cap.tif", name)),
    width = 8.8, height = 6, units = "cm", pointsize = 8,
    compression = "lzw", res = 600, type = "cairo", antialias = "subpixel")

    par(mai = mai, cex = 1)

        dor <- cartogram_dorling(sf_pop, name)
        plot(dor[name], pal = viridis, key.width = 0.15,
            main = sprintf("%s [t/cap]", name), reset = FALSE)
        plot(st_geometry(sf), border = "grey80", add = TRUE)
        plot(dor[name], pal = viridis, add = TRUE)

    dev.off()

}


