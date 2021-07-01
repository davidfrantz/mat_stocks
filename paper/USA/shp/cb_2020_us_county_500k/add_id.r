require(sf)
require(dplyr)

# add ID

sf <- st_read("paper/USA/shp/cb_2020_us_county_500k/cb_2020_us_county_500k.shp")

sf <- sf %>%
    mutate(FIPS =
        as.integer(STATEFP) * 1000 + as.integer(COUNTYFP)
    )

sf <- sf %>%
    mutate(MS_ID = 
        as.numeric(
            factor(
                FIPS
            )
        )
    )

dict <- st_drop_geometry(sf) %>%
            select(FIPS, MS_ID)

write.csv(dict,
        sprintf("paper/USA/shp/cb_2020_us_county_500k/FIPS-dictionary_ENLOCALE.csv"),
        row.names = FALSE)
write.csv2(dict,
        sprintf("paper/USA/shp/cb_2020_us_county_500k/FIPS-dictionary_DELOCALE.csv"),
        row.names = FALSE)


st_write(sf,
    dsn = "paper/USA/shp/cb_2020_us_county_500k/cb_2020_us_county_500k_id.shp",
    layer = "counties",
    driver = "ESRI Shapefile")
