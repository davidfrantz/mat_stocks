require(dplyr)
require(tidyr)

# changes in counties to consider:
# https://www.census.gov/programs-surveys/geography/technical-documentation/county-changes.2010.html
###########################################################################################################
# new FIPS code (accounted for)
# - Oglala Lakota County, South Dakota (46-102)
#   Changed name and code from Shannon County (46-113) effective May 1, 2015.
# - Miami-Dade County, Florida (12-086):
#   Renamed from Dade County (12-025) effective July 22, 1997.
###########################################################################################################
# complete assimilation (accounted for)
# - Bedford (independent) city, Virginia (51-515):
#   Changed to town status and added to Bedford County (51-019) effective July 1, 2013.
# - Clifton Forge (independent) city, Virginia (51-560):
#   Changed to town status and added to Alleghany County (51-005) effective July 1, 2001.
# - Yellowstone National Park (county equivalent), Montana (30-113):
#   Annexed to Gallatin (30-031) and Park (30-067) counties effective November 7, 1997.
#   Gallatin County, Montana (30-031):
#   Annexed unpopulated portion of deleted Yellowstone National Park (county equivalent) (30-113) effective November 7, 1997.
#   Park County, Montana (30-067):
#   Annexed portion of deleted Yellowstone National Park (county equivalent) (30-113) effective November 7, 1997; 1990 added population: 52.
# - South Boston (independent) city, Virginia (51-780):
#   Changed to town status and added to Halifax County (51-083) effective June 30, 1995.
###########################################################################################################
# new county from parts of other counties (NOT accounted for, NAs in previous years)
# - Broomfield County, Colorado (08-014):
#   Created from parts of Adams (08-001), Boulder (08-013), Jefferson (08-059), and Weld (08-123) counties effective November 15, 2001. The boundaries of Broomfield County reflect the boundaries of Broomfield city legally in effect on that date; estimated population: 39,177.
#   Adams County, Colorado (08-001):
#   Part taken to create new Broomfield County (08-014) effective November 15, 2001; estimated detached population: 15,870.
#   Boulder County, Colorado (08-013):
#   Part taken to create new Broomfield County (08-014) effective November 15, 2001; estimated detached population: 21,512.
#   Jefferson County, Colorado (08-059):
#   Part taken to create new Broomfield County (08-014) effective November 15, 2001; estimated detached population: 1,726.
#   Weld County, Colorado (08-123):
#   Part taken to create new Broomfield County (08-014) effective November 15, 2001; estimated detached population: 69.
###########################################################################################################
# territorial changes (NOT accounted for)
# - York County, Virginia (51-199):
#   Exchanged territory with Newport News (independent) city (51-700) effective July 1, 2007; estimated net detached population: 293.
#   Newport News (independent) city, Virginia (51-700):
#   Exchanged territory with York County (51-199) effective July 1, 2007; estimated net added population: 293.
# - Montgomery County, Maryland (24-031):
#   Added territory (Takoma Park city) from Prince George?s County (24-033) effective July 1, 1997; 1990 added population: 5,156.
#   Prince Georges County, Maryland (24-033):
#   Lost territory (Takoma Park city) to Montgomery County (24-031) effective July 1, 1997; 1990 detached population: 5,156.
# - Carteret County, North Carolina (37-031):
#   Boundary correction added from and detached unpopulated parts to Craven County (37-049); estimated area added: five square miles; estimated area detached: 16 square miles.
#   Craven County, North Carolina (37-049):
#   Boundary correction added from and detached unpopulated parts to Carteret County (37-031); estimated area added: 16 square miles; estimated area detached: five square miles.
# - Augusta County, Virginia (51-015):
#   Part annexed to Waynesboro (independent) city (51-820) effective July 1, 1994; no estimated population available.
#   Waynesboro (independent) city, Virginia (51-820):
#   Annexed part of Augusta County (51-015) effective July 1, 1994; no estimated population available.
# - Bedford County, Virginia (51-019):
#   Part annexed to Bedford (independent) city (51-515) effective July 1, 1993; estimated population: 200.
#   Bedford (independent) city, Virginia (51-515):
#   Annexed part of Bedford County (51-019) effective July 1, 1993; estimated population: 200.
# - Fairfax County, Virginia (51-059):
#   Parts annexed to Fairfax (independent) city (51-600) effective December 31, 1991 and January 1, 1994; estimated population: 400.
#   Fairfax (independent) city, Virginia (51-600):
#   Annexed parts of Fairfax County (51-059) effective December 31, 1991 and January 1, 1994; estimated population: 400.
# - Prince William County, Virginia (51-153):
#   Part annexed to Manassas Park (independent) city (51-685) effective December 31, 1990; no estimated population available.
#   Manassas Park (independent) city, Virginia (51-685):
#   Annexed part of Prince William County (51-153) effective December 31, 1990; no estimated population available.
# - Southampton County, Virginia (51-175):
#   Part annexed to Franklin (independent) city (51-620) effective December 31, 1995; estimated population: 400.
#   Franklin (independent) city, Virginia (51-620):
#   Annexed part of Southampton County (51-175) effective December 31, 1995; estimated population: 400.
# - La Paz County, Arizona (04-012):
#   Created from part of Yuma County (04-027) effective January 1, 1983; 1980 population: 12,557.
#   Yuma County, Arizona (04-027):
#   Part taken to create new La Paz County (04-012) effective January 1, 1983; 1980 detached population: 12,557.
#   data %>% filter(FIPS == "04012") %>% select(starts_with("POPESTIMATE")) %>% unlist() %>% plot(1980:2019, .)
# - Cibola County, New Mexico (35-006):
#   Created from part of Valencia County (35-061) effective June 19, 1981; 1980 population: 30,347.
#   Valencia County, New Mexico (35-061):
#   Part taken to create new Cibola County (35-006) effective June 19, 1981; 1980 detached population: 30,347.
#   data %>% filter(FIPS == "35006") %>% select(starts_with("POPESTIMATE")) %>% unlist() %>% plot(1980:2019, .)
# - Adams County, Colorado (08-001):
#   Annexed part of Denver County (08-031) coextensive with Denver city effective October 18, 1980; estimated population: 2,500. Part annexed to Denver County (08-031) effective May 17, 1988; estimated area 43.31 square miles with no estimated population.
#   Denver County, Colorado (08-031) coextensive with Denver city:
#   Part annexed to Adams County (08-001) effective October 18, 1980; estimated population: 2,500. Annexed part of Adams County (08-001) effective May 17, 1988; estimated area 43.31 square miles with no estimated population. Part annexed to Arapahoe County (08-005) effective July 28, 1980; estimated area one square mile with no estimated population.
# - Augusta County, Virginia (51-015):
#   Part annexed to Staunton (independent) city (51-790) effective December 31, 1986; estimated population: 2,300. Part annexed to Waynesboro (independent) city (51-820) effective December 31, 1985; estimated population 3,000.
# - Fairfax County, Virginia (51-059):
#   Part annexed to Fairfax (independent) city (51-600) effective December 31, 1980; estimated population: 1,100.
# - Greensville County, Virginia (51-081):
#   Part annexed to Emporia (independent) city (51-595) effective January 1, 1988; estimated population: 400.
# - James City County, Virginia (51-095):
#   Part annexed to Williamsburg (independent) city (51-830) effective January 1, 1983; estimated population: 400.
# - Pittsylvania County, Virginia (51-143):
#   Part annexed to Danville (independent) city (51-590) effective December 31, 1987 and December 31, 1988; estimated population: 10,500.
# - Prince William County, Virginia (51-153):
#   Part annexed to Manassas (independent) city (51-683) effective December 31, 1983; estimated population: 300.
# - Rockbridge County, Virginia (51-163):
#   Part annexed to Buena Vista (independent) city (51-530) effective December 31, 1983; estimated population: 200.
# - Rockingham County, Virginia (51-165):
#   Part annexed to Harrisonburg (independent) city (51-660) effective December 31, 1982; estimated population: 5,500.
# - Southampton County, Virginia (51-175):
#   Part annexed to Franklin (independent) city (51-620) effective December 31, 1985; estimated population: 600.
# - Spotsylvania County, Virginia (51-177):
#   Part annexed to Fredericksburg (independent) city (51-630) effective December 31, 1983; estimated population: 2,800.
# - Buena Vista (independent) city, Virginia (51-530):
#   Annexed part of Rockbridge County (51-163) effective December 31, 1983; estimated population: 200.
# - Charlottesville (independent) city, Virginia (51-540):
#   Annexed part of Albemarle County (51-003) effective February 9, 1988; no estimated population available.
# - Danville (independent) city, Virginia (51-590):
#   Annexed part of Pittsylvania County (51-143) effective December 31, 1987 and December 31, 1988; estimated population: 10,500.
# - Emporia (independent) city, Virginia (51-595):
#   Annexed part of Greensville County (51-081) effective January 1, 1988; estimated population: 400.
# - Fairfax (independent) city, Virginia (51-600):
#   Annexed part of Fairfax County (51-059) effective December 31, 1980; estimated population: 1,100.
# - Franklin (independent) city, Virginia (51-620):
#   Annexed part of Southampton County (51-175) effective December 31, 1985; estimated population: 600.
# - Fredericksburg (independent) city, Virginia (51-630):
#   Annexed part of Spotsylvania County (51-177) effective December 31, 1983; estimated population: 2,800.
# - Harrisonburg (independent) city, Virginia (51-660):
#   Annexed part of Rockingham County (51-165) effective December 31, 1982; estimated population: 5,500.
# - Manassas (independent) city, Virginia (51-683):
#   Annexed part of Prince William County (51-153) effective December 31, 1983; estimated population: 300.
# - Staunton (independent) city, Virginia (51-790):
#   Annexed part of Augusta County (51-015) effective December 31, 1986; estimated population: 2,300.
# - Waynesboro (independent) city, Virginia (51-820):
#   Annexed part of Augusta County (51-015) effective December 31, 1985; estimated population: 3,000.
# - Williamsburg (independent) city, Virginia (51-830):
#   Annexed part of James City County (51-095) effective December 31, 1983; estimated population: 400.

