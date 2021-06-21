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

st_write(sf,
    dsn = "paper/USA/shp/cb_2020_us_county_500k/cb_2020_us_county_500k_id.shp",
    layer = "counties",
    driver = "ESRI Shapefile")
