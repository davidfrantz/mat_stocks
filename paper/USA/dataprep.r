require(sf)
require(dplyr)
require(tidyr)


dcsv  <- "csv"
dshp  <- "shp/cb_2020_us_county_500k"

f_mat <- dir(sprintf("%s/mass-per-state", dcsv), "ENLOCALE", full.names = TRUE)
n_mat <- length(f_mat)

material <- data.frame(0)

for (i in 1:n_mat) {

    tmp <- read.csv(f_mat[i], sep = ",") %>%
        filter(!is.na(aggregate)) %>%
        mutate(category = gsub("^street_", "mobility_", category)) %>%
        mutate(category = gsub("^rail_", "mobility_",   category)) %>%
        mutate(category = gsub("^other_", "mobility_",  category)) %>%
        mutate(group = gsub("_.*", "", category)) %>%
        group_by(group) %>%
        summarise_if(is.numeric, sum, na.rm = TRUE) %>%
        ungroup() %>%
        mutate(state = substr(basename(f_mat[i]), 4, 5))

    material <- material %>% bind_rows(tmp)

}

material <- material %>%
        filter(!is.na(aggregate)) %>%
        select(-X0) %>%
        group_by(group) %>%
        summarise_if(is.numeric, sum, na.rm = TRUE) %>%
        ungroup()
material

sf <- st_read(sprintf("%s/cb_2020_us_county_500k_id_clim_proj.shp", dshp))

stats_pop    <- read.csv(
    sprintf("%s/stats-all-counties/counties_pop.csv", dcsv))
stats_birth  <- read.csv(
    sprintf("%s/stats-all-counties/counties_birth.csv", dcsv))
stats_death  <- read.csv(
    sprintf("%s/stats-all-counties/counties_death.csv", dcsv))
stats_natinc <- read.csv(
    sprintf("%s/stats-all-counties/counties_naturalincrease.csv", dcsv))
stats_dommig <- read.csv(
    sprintf("%s/stats-all-counties/counties_domesticmigration.csv", dcsv))
stats_intmig <- read.csv(
    sprintf("%s/stats-all-counties/counties_internationalmigration.csv", dcsv))
stats_netmig <- read.csv(
    sprintf("%s/stats-all-counties/counties_netmigration.csv", dcsv))
stats_urban  <- read.csv(
    sprintf("%s/stats-all-counties/counties_urbanrate.csv", dcsv))

stocks <- read.csv(
    sprintf("%s/mass-per-county/zonal_mass_ENLOCALE.csv", dcsv), sep = ",")
colnames(stocks)[1] <- "MS_ID"

biomass_agb <- read.csv(
    sprintf("%s/biomass-per-county/biomass_agb_zonal.csv", dcsv), sep = ";")
colnames(biomass_agb) <- c("MS_ID", "mass_bio_agb")

biomass_bgb <- read.csv(
    sprintf("%s/biomass-per-county/biomass_bgb_zonal.csv", dcsv), sep = ";")
colnames(biomass_bgb) <- c("MS_ID", "mass_bio_bgb")

biomass <- biomass_agb %>%
    full_join(biomass_bgb, by = "MS_ID") %>%
    mutate(mass_bio = mass_bio_agb + mass_bio_bgb) %>%
    select(MS_ID, mass_bio)

#str(biomass)
#str(stats)
#str(stocks)

names(sf)
names(stats_pop)
names(stocks)

df <- sf %>%
        full_join(stats_pop, by = "FIPS") %>%
        full_join(stats_birth,  by = c("FIPS", "YEAR")) %>%
        full_join(stats_death,  by = c("FIPS", "YEAR")) %>%
        full_join(stats_natinc, by = c("FIPS", "YEAR")) %>%
        full_join(stats_dommig, by = c("FIPS", "YEAR")) %>%
        full_join(stats_intmig, by = c("FIPS", "YEAR")) %>%
        full_join(stats_netmig, by = c("FIPS", "YEAR")) %>%
        full_join(stats_urban,  by = "FIPS") %>%
        full_join(stocks, by = "MS_ID") %>%
        full_join(biomass, by = "MS_ID") %>%
        select(- starts_with("X.")) %>%
        filter(!is.na(FIPS))

