dplot <- "plot/multipanel"

names <- c("mass_building", 
           "mass_mobility")

lab <- c("log. mass of\nbuildings (kg/cap)",
         "log. mass of mobility\ninfrastructure (kg/cap)")

for (i in 1:length(names)) {

    tiff(sprintf("%s/pop-density_vs_%s.tif", dplot, gsub("_", "-", names[i])),
    width = width, height = height, units = "cm", pointsize = 7,
    compression = "lzw", res = 600, type = "cairo", antialias = "subpixel")

    par(mai = mai,
        cex = 1,
        mgp = c(3, 0.5, 0))


        sub <- df_pop_ %>% 
        filter(YEAR == 2018) %>%
        select(POP_PER_AREA, names[i], POPPCT_URBAN) %>%
        filter(.data[[names[i]]] > 0) %>%
        mutate_at(vars(starts_with("mass")), .funs = funs(. * 1000))

        col <- colorRampPalette(
                brewer.pal(n = 8,
                           name = "RdYlBu"))(101)[sub$POPPCT_URBAN + 1]

        plot(sub$POP_PER_AREA,
             sub[[names[i]]],
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

        mtext(lab[i],
              side = 2,
              line = 1.5)

        mtext("population density (cap/km²)",
              side = 1,
              line = 1.5)

        lsub <- sub %>% 
                mutate(across(where(is.numeric), log))

        mod <- lm(get(names[i]) ~ POP_PER_AREA, lsub)
        modsum <- summary(mod)

        line <- data.frame(POP_PER_AREA = seq(-1e2, 1e2, 0.1))
        predict(mod, newdata = line) %>%
            exp() %>%
            lines(exp(line$POP_PER_AREA), .)

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
