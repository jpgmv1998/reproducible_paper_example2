
# > PROJECT INFO
# NAME: PRIORITY MUNICIPALITIES AMAZON - EXAMPLE
# LEAD: JOAO VIEIRA
#
# > THIS SCRIPT
# AIM: MASTERFILE SCRIPT TO RUN ALL PROJECT-SPECIFIC SCRIPTS
# AUTHOR: JOAO VIEIRA
#
# > NOTES
# 1: -





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# RUN 'setup.R' TO CONFIGURE INITIAL SETUP (mostly installing/loading packages)
source("code/setup.R")


# START TIMER
tictoc::tic(msg = "masterfile_projectSpecific.R script", log = T)





# RUN ALL MUNI LEVEL SCRIPTS -------------------------------------------------------------------------------------------------------------------------

# CONSTRUCT AMAZON MUNICIPALITIES SAMPLE
source(here::here("code/projectSpecific/sampleConstruction_projectSpecific_muniLevel.R"), encoding = "UTF-8", echo = T)

# clear all objects from global environment
rm(list = ls())


# ADD AMAZON PRIORITY LIST DATA TO MUNI LEVEL PANEL SAMPLE
source(here::here("code/projectSpecific/panel_priorityList_projectSpecific_muniLevel.R"), encoding = "UTF-8", echo = T)

# clear all objects from global environment
rm(list = ls())


# ADD PRODES AMAZON LAND COVER/DEFORESTATION DATA TO MUNI LEVEL PANEL SAMPLE
source(here::here("code/projectSpecific/panel_prodesAmazon_projectSpecific_muniLevel.R"), encoding = "UTF-8", echo = T)

# clear all objects from global environment
rm(list = ls())



# CONSTRUCT FINAL PANEL SAMPLE FOR ANALYSIS AND ADAPT IT TO SPATIAL FORMAT
source(here::here("code/projectSpecific/sampleForAnalysis_projectSpecific_muniLevel.R"), encoding = "UTF-8", echo = T)

# clear all objects from global environment
rm(list = ls())





# EXPORT TIME PROCESSING -----------------------------------------------------------------------------------------------------------------------------

# END TIMER
tictoc::toc(log = T)


# SOURCE EXPORT TIME PROCESSING AGAIN BECAUSE OF rm(list = ls()
source(here::here("code/_functions/ExportTimeProcessing.R"))

# export time to csv table
ExportTimeProcessing("code/projectSpecific")





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------