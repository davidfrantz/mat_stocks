require(dplyr)
require(tidyr)

cnt <- "USA"
dbase <- "/data/Jakku/mat_stocks"
dstock <- sprintf("%s/stock/%s/ALL", dbase, cnt)
dcsv <- sprintf("%s/git/mat_stocks/paper/USA/csv", dbase)

files <-    dstock %>%
            dir(".csv", full.names = TRUE, recursive = TRUE) %>%
            grep("total", ., value = TRUE)
nfiles <-   length(files)
values <-   lapply(files,
                   function(x) read.csv(x, sep = ";"))
rfiles <-   files %>% gsub(dstock, "", .)
labels <-   basename(files) %>%
            gsub("\\..*", "", .) %>%
            gsub("_total", "", .)

df <- values[[1]]
for (i in 2:nfiles) {
    df <- df %>% 
        full_join(values[[i]], by = "zone")
}

str(df)
colnames(df) <- c("zone", labels)

write.csv( df,
           sprintf("%s/mass-per-county/zonal_mass_ENLOCALE.csv", dcsv),
           row.names = FALSE)
write.csv2(df,
           sprintf("%s/mass-per-county/zonal_mass_DELOCALE.csv", dcsv),
           row.names = FALSE)
