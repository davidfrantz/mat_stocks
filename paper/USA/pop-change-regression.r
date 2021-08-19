
dplot <- "plot/multipanel"

names <- c("mass_building",
           "mass_mobility")

lab <- c("log. mass of\nbuildings (kg/cap)",
         "log. mass of mobility\ninfrastructure (kg/cap)")

year <- 1980

aux_name <- "MEAN_RPOP"
aux_lab  <- sprintf("mean pop. change rate (cap / 1000 cap)")


for (i in 1:length(names)) {

    tiff(sprintf("%s/pop-change_vs_%s.tif", dplot, gsub("_", "-", names[i])),
    width = width, height = height, units = "cm", pointsize = 7,
    compression = "lzw", res = 600, type = "cairo", antialias = "subpixel")

    par(mai = mai,
        cex = 1,
        mgp = c(3, 0.5, 0))

        sub <- df_pop_ %>% 
            filter(YEAR == year) %>%
            select(c(aux_name, names[i], POPPCT_URBAN)) %>%
            filter(.data[[names[i]]] >= 0) %>%
            mutate_at(vars(starts_with("mass")), .funs = funs(. * 1000))

        x <- sub[aux_name] %>% unlist()
        y <- sub[names[i]] %>% unlist()
        z <- sub$POPPCT_URBAN %>% unlist()

        col <- colorRampPalette(
                brewer.pal(n = 8,
                           name = "RdYlBu"))(101)[z + 1]

        plot(x, 
             y, 
             log = "y", 
             xlab = "",
             ylab = "",
             axes = FALSE,
             pch = 19,
             cex = 0.1,
             col = col)

        abline(v = 0, lty = 3)

        axis(side = 1, tcl = -0.3)
        axis(side = 2, tcl = -0.3)

        box(bty = "l")

        mtext(lab[i],
              side = 2,
              line = 1.5)

        mtext(aux_lab,
              side = 1,
              line = 1.5)

        if (sum(y <= 0) > 0) {
            x <- x[-which(y <= 0)]
            y <- y[-which(y <= 0)]
        }

        y <- log(y)

        mod  <- lm(y ~ x + I(x*x))
        modsum <- summary(mod)

        newx <- seq(-1000, 1000, 1)
        lines(newx, 
              exp(coef(mod)[1] +
                  coef(mod)[2] * newx +
                  coef(mod)[3] * newx**2))

        p <- modsum %>%
            capture.output() %>%
            grep("p-value", ., value = TRUE) %>%
            gsub(".*, +p", "p", .)

        legend("topright",
               legend = c(
                    sprintf("R²: %.3f", modsum$r.squared),
                    sprintf("n: %d", modsum$residuals %>% length()),
                    p),
                bty = "n",
                cex = 0.8,
                inset = c(-0.025, -0.075),
                xpd = TRUE)

    dev.off()

}
