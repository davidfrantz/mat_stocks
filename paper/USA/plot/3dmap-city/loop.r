require(rjson)

dplot <- "paper/USA/plot/3dmap-city"

json <- fromJSON(file = file.path(dplot, "cities.json"))

source(file.path(dplot, "3dmap-city.r"))

#for (i in 1:length(json)) {
for (i in 292:length(json)) {

    item <- as.data.frame(t(unlist(json[i])))

    lat <- as.numeric(item$latitude)
    lon <- as.numeric(item$longitude)
    name <- item$city
    state <- item$state
    pop <- as.integer(item$population)
    fname <- sprintf("%s/%04d_%s_%s",
        dplot,
        i,
        gsub(" ", "-", name),
        gsub(" ", "-", state))
    vmax <-  618.5618 # for scale (max in NY)

    if (state %in% c("Hawaii", "Alaska")) next

    city3d(lat, lon, name, state, pop, fname, vmax)

    cat(sprintf("done with city # %d: %s, %s\n", i, item$city, item$state))
    flush.console()

}

