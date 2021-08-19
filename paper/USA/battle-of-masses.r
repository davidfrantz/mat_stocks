dplot <- "plot/battle-of-masses"

xnames <- c("mass_building",
            "mass_total")
ynames <- c("mass_mobility",
            "mass_bio")

xlab <- c("log. mass of buildings (kg/cap)",
          "log. mass of material stock (kg/cap)")
ylab <- c("log. mass of mobility\ninfrastructure (kg/cap)",
          "log. mass of living\nvegetation (kg/cap)")

legend_pos <- c("topleft",
                "bottomright")
legend_xinset <- c(-0.05,
                   -0.025)
legend_yinset <- c(-0.075,
                    0.025)

dimlab <- c("pop", 
            "area")

for (DIM in 1:2) {

for (i in 1:length(xnames)) {

    tiff(sprintf("%s/%s_vs_%s_%s.tif",
        dplot,
        gsub("_", "-", xnames[i]),
        gsub("_", "-", ynames[i]),
        dimlab[DIM]),
    width = width, height = height, units = "cm", pointsize = 7,
    compression = "lzw", res = 600, type = "cairo", antialias = "subpixel")

    par(mai = mai,
        cex = 1,
        mgp = c(3, 0.5, 0))

        if (dimlab[DIM] == "pop") DF <- df_pop_
        if (dimlab[DIM] == "area") DF <- df_area_

        if (dimlab[DIM] == "area") ylab <- gsub("cap", "km²", ylab)
        if (dimlab[DIM] == "area") xlab <- gsub("cap", "km²", xlab)


        sub <- DF %>% 
        filter(YEAR == 2018) %>%
        select(xnames[i], ynames[i], POPPCT_URBAN) %>%
        filter(.data[[xnames[i]]] > 0) %>%
        filter(.data[[ynames[i]]] > 0) %>%
        mutate_at(vars(starts_with("mass")), .funs = funs(. * 1000))

        col <- colorRampPalette(
                brewer.pal(n = 8,
                           name = "RdYlBu"))(101)[sub$POPPCT_URBAN + 1]

        plot(sub[[xnames[i]]],
             sub[[ynames[i]]],
             log = "xy",
             xlab = "",
             ylab = "",
             axes = FALSE,
             pch = 19,
             cex = 0.1,
             col = col)

        axis(side = 1, tcl = -0.3)
        axis(side = 2, tcl = -0.3)

        box(bty = "l")

        mtext(ylab[i],
              side = 2,
              line = 1.5)

        mtext(xlab[i],
              side = 1,
              line = 1.5)

        lsub <- sub %>%
                mutate(across(where(is.numeric), log))

        mod <- lm(get(ynames[i]) ~
                    get(xnames[i]) +
                    I(get(xnames[i]) * get(xnames[i])), lsub)
        modsum <- summary(mod)

#        newx <- seq(0, 100, 0.1)
#        lines(exp(newx),
#              exp(coef(mod)[1] +
#                  coef(mod)[2] * newx +
#                  coef(mod)[3] * newx**2))

        line <- data.frame(seq(-1e2, 1e2, 0.1))
        colnames(line) <- xnames[i]
        predict(mod, newdata = line) %>%
            exp() %>%
            lines(exp(line[[xnames[i]]]), .)

        p <- modsum %>%
            capture.output() %>%
            grep("p-value", ., value = TRUE) %>%
            gsub(".*, +p", "p", .)

        legend(legend_pos[i],
               legend = c(
                    sprintf("R²: %.3f", modsum$r.squared),
                    sprintf("n: %d", modsum$residuals %>% length()),
                    p),
                bty = "n",
                cex = 0.8,
                inset = c(legend_xinset[i], legend_yinset[i]),
                xpd = TRUE)

    dev.off()

}

}
