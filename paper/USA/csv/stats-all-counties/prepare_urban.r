require(dplyr)
require(tidyr)
require(gdata)

d19 <- read.csv("paper/USA/csv/stats-all-counties/co-est2019-alldata.csv") %>%
    filter(SUMLEV != 40) %>%
    filter(STNAME != "Alaska") %>%
    filter(STNAME != "Hawaii") %>%
    mutate(FIPS = sprintf("%05d", STATE * 1000 + COUNTY))
d19 %>% nrow()


d <- read.xls("paper/USA/csv/stats-all-counties/PctUrbanRural_County.xls") %>%
    filter(STATENAME != "Alaska") %>%
    filter(STATENAME != "Hawaii") %>%
    filter(STATENAME != "Puerto Rico") %>%
    mutate(FIPS = sprintf("%05d", STATE * 1000 + COUNTY)) %>%
    select(FIPS, POPPCT_URBAN, POPPCT_RURAL, POP_URBAN, POP_RURAL)
d %>% nrow()

# Renamed Shannon county -> Oglala Lakota County, new FIPS code in 2015
d <- d %>% mutate(FIPS = replace(FIPS, FIPS == "46113", "46102"))

# Added Bedford city to Bedford County in 2013
# recompute percentages
# drop columns
d <- d %>% mutate(FIPS = replace(FIPS, FIPS == "51515", "51019")) %>%
    group_by(FIPS) %>%
    summarize_at(vars(starts_with("POP_")), sum) %>%
    ungroup() %>%
    mutate(POPPCT_URBAN = POP_URBAN / (POP_URBAN + POP_RURAL) * 100) %>%
    mutate(POPPCT_RURAL = POP_RURAL / (POP_URBAN + POP_RURAL) * 100) %>%
    select(- starts_with("POP_"))

nrow(d19)
nrow(d)

# should be 0
anti_join(d19, d, by = "FIPS") %>%
bind_rows(
anti_join(d, d19, by = "FIPS"))

write.csv(d, "paper/USA/csv/stats-all-counties/counties_urbanrate.csv")
