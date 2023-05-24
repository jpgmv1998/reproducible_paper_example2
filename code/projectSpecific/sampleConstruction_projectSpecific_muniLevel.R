
# > PROJECT INFO
# NAME: PRIORITY MUNICIPALITIES AMAZON - EXAMPLE
# LEAD: JOAO VIEIRA
#
# > THIS SCRIPT
# AIM: CONSTRUCT AMAZON MUNICIPALITIES SAMPLE
# AUTHOR: JOAO VIEIRA
#
# > NOTES
# 1: -





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# RUN 'setup.R' TO CONFIGURE INITIAL SETUP (mostly installing/loading packages)
source("code/setup.R")


# START TIME
tictoc::tic(msg = "sampleConstruction_projectSpecific_muniLevel.R script", log = T)





# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# BRAZILIAN MUNICIPALITIES DIVISION SHAPEFILE (IBGE-)
clean.muniDivision <- readRDS(file = here::here("data/raw2clean/muniDivision_ibge/output", "clean_muniDivision.rds"))


# BRAZILIAN BIOMES DIVISION SHAPEFILE (IBGE-2019)
clean.biomeDivision <- readRDS(file = here::here("data/raw2clean/biomeDivision_ibge/output", "clean_biomeDivision.rds"))





# DATA MANIPULATION ----------------------------------------------------------------------------------------------------------------------------------

# calculate municipality area in square kilometers
clean.muniDivision <-
  clean.muniDivision %>%
  dplyr::mutate(muni_area = sf::st_area(.) %>%
                              units::set_units(km^2) %>%
                              unclass())

# select amazon biome
clean.biomeDivision <-
  clean.biomeDivision %>%
  dplyr::filter(biome_name == "Amazon")

# create auxiliar shapefile with the municipalities-amazon spatial intersection
aux.muniAmazon <- sf::st_intersection(clean.muniDivision, clean.biomeDivision)

# calculate intersection area
aux.muniAmazon <-
  aux.muniAmazon %>%
  dplyr::mutate(biome_area = sf::st_area(.) %>%
                  units::set_units(km^2) %>%
                  unclass())

# calculate share of municipality inside the amazon biome, select relevant columns, and drop spatial dimension
aux.muniAmazon <-
  aux.muniAmazon %>%
  dplyr::mutate(muni_amazon_share = biome_area/muni_area) %>%
  dplyr::select(muni_code, muni_amazon_share) %>%
  sf::st_drop_geometry()

# add share of municipality inside the amazon biome and filter for municipalities inside the amazon
spatial.sample.muniLevel <-
  clean.muniDivision %>%
  dplyr::left_join(aux.muniAmazon) %>%
  dplyr::filter(muni_amazon_share > 0)

# remove objects from global environment
rm(aux.muniAmazon, clean.muniDivision, clean.biomeDivision)





# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# LABELS
# check existing labels
sjlabelled::get_label(spatial.sample.muniLevel)

# add labels to new variables
sjlabelled::set_label(spatial.sample.muniLevel$muni_area) <- "municipality area (square kilometers, cross-section, IBGE-2015)"
sjlabelled::set_label(spatial.sample.muniLevel$muni_amazon_share) <- "share of municipality area inside the Amazon biome (fraction, cross-section, IBGE-2015 and IBGE-2019)"


# OTHER EXPORT FORMATS
# extract data.frame from spatial data
crossSection.sample.muniLevel <-
  spatial.sample.muniLevel %>%
  sf::st_drop_geometry()

# create annual panel data from crossSection and add missing label
panel.sample.muniLevel <-
  crossSection.sample.muniLevel %>%
  tidyr::expand_grid(year = 2000:2019) %>%
  dplyr::arrange(muni_code, year)

sjlabelled::set_label(panel.sample.muniLevel$year) <- "year of reference, calendar from Jan/t to Dec/t or PRODES from Aug/t-1 to Jul/t (4-digits, panel)"



# POST-TREATMENT OVERVIEW
# summary(spatial.sample.muniLevel)
# summary(crossSection.sample.muniLevel)
# summary(panel.sample.muniLevel)






# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

saveRDS(spatial.sample.muniLevel,
        file = here::here("data/projectSpecific/muniLevel", "spatial_sample_muniLevel.rds"))

saveRDS(crossSection.sample.muniLevel,
        file = here::here("data/projectSpecific/muniLevel", "crossSection_sample_muniLevel.rds"))

saveRDS(panel.sample.muniLevel,
        file = here::here("data/projectSpecific/muniLevel", "panel_sample_muniLevel.rds"))


# END TIMER
tictoc::toc(log = T)

# export time to csv table
ExportTimeProcessing("code/projectSpecific")





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------