df <- df %>%
    mutate(mass_bio = mass_bio / 10000 * 100 * 0.1 * 2)

df <- df %>%
        mutate(POP_PER_AREA = POP / AREA)

names(df) <- names(df) %>%
    gsub("mass_grand_t_10m2", "mass_total", .)

names(df) <- names(df) %>%
    gsub("mass_other_airport", "mass_airport", .)

df <- df %>%
        mutate(mass_parking_yards =
            mass_other_parking + mass_other_remaining_impervious) %>%
        select(-mass_other_parking) %>%
        select(-mass_other_remaining_impervious) %>%
        select(-mass_other)

names(df) <- names(df) %>%
    gsub("singlefamily",           "RES_LR", .) %>%
    gsub("multifamily",            "RES_MR", .) %>%
    gsub("commercial_innercity",   "RCMU_RR", .) %>%
    gsub("highrise",               "RCMU_HR", .) %>%
    gsub("skyscraper",             "RCMU_SKY", .) %>%
    gsub("commercial_industrial",  "CI", .) %>%
    gsub("lightweight",            "RES_MLB", .)

df <- df %>%
    mutate(mass_building_RES =
        mass_building_RES_LR + mass_building_RES_MR + mass_building_RES_MLB) %>%
    mutate(mass_building_RCMU =
        mass_building_RCMU_RR + mass_building_RCMU_HR + mass_building_RCMU_SKY)

df <- df %>%
    mutate(mass_mobility =
        mass_street + mass_rail + mass_airport + mass_parking_yards)

df <- df %>%
    mutate(building_ratio =
        mass_building / mass_mobility * 100)

df <- df %>%
    mutate(building_percentage =
        mass_building / (mass_building + mass_mobility) * 100)

df <- df %>%
    mutate(mobility_percentage =
        mass_mobility / (mass_building + mass_mobility) * 100)

df <- df %>%
    mutate(techno_bio_ratio =
        mass_total / mass_bio * 100)

df <- df %>%
    mutate(bio_percentage =
        mass_bio / (mass_total + mass_bio) * 100)

df <- df %>%
    mutate(techno_percentage =
        mass_total / (mass_total + mass_bio) * 100)

tmp <- st_drop_geometry(df) %>%
    filter(YEAR == 2018) %>%
    mutate(POP_NOW = POP) %>%
    select(FIPS, POP_NOW)
df <- df %>% full_join(tmp, by = "FIPS")

miny <- st_drop_geometry(df) %>% 
    select(YEAR) %>%
    min()
numy <- 2018 - miny + 1

mean_rates <- data.frame()

for (y in 1:numy) {
    tmp <- st_drop_geometry(df) %>% 
        filter(YEAR >= (miny + y - 1)) %>%
        group_by(FIPS) %>%
        summarise(
            MEAN_RPOP              = mean(RPOP, na.rm = TRUE),
            MEAN_RNATURALINC       = mean(RNATURALINC, na.rm = TRUE),
            MEAN_RBIRTH            = mean(RBIRTH, na.rm = TRUE),
            MEAN_RDEATH            = mean(RDEATH, na.rm = TRUE),
            MEAN_RNETMIG           = mean(RNETMIG, na.rm = TRUE),
            MEAN_RDOMESTICMIG      = mean(RDOMESTICMIG, na.rm = TRUE),
            MEAN_RINTERNATIONALMIG = mean(RINTERNATIONALMIG, na.rm = TRUE),
            YEAR                   = min(YEAR))
    mean_rates <- bind_rows(mean_rates, tmp)
}

df <- df %>%
    full_join(mean_rates, by = c("FIPS", "YEAR"))

df_area <- df %>% mutate_at(
                    vars(starts_with("mass")), 
                    ~ . / AREA)
df_pop  <- df %>% mutate_at(
                    vars(starts_with("mass")), 
                    ~ . / POP_NOW)

df_      <- st_drop_geometry(df)
df_area_ <- st_drop_geometry(df_area)
df_pop_  <- st_drop_geometry(df_pop)

names(df_)
