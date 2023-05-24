
# > PROJECT INFO
# NAME: PRIORITY MUNICIPALITIES AMAZON - EXAMPLE
# LEAD: JOAO VIEIRA
#
# > THIS SCRIPT
# AIM: CONSTRUCT FINAL PANEL SAMPLE FOR ANALYSIS AND ADAPT IT TO SPATIAL FORMAT
# AUTHOR: JOAO VIEIRA
#
# > NOTES
# 1: -





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# RUN 'setup.R' TO CONFIGURE INITIAL SETUP (mostly installing/loading packages)
source("code/setup.R")


# START TIMER
tictoc::tic(msg = "sampleForAnalysis_projectSpecific_muniLevel.R script", log = T)





# DATA INPUT -----------------------------------------------------------------------------------------------------------------------------------------

# PANEL SAMPLE
panel.sample.muniLevel <- readRDS(file = here::here("data/projectSpecific/muniLevel/panel_sample_muniLevel.rds"))


# SPATIAL SAMPLE
spatial.sample.muniLevel <- readRDS(file = here::here("data/projectSpecific/muniLevel/spatial_sample_muniLevel.rds"))


# PANEL PRIORITY LIST
panel.priorityList.muniLevel <- readRDS(file = here::here("data/projectSpecific/muniLevel/panel_priorityList_muniLevel.rds"))


# PANEL PRODES AMAZON
panel.prodesAmazon.muniLevel <- readRDS(file = here::here("data/projectSpecific/muniLevel/panel_prodesAmazon_muniLevel.rds"))





# DATA MANPULATION -----------------------------------------------------------------------------------------------------------------------------------

# MERGE SAMPLE WITH ADDITIONAL VARIABLES
panel.sampleForAnalysis.muniLevel <-
  panel.sample.muniLevel %>%
  dplyr::left_join(panel.priorityList.muniLevel, by = c("muni_code", "year")) %>%
  dplyr::left_join(panel.prodesAmazon.muniLevel, by = c("muni_code", "year"))

# remove objects from global environment
rm(panel.sample.muniLevel, panel.priorityList.muniLevel, panel.prodesAmazon.muniLevel)


# FINAL SAMPLE SELECTION
# drop municipalities with no PRODES data
panel.sampleForAnalysis.muniLevel <-
  panel.sampleForAnalysis.muniLevel %>%
  dplyr::filter(!is.na(prodesAmazon_deforestAccumulated))





# EXPORT PREP ----------------------------------------------------------------------------------------------------------------------------------------

# LABELS
# check existing labels
sjlabelled::get_label(panel.sampleForAnalysis.muniLevel)

# add labels when missing
sjlabelled::set_label(panel.sampleForAnalysis.muniLevel$year) <- "year of reference, calendar from Jan/t to Dec/t or PRODES from Aug/t-1 to Jul/t (4-digits, panel)"


# POST-TREATMENT OVERVIEW
# summary(panel.sampleForAnalysis.muniLevel)


# OTHER EXPORT FORMATS

# add spatial dimension
spatial.sampleForAnalysis.muniLevel <-
  panel.sampleForAnalysis.muniLevel %>%
  dplyr::left_join(spatial.sample.muniLevel) %>%
  sf::st_as_sf()





# EXPORT ---------------------------------------------------------------------------------------------------------------------------------------------

saveRDS(panel.sampleForAnalysis.muniLevel,
        file = here::here("data/projectSpecific/muniLevel", "panel_sampleForAnalysis_muniLevel.rds"))

saveRDS(spatial.sampleForAnalysis.muniLevel,
        file = here::here("data/projectSpecific/muniLevel", "spatial_sampleForAnalysis_muniLevel.rds"))


# END TIMER
tictoc::toc(log = T)

# export time to csv table
ExportTimeProcessing("code/projectSpecific")





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------