d19 <- read.csv("paper/USA/csv/stats-all-counties/co-est2019-alldata.csv") %>%
    filter(SUMLEV != 40) %>%
    filter(STNAME != "Alaska") %>%
    filter(STNAME != "Hawaii") %>%
    mutate(FIPS = sprintf("%05d", STATE * 1000 + COUNTY)) %>%
    select(FIPS, starts_with("POPESTIMATE"))
d19 %>% nrow()

d10 <- read.csv("paper/USA/csv/stats-all-counties/co-est2010-alldata.csv") %>%
    filter(SUMLEV != 40) %>%
    filter(STNAME != "Alaska") %>%
    filter(STNAME != "Hawaii") %>%
    mutate(FIPS = sprintf("%05d", STATE * 1000 + COUNTY)) %>%
    select(- ends_with("2010")) %>%
    select(FIPS, starts_with("POPESTIMATE"))
d10 %>% nrow()

tmp <- readLines("paper/USA/csv/stats-all-counties/co-99-10.txt", skip = 18)
tmp <- tmp[- (1:(grep("^1990", tmp)[1] - 1))]
tmp_y <- strsplit(tmp, " +") %>%
    sapply("[", 1)
tmp_f <- strsplit(tmp, " +") %>%
    sapply("[", 2)
tmp_p <- strsplit(tmp, " +") %>%
    sapply(function(x) sum(as.numeric(x[3:length(x)])))
