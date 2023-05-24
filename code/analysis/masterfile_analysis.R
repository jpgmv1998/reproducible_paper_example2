
# > PROJECT INFO
# NAME: AMAZON PRIORITY MUNICIPALITIES - EXAMPLE
# LEAD: JOÃO VIEIRA
#
# > THIS SCRIPT
# AIM: MASTERFILE SCRIPT TO RUN ALL ANALYSIS SCRIPTS
# AUTHOR: JOÃO VIEIRA
#
# > NOTES
# 1: -





# SETUP ----------------------------------------------------------------------------------------------------------------------------------------------

# RUN 'setup.R' TO CONFIGURE INITIAL SETUP (mostly installing/loading packages)
source("code/setup.R")


# START TIMER
tictoc::tic(msg = "masterfile_analysis.R script", log = T)




# RUN ALL REGRESSIONS --------------------------------------------------------------------------------------------------------------------------------

# RUN REGRESSION NAME
source(here::here("code/analysis/regression_did_analysis.R"), encoding = "UTF-8", echo = T)

# clear all objects from global environment
rm(list = ls())





# RUN PAPER MAIN RESULTS ------------------------------------------------------------------------------------------------------------------------------

# GENERATE SUPPORTING STATS CITED IN-TEXT
source(here::here("code/analysis/supportingStats_analysis.R"), encoding = "UTF-8", echo = T)

# clear all objects from global environment
rm(list = ls())


# GENERATE FIGURE 1: BALANCED EVENT-STUDY
source(here::here("code/analysis/fig1_eventStudyBalanced_analysis.R"), encoding = "UTF-8", echo = T)

# clear all objects from global environment
rm(list = ls())


# GENERATE TABLE 1: SUMMARY STATISTCS BY TREATMENT COHORT
source(here::here("code/analysis/tab1_summaryStat_analysis.R"), encoding = "UTF-8", echo = T)

# clear all objects from global environment
rm(list = ls())





# RUN PAPER APPENDIX RESULTS ---------------------------------------------------------------------------------------------------------------------------

# GENERATE FIGURE A1: UNBALANCED EVENT-STUDY
source(here::here("code/analysis/figA1_eventStudyUnbalanced_analysis.R"), encoding = "UTF-8", echo = T)

# clear all objects from global environment
rm(list = ls())





# EXPORT TIME PROCESSING -----------------------------------------------------------------------------------------------------------------------------

# END TIMER
tictoc::toc(log = T)


# SOURCE EXPORT TIME PROCESSING AGAIN BECAUSE OF rm(list = ls()
source(here::here("code/_functions/ExportTimeProcessing.R"))

# export time to csv table
ExportTimeProcessing("code/analysis")





# END OF SCRIPT --------------------------------------------------------------------------------------------------------------------------------------