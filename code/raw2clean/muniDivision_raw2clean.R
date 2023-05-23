
# > PROJECT INFO
# NAME: AMAZON PRIORITY MUNICIPALITIES - EXAMPLE
# LEAD: JOAO VIEIRA
#
# > THIS SCRIPT
# AIM: CLEAN RAW DATA SHAPEFILE OF MUNI DIVISION (IBGE-2015)
# AUTHOR: JOAO VIEIRA
#
# > NOTES
# 1: -





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# RUN 'setup.R' TO CONFIGURE INITIAL SETUP (mostly installing/loading packages)
source("code/setup.R")


# START TIMER
tictoc::tic(msg = "muniDivision_raw2clean.R script", log = T)





# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# read shapefile
raw.muni <- sf::st_read(dsn   = here::here("data/raw2clean/muniDivision_ibge/input"),
                        layer = "BRMUE250GC_SIR")



# DATA EXPLORATION (use when building the script to understand the input data)
# summary(raw.muni)
# str(raw.muni) # avoid with spatial data
# plot(raw.muni$geometry) # only for spatial data (vector)





# DATASET CLEANUP AND PREP ---------------------------------------------------------------------------------------------------------------------------

# COLUMN CLEANUP
# names
colnames(raw.muni)

# clean column names
raw.muni <-
  raw.muni %>%
  janitor::clean_names()

# translate column names
raw.muni <-
  raw.muni %>%
  dplyr::rename(muni_code = cd_geocmu,
                muni_name = nm_municip)

# add state_uf column
raw.muni <-
  raw.muni %>%
  dplyr::mutate(state_uf = dplyr::case_when(stringr::str_sub(muni_code, 1, 2) == 11 ~  "RO",
                                            stringr::str_sub(muni_code, 1, 2) == 12 ~  "AC",
                                            stringr::str_sub(muni_code, 1, 2) == 13 ~  "AM",
                                            stringr::str_sub(muni_code, 1, 2) == 14 ~  "RR",
                                            stringr::str_sub(muni_code, 1, 2) == 15 ~  "PA",
                                            stringr::str_sub(muni_code, 1, 2) == 16 ~  "AP",
                                            stringr::str_sub(muni_code, 1, 2) == 17 ~  "TO",
                                            stringr::str_sub(muni_code, 1, 2) == 21 ~  "MA",
                                            stringr::str_sub(muni_code, 1, 2) == 22 ~  "PI",
                                            stringr::str_sub(muni_code, 1, 2) == 23 ~  "CE",
                                            stringr::str_sub(muni_code, 1, 2) == 24 ~  "RN",
                                            stringr::str_sub(muni_code, 1, 2) == 25 ~  "PB",
                                            stringr::str_sub(muni_code, 1, 2) == 26 ~  "PE",
                                            stringr::str_sub(muni_code, 1, 2) == 27 ~  "AL",
                                            stringr::str_sub(muni_code, 1, 2) == 28 ~  "SE",
                                            stringr::str_sub(muni_code, 1, 2) == 29 ~  "BA",
                                            stringr::str_sub(muni_code, 1, 2) == 31 ~  "MG",
                                            stringr::str_sub(muni_code, 1, 2) == 32 ~  "ES",
                                            stringr::str_sub(muni_code, 1, 2) == 33 ~  "RJ",
                                            stringr::str_sub(muni_code, 1, 2) == 35 ~  "SP",
                                            stringr::str_sub(muni_code, 1, 2) == 41 ~  "PR",
                                            stringr::str_sub(muni_code, 1, 2) == 42 ~  "SC",
                                            stringr::str_sub(muni_code, 1, 2) == 43 ~  "RS",
                                            stringr::str_sub(muni_code, 1, 2) == 50 ~  "MS",
                                            stringr::str_sub(muni_code, 1, 2) == 51 ~  "MT",
                                            stringr::str_sub(muni_code, 1, 2) == 52 ~  "GO",
                                            stringr::str_sub(muni_code, 1, 2) == 53 ~  "DF"))

# check columns class
lapply(raw.muni, class)

# change muni_code class to numeric
raw.muni <-
  raw.muni %>%
  dplyr::mutate(muni_code = as.numeric(muni_code))


# CHARACTER TREATMENT

# clean latin characters
raw.muni <-
  raw.muni %>%
  dplyr::mutate(dplyr::across(tidyselect:::where(is.character),
                              \(x) iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")))

# capitalize characters
raw.muni <-
  raw.muni %>%
  dplyr::mutate(muni_name = toupper(muni_name))


# REMOVE POLYGONS IDENTIFIED AS BODY OF WATERS AND NOT MUNICIPALITIES
raw.muni <-
  raw.muni %>%
  dplyr::filter(!muni_code %in% c(4300001, 4300002))


# SPATIAL DATA TREATMENT (vector)

# project to SIRGAS 2000 / Brazil Polyconic (https://epsg.io/5880)
raw.muni <- sf::st_transform(x = raw.muni, crs = 5880)

# check and clean geometries
raw.muni <- sf::st_make_valid(raw.muni)





# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# LABELS
sjlabelled::set_label(raw.muni$muni_code) <- "municipality code (7-digit, cross-section, IBGE-2015)"
sjlabelled::set_label(raw.muni$muni_name) <- "municipality name (character, cross-section, IBGE-2015)"
sjlabelled::set_label(raw.muni$state_uf)  <- "state name (2-characters, cross-section, IBGE-2015)"


# POST-TREATMENT OVERVIEW
# summary(raw.muni)
# plot(raw.muni$geometry)


# CODEBOOK GENERATION (VARIABLES DESCRIPTION + SUMMARY STATISTICS)

# create text file to be filled with console output
sink(here::here("data/raw2clean/muniDivision_ibge/documentation/codebook_muniDivision.txt"))

# if the object is spatial (sf class) drop geometry column to simplify the codebook and avoid error in describe
if (any(class(raw.muni) == "sf")) {

  # describe all variables
  raw.muni %>%
    sf::st_drop_geometry() %>%
    Hmisc::describe() %>%
    print()

}

# end printing console output to text file
sink()





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

saveRDS(raw.muni,
        file = here::here("data/raw2clean/muniDivision_ibge/output", "clean_muniDivision.rds"))


# END TIMER
tictoc::toc(log = T)

# export time to csv table
ExportTimeProcessing("code/raw2clean")





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------