d00 <- data.frame(
        YEAR = paste0("POPESTIMATE", tmp_y),
        FIPS = sprintf("%05d", as.integer(tmp_f)),
        POPESTIMATE = tmp_p) %>%
    spread(YEAR, POPESTIMATE) %>%
    filter(!grepl("^02.*", FIPS, )) %>%
    filter(!grepl("^15.*", FIPS, ))

d90 <- read.csv("paper/USA/csv/stats-all-counties/pe-02.csv",
            skip = 6) %>%
        select(-3)
colnames(d90)[1:2] <- c("YEAR", "FIPS")
d90 <- d90 %>%
    mutate(FIPS = sprintf("%05d", FIPS)) %>%
    filter(!grepl("^02.*", FIPS, )) %>%
    filter(!grepl("^15.*", FIPS, )) %>%
    mutate(YEAR = paste0("POPESTIMATE", YEAR)) %>%
    mutate(POPESTIMATE = rowSums(across(starts_with("X")))) %>%
    select(- starts_with("X")) %>%
    group_by(YEAR, FIPS) %>%
    summarise(POPESTIMATE = sum(POPESTIMATE)) %>%
    ungroup() %>%
    spread(YEAR, POPESTIMATE)


# Renamed Shannon county -> Oglala Lakota County, new FIPS code in 2015
d10 <- d10 %>% mutate(FIPS = replace(FIPS, FIPS == "46113", "46102"))
d00 <- d00 %>% mutate(FIPS = replace(FIPS, FIPS == "46113", "46102"))
d90 <- d90 %>% mutate(FIPS = replace(FIPS, FIPS == "46113", "46102"))

