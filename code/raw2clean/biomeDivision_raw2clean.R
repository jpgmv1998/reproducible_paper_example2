
# > PROJECT INFO
# NAME: AMAZON PRIORITY MUNICIPALITIES - EXAMPLE
# LEAD: JOAO VIEIRA
#
# > THIS SCRIPT
# AIM: CLEAN RAW DATA SHAPEFILE OF BIOME DIVISION (IBGE-2019)
# AUTHOR: JOAO VIEIRA
#
# > NOTES
# 1: -





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# RUN 'setup.R' TO CONFIGURE INITIAL SETUP (mostly installing/loading packages)
source("code/setup.R")


# START TIMER
tictoc::tic(msg = "biomeDivision_raw2clean.R script", log = T)





# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# read shapefile
raw.biome <- sf::st_read(dsn   = here::here("data/raw2clean/biomeDivision_ibge/input"),
                         layer = "lm_bioma_250")




# DATA EXPLORATION (use when building the script to understand the input data)
# summary(raw.biome)
# str(raw.biome) # avoid with spatial data
# plot(raw.biome$geometry) # only for spatial data (vector)





# DATASET CLEANUP AND PREP ---------------------------------------------------------------------------------------------------------------------------

# COLUMN CLEANUP
# names
colnames(raw.biome)

# clean column names
raw.biome <-
  raw.biome %>%
  janitor::clean_names()

# translate column names
raw.biome <-
  raw.biome %>%
  dplyr::rename(biome_code = cd_bioma,
                biome_name = bioma)

# check columns class
lapply(raw.biome, class)


# CHARACTER TREATMENT

# clean latin characters
raw.biome <-
  raw.biome %>%
  dplyr::mutate(dplyr::across(tidyselect:::where(is.character),
                              \(x) iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")))

# translate characters
raw.biome <-
  raw.biome %>%
  dplyr::mutate(biome_name = dplyr::case_when(biome_name == "Amazonia" ~ "Amazon",
                                              biome_name == "Mata Atlantica" ~ "Atlantic Forest",
                                              TRUE ~ biome_name))


# SPATIAL DATA TREATMENT (vector)

# project to SIRGAS 2000 / Brazil Polyconic (https://epsg.io/5880)
raw.biome <- sf::st_transform(x = raw.biome, crs = 5880)

# check and clean geometries
raw.biome <- sf::st_make_valid(raw.biome)





# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# LABELS
sjlabelled::set_label(raw.biome$biome_code) <- "biome code (1-digit, cross-section, IBGE-2019)"
sjlabelled::set_label(raw.biome$biome_name) <- "biome name (character, cross-section, IBGE-2019)"


# POST-TREATMENT OVERVIEW
# summary(raw.biome)
# plot(raw.biome$geometry) # only for spatial data (vector)


# CODEBOOK GENERATION (VARIABLES DESCRIPTION + SUMMARY STATISTICS)

# create text file to be filled with console output
sink(here::here("data/raw2clean/biomeDivision_ibge/documentation/codebook_biomeDivision.txt"))

# if the object is spatial (sf class) drop geometry column to simplify the codebook and avoid error in describe
if (any(class(raw.biome) == "sf")) {

  # describe all variables
  raw.biome %>%
    sf::st_drop_geometry() %>%
    Hmisc::describe() %>%
    print()

}

# end printing console output to text file
sink()





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

saveRDS(raw.biome,
        file = here::here("data/raw2clean/biomeDivision_ibge/output", "clean_biomeDivision.rds"))


# END TIMER
tictoc::toc(log = T)

# export time to csv table
ExportTimeProcessing("code/raw2clean")





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------