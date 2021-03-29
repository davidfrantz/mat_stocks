require(sf)
require(dplyr)
require(cartogram)
require(viridis)

sf <- st_read("paper/USA/shp/county_proj.shp")

stats <- read.csv("paper/USA/csv/stats-all-counties/area_pop_per_county.csv")

stock_street <- read.csv("paper/USA/csv/mass_per_county/mass_street_total.tif.txt", sep = ";")
colnames(stock_street) <- c("ID", "street")

stock_rail <- read.csv("paper/USA/csv/mass_per_county/mass_rail_total.tif.txt", sep = ";")
colnames(stock_rail) <- c("ID", "rail")

stock_other <- read.csv("paper/USA/csv/mass_per_county/mass_other_total.tif.txt", sep = ";")
colnames(stock_other) <- c("ID", "other")

stock_building <- read.csv("paper/USA/csv/mass_per_county/mass_building_total.tif.txt", sep = ";")
colnames(stock_building) <- c("ID", "building")

sf <- sf %>%
        inner_join(stats, by = "ID") %>%
        inner_join(stock_street, by = "ID") %>%
        inner_join(stock_rail, by = "ID") %>%
        inner_join(stock_other, by = "ID") %>%
        inner_join(stock_building, by = "ID")

sf <- sf %>%
        mutate(total = street + rail + other + building)

sf <- sf %>%
        mutate(POP_PER_KM2 = POPESTIMATE2018 / AREA_KM2)

sf <- sf %>%
        mutate(BUILDING_RATIO = building / (street + rail + other) * 100)

sf_area <- sf %>% mutate_at(c(11:14, 16), funs(. / AREA_KM2))
sf_pop  <- sf %>% mutate_at(c(11:14, 16), funs(. / POPESTIMATE2018))

dplot <- "paper/USA/plot/dorling-county"

for (k in seq(0.1, 1, 0.1)) {

    for (i in c(11:14, 16, 18)) {

        name <- colnames(sf)[i]
        mai  <- c(0.4, 0.2, 0.4, 0.2)

        tiff(file.path(dplot, sprintf("%s-tons-k%.1f.tif", name, k)),
        width = 8.8, height = 6, units = "cm", pointsize = 8,
        compression = "lzw", res = 600, type = "cairo", antialias = "subpixel")

        par(mai = mai, cex = 1)

            dor <- cartogram_dorling(sf, name, k = k)
            plot(dor[name], pal = viridis, key.width = 0.15,
                main = sprintf("%s mass [t]", name), reset = FALSE, lwd = 0.5)
            plot(st_geometry(sf), border = "grey90", add = TRUE, lwd = 0.5)
            plot(dor[name], pal = viridis, add = TRUE, lwd = 0.5)

        dev.off()


        tiff(file.path(dplot, sprintf("%s-tons-sqm-k%.1f.tif", name, k)),
        width = 8.8, height = 6, units = "cm", pointsize = 8,
        compression = "lzw", res = 600, type = "cairo", antialias = "subpixel")

        par(mai = mai, cex = 1)

            dor <- cartogram_dorling(sf_area, name, k = k)
            plot(dor[name], pal = viridis, key.width = 0.15,
                main = sprintf("%s mass [t/m²]", name), reset = FALSE, lwd = 0.5)
            plot(st_geometry(sf), border = "grey90", add = TRUE, lwd = 0.5)
            plot(dor[name], pal = viridis, add = TRUE, lwd = 0.5)

        dev.off()


        tiff(file.path(dplot, sprintf("%s-tons-cap-k%.1f.tif", name, k)),
        width = 8.8, height = 6, units = "cm", pointsize = 8,
        compression = "lzw", res = 600, type = "cairo", antialias = "subpixel")

        par(mai = mai, cex = 1)

            dor <- cartogram_dorling(sf_pop, name, k = k)
            plot(dor[name], pal = viridis, key.width = 0.15,
                main = sprintf("%s mass [t/cap]", name), reset = FALSE, lwd = 0.5)
            plot(st_geometry(sf), border = "grey90", add = TRUE, lwd = 0.5)
            plot(dor[name], pal = viridis, add = TRUE, lwd = 0.5)

        dev.off()

    }

}



df <- st_drop_geometry(sf) %>%
        inner_join(
            st_drop_geometry(sf_area),
            by = "ID",
            suffix = c("", ".area")) %>%
        inner_join(
            st_drop_geometry(sf_pop),
            by = "ID",
            suffix = c("", ".pop"))  %>%
        select(
            starts_with(
                c("street.", "rail.", "other.", "building.", "total."),
                ignore.case = FALSE),
            BUILDING_RATIO)


# correlation plot
heatmap(cor(df), scale = "none")


pca <- prcomp(df, scale = TRUE)

library(factoextra)
fviz_eig(pca)

fviz_pca_ind(pca,
             col.ind = "cos2", # Color by the quality of representation
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE     # Avoid text overlapping
             )

fviz_pca_var(pca,
             col.var = "contrib", # Color by contributions to the PC
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE     # Avoid text overlapping
             )