# Renamed Dade county -> Miami Dade County, new FIPS code in 1997
d90 <- d90 %>% mutate(FIPS = replace(FIPS, FIPS == "12025", "12086"))

# Added Bedford city to Bedford County in 2013
d10 <- d10 %>% mutate(FIPS = replace(FIPS, FIPS == "51515", "51019"))
d00 <- d00 %>% mutate(FIPS = replace(FIPS, FIPS == "51515", "51019"))
d90 <- d90 %>% mutate(FIPS = replace(FIPS, FIPS == "51515", "51019"))
d10 <- d10 %>% group_by(FIPS) %>%
    summarize_at(vars(starts_with("POPESTIMATE")), sum) %>%
    ungroup()
d00 <- d00 %>% group_by(FIPS) %>%
    summarize_at(vars(starts_with("POPESTIMATE")), sum) %>%
    ungroup()
d90 <- d90 %>% group_by(FIPS) %>%
    summarize_at(vars(starts_with("POPESTIMATE")), sum) %>%
    ungroup()

# Added Clifton Forge city to Alleghany County in 2001
d00 <- d00 %>% mutate(FIPS = replace(FIPS, FIPS == "51560", "51005"))
d90 <- d90 %>% mutate(FIPS = replace(FIPS, FIPS == "51560", "51005"))
d00 <- d00 %>% group_by(FIPS) %>%
    summarize_at(vars(starts_with("POPESTIMATE")), sum) %>%
    ungroup()
d90 <- d90 %>% group_by(FIPS) %>%
    summarize_at(vars(starts_with("POPESTIMATE")), sum) %>%
    ungroup()

# Added Yellowstone National Park to Park County in 1997
d90 <- d90 %>% mutate(FIPS = replace(FIPS, FIPS == "30113", "30067"))
d90 <- d90 %>% group_by(FIPS) %>%
    summarize_at(vars(starts_with("POPESTIMATE")), sum) %>%
    ungroup()

# Added South Boston city to Halifax County in 1997
d90 <- d90 %>% mutate(FIPS = replace(FIPS, FIPS == "51780", "51083"))
d90 <- d90 %>% group_by(FIPS) %>%
    summarize_at(vars(starts_with("POPESTIMATE")), sum) %>%
    ungroup()


# plot county
#data %>% filter(FIPS == "51019") %>% select(starts_with("POPESTIMATE")) %>% unlist() %>% plot(1980:2019, .)

nrow(d19)
nrow(d10)
nrow(d00)
nrow(d90)

# should be 0
anti_join(d19, d10, by = "FIPS") %>%
bind_rows(
anti_join(d10, d19, by = "FIPS"))

# should be 0
anti_join(d19, d00, by = "FIPS") %>%
bind_rows(
anti_join(d00, d19, by = "FIPS"))

# should be 0
anti_join(d19, d90, by = "FIPS") %>%
bind_rows(
anti_join(d90, d19, by = "FIPS"))


data <- d90 %>% 
    full_join(d00, by = "FIPS") %>%
    full_join(d10, by = "FIPS") %>%
    full_join(d19, by = "FIPS")

names(data) <- gsub("POPESTIMATE", "", names(data))


data <- data %>%
    gather("YEAR", "POP", 2:ncol(data))

nrow(data)

write.csv(data, "paper/USA/csv/stats-all-counties/counties_pop.csv")
