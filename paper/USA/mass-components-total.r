dplot <- "plot/battle-of-masses"

total <- df_ %>%
    filter(YEAR == 2018) %>%
    select(mass_bio, mass_building, mass_mobility) %>%
    summarise_all(sum) %>%
    `*`(1000) %>%
    unlist()


tiff(sprintf("%s/barplot_%s.tif", dplot, "overall"),
width = 2.4, height = 0.8, units = "cm", pointsize = 6,
compression = "lzw", res = 600, type = "cairo", antialias = "subpixel")

    par(mai = c(0.12, 0.07, 0.01, 0.405),
        cex = 1,
        mgp = c(3, 0.25, 0))


    opar <- par(lwd = 0.5)
    c(0, total) %>%
        matrix(2, 2) %>%
        barplot(
            col = c("red", "blue"), # need to photoshop lower bar to green
            axes = FALSE,
            axisnames = FALSE,
            lwd = 0.5,
            horiz = TRUE)

    text(0.5e13, 0.7,
         sprintf("%.2f", total[1] / 1e13),
         adj = 0,
         xpd = TRUE,
         cex = 0.9,
         col = "black")

    text(1e13, 1.9,
         sprintf("%.2f", total[2] / 1e13),
         adj = 0,
         xpd = TRUE,
         cex = 0.9,
         col = "white")

    text(total[2] + 1e13, 1.9,
         sprintf("%.2f", total[3] / 1e13),
         adj = 0,
         xpd = TRUE,
         cex = 0.9,
         col = "white")

  text(total[1]  + 1e13, 0.7,
         sprintf("stock totals (kg)"),
         adj = 0,
         xpd = TRUE,
         cex = 0.9)



    #legend("topleft", legend = c("urban", "rural"),
    #        fill = col,
    #        bty = "n",
    #        cex = 0.8,
    #        inset = c(-0.01, -0.01),
    #        xpd = TRUE)
    par(opar)


    axis(side = 1,
         line = 0.1,
         at = c(0, sum(total[2:3])),
         labels = c("0", sprintf("%.1fe+13", sum(total[2:3])/1e13)),
         tcl = -0.3,
         gap.axis = 0.2,
         cex.axis = 0.9,
         xpd = TRUE)

    #mtext("mass (kg)",
    #      side = 1,
    #      line = 0)

dev.off()
