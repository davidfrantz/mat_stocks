#!/usr/bin/env Rscript

require(dplyr)
require(tidyr)

args <- commandArgs(trailingOnly = TRUE)

cnt <- args[1]
dbase <- "/data/ahsoka/gi-sds/hub/mat_stocks"
dstock <- sprintf("%s/stock/%s/ALL/area", dbase, cnt)
dcsv <- sprintf("%s/git/mat_stocks/paper/%s/csv", dbase, cnt)
dir.create(dcsv)

files <-    dstock %>%
            dir(".csv", full.names = TRUE, recursive = TRUE)
nfiles <-   length(files)
values <-   lapply(files,
                function(x) read.csv(x, sep = ";"))
rfiles <-   files %>% gsub(dstock, "", .)
labels <-   basename(files) %>%
            gsub("\\..*", "", .)

df <- values[[1]]
for (i in 2:nfiles) {
    df <- df %>% 
        full_join(values[[i]], by = "zone")
}

colnames(df) <- c("zone", labels)
str(df)

dir.create(sprintf("%s/mass-per-county", dcsv))
write.csv( df,
        sprintf("%s/mass-per-county/zonal_area_ENLOCALE.csv", dcsv),
        row.names = FALSE)
write.csv2(df,
        sprintf("%s/mass-per-county/zonal_area_DELOCALE.csv", dcsv),
        row.names = FALSE)
