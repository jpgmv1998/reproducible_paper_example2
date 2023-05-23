
# > PROJECT INFO
# NAME: AMAZON PRIORITY MUNICIPALITIES - EXAMPLE
# LEAD: JOÃO VIEIRA
#
# > THIS SCRIPT
# AIM: MASTERFILE SCRIPT TO RUN ALL RAW2CLEAN SCRIPTS - EXAMPLE
# AUTHOR: JOÃO VIEIRA
#
# > NOTES
# 1: -





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# RUN 'setup.R' TO CONFIGURE INITIAL SETUP (mostly installing/loading packages)
source("code/setup.R")


# START TIMER
tictoc::tic(msg = "masterfile_raw2clean.R script", log = T)





# RUN RAW2CLEAN SCRIPTS ------------------------------------------------------------------------------------------------------------------------------

# CLEAN RAW DATA SHAPEFILE OF BIOME DIVISION (IBGE-2019)
source(file = here::here("code/raw2clean/biomeDivision_raw2clean.R"), encoding = "UTF-8", echo = T)

# clear all objects from global environment
rm(list = ls())


# CLEAN RAW DATA SHAPEFILE OF MUNI DIVISION (IBGE-2015)
source(file = here::here("code/raw2clean/muniDivision_raw2clean.R"), encoding = "UTF-8", echo = T)

# clear all objects from global environment
rm(list = ls())


# EXTRACT AMAZON PRIORITY MUNI DATA FROM PDF AND CLEAN IT (MMA-2017)
source(file = here::here("code/raw2clean/priorityList_raw2clean.R"), encoding = "UTF-8", echo = T)

# clear all objects from global environment
rm(list = ls())


# CLEAN RAW PRODES LAND COVER DATA FROM THE BRAZILIAN AMAZON AT THE MUNICIPALITY LEVEL (INPE-2020)
source(file = here::here("code/raw2clean/prodesAmazon_raw2clean.R"), encoding = "UTF-8", echo = T)

# clear all objects from global environment
rm(list = ls())





# EXPORT TIME PROCESSING -----------------------------------------------------------------------------------------------------------------------------

# END TIMER
tictoc::toc(log = T)


# SOURCE EXPORT TIME PROCESSING AGAIN BECAUSE OF rm(list = ls()
source(here::here("code/_functions/ExportTimeProcessing.R"))

# export time to csv table
ExportTimeProcessing("code/raw2clean")





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------