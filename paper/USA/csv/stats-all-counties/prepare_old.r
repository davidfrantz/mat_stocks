require(sf)
require(dplyr)
require(stringr)


# really messy - do not use unless you have to

sf <- st_read("paper/USA/shp/county_proj.shp") %>%
#sf <- st_read("paper/USA/shp/cb_2020_us_county_500k/cb_2020_us_county_500k.shp") %>%
    st_drop_geometry()
sf$NAME_2 <- gsub(" City", "", sf$NAME_2)


nrow(sf)
tab1 <- read.csv("paper/USA/csv/stats-all-counties/Export_Output.txt")
tab1 <- select(tab1, -ID)
sf <- inner_join(sf, tab1, by = "HASC_2")
sf <- mutate(sf, key = tolower(gsub(" ", "", paste(sf$NAME_1, sf$NAME_2))))
sf$key <- gsub("southdakotashannon", "southdakotaoglalalakota", sf$key)
sf$key <- gsub("missourishannon", "missourioglalalakota", sf$key)
nrow(sf)


tab2 <- read.csv("paper/USA/csv/stats-all-counties/co-est2019-alldata.csv")
tab2 <- filter(tab2, SUMLEV != 40)
tab2 <- filter(tab2, STNAME != "Alaska")
tab2 <- filter(tab2, STNAME != "Hawaii")
tab2 %>% nrow()



tab2 <- tab2 %>%
    mutate(MS_ID = 
        as.numeric(
            factor(
                as.integer(STATE) * 1000 + as.integer(COUNTY)
            )
        )
    )


#sf <- inner_join(sf, tab2, by = "MS_ID")


colnames(tab2)[6] <- "NAME_1"
colnames(tab2)[7] <- "NAME_2"
tab2$NAME_2 <- gsub("Shannon County", "Oglala Lakota County", tab2$NAME_2)
tab2 <- mutate(tab2, key = tolower(gsub(" ", "", paste(NAME_1, NAME_2))))



tab3 <- read.csv("paper/USA/csv/stats-all-counties/co-est2010-alldata.csv")
colnames(tab3)[6] <- "NAME_1"
colnames(tab3)[7] <- "NAME_2"
tab3 <- filter(tab3, NAME_1 != "Alaska")
tab3 <- filter(tab3, NAME_1 != "Hawaii")
tab3 <- filter(tab3, SUMLEV != 40)

tmp <- tab3 %>% 
    filter(NAME_1 == "Virginia" &
        str_detect(NAME_2, "^Bedford")) %>%
    mutate(across(where(is.numeric), sum)) %>%
    slice(1)
nrow(tab3)
tab3 <- tab3 %>%
    filter(NAME_1 != "Virginia" |
            str_detect(NAME_2, "^Bedford", negate = TRUE))
nrow(tab3)
tab3 <- tab3 %>% rbind(tmp)
nrow(tab3)

tab3$NAME_2 <- gsub("Shannon County", "Oglala Lakota County", tab3$NAME_2)
tab3 <- mutate(tab3, key = tolower(gsub(" ", "", paste(NAME_1, NAME_2))))

tab3 <- select(tab3, -c(NAME_1, NAME_2))


tab2$key[which(!tab2$key %in% tab3$key)]
tab3$key[which(!tab3$key %in% tab2$key)]

tab3 <- select(tab3, -POPESTIMATE2010)

tab <- inner_join(tab2, tab3, by = "key")

nrow(tab)
nrow(sf)


tab$key <- gsub("county$", "", tab$key)
tab$key <- gsub("city$", "", tab$key)
tab$key <- gsub("parish$", "", tab$key)
tab$key <- gsub("st\\.", "saint", tab$key)
tab$key <- gsub("ste\\.", "sainte", tab$key)
tab$key <- gsub("do\U3e31663caana", "donaana", tab$key)

tab$key[which(!tab$key %in% sf$key)]
sf$key[which(!sf$key %in% tab$key)]

which(table(sf$key) > 1)
which(table(tab$key) > 1)


{
    tmp <- tab %>% 
        filter(NAME_1 == "Maryland" &
            str_detect(NAME_2, "^Baltimore")) %>%
        mutate(across(where(is.numeric), sum)) %>%
        slice(1)
    nrow(tab)
    tab <- tab %>%
        filter(NAME_1 != "Maryland" |
                str_detect(NAME_2, "^Baltimore", negate = TRUE))
    nrow(tab)
    tab <- tab %>% rbind(tmp)
    nrow(tab)

    tmp <- tab %>% 
        filter(NAME_1 == "Missouri" &
            str_detect(NAME_2, "^St. Louis")) %>%
        mutate(across(where(is.numeric), sum)) %>%
        slice(1)
    nrow(tab)
    tab <- tab %>%
        filter(NAME_1 != "Missouri" |
                str_detect(NAME_2, "^St. Louis", negate = TRUE))
    nrow(tab)
    tab <- tab %>% rbind(tmp)
    nrow(tab)

    tmp <- tab %>% 
        filter(NAME_1 == "Virginia" &
            str_detect(NAME_2, "^Roanoke")) %>%
        mutate(across(where(is.numeric), sum)) %>%
        slice(1)
    nrow(tab)
    tab <- tab %>%
        filter(NAME_1 != "Virginia" |
                str_detect(NAME_2, "^Roanoke", negate = TRUE))
    nrow(tab)
    tab <- tab %>% rbind(tmp)
    nrow(tab)

    tmp <- tab %>% 
        filter(NAME_1 == "Virginia" &
            str_detect(NAME_2, "^Richmond")) %>%
        mutate(across(where(is.numeric), sum)) %>%
        slice(1)
    nrow(tab)
    tab <- tab %>%
        filter(NAME_1 != "Virginia" |
                str_detect(NAME_2, "^Richmond", negate = TRUE))
    nrow(tab)
    tab <- tab %>% rbind(tmp)
    nrow(tab)

    tmp <- tab %>% 
        filter(NAME_1 == "Virginia" &
            str_detect(NAME_2, "^Franklin")) %>%
        mutate(across(where(is.numeric), sum)) %>%
        slice(1)
    nrow(tab)
    tab <- tab %>%
        filter(NAME_1 != "Virginia" |
                str_detect(NAME_2, "^Franklin", negate = TRUE))
    nrow(tab)
    tab <- tab %>% rbind(tmp)
    nrow(tab)

    tmp <- tab %>% 
        filter(NAME_1 == "Virginia" &
            str_detect(NAME_2, "^Fairfax")) %>%
        mutate(across(where(is.numeric), sum)) %>%
        slice(1)
    nrow(tab)
    tab <- tab %>%
        filter(NAME_1 != "Virginia" |
                str_detect(NAME_2, "^Fairfax", negate = TRUE))
    nrow(tab)
    tab <- tab %>% rbind(tmp)
    nrow(tab)

}

tab$key[which(!tab$key %in% sf$key)]
sf$key[which(!sf$key %in% tab$key)]

which(table(sf$key) > 1)
which(table(tab$key) > 1)


tab <- select(tab, -c(NAME_1, NAME_2))

new_tab <- inner_join(sf, tab, by = "key")
nrow(new_tab)
colnames(sf)
colnames(new_tab)

#new_tab <- new_tab %>% select(HASC_2, ID, NAME_1, NAME_2, AREA, starts_with("POPESTIMATE"))
colnames(new_tab)
write.csv(new_tab, "paper/USA/csv/stats-all-counties/area_pop_per_county.csv")
