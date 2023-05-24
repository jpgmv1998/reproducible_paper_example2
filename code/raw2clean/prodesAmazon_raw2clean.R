
# > PROJECT INFO
# NAME: AMAZON PRIORITY MUNICIPALITIES - EXAMPLE
# LEAD: JOAO VIEIRA
#
# > THIS SCRIPT
# AIM: CLEAN RAW PRODES LAND COVER DATA FROM THE BRAZILIAN AMAZON AT THE MUNICIPALITY LEVEL (INPE-2020)
# AUTHOR: JOAO VIEIRA
#
# > NOTES
# 1: -





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# RUN 'setup.R' TO CONFIGURE INITIAL SETUP (mostly installing/loading packages)
source("code/setup.R")


# START TIMER
tictoc::tic(msg = "prodesAmazon_raw2clean.R script", log = T)





# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# list all .txt input files
aux.txtFiles <- list.files(path = here::here("data/raw2clean/prodesAmazon_inpe/input"),
                           pattern = "*.txt",
                           full.names = T)

# read all txt files, remove "Nr" and "Soma " columns and bind them into a single data.frame
raw.prodesAmazon <-
  aux.txtFiles %>%
  purrr::map(readr::read_delim, delim = ",", locale = locale(encoding =  "latin1")) %>% # read all txt files
  purrr::map_df(dplyr::select, -Nr, -`Soma `)




# DATA EXPLORATION (use when building the script to understand the input data)
# summary(raw.prodesAmazon)
# str(raw.prodesAmazon)





# DATASET CLEANUP AND PREP ---------------------------------------------------------------------------------------------------------------------------

# COLUMN CLEANUP

# extract column names
colnames(raw.prodesAmazon)

# clean column names
raw.prodesAmazon <-
  raw.prodesAmazon %>%
  janitor::clean_names()

# fix column names from pattern "incrementoXXXXYYYY" to "incrementoYYYY", where XXXX indicates year t-1 and YYYY indicates year t
raw.prodesAmazon <-
  raw.prodesAmazon %>%
  dplyr::rename_with(.fn = ~ str_remove(., pattern = "\\d{4}"), .cols = starts_with("incremento"))

# select columns of interest
raw.prodesAmazon <-
  raw.prodesAmazon %>%
  dplyr::select(muni_name = municipio,
                muni_code = cod_ibge,
                state_uf = estado,
                muni_area = area_km2,
                matches("\\d{4}$"))

# translate column names
raw.prodesAmazon <-
  raw.prodesAmazon %>%
  dplyr::rename_with(.fn = ~ str_replace(., pattern = "desmatado", replacement = "prodesAmazon_deforestAccumulated.")) %>%
  dplyr::rename_with(.fn = ~ str_replace(., pattern = "incremento", replacement = "prodesAmazon_deforestIncrement.")) %>%
  dplyr::rename_with(.fn = ~ str_replace(., pattern = "nao_floresta", replacement = "prodesAmazon_nonForest.")) %>%
  dplyr::rename_with(.fn = ~ str_replace(., pattern = "floresta", replacement = "prodesAmazon_forest.")) %>%
  dplyr::rename_with(.fn = ~ str_replace(., pattern = "nuvem", replacement = "prodesAmazon_cloud.")) %>%
  dplyr::rename_with(.fn = ~ str_replace(., pattern = "nao_observado", replacement = "prodesAmazon_nonObserved.")) %>%
  dplyr::rename_with(.fn = ~ str_replace(., pattern = "hidrografia", replacement = "prodesAmazon_hidrography."))

# check columns class
lapply(raw.prodesAmazon, class)


# RESHAPE TO PANEL FORMAT (MUNI-YEAR)
raw.prodesAmazon <-
  raw.prodesAmazon %>%
  tidyr::pivot_longer(cols = matches("\\d{4}$"), values_drop_na = TRUE) %>% # pivot all prodesAmazon_category.year columns to long format
  tidyr::separate(name, c("prodesAmazon_category", "year"), sep = "\\.") %>% # break "prodesAmazon_category.year" into two column: one with "prodesAmazon_category" and one with "year"
  tidyr::pivot_wider(names_from = prodesAmazon_category) %>% # pivot prodesAmazon_category to wide format
  dplyr::mutate(year = as.numeric(year)) %>%  # change year column class to numeric
  dplyr::arrange(muni_code, year) # order by muni-year


# CHARACTER TREATMENT

# clean latin characters
raw.prodesAmazon <-
  raw.prodesAmazon %>%
  dplyr::mutate(dplyr::across(tidyselect:::where(is.character),
                              \(x) iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT")))

# capitalize characters
raw.prodesAmazon <-
  raw.prodesAmazon %>%
  dplyr::mutate(muni_name = toupper(muni_name))





# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# LABELS
sjlabelled::set_label(raw.prodesAmazon$muni_code) <- "municipality code (7-digit, cross-section, INPE-2020)"
sjlabelled::set_label(raw.prodesAmazon$muni_name) <- "municipality name (character, cross-section, INPE-2020)"
sjlabelled::set_label(raw.prodesAmazon$state_uf)  <- "state name (2-characters, cross-section, INPE-2020)"
sjlabelled::set_label(raw.prodesAmazon$muni_area) <- "municipality area (square kilometers, cross-section, INPE-2020)"
sjlabelled::set_label(raw.prodesAmazon$year)      <- "PRODES year, starts in August/t-1 and ends in July/t with t = calendar year (4-digits, panel, INPE-2020)"
sjlabelled::set_label(raw.prodesAmazon$prodesAmazon_deforestAccumulated) <- "accumulated deforestation area (square kilometers, panel, INPE-2020)"
sjlabelled::set_label(raw.prodesAmazon$prodesAmazon_deforestIncrement)   <- "incremental deforestation area (square kilometers, panel, INPE-2020)"
sjlabelled::set_label(raw.prodesAmazon$prodesAmazon_forest)   <- "remaining primary forest area (square kilometers, panel, INPE-2020)"
sjlabelled::set_label(raw.prodesAmazon$prodesAmazon_cloud)               <- "area covered by clouds during remote sensing (square kilometers, panel, INPE-2020)"
sjlabelled::set_label(raw.prodesAmazon$prodesAmazon_nonObserved)         <- "area blocked from view during remote sensing (square kilometers, panel, INPE-2020)"
sjlabelled::set_label(raw.prodesAmazon$prodesAmazon_nonForest)           <- "area originally covered by non-tropical forest vegetation (square kilometers, cross-section, INPE-2020)"
sjlabelled::set_label(raw.prodesAmazon$prodesAmazon_hidrography)         <- "area covered by bodies of water (square kilometers, cross-section, INPE-2020)"


# POST-TREATMENT OVERVIEW
# summary(raw.prodesAmazon)
# str(raw.prodesAmazon)


# CODEBOOK GENERATION (VARIABLES DESCRIPTION + SUMMARY STATISTICS)

# create text file to be filled with console output
sink(here::here("data/raw2clean/prodesAmazon_inpe/documentation/codebook_prodesAmazon.txt"))

# describe all variables
raw.prodesAmazon %>%
  Hmisc::describe() %>%
  print()

# end printing console output to text file
sink()





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

saveRDS(raw.prodesAmazon,
        file = here::here("data/raw2clean/prodesAmazon_inpe/output", "clean_prodesAmazon.rds"))


# END TIMER
tictoc::toc(log = T)

# export time to csv table
ExportTimeProcessing("code/raw2clean")





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------