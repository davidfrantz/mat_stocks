require(dplyr)
require(tidyr)

cnt <- "USA"
dbase <- "/data/Jakku/mat_stocks"
dstock <- sprintf("%s/stock/%s", dbase, cnt)


files <-    dstock %>%
            dir(".txt", full.names = TRUE, recursive = TRUE) %>%
            grep("mosaic", ., value = TRUE)
values <-   sapply(files, readLines) %>%
            as.numeric()
rfiles <-   files %>% gsub(dstock, "", .)

df <- data.frame(
    state     = rfiles %>% gsub("/mosaic.*", "", .) %>% gsub(".*/", "", .),
    dimension = rfiles %>% gsub(".*mosaic/", "", .) %>% gsub("/.*", "", .) %>% gsub("_.*", "", .),
    material  = rfiles %>% dirname() %>% basename() %>% gsub("mosaic", "total", .),
    value     = values,
    file      = rfiles
)



tmp <- rfiles %>% basename() %>% gsub("\\..*", "", .) 
for (i in unique(df$dimension)) tmp <- gsub(sprintf("^%s_", i), "", tmp)
for (i in unique(df$material))  tmp <- gsub(sprintf("_%s$", i), "", tmp)
df$category <- tmp


total_mass_all_states <- df %>% 
                        filter(dimension == "mass", 
                            material == "total") %>% 
                        select(state, category, value) %>%
                        pivot_wider(names_from = category, values_from = value)


write.csv (total_mass_all_states,  sprintf("%s/total_mass_all_states_ENLOCALE.csv", dstock), row.names = FALSE)
write.csv2(total_mass_all_states,  sprintf("%s/total_mass_all_states_DELOCALE.csv", dstock), row.names = FALSE)



write_state_csv <- function(df, key) {

    df_ <- df %>%
        filter(dimension == "mass") %>%
        select(material, category, value) %>%
        pivot_wider(names_from = material, values_from = value)

    write.csv (df_,  sprintf("%s/%s_mass_ENLOCALE.csv", dstock, key$state), row.names = FALSE)
    write.csv2(df_,  sprintf("%s/%s_mass_DELOCALE.csv", dstock, key$state), row.names = FALSE)

}

df %>%
group_by(state) %>%
group_map(~ write_state_csv(.x, .y))

