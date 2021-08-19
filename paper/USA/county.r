require(moments)
require(cartogram)
require(viridis)
require(plotly)
require(RColorBrewer)
require(raster)

setwd("paper/USA")

source("dataprep.r")

width  <- 5.5
height <- 3.0
mai    <- c(0.3, 0.4, 0.08, 0.05)

source("pop-density-regression.r")
source("pop-change-regression.r")
source("mass-per-cap-map.r")

source("urban-rate-map.r")

source("battle-of-masses.r")
source("mass-ratios-map.r")
source("mass_ratio_per_pop_barplot.r")
source("mass_ratio_per_pop_cumplot.r")
source("map_components.r")
source("mass-components-total.r")









































#### Maps for explanatory variables

names <- c("POP_PER_AREA")

lab <- c("population density [cap / km²]")

for (i in 1:length(names)) {

    #fig <- 
    ggplot(df %>% filter(YEAR == 2018)) +
        geom_sf(
           aes_string(fill = names[i]),
           lwd = 0) +
        scale_fill_viridis(rescaler = function(x, to = c(0, 1), from = NULL) {
            upper <- quantile(x, 0.975, na.rm = TRUE)
            lower <- quantile(x, 0.025, na.rm = TRUE)
            scale <- scales::rescale(x,
                           to = to,
                           from = c(lower, upper))
            scale[x < lower] <- 0
            scale[x > upper] <- 1
            return(scale) }) +
        ggtitle(lab[i])# +
        #theme_bw()
    #fig %>% plot()

}

names <- c("MEAN_RPOP")

lab <- c("mean population change rate 1980-2018 [cap / 1000 cap]")

for (i in 1:length(names)) {

    fig <- ggplot(df %>% filter(YEAR == 2018)) +
        geom_sf(
           aes_string(fill = names[i]),
           lwd = 0) +
        scale_fill_gradientn(colours = brewer.pal(7, "PiYG"), rescaler = function(x, to = c(0,1), from = NULL) {
            upper <- quantile(x, 0.975, na.rm = TRUE)
            lower <- quantile(x, 0.025, na.rm = TRUE)
            scale <- ifelse(x < 0,
                scales::rescale(x,
                    to = c(0, 0.5),
                    from = c(lower, 0)),
                scales::rescale(x,
                    to = c(0.5, 1),
                    from = c(0, upper))
              )
            scale[x < lower] <- 0
            scale[x > upper] <- 1
            return(scale) }) +
        ggtitle(lab[i]) +
        theme_bw()
    fig %>% plot()

}



names <- "building_ratio"

lab <- "building to infrastructure ratio [%]"

for (i in 1:length(names)) {

    fig <- ggplot(df_pop %>% filter(YEAR == 2018)) +
        geom_sf(
           aes_string(fill = names[i]),
           lwd = 0) +
        scale_fill_gradientn(colours = brewer.pal(7, "PiYG"), rescaler = function(x, to = c(0,1), from = NULL) {
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
        ggtitle(lab[i]) +
        theme_bw()
    fig %>% plot()

}
