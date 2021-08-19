dplot <- "plot/battle-of-masses"

names <- c("building_percentage",
           "techno_percentage")

lab  <- c("building mass / human-made material stock (%)",
          "human-made material stock / entire stock (%)")
lab_left  <- c("more\nmobility\ninfrastructure", "more\nbiomass")
lab_right <- c("more\nbuildings", "more\nhuman-made\nmaterials")

textx_left  <- c(20, 30)
texty_left  <- c(8, 12)
textx_right <- c(75, 55)
texty_right <- c(8, 12)

pal <- list(
    brewer.pal(7, "BrBG"),
    brewer.pal(7, "PiYG") %>% rev())

col <- brewer.pal(n = 8, name = "RdYlBu")[c(1, 8)] %>%
    rev()

br <- seq(0, 100, 2.50) # use 1 for citing numbers in the paper
nbr <- length(br) - 1
labels <- sprintf("%.1f", br[-nbr])
labels
#br
cbind(br[-nbr+1], labels)

for (i in 1:length(names)) {

    tmp <- df_ %>% filter(YEAR == 2018) %>%
        mutate(pop_urban = POPPCT_URBAN / 100 * POP_NOW) %>%
        mutate(pop_rural = (100 - POPPCT_URBAN) / 100 * POP_NOW) %>%
        select(names[i], pop_urban, pop_rural) %>%
        mutate(cat = cut(.data[[names[i]]], breaks = br, labels = labels)) %>%
        select(-names[i]) %>%
        group_by(cat) %>%
        summarise_all(sum) %>%
        ungroup()
    
    empty <- which(!labels %in% tmp$cat)
    add_df <- data.frame(labels[empty], rep(0, length(empty)), rep(0, length(empty)))
    rownames(add_df) <- labels[empty]
    colnames(add_df) <- colnames(tmp)
    tmp <- rbind(tmp, add_df)

    tmp <- tmp %>% 
        arrange(cat) %>%
        mutate(pop_urban_cum = cumsum(pop_urban)) %>%
        mutate(pop_rural_cum = cumsum(pop_rural)) %>%
        mutate(pop_urban_cum_pct = pop_urban_cum / max(pop_urban_cum) * 100) %>%
        mutate(pop_rural_cum_pct = pop_rural_cum / max(pop_rural_cum) * 100) %>%
        mutate(pop_urban_cum_pct_total = pop_urban_cum / (max(pop_rural_cum) + max(pop_urban_cum)) * 100) %>%
        mutate(pop_rural_cum_pct_total = pop_rural_cum / (max(pop_rural_cum) + max(pop_urban_cum)) * 100) %>%
        mutate(pop_total_cum_pct_total = (pop_rural_cum + pop_urban_cum) / (max(pop_rural_cum) + max(pop_urban_cum)) * 100)

    tmp
    #sum(tmp$pop_urban)
    #sum(tmp$pop_rural)
    #sum(tmp$pop_urban)+sum(tmp$pop_rural)

    mat <- tmp %>% 
        select(pop_urban, pop_rural) %>%
        as.matrix()
    rownames(mat) <- tmp$cat

    tiff(sprintf("%s/barplot_%s.tif", dplot, gsub("_", "-", names[i])),
    width = width, height = height, units = "cm", pointsize = 6,
    compression = "lzw", res = 600, type = "cairo", antialias = "subpixel")

    par(mai = c(0.25, 0.45, 0.08, 0.05),
        cex = 1,
        mgp = c(3, 0.5, 0))


    opar <- par(lwd = 0.5)
    mat %>% 
        `/`(sum(mat)) %>%
        `*`(100) %>%
        t() %>%
        barplot(
            beside = TRUE,
            col = col,
            axes = FALSE,
            axisnames = FALSE,
            lwd = 0.5
           )



    legend("topleft", legend = c("urban", "rural"),
            fill = col,
            bty = "n",
            cex = 0.8,
            inset = c(-0.01, -0.01),
            xpd = TRUE)
    par(opar)

    bar <- rownames(mat) %>% as.numeric()

    box(bty = "l")

    axis(side = 1,
        at = seq(2, by = 3, length.out = length(bar))[seq(1, length(bar), 4)],
        labels = sprintf("%.0f", bar)[seq(1, length(bar), 4)],
        tcl = -0.3,
        cex.axis = 1.0,
        gap.axis = 0.2)

    axis(side = 2,
         tcl = -0.3,
         gap.axis = 0.2)

    mtext("population living in\ncounties with given\nmaterial footprint (%)",
          side = 2,
          line = 1.5)

    mtext(lab[i],
          side = 1,
          line = 1.5)

#    abline(v = (which(bar == 50) - 1) * 3 + 0.5,
#           lty = 1,
#           lwd = 0.5,
#           xpd = FALSE,
#           col = "grey40")

    arrows(40 / 2.5 * 3, 8,
           70 / 2.5 * 3, 8,
           col = "grey40",
           lwd = 0.8,
           code = 3,
           length = 0.05)

    arrows(50 / 2.5 * 3, 6,
           50 / 2.5 * 3, 10,
           col = "white",
           lwd = 2,
           code = 0,
           length = 0.05)

    arrows(50 / 2.5 * 3, 7,
           50 / 2.5 * 3, 9,
           col = "grey40",
           lwd = 0.8,
           code = 0,
           length = 0.05)

    text(textx_left[i] / 2.5 * 3, texty_left[i], lab_left[i],
        cex = 0.8,
        adj = 0,
        font = 3,
        col = "grey40")
    text(textx_right[i] / 2.5 * 3, texty_right[i], lab_right[i],
        cex = 0.8,
        adj = 0,
        font = 3,
        col = "grey40")

    dev.off()

    tmp %>% 
        filter(pop_urban_cum_pct > 50)
    tmp %>% 
        filter(pop_rural_cum_pct > 50)